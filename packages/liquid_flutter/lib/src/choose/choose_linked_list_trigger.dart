import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A trigger for [LdChoose] that renders selected items as a list of
/// [LdListItem]s with swipe-to-remove support, followed by an "Add" row that
/// opens the picker.
///
/// Designed for record-linking use cases where the user selects a set of
/// related items and each selected item is shown inline with optional
/// navigation support.
///
/// Typical usage inside an [LdCard]:
///
/// ```dart
/// LdCard(
///   padding: EdgeInsets.zero,
///   child: LdChoose<MyRecord, String>(
///     repository: repo,
///     multiple: true,
///     allowEmpty: true,
///     value: _selected,
///     onChanged: (ids) => setState(() => _selected = ids),
///     itemBuilder: (ctx, item, _) => LdListItem(title: Text(item.value!.name)),
///     selectedItemBuilder: (ctx, item) => Text(item.name),
///     triggerBuilder: (ctx, config) => LdChooseLinkedListTrigger(
///       config: config,
///       onItemPressed: (ctx, item) => Navigator.of(ctx).push(...),
///     ),
///   ),
/// )
/// ```
class LdChooseLinkedListTrigger<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdChooseLinkedListTrigger({
    required this.config,
    this.onItemPressed,
    this.addLabel,
    this.removeLabel,
    super.key,
  });

  final LdChooseTriggerConfig<T, IdType> config;

  /// Called when the user taps a selected-item row. Intended for navigation.
  /// If null the rows are non-interactive (no tap feedback).
  final void Function(BuildContext context, T item)? onItemPressed;

  /// Label shown on the "Add" row. Defaults to [LiquidLocalizations.choose].
  final String? addLabel;

  /// Label shown on the swipe-to-remove action. Defaults to `"Remove"`.
  final String? removeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final items = config.selectedItems;
    final ids = config.selectedIds;
    final canRemoveLast = config.allowEmpty;

    return LdSlidableGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state hint shown above the Add row when nothing is selected.
          if (items.isEmpty)
            Padding(
              padding: theme.balPad(LdSize.s),
              child: DefaultTextStyle(
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.paragraph,
                  LdSize.s,
                  color: theme.textMuted,
                ),
                child: config.hint,
              ),
            ),

          // Selected item rows.
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) LdDivider(height: 1),
            _buildItemRow(context, theme, items[i], ids, canRemoveLast),
          ],

          // Divider between items and Add row only when there are items.
          if (items.isNotEmpty) LdDivider(height: 1),

          // "Add" row — always present at the bottom.
          LdListItem(
            disabled: config.disabled,
            onPressed: config.disabled ? null : config.onTap,
            leading: Icon(
              LucideIcons.plus,
              color: config.disabled ? theme.textMuted : theme.primaryColor,
              size: theme.labelSize(LdSize.m),
            ),
            title: Text(addLabel ?? LiquidLocalizations.of(context).choose),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    LdTheme theme,
    T item,
    List<IdType> ids,
    bool canRemoveLast,
  ) {
    // Disable removal when allowEmpty is false and this is the last item.
    final isLastItem = ids.length == 1;
    final removalEnabled = config.onRemoveItem != null && (canRemoveLast || !isLastItem);

    return LdSlidableListItem(
      enabled: !config.disabled && removalEnabled,
      endActionPane: removalEnabled
          ? LdSlideActionPane(
              actions: [
                LdSlideAction(
                  icon: LucideIcons.trash2,
                  label: removeLabel ?? 'Remove',
                  color: theme.error,
                  dismissBehavior: LdSlideActionDismissBehavior.dismiss,
                  onTriggered: (_) => config.onRemoveItem?.call(item.id),
                ),
              ],
            )
          : null,
      child: LdListItem(
        disabled: config.disabled,
        onPressed: onItemPressed == null ? null : () => onItemPressed!(context, item),
        title: config.selectedItemBuilder(context, item),
        trailing: onItemPressed != null
            ? Icon(
                LucideIcons.chevronRight,
                size: theme.labelSize(LdSize.m),
                color: theme.primaryColor,
              )
            : null,
      ),
    );
  }
}
