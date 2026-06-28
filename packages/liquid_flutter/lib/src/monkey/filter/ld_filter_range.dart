import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterRange<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  final RangeValues range;
  final double min;
  final double max;
  final double step;

  LdFilterRange({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.min,
    this.step = 1,
    required this.max,
    RangeValues? range,
    super.isEnabled,
    super.affectedByUpdate,
  }) : range = range ?? RangeValues(min, max);

  @override
  String serialize() {
    // Determine the precision based on the step
    final precision = step.toString().split(".").last.length;

    return "${range.start.toStringAsFixed(precision)},${range.end.toStringAsFixed(precision)}";
  }

  @override
  LdFilterRange<T, IdType> marshalSerialized(String value) {
    if (value.isEmpty) {
      return copyWith(isOn: false);
    }

    final values = value.split(",");

    if (values.length != 2) {
      return copyWith(isOn: false);
    }

    final min = double.tryParse(values[0]);
    final max = double.tryParse(values[1]);

    if (min == null || max == null || min < this.min || max > this.max) {
      return copyWith(isOn: false);
    }

    return copyWith(
      range: RangeValues(min, max),
      isOn: true,
    );
  }

  @override
  LdFilterRange<T, IdType> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    RangeValues? range,
    double? min,
    double? max,
    double? step,
    bool Function(BuildContext context)? isEnabled,
    LdAffectedByUpdate<T>? affectedByUpdate,
  }) {
    return LdFilterRange<T, IdType>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      min: min ?? this.min,
      max: max ?? this.max,
      step: step ?? this.step,
      range: range ?? this.range,
      isEnabled: isEnabled ?? this.isEnabled,
      affectedByUpdate: affectedByUpdate ?? this.affectedByUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdFilterRangeWidget<T, IdType>(filter: this);
  }
}

extension InRange on RangeValues {
  bool inRange(num value) {
    return value >= start && value <= end;
  }
}

class LdFilterRangeWidget<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdFilterRange<T, IdType> filter;
  final String? title;

  const LdFilterRangeWidget({
    super.key,
    required this.filter,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final header = title ?? filter.label(context);

    return LdAutoSpace(
      children: [
        Row(
          children: [
            Expanded(child: LdText.l(header)),
            LdButton.vague(
              size: LdSize.s,
              onPressed: () {
                filter.update(
                  context,
                  filter.copyWith(
                    isOn: false,
                    range: RangeValues(filter.min, filter.max),
                  ),
                );
                maybePopContextMenu(context);
              },
              child: const Icon(LucideIcons.x),
            ),
          ],
        ),
        LdSlider.range(
          lowValue: filter.range.start,
          highValue: filter.range.end,
          min: filter.min,
          max: filter.max,
          step: filter.step,
          onRangeChanged: (low, high) {
            filter.update(
              context,
              filter.copyWith(
                range: RangeValues(low, high),
                isOn: true,
              ),
            );
          },
        ),
      ],
    ).padM();
  }
}
