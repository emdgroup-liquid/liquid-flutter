import 'package:liquid_flutter_ai/src/usage/usage_compute.dart';
import 'package:liquid_flutter_ai/src/usage/usage_models.dart';

/// Approximate chars per token for heuristic estimation.
const ldContextCharsPerToken = 4;

const ldContextSafetyCushionTokens = 40000;

int ldEstimateTextTokens(String text) {
  if (text.isEmpty) {
    return 0;
  }
  return (text.length / ldContextCharsPerToken).ceil() + 4;
}

int ldEstimateContextTokens({
  required Iterable<LdContextTokenSource> sources,
  String? draftText,
}) {
  var total = 0;
  for (final source in sources) {
    if (source.excludedFromContext) {
      continue;
    }
    total += ldEstimateTextTokens(source.text);
  }
  if (draftText != null && draftText.isNotEmpty) {
    total += ldEstimateTextTokens(draftText);
  }
  return total;
}

LdContextUsage ldComputeContextUsage({
  required Iterable<LdContextTokenSource> sources,
  int contextLimit = 0,
  String? draftText,
  int? lastPromptTokens,
  bool hasCompaction = false,
}) {
  final excluded = sources.where((s) => s.excludedFromContext).length;
  return LdContextUsage(
    estimatedTokens: ldEstimateContextTokens(
      sources: sources,
      draftText: draftText,
    ),
    contextLimit: contextLimit,
    lastPromptTokens: lastPromptTokens,
    excludedPieceCount: excluded,
    hasCompaction: hasCompaction,
  );
}

String ldFormatContextUsageLabel(LdContextUsage usage) {
  if (!usage.hasLimit) {
    return '~${ldFormatTokenCount(usage.estimatedTokens)}';
  }
  return '~${ldFormatTokenCount(usage.estimatedTokens)} / ${ldFormatContextLimit(usage.contextLimit)}';
}

String ldFormatContextLimit(int limit) {
  if (limit >= 1000) {
    final k = limit / 1000;
    if (k == k.roundToDouble()) {
      return '${k.toInt()}k';
    }
    return '${k.toStringAsFixed(1)}k';
  }
  return ldFormatTokenCount(limit);
}
