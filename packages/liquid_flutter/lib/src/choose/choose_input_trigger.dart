import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/intersperse.dart';
import 'package:liquid_flutter/src/touchable/input_color.dart';
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
    final size = config.size;
    final disabled = config.disabled;
    final selectedItemBuilder = config.selectedItemBuilder;
    var theme = LdTheme.of(context, listen: true);
    final selectedItemsCount = selectedIds.length;

    int displayItems = selectedItems.length;
    int left = 0;

    displayItems = min(displayItems, truncateDisplay);
    left = selectedItemsCount - displayItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: label,
          size: size,
        ),
        LdTouchableSurface(
          disabled: disabled,
          key: const Key("ldChoose_trigger"),
          onPressed: onTap,
          builder: (contxt, status, child) {
            final colorBundle = inputColor(theme, status, isValid: true);
            return Container(
              padding: theme.balPad(size),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: theme.radius(LdSize.s),
                color: colorBundle.surface,
                border: Border.all(
                  color: colorBundle.border,
                  width: theme.borderWidth,
                ),
              ),
              child: child!,
            );
          },
          child: Row(
            children: [
              DefaultTextStyle(
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.label,
                  LdSize.m,
                ),
                child: Expanded(
                  child: Opacity(
                    opacity: disabled ? 0.5 : 1,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (selectedItemsCount == 0)
                          DefaultTextStyle(
                              style: ldBuildTextStyle(
                                theme,
                                LdTextType.label,
                                LdSize.m,
                                color: theme.textMuted,
                              ),
                              child: config.hint!),
                        ...selectedItems
                            .sublist(0, displayItems)
                            .map((item) => selectedItemBuilder(context, item))
                            .intersperse(separator ?? const Text(", ")),
                        if (left > 0)
                          Text(
                            " +$left",
                          )
                      ],
                    ),
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
      ],
    );
  }
}
