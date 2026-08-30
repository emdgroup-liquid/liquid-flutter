import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/usage/usage_compute.dart';
import 'package:liquid_flutter_ai/src/usage/usage_models.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modal showing conversation token usage, cost, and optional context window.
class LdUsageCostModal extends StatelessWidget {
  final LdUsageTotals totals;
  final LdContextUsage? contextUsage;
  final String? pricingDisclaimer;

  const LdUsageCostModal({
    super.key,
    required this.totals,
    this.contextUsage,
    this.pricingDisclaimer,
  });

  @override
  Widget build(BuildContext context) {
    final disclaimer =
        pricingDisclaimer ??
        'Cost is estimated from list prices and may differ from your bill.';

    return LdScaffold(
      body: LdAppBar(
        title: const Text('Usage & cost'),
        child: LdScaffoldBody(
          addContainer: true,
          children: [
            LdAutoSpace(
              children: [
                if (contextUsage != null)
                  _ContextWindowCard(usage: contextUsage!),
                _SummaryCard(totals: totals),
                if (totals.chartKinds.isNotEmpty) ...[
                  LdText.caption('TOKEN MIX'),
                  _TokenMixCard(totals: totals),
                ],

                if (totals.byTool.isNotEmpty) ...[
                  LdText.caption('BY TOOL'),
                  LdCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < totals.byTool.length; i++) ...[
                          if (i > 0) const LdDivider(),
                          _ToolUsageRow(
                            usage: totals.byTool[i],
                            parentTotal: totals.totalTokens,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (totals.byModel.isNotEmpty) ...[
                  LdText.caption('BY MODEL'),
                  LdCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < totals.byModel.length; i++) ...[
                          if (i > 0) const LdDivider(),
                          _ModelUsageRow(usage: totals.byModel[i]),
                        ],
                      ],
                    ),
                  ),
                ],
                if (!totals.hasUsage)
                  LdHint(
                    type: LdHintType.info,
                    child: LdText.p(
                      'No token usage recorded yet. Usage appears after assistant replies complete.',
                    ),
                  )
                else if (!totals.hasPricing)
                  LdHint(
                    type: LdHintType.info,
                    child: LdText.p(
                      'Model pricing is unavailable. Token counts are still accurate.',
                    ),
                  )
                else
                  LdHint(type: LdHintType.info, child: LdText.p(disclaimer)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextWindowCard extends StatelessWidget {
  final LdContextUsage usage;

  const _ContextWindowCard({required this.usage});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final lastPrompt = usage.lastPromptTokens;

    return LdCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          LdHorizontalScroll(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow(
                label: 'Estimated context',
                value: usage.estimatedTokens.toDouble(),
                icon: LucideIcons.gauge,
              ),
              if (lastPrompt != null)
                _StatRow(
                  label: 'Last request (prompt)',
                  value: lastPrompt.toDouble(),
                  icon: LucideIcons.history,
                ),
              if (usage.excludedPieceCount > 0)
                _StatRow(
                  label: 'Excluded pieces',
                  value: usage.excludedPieceCount.toDouble(),
                  icon: LucideIcons.eyeOff,
                ),
            ],
          ),
          if (usage.hasCompaction)
            LdListItem(
              leading: LdAvatar(child: Icon(LucideIcons.layers)),
              title: const Text('Context compacted'),
              subtitle: Text(
                'Older messages were summarized to fit the context window.',
                style: TextStyle(color: theme.textMuted),
              ),
              trailing: const SizedBox.shrink(),
            ),
          if (usage.hasLimit)
            Padding(
              padding: theme.pad(size: LdSize.s),
              child: ClipRRect(
                borderRadius: theme.radius(LdSize.s),
                child: LinearProgressIndicator(
                  value: usage.usageRatio,
                  minHeight: 6,
                  backgroundColor: theme.neutralShade(2),
                  color: usage.isNearLimit
                      ? theme.warningColor
                      : theme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final LdUsageTotals totals;

  const _SummaryCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      padding: EdgeInsets.zero,
      child: LdHorizontalScroll(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _StatRow(
            label: 'Prompt tokens',
            value: totals.promptTokens.toDouble(),
            icon: LucideIcons.arrowDownToLine,
          ),
          _StatRow(
            label: 'Completion tokens',
            value: totals.completionTokens.toDouble(),
            icon: LucideIcons.arrowUpFromLine,
          ),
          _StatRow(
            label: 'Total tokens',
            value: totals.totalTokens.toDouble(),
            icon: LucideIcons.sigma,
          ),
          _StatRow(
            label: 'Assistant turns',
            value: totals.billedTurnCount.toDouble(),
            icon: LucideIcons.messagesSquare,
          ),
          _StatRow(
            label: 'Estimated cost',
            value: totals.estimatedCostUsd?.toDouble() ?? 0,
            icon: LucideIcons.circleDollarSign,
            precision: 2,
          ),
        ],
      ),
    );
  }
}

class _TokenMixCard extends StatelessWidget {
  final LdUsageTotals totals;

  const _TokenMixCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final segments = totals.chartKinds;
    final total = totals.totalTokens;

    return LdCard(
      child: LdAutoSpace(
        children: [
          _UsageFractionBar(
            segments: [
              for (final usage in segments)
                _FractionSegment(
                  fraction: usage.fractionOf(total),
                  color: ldUsageKindColor(theme, usage.kind),
                ),
            ],
          ),
          Wrap(
            spacing: theme.paddingSize(size: LdSize.m),
            runSpacing: theme.paddingSize(size: LdSize.s),
            children: [
              for (final usage in segments)
                _MixLegendItem(
                  label: ldUsageKindLabel(usage.kind),
                  color: ldUsageKindColor(theme, usage.kind),
                  detail:
                      '${ldFormatPercent(usage.fractionOf(total))} · ${ldFormatTokenCount(usage.totalTokens)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageFractionBar extends StatelessWidget {
  final List<_FractionSegment> segments;

  const _UsageFractionBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final radius = theme.radius(LdSize.s);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (final segment in segments)
              if (segment.fraction > 0)
                Expanded(
                  flex: (segment.fraction * 1000).round().clamp(1, 1000),
                  child: SizedBox(
                    height: 10,
                    child: ColoredBox(color: segment.color),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _FractionSegment {
  const _FractionSegment({required this.fraction, required this.color});

  final double fraction;
  final Color color;
}

class _MixLegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final String detail;

  const _MixLegendItem({
    required this.label,
    required this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: theme.radius(LdSize.xs),
          ),
        ),
        ldHSpacerXS,
        LdText.lxs('$label · $detail'),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final int? precision;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    this.precision,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LdAvatar(child: Icon(icon)),

        LdAutoSpace(
          children: [
            LdMute(
              child: LdCounter(
                value: value,
                precision: precision ?? 0,
                style: ldBuildTextStyle(
                  LdTheme.of(context),
                  LdTextType.headline,
                  LdSize.m,
                ),
              ),
            ),
            ldSpacerXS,
            LdText.l(label),
          ],
        ),
      ],
    ).spaceS().padM();
  }
}

class _ModelUsageRow extends StatelessWidget {
  final LdUsageByModel usage;

  const _ModelUsageRow({required this.usage});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final subtitleParts = <String>[
      '${ldFormatTokenCount(usage.promptTokens)} in',
      '${ldFormatTokenCount(usage.completionTokens)} out',
      '${ldFormatTokenCount(usage.totalTokens)} total',
    ];
    if (usage.estimatedCostUsd != null) {
      subtitleParts.add(ldFormatUsd(usage.estimatedCostUsd));
    }

    return LdListItem(
      title: Text(usage.displayName),
      subtitle: Text(
        subtitleParts.join(' · '),
        style: TextStyle(color: theme.textMuted),
      ),
      trailing: LdText.l(
        '${usage.turnCount} ${usage.turnCount == 1 ? 'turn' : 'turns'}',
        color: theme.textMuted,
      ),
    );
  }
}

class _ToolUsageRow extends StatelessWidget {
  final LdUsageByTool usage;
  final int parentTotal;

  const _ToolUsageRow({required this.usage, required this.parentTotal});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    // Tool tokens are prompt-attributed; apps may map results → completion for
    // "out". Prefer args/result labels over model-style in/out.
    final subtitleParts = <String>[
      if (usage.completionTokens > 0) ...[
        if (usage.promptTokens > 0)
          '${ldFormatTokenCount(usage.promptTokens)} args',
        '${ldFormatTokenCount(usage.completionTokens)} result',
        '${ldFormatTokenCount(usage.totalTokens)} total',
      ] else
        '${ldFormatTokenCount(usage.totalTokens)} tokens',
    ];
    if (usage.estimatedCostUsd != null) {
      subtitleParts.add(ldFormatUsd(usage.estimatedCostUsd));
    }

    return LdListItem(
      leading: LdAvatar(child: Icon(LucideIcons.wrench)),
      title: Text(usage.toolName),
      subtitle: Text(
        subtitleParts.join(' · '),
        style: TextStyle(color: theme.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LdText.l(
            ldFormatPercent(usage.fractionOf(parentTotal)),
            color: theme.textMuted,
          ),
          LdText.lxs(
            '${usage.callCount} ${usage.callCount == 1 ? 'call' : 'calls'}',
            color: theme.textMuted,
          ),
        ],
      ),
    );
  }
}

/// Theme colors for usage kinds in charts and legends.
Color ldUsageKindColor(LdTheme theme, LdUsageKind kind) {
  return switch (kind) {
    LdUsageKind.system => theme.neutralShade(5),
    LdUsageKind.user => theme.errorColor,
    LdUsageKind.tools => theme.warningColor,
    LdUsageKind.agent => theme.primaryColor,
    LdUsageKind.reasoning => theme.successColor,
  };
}
