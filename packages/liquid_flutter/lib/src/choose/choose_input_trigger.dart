import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/intersperse.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdChooseInputTrigger<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdChooseInputTrigger({
    required this.config,
    this.separator,
    super.key,
  });

  final LdChooseTriggerConfig<T, IdType> config;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    final selectedIds = config.selectedIds;
    final selectedItems = config.selectedItems;

    final onTap = config.onTap;
    final truncateDisplay = config.truncateDisplay;
    final label = config.label;
    final disabled = config.disabled;
    var theme = LdTheme.of(context, listen: true);
    final scope = LdControlGroupScope.of(context);
    final size = scope?.size ?? config.size;
    final selectedItemsCount = selectedIds.length;

    int displayItems = selectedItems.length;
    int left = 0;

    displayItems = min(displayItems, truncateDisplay);
    left = selectedItemsCount - displayItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty && scope == null)
          LdText.l(
            label,
            size: size,
          ),
        ldGroupLabelTooltip(
          context: context,
          label: label,
          child: LdTouchableSurface(
            disabled: disabled,
            key: const Key("ldChoose_trigger"),
            onPressed: onTap,
            builder: (contxt, status, child) {
              final colorBundle = inputColor(theme, status, isValid: true);
              return LdFieldFrame(
                colors: colorBundle,
                size: size,
                child: child!,
              );
            },
            child: Row(
              children: [
                DefaultTextStyle(
                  style: ldBuildTextStyle(
                    theme,
                    LdTextType.label,
                    size,
                  ),
                  child: Expanded(
                    child: Opacity(
                      opacity: disabled ? 0.5 : 1,
                      child: _selection(
                          context, theme, size, selectedItems, displayItems, left, selectedItemsCount, scope),
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: theme.labelSize(size),
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    ).spaceS();
  }

  /// The selectable content of the trigger.
  ///
  /// Standalone it may wrap onto several lines; inside an [LdInputGroup] it is
  /// constrained to a single line so it joins the other members at
  /// [LdTheme.controlHeight].
  Widget _selection(
    BuildContext context,
    LdTheme theme,
    LdSize size,
    List<T> selectedItems,
    int displayItems,
    int left,
    int selectedItemsCount,
    LdControlGroupScope? scope,
  ) {
    final wrap = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (selectedItemsCount == 0)
          DefaultTextStyle(
              style: ldBuildTextStyle(
                theme,
                LdTextType.label,
                size,
                color: theme.textMuted,
              ),
              child: config.hint),
        ...selectedItems
            .sublist(0, displayItems)
            .map((item) => config.selectedItemBuilder(context, item))
            .intersperse(separator ?? const Text(", ")),
        if (left > 0)
          Text(
            " +$left",
          )
      ],
    );

    if (scope == null) {
      return wrap;
    }

    // Inside a group keep the trigger to a single line so it joins the other
    // members at [LdTheme.controlHeight]; longer content is clipped rather than
    // wrapping the (already truncated) selection.
    return ClipRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: theme.labelSize(size) * ldLineHeight(LdTextType.label, size: size),
        ),
        child: wrap,
      ),
    );
  }
}
