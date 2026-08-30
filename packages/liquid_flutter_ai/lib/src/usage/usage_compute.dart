import 'package:liquid_flutter_ai/src/usage/usage_models.dart';

/// Aggregates [records] into totals with by-model, by-kind, and by-tool breakdowns.
LdUsageTotals ldComputeUsage({
  required Iterable<LdTokenUsageRecord> records,
  Map<String, LdModelPricing> pricingByModelId = const {},
}) {
  final byModel = <String, _MutableUsage>{};
  final byKind = <LdUsageKind, _MutableUsage>{};
  final byTool = <String, _MutableUsage>{};

  for (final record in records) {
    if (record.isEmpty) {
      continue;
    }

    final prompt = record.promptTokens;
    final completion = record.completionTokens;
    final total = record.totalTokens > 0
        ? record.totalTokens
        : prompt + completion;

    final normalized = ldNormalizeModelId(record.modelId);
    final pricing = pricingByModelId[normalized];
    final modelId = pricing?.modelId ?? normalized;
    final bucketKey = modelId.isEmpty ? '(unknown model)' : modelId;
    final bucket = byModel.putIfAbsent(
      bucketKey,
      () => _MutableUsage(modelId: modelId),
    );
    bucket.promptTokens += prompt;
    bucket.completionTokens += completion;
    bucket.totalTokens += total;
    bucket.turnCount += 1;

    final kind = record.kind;
    // Tool mix shares are carved from prompt budget even when apps map tool
    // results to completionTokens for by-tool "out" display — price as prompt.
    final costPrompt = kind == LdUsageKind.tools ? prompt + completion : prompt;
    final costCompletion = kind == LdUsageKind.tools ? 0 : completion;
    final tokenCost = pricing != null && pricing.hasTokenRates
        ? pricing.estimateTokenCost(
            promptTokens: costPrompt,
            completionTokens: costCompletion,
          )
        : null;
    if (tokenCost != null) {
      bucket.tokenCostUsd = (bucket.tokenCostUsd ?? 0) + tokenCost;
    }

    if (kind != null) {
      final kindBucket = byKind.putIfAbsent(
        kind,
        () => _MutableUsage(modelId: ''),
      );
      kindBucket.promptTokens += prompt;
      kindBucket.completionTokens += completion;
      kindBucket.totalTokens += total;
      kindBucket.turnCount += 1;
      if (tokenCost != null) {
        kindBucket.tokenCostUsd = (kindBucket.tokenCostUsd ?? 0) + tokenCost;
      }
    }

    final toolName = record.toolName?.trim();
    if (toolName != null && toolName.isNotEmpty) {
      final toolBucket = byTool.putIfAbsent(
        toolName,
        () => _MutableUsage(modelId: ''),
      );
      toolBucket.promptTokens += prompt;
      toolBucket.completionTokens += completion;
      toolBucket.totalTokens += total;
      toolBucket.turnCount += 1;
      if (tokenCost != null) {
        toolBucket.tokenCostUsd = (toolBucket.tokenCostUsd ?? 0) + tokenCost;
      }
    }
  }

  var promptSum = 0;
  var completionSum = 0;
  var totalSum = 0;
  var turnSum = 0;
  double? costSum;
  final modelBreakdown = <LdUsageByModel>[];

  for (final entry in byModel.entries) {
    final modelKey = entry.key;
    final usage = entry.value;
    final pricing = pricingByModelId[usage.modelId];
    final displayName =
        pricing?.displayName ??
        (modelKey == '(unknown model)' ? modelKey : modelKey);

    final tokenCost = usage.tokenCostUsd;
    final requestCost = pricing != null && pricing.requestPrice > 0
        ? pricing.requestPrice * usage.turnCount
        : 0.0;
    final turnCost = tokenCost != null || requestCost > 0
        ? (tokenCost ?? 0) + requestCost
        : null;
    final hasPricing = pricing != null && pricing.hasRates;

    promptSum += usage.promptTokens;
    completionSum += usage.completionTokens;
    totalSum += usage.totalTokens;
    turnSum += usage.turnCount;

    if (turnCost != null && hasPricing) {
      costSum = (costSum ?? 0) + turnCost;
    }

    modelBreakdown.add(
      LdUsageByModel(
        modelId: usage.modelId.isEmpty ? modelKey : usage.modelId,
        displayName: displayName,
        promptTokens: usage.promptTokens,
        completionTokens: usage.completionTokens,
        totalTokens: usage.totalTokens,
        turnCount: usage.turnCount,
        estimatedCostUsd: turnCost != null && hasPricing ? turnCost : null,
      ),
    );
  }

  modelBreakdown.sort((a, b) => b.totalTokens.compareTo(a.totalTokens));

  final kindBreakdown = <LdUsageByKind>[];
  for (final kind in LdUsageKind.values) {
    final usage = byKind[kind];
    if (usage == null) {
      continue;
    }
    kindBreakdown.add(
      LdUsageByKind(
        kind: kind,
        promptTokens: usage.promptTokens,
        completionTokens: usage.completionTokens,
        totalTokens: usage.totalTokens,
        estimatedCostUsd: usage.tokenCostUsd,
      ),
    );
  }

  final toolBreakdown = byTool.entries
      .map(
        (entry) => LdUsageByTool(
          toolName: entry.key,
          promptTokens: entry.value.promptTokens,
          completionTokens: entry.value.completionTokens,
          totalTokens: entry.value.totalTokens,
          callCount: entry.value.turnCount,
          estimatedCostUsd: entry.value.tokenCostUsd,
        ),
      )
      .toList()
    ..sort((a, b) => b.totalTokens.compareTo(a.totalTokens));

  return LdUsageTotals(
    promptTokens: promptSum,
    completionTokens: completionSum,
    totalTokens: totalSum,
    billedTurnCount: turnSum,
    estimatedCostUsd: costSum,
    byModel: modelBreakdown,
    byKind: kindBreakdown,
    byTool: toolBreakdown,
  );
}

/// Builds a pricing lookup keyed by normalized model id and short name.
Map<String, LdModelPricing> ldModelPricingLookup(
  Iterable<LdModelPricing> models,
) {
  final lookup = <String, LdModelPricing>{};
  for (final pricing in models) {
    final id = ldNormalizeModelId(pricing.modelId);
    lookup[id] = pricing;
    final slash = id.lastIndexOf('/');
    if (slash >= 0 && slash < id.length - 1) {
      lookup.putIfAbsent(id.substring(slash + 1), () => pricing);
    }
  }
  return lookup;
}

String ldNormalizeModelId(String modelName) {
  final trimmed = modelName.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  if (trimmed.contains(':')) {
    final parts = trimmed.split(':');
    if (parts.first.toLowerCase() == 'openrouter' && parts.length > 1) {
      return parts.sublist(1).join(':');
    }
    return parts.last;
  }
  return trimmed;
}

String ldFormatTokenCount(int count) {
  final text = count.toString();
  return text.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}

String ldFormatUsd(double? amount) {
  if (amount == null) {
    return '—';
  }
  if (amount == 0) {
    return r'$0.00';
  }
  if (amount < 0.01) {
    return '\$${amount.toStringAsFixed(4)}';
  }
  return '\$${amount.toStringAsFixed(2)}';
}

String ldFormatPercent(double fraction) {
  final pct = (fraction * 100).clamp(0, 100);
  if (pct > 0 && pct < 1) {
    return '<1%';
  }
  return '${pct.round()}%';
}

String ldUsageKindLabel(LdUsageKind kind) {
  return switch (kind) {
    LdUsageKind.system => 'System',
    LdUsageKind.user => 'User',
    LdUsageKind.tools => 'Tools',
    LdUsageKind.agent => 'Agent',
    LdUsageKind.reasoning => 'Reasoning',
  };
}

class _MutableUsage {
  final String modelId;
  int promptTokens = 0;
  int completionTokens = 0;
  int totalTokens = 0;
  int turnCount = 0;
  double? tokenCostUsd;

  _MutableUsage({required this.modelId});
}
