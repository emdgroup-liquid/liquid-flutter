import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdListEmpty extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final String? text;

  /// When true, the empty state shows a filter-aware message and an option to
  /// clear the active filters via [onClearFilters].
  final bool hasActiveFilters;

  /// Called when the user taps the "Clear filters" button. Only shown when
  /// [hasActiveFilters] is true.
  final Future<void> Function()? onClearFilters;

  const LdListEmpty({
    super.key,
    this.onRefresh,
    this.text,
    this.hasActiveFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final loc = LiquidLocalizations.of(context);
    final label = text ?? (hasActiveFilters ? loc.noItemsMatchFilter : loc.noItemsFound);

    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        LdAvatar(child: Icon(hasActiveFilters ? LucideIcons.filterX : LucideIcons.searchSlash)),
        ldSpacerM,
        LdText.p(label),
        ldSpacerM,
        if (hasActiveFilters && onClearFilters != null)
          LdButton(
            mode: LdButtonMode.outline,
            onPressed: () => onClearFilters!(),
            child: Text(loc.clearFilters),
          )
        else if (onRefresh != null)
          LdSubmit<void, void>(
            config: LdSubmitConfig<void, void>(
              action: (_) => onRefresh!(),
            ),
            child: LdSubmitInlineBuilder<void, void>(
              submitButtonBuilder: (context, controller) => LdButton(
                mode: LdButtonMode.outline,
                onPressed: controller.trigger,
                child: Text(loc.refresh),
              ),
            ),
          ),
      ]),
    );
  }
}
