import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum LdFilterChipPresentation { inline, sheet }

sealed class LdFilterChipConfig<T extends Identifiable<IdType>, IdType> {
  const LdFilterChipConfig({
    required this.filterName,
    this.groupLabel,
  });

  final String filterName;

  /// Muted label shown before this filter's chips (e.g. "Genre").
  final String Function(BuildContext context)? groupLabel;

  factory LdFilterChipConfig.bool({
    required String filterName,
    String Function(BuildContext context)? groupLabel,
    String Function(BuildContext context)? chipLabel,
  }) = LdFilterChipBoolConfig<T, IdType>;

  factory LdFilterChipConfig.range({
    required String filterName,
    required LdFilterChipPresentation presentation,
    String Function(BuildContext context)? groupLabel,
    String Function(BuildContext context, LdFilterRange<T, IdType> filter)? summaryLabel,
    String Function(BuildContext context)? sheetTitle,
  }) = LdFilterChipRangeConfig<T, IdType>;

  factory LdFilterChipConfig.oneOf({
    required String filterName,
    required LdFilterChipPresentation presentation,
    required bool showAllOption,
    String Function(BuildContext context)? groupLabel,
    String Function(BuildContext context)? allLabel,
    String Function(BuildContext context)? sheetTitle,
    Widget Function(BuildContext context, dynamic option)? optionChild,
  }) = LdFilterChipOneOfConfig<T, IdType>;

  factory LdFilterChipConfig.anyOf({
    required String filterName,
    required LdFilterChipPresentation presentation,
    String Function(BuildContext context)? groupLabel,
    String Function(BuildContext context)? sheetTitle,
    Widget Function(BuildContext context, dynamic option)? optionChild,
  }) = LdFilterChipAnyOfConfig<T, IdType>;
}

final class LdFilterChipBoolConfig<T extends Identifiable<IdType>, IdType> extends LdFilterChipConfig<T, IdType> {
  const LdFilterChipBoolConfig({
    required super.filterName,
    super.groupLabel,
    this.chipLabel,
  });

  final String Function(BuildContext context)? chipLabel;
}

final class LdFilterChipRangeConfig<T extends Identifiable<IdType>, IdType> extends LdFilterChipConfig<T, IdType> {
  const LdFilterChipRangeConfig({
    required super.filterName,
    super.groupLabel,
    this.presentation = LdFilterChipPresentation.sheet,
    this.summaryLabel,
    this.sheetTitle,
  });

  final LdFilterChipPresentation presentation;
  final String Function(BuildContext context, LdFilterRange<T, IdType> filter)? summaryLabel;
  final String Function(BuildContext context)? sheetTitle;
}

final class LdFilterChipOneOfConfig<T extends Identifiable<IdType>, IdType> extends LdFilterChipConfig<T, IdType> {
  const LdFilterChipOneOfConfig({
    required super.filterName,
    super.groupLabel,
    this.presentation = LdFilterChipPresentation.inline,
    this.showAllOption = true,
    this.allLabel,
    this.sheetTitle,
    this.optionChild,
  });

  final LdFilterChipPresentation presentation;
  final bool showAllOption;
  final String Function(BuildContext context)? allLabel;
  final String Function(BuildContext context)? sheetTitle;
  final Widget Function(BuildContext context, dynamic option)? optionChild;
}

final class LdFilterChipAnyOfConfig<T extends Identifiable<IdType>, IdType> extends LdFilterChipConfig<T, IdType> {
  const LdFilterChipAnyOfConfig({
    required super.filterName,
    super.groupLabel,
    this.presentation = LdFilterChipPresentation.sheet,
    this.sheetTitle,
    this.optionChild,
  });

  final LdFilterChipPresentation presentation;
  final String Function(BuildContext context)? sheetTitle;
  final Widget Function(BuildContext context, dynamic option)? optionChild;
}

/// Horizontal chip bar for monkey filters (presentation only).
class LdFilterChipsBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdFilterChipsBar({
    super.key,
    required this.configs,
  });

  final List<LdFilterChipConfig<T, IdType>> configs;

  @override
  Widget build(BuildContext context) {
    final groups = <Widget>[];
    for (final config in configs) {
      final group = switch (config) {
        LdFilterChipBoolConfig<T, IdType> c => _BoolChip<T, IdType>(config: c),
        LdFilterChipRangeConfig<T, IdType> c => _RangeChip<T, IdType>(config: c),
        LdFilterChipOneOfConfig<T, IdType> c => _OneOfChip<T, IdType>(config: c),
        LdFilterChipAnyOfConfig<T, IdType> c => _AnyOfChip<T, IdType>(config: c),
      };
      if (!_isEmptyFilterChipGroup(group)) {
        groups.add(
          _FilterChipGroup<T, IdType>(
            config: config,
            child: group,
          ),
        );
      }
    }

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < groups.length; i++) {
      if (i > 0) {
        children.add(const _FilterChipGroupDivider());
      }
      children.add(groups[i]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ).spaceS(),
    );
  }
}

bool _isEmptyFilterChipGroup(Widget widget) {
  if (widget is! SizedBox) {
    return false;
  }
  final width = widget.width;
  final height = widget.height;
  return (width == null || width == 0) && (height == null || height == 0);
}

class _FilterChipGroup<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _FilterChipGroup({
    required this.config,
    required this.child,
  });

  final LdFilterChipConfig<T, IdType> config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final groupLabel = config.groupLabel?.call(context);
    if (groupLabel == null) {
      return child;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FilterChipGroupLabel(text: groupLabel),
        child,
      ],
    ).spaceS();
  }
}

/// Muted group label aligned to [LdButton] size `s` chip content lane.
class _FilterChipGroupLabel extends StatelessWidget {
  const _FilterChipGroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LdMute(
      child: LdText.ls(
        text,
        lineHeight: 1.2,
      ),
    );
  }
}

class _FilterChipGroupDivider extends StatelessWidget {
  const _FilterChipGroupDivider();

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return SizedBox(
      height: theme.labelSize(LdSize.s) * 2,
      child: VerticalDivider(
        width: theme.borderWidth,
        color: theme.border,
        indent: 0,
        endIndent: 0,
      ),
    );
  }
}

F? findMonkeyFilterByName<T extends Identifiable<IdType>, IdType, F extends LdFilterOption<T, IdType>>(
  BuildContext context, {
  required String filterName,
  bool listen = false,
}) {
  final filterState = LdMonkeySortAndFilterState.of<T, IdType>(context, listen: listen);
  for (final filter in filterState.filters) {
    if (filter.name == filterName && filter is F) {
      return filter;
    }
  }
  return null;
}

Widget? _ldFilterChipTrailing({
  required bool selected,
  required bool showChevron,
  required bool showClearIcon,
}) {
  if (showChevron) {
    return const Icon(LucideIcons.chevronDown);
  }
  if (selected && showClearIcon) {
    return const Icon(LucideIcons.x);
  }
  return null;
}

Widget ldFilterChipButton({
  required bool selected,
  required VoidCallback onPressed,
  required Widget child,
  bool showChevron = false,
  bool showClearIcon = true,
}) {
  final trailing = _ldFilterChipTrailing(
    selected: selected,
    showChevron: showChevron,
    showClearIcon: showClearIcon,
  );
  return selected
      ? LdButton.outline(
          size: LdSize.s,
          active: true,
          onPressed: onPressed,
          trailing: trailing,
          child: child,
        )
      : LdButton.vague(
          size: LdSize.s,
          onPressed: onPressed,
          trailing: trailing,
          child: child,
        );
}

class _BoolChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _BoolChip({required this.config});

  final LdFilterChipBoolConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterBool<T, IdType>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    final label = config.chipLabel?.call(context) ?? filter.label(context);
    return ldFilterChipButton(
      selected: filter.isOn,
      onPressed: () {
        filter.update(context, filter.copyWith(isOn: !filter.isOn));
      },
      child: Text(label),
    );
  }
}

class _RangeChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _RangeChip({required this.config});

  final LdFilterChipRangeConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterRange<T, IdType>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    final label = switch (config.summaryLabel) {
      final builder? when filter.isOn => builder(context, filter),
      _ => filter.label(context),
    };

    return ldFilterChipButton(
      selected: filter.isOn,
      showChevron: config.presentation == LdFilterChipPresentation.sheet,
      onPressed: () => switch (config.presentation) {
        LdFilterChipPresentation.sheet => ldFilterChipSheet<T, IdType>(
            context,
            filter: filter,
            title: config.sheetTitle?.call(context) ?? filter.label(context),
          ),
        LdFilterChipPresentation.inline => filter.update(
            context,
            filter.copyWith(isOn: !filter.isOn),
          ),
      },
      child: Text(label),
    );
  }
}

class _OneOfChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfChip({required this.config});

  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterOneOf<T, IdType, dynamic>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    return switch (config.presentation) {
      LdFilterChipPresentation.sheet => _OneOfSheetChip<T, IdType>(filter: filter, config: config),
      LdFilterChipPresentation.inline => _OneOfInlineChips<T, IdType>(filter: filter, config: config),
    };
  }
}

class _OneOfSheetChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfSheetChip({required this.filter, required this.config});

  final LdFilterOneOf<T, IdType, dynamic> filter;
  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter.isOn && filter.selectedValue != null) {
      true => filter.selectedValue.toString(),
      false => filter.label(context),
    };

    return ldFilterChipButton(
      selected: filter.isOn,
      showChevron: true,
      onPressed: () => ldFilterChipSheet<T, IdType>(
        context,
        filter: filter,
        title: config.sheetTitle?.call(context) ?? filter.label(context),
      ),
      child: Text(label),
    );
  }
}

class _OneOfInlineChips<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _OneOfInlineChips({required this.filter, required this.config});

  final LdFilterOneOf<T, IdType, dynamic> filter;
  final LdFilterChipOneOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final options = filter.allValues.keys.toList();
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    if (config.showAllOption) {
      final allLabel = config.allLabel?.call(context) ?? 'All';
      chips.add(
        ldFilterChipButton(
          selected: !filter.isOn,
          showClearIcon: false,
          onPressed: () {
            filter.update(
              context,
              filter.copyWith(isOn: false, clearSelectedValue: true),
            );
          },
          child: Text(allLabel),
        ),
      );
    }

    for (final value in options) {
      final isSelected = filter.isOn && filter.selectedValue == value;
      final child =
          config.optionChild?.call(context, value) ?? filter.allValues[value]?.call(context) ?? Text(value.toString());
      chips.add(
        ldFilterChipButton(
          selected: isSelected,
          onPressed: () {
            filter.update(
              context,
              filter.copyWith(selectedValue: value, isOn: true),
            );
          },
          child: child,
        ),
      );
    }

    return Row(children: chips).spaceS();
  }
}

class _AnyOfChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfChip({required this.config});

  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final filter = findMonkeyFilterByName<T, IdType, LdFilterAnyOf<T, IdType, dynamic>>(
      context,
      filterName: config.filterName,
      listen: true,
    );
    if (filter == null) {
      return const SizedBox.shrink();
    }

    return switch (config.presentation) {
      LdFilterChipPresentation.sheet => _AnyOfSheetChip<T, IdType>(filter: filter, config: config),
      LdFilterChipPresentation.inline => _AnyOfInlineChips<T, IdType>(filter: filter, config: config),
    };
  }
}

class _AnyOfSheetChip<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfSheetChip({required this.filter, required this.config});

  final LdFilterAnyOf<T, IdType, dynamic> filter;
  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final count = filter.selectedValues.length;
    final label = switch (filter.isOn && count > 0) {
      true => '${filter.label(context)} ($count)',
      false => filter.label(context),
    };

    return ldFilterChipButton(
      selected: filter.isOn,
      showChevron: true,
      onPressed: () => ldFilterChipSheet<T, IdType>(
        context,
        filter: filter,
        title: config.sheetTitle?.call(context) ?? filter.label(context),
      ),
      child: Text(label),
    );
  }
}

class _AnyOfInlineChips<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _AnyOfInlineChips({required this.filter, required this.config});

  final LdFilterAnyOf<T, IdType, dynamic> filter;
  final LdFilterChipAnyOfConfig<T, IdType> config;

  @override
  Widget build(BuildContext context) {
    final options = filter.allValues.keys.toList();
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];
    for (final value in options) {
      final isSelected = filter.selectedValues.contains(value);
      final child =
          config.optionChild?.call(context, value) ?? filter.allValues[value]?.call(context) ?? Text(value.toString());
      chips.add(
        ldFilterChipButton(
          selected: isSelected,
          onPressed: () => filter.toggleSelectedValue(context, value),
          child: child,
        ),
      );
    }

    return Row(children: chips).spaceS();
  }
}
