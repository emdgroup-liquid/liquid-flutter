import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
