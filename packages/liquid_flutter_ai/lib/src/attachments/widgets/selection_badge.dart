import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A circular selection indicator overlaid on media tiles.
///
/// In single-select mode it shows a check when selected. In multi-select mode
/// it shows the 1-based selection order, matching the Telegram picker.
class LdAttachmentSelectionBadge extends StatelessWidget {
  const LdAttachmentSelectionBadge({
    super.key,
    required this.selected,
    this.index,
    this.size = 24,
  });

  final bool selected;

  /// 1-based selection order. When null, a check icon is shown instead.
  final int? index;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    final background = selected
        ? theme.primaryColor
        : theme.surface.withValues(alpha: 0.72);
    final border = selected
        ? Colors.transparent
        : theme.surface.withValues(alpha: 0.9);
    final foreground = selected
        ? theme.primaryColorText
        : theme.text.withValues(alpha: 0.85);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: selected
          ? (index == null
                ? Icon(LucideIcons.check, size: size * 0.6, color: foreground)
                : Text(
                    '$index',
                    style: TextStyle(
                      color: foreground,
                      fontSize: size * 0.52,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ))
          : null,
    );
  }
}
