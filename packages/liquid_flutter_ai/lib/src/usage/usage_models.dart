/// Optional attribution for a usage sample.
enum LdUsageKind {
  system,
  user,
  tools,
  agent,
  reasoning,
}

/// Kinds shown in the combined usage fraction chart.
const ldUsageChartKinds = <LdUsageKind>[
  LdUsageKind.user,
  LdUsageKind.tools,
  LdUsageKind.agent,
  LdUsageKind.reasoning,
];

/// One usage sample. Apps map from provider/API data.
class LdTokenUsageRecord {
  const LdTokenUsageRecord({
    required this.modelId,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
    this.kind,
    this.toolName,
  });

  final String modelId;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final LdUsageKind? kind;

  /// When [kind] is [LdUsageKind.tools], the tool that produced these tokens.
  final String? toolName;

  bool get isEmpty =>
      promptTokens == 0 && completionTokens == 0 && totalTokens == 0;
}

/// Per-model pricing used for cost estimates.
class LdModelPricing {
  const LdModelPricing({
    required this.modelId,
    required this.displayName,
    this.promptPricePerToken = 0,
    this.completionPricePerToken = 0,
    this.requestPrice = 0,
  });

  final String modelId;
  final String displayName;
  final double promptPricePerToken;
  final double completionPricePerToken;
  final double requestPrice;

  bool get hasRates =>
      promptPricePerToken > 0 ||
      completionPricePerToken > 0 ||
      requestPrice > 0;

  bool get hasTokenRates =>
      promptPricePerToken > 0 || completionPricePerToken > 0;

  /// Token-only cost (excludes per-request fees).
  double estimateTokenCost({
    required int promptTokens,
    required int completionTokens,
  }) {
    return promptTokens * promptPricePerToken +
        completionTokens * completionPricePerToken;
  }

  double estimateCost({
    required int promptTokens,
    required int completionTokens,
    required int assistantTurnCount,
  }) {
    return estimateTokenCost(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
        ) +
        requestPrice * assistantTurnCount;
  }
}

class LdUsageByModel {
  const LdUsageByModel({
    required this.modelId,
    required this.displayName,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.turnCount,
    this.estimatedCostUsd,
  });

  final String modelId;
  final String displayName;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int turnCount;
  final double? estimatedCostUsd;
}

class LdUsageByKind {
  const LdUsageByKind({
    required this.kind,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.estimatedCostUsd,
  });

  final LdUsageKind kind;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final double? estimatedCostUsd;

  /// Share of [totalTokens] relative to a parent total (0–1).
  double fractionOf(int parentTotal) =>
      parentTotal > 0 ? totalTokens / parentTotal : 0;
}

class LdUsageByTool {
  const LdUsageByTool({
    required this.toolName,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.callCount,
    this.estimatedCostUsd,
  });

  final String toolName;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int callCount;
  final double? estimatedCostUsd;

  double fractionOf(int parentTotal) =>
      parentTotal > 0 ? totalTokens / parentTotal : 0;
}

class LdUsageTotals {
  const LdUsageTotals({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.billedTurnCount,
    required this.byModel,
    this.byKind = const [],
    this.byTool = const [],
    this.estimatedCostUsd,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int billedTurnCount;
  final double? estimatedCostUsd;
  final List<LdUsageByModel> byModel;
  final List<LdUsageByKind> byKind;

  /// Per-tool totals, sorted by [LdUsageByTool.totalTokens] descending.
  final List<LdUsageByTool> byTool;

  bool get hasUsage => totalTokens > 0;
  bool get hasPricing => estimatedCostUsd != null;

  /// Chart kinds that have usage, in display order.
  List<LdUsageByKind> get chartKinds {
    final byKindMap = {for (final k in byKind) k.kind: k};
    return [
      for (final kind in ldUsageChartKinds)
        if (byKindMap[kind] != null) byKindMap[kind]!,
    ];
  }
}

/// Heuristic context-window estimate input (app maps conversation pieces).
class LdContextTokenSource {
  const LdContextTokenSource({
    required this.text,
    this.excludedFromContext = false,
    this.kind,
  });

  final String text;
  final bool excludedFromContext;
  final LdUsageKind? kind;
}

class LdContextUsage {
  const LdContextUsage({
    required this.estimatedTokens,
    required this.contextLimit,
    this.lastPromptTokens,
    this.excludedPieceCount = 0,
    this.hasCompaction = false,
  });

  final int estimatedTokens;
  final int contextLimit;
  final int? lastPromptTokens;
  final int excludedPieceCount;
  final bool hasCompaction;

  bool get hasLimit => contextLimit > 0;

  double get usageRatio =>
      hasLimit ? (estimatedTokens / contextLimit).clamp(0.0, 1.0) : 0;

  bool get isNearLimit => hasLimit && usageRatio >= 0.75;

  bool get isOverBudget => hasLimit && estimatedTokens > contextLimit;
}
