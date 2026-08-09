import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/usage/usage_models.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact context-window gauge for compose chrome.
///
/// Accepts precomputed [contextUsage]; the host owns model fetch / estimation.
class LdContextUsageIndicator extends StatelessWidget {
  final LdContextUsage contextUsage;
  final VoidCallback? onTap;
  final LdSize size;

  const LdContextUsageIndicator({
    super.key,
    required this.contextUsage,
    this.size = LdSize.l,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final usage = contextUsage;
    if (!usage.hasLimit && usage.estimatedTokens == 0) {
      return const SizedBox.shrink();
    }

    final theme = LdTheme.of(context);
    final progressColor = switch (usage.usageRatio) {
      >= 0.9 => theme.errorColor,
      >= 0.75 => theme.warningColor,
      _ => theme.primaryColor,
    };

    return LdButton.outline(
      circular: true,
      size: size,
      disabled: onTap == null,
      onPressed: () async {
        onTap?.call();
      },
      child: usage.hasLimit
          ? Builder(
              builder: (context) {
                final iconSize = IconTheme.of(context).size ?? 14;
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    value: usage.usageRatio,
                    color: progressColor,
                    strokeWidth: iconSize * 0.15,
                    backgroundColor: theme.neutralShade(3),
                  ),
                );
              },
            )
          : Icon(LucideIcons.gauge, size: 14, color: progressColor),
    );
  }
}
