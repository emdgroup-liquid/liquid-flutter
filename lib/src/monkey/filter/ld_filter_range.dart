import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFilterRange<T extends Identifiable<IdType>, IdType> extends LdFilterOption<T, IdType> {
  @override
  String serialize() {
    // Determine the precision based on the step
    final precision = step.toString().split(".").last.length;

    return "${range.start.toStringAsFixed(precision)},${range.end.toStringAsFixed(precision)}";
  }

  @override
  void marshalSerialized(String value) {
    isOn = false;
    if (value.isEmpty) {
      return;
    }

    final values = value.split(",");

    if (values.length != 2) {
      return;
    }

    final min = double.tryParse(values[0]);
    final max = double.tryParse(values[1]);

    if (min == null || max == null || min < this.min || max > this.max) {
      return;
    }

    range = RangeValues(min, max);
    isOn = true;
  }

  @override
  bool optimisticFilter(T item) {
    return _optimisticFilter(item, range);
  }

  RangeValues range;
  final double min;
  final double max;
  final double step;

  final bool Function(T item, RangeValues range) _optimisticFilter;

  LdFilterRange({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    required this.min,
    this.step = 1,
    required this.max,
    required bool Function(T item, RangeValues range) optimisticFilter,
  })  : _optimisticFilter = optimisticFilter,
        range = RangeValues(min, max);
}

extension InRange on RangeValues {
  bool inRange(num value) {
    return value >= start && value <= end;
  }
}

class LdFilterRangeWidget<T extends Identifiable<IdType>, IdType, GroupBy> extends StatelessWidget {
  final LdFilterRange<T, IdType> filter;
  final void Function(LdFilterRange<T, IdType>) onFilterChanged;

  const LdFilterRangeWidget({super.key, required this.filter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        Row(
          children: [
            Expanded(child: LdTextL(filter.label(context))),
            LdButtonVague(
              child: const Icon(LucideIcons.x),
              size: LdSize.s,
              onPressed: () {
                filter.isOn = false;
                onFilterChanged(filter);
              },
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(showValueIndicator: ShowValueIndicator.never),
          child: RangeSlider(
              activeColor: LdTheme.of(context).primaryColor,
              padding: EdgeInsets.zero,
              min: filter.min,
              max: filter.max,
              divisions: (filter.max - filter.min) ~/ filter.step,
              values: filter.range,
              onChanged: (values) {
                filter.range = values;
                onFilterChanged(filter);
              }),
        )
      ],
    ).padM();
  }
}
