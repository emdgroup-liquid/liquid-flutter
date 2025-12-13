import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/shrinkwrap_pageview.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LdDatePicker extends StatefulWidget {
  final String? label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? value;
  final String displayFormat;
  final LdButtonMode buttonMode;
  final bool disabled;
  final bool useRootNavigator;
  final void Function(DateTime?) onChanged;

  const LdDatePicker({
    super.key,
    this.label,
    this.value,
    this.minDate,
    this.maxDate,
    this.displayFormat = "yMd",
    this.buttonMode = LdButtonMode.filled,
    required this.onChanged,
    this.disabled = false,
    this.useRootNavigator = false,
  });

  @override
  State<LdDatePicker> createState() => _LdDatePickerState();
}

class _LdDatePickerState extends State<LdDatePicker> {
  late ValueNotifier<DateTime> _selectedDateNotifier;
  late DateTime _selectedDate;

  DateTime get _initialDate => widget.value ?? DateTime.now();

  Jiffy get initialDateJiffy => Jiffy.parseFromDateTime(_initialDate);

  String get initialDateString => initialDateJiffy.format(
        pattern: widget.displayFormat,
      );

  @override
  void initState() {
    super.initState();
    _selectedDate = _initialDate;
    _selectedDateNotifier = ValueNotifier<DateTime>(_selectedDate);
  }

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LdDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selectedDate = widget.value ?? DateTime.now();
      _selectedDateNotifier.value = _selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdModalBuilder(
      useRootNavigator: widget.useRootNavigator,
      builder: (context, open) => LdBundle(
        children: [
          if (widget.label != null) LdText.l(widget.label!),
          LdTouchableSurface(
            allowTapOutside: true,
            mode: LdTouchableSurfaceMode.input,
            isInput: true,
            key: const Key("date_picker_button"),
            onPressed: () async {
              await open();
              if (!mounted) return;
              widget.onChanged(_selectedDateNotifier.value);
            },
            disabled: widget.disabled,
            builder: (context, colors, status, _) => Container(
              clipBehavior: Clip.hardEdge,
              padding: theme.pad(size: LdSize.s),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: theme.radius(LdSize.s),
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
              ),
              child: LdText.l(initialDateString),
            ),
          )
        ],
      ),
      modal: LdModalRoute(
        context: context,
        pageBuilder: (context) => _DatePickerSheet(
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          selectedDateNotifier: _selectedDateNotifier,
          label: widget.label ?? LiquidLocalizations.of(context).selectDate,
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDateNotifier;
  final String label;
  final DateTime? minDate;
  final DateTime? maxDate;

  const _DatePickerSheet({
    required this.selectedDateNotifier,
    required this.label,
    required this.minDate,
    required this.maxDate,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late PageController? _pageController = PageController(
    initialPage: monthSince0(widget.selectedDateNotifier.value),
  );

  int monthSince0(DateTime other) =>
      Jiffy.parseFromDateTime(other).diff(Jiffy.parseFromDateTime(DateTime(0)), unit: Unit.month).toInt();

  bool get _pageControllerIsValid => (_pageController?.positions.length == 1);

  int get _currentPage => _pageControllerIsValid
      ? _pageController!.page?.toInt() ?? monthSince0(widget.selectedDateNotifier.value)
      : monthSince0(widget.selectedDateNotifier.value);

  DateTime get _viewDate => Jiffy.parseFromDateTime(DateTime(0)).add(months: _currentPage).dateTime;

  @override
  initState() {
    super.initState();
    _pageController?.addListener(() {
      if (!_animating) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _DatePickerSheet oldWidget) {
    if (oldWidget.selectedDateNotifier != widget.selectedDateNotifier) {
      viewDate(widget.selectedDateNotifier.value);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  dispose() {
    _pageController?.dispose();
    _pageController = null;
    super.dispose();
  }

  bool _animating = false;

  void _selectDate(DateTime date) {
    widget.selectedDateNotifier.value = date;
    viewDate(date);
    setState(() {});
  }

  void viewDate(DateTime date) async {
    _animating = true;
    if (!mounted) return;
    HapticFeedback.selectionClick();
    await _pageController?.animateToPage(
      monthSince0(date),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animating = false;
    if (!mounted) return;
    setState(() {});
  }

  LdSelect _buildMonthSelect() {
    return LdSelect(
      value: _viewDate.month - 1,
      onChanged: (p0) {
        viewDate(DateTime(_viewDate.year, p0 + 1, _viewDate.day));
      },
      items: List.generate(
        12,
        (index) {
          return LdSelectItem(
            value: index,
            key: Key("month_$index"),
            enabled: containsValidDate(
              DateTime(_viewDate.year, index + 1),
              DateTime(_viewDate.year, index + 1, 31),
            ),
            child: Text(DateFormat.MMMM().format(DateTime(2000, index + 1))),
          );
        },
      ),
    );
  }

  LdSelect _buildYearSelect() {
    final selectedYear = _viewDate.year;

    var yearsToShow = 50;

    if (widget.maxDate != null && widget.minDate != null) {
      yearsToShow = widget.maxDate!.year - widget.minDate!.year + 1;
    }

    return LdSelect(
      value: _viewDate.year,
      onChanged: (p0) {
        viewDate(DateTime(p0, _viewDate.month, _viewDate.day));
      },
      items: List.generate(
        yearsToShow,
        (index) {
          final year = selectedYear - max(yearsToShow / 2, 0).toInt() + index;
          return LdSelectItem(
            value: year,
            key: Key("year_$year"),
            enabled: containsValidDate(DateTime(year), DateTime(year, 12, 31)),
            child: Text((year).toString()),
          );
        },
      ),
    );
  }

  bool isSelected(DateTime date) {
    final selectedDate = widget.selectedDateNotifier.value;
    return date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
  }

  bool get showTodayButton {
    if (widget.minDate != null) {
      if (DateTime.now().isBefore(widget.minDate!)) {
        return false;
      }
    }
    if (widget.maxDate != null) {
      if (DateTime.now().isAfter(widget.maxDate!)) {
        return false;
      }
    }
    return true;
  }

  bool get nextMonthIsValid {
    return containsValidDate(
      DateTime(_viewDate.year, _viewDate.month + 1),
      Jiffy.parseFromDateTime(
        DateTime(_viewDate.year, _viewDate.month + 1),
      ).endOf(Unit.month).dateTime,
    );
  }

  bool get previousMonthIsValid {
    return containsValidDate(
      DateTime(_viewDate.year, _viewDate.month - 1),
      Jiffy.parseFromDateTime(
        DateTime(_viewDate.year, _viewDate.month - 1),
      ).endOf(Unit.month).dateTime,
    );
  }

  bool containsValidDate(DateTime start, DateTime end) {
    DateTime min = widget.minDate ?? DateTime(0);
    DateTime max = widget.maxDate ?? DateTime(9999, 12, 31);
    final valid = start.isBefore(max) && end.isAfter(min);
    return valid;
  }

  bool isValidDate(DateTime date) {
    if (widget.minDate != null) {
      if (date.isBefore(widget.minDate!)) {
        return false;
      }
    }

    if (widget.maxDate != null) {
      if (date.isAfter(widget.maxDate!)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final previousMonth = LdButton.ghost(
      child: const Icon(LucideIcons.arrowLeft),
      disabled: !previousMonthIsValid,
      onPressed: () {
        viewDate(
          DateTime(
            _viewDate.year,
            _viewDate.month - 1,
            _viewDate.day,
          ),
        );
      },
    );

    final nextMonth = LdButton.ghost(
      child: const Icon(LucideIcons.arrowRight),
      disabled: !nextMonthIsValid,
      onPressed: () {
        viewDate(DateTime(
          _viewDate.year,
          _viewDate.month + 1,
          _viewDate.day,
        ));
      },
    );

    return LdScaffold(
      appBars: [
        LdAppBar(
          title: Text(widget.label),
          backgroundMode: LdAppBarBackgroundMode.visible,
          borderMode: LdAppBarBorderMode.visible,
          shadowMode: LdAppBarShadowMode.visible,
        ),
        LdAppBar(
          positionMode: LdAppBarPositionMode.bottom,
          actions: [
            LdButton(
              active: isSelected(DateTime.now()),
              disabled: !isValidDate(DateTime.now()),
              child: const Text('Today'),
              onPressed: () {
                _selectDate(DateTime.now());
              },
            ),
            ...[7, 30, 90]
                .map((days) => LdButton(
                      active: isSelected(widget.selectedDateNotifier.value.add(Duration(days: days))),
                      disabled: !isValidDate(widget.selectedDateNotifier.value.add(Duration(days: days))),
                      child: Text('+${days}d'),
                      onPressed: () {
                        _selectDate(widget.selectedDateNotifier.value.add(Duration(days: days)));
                      },
                    ))
                .toList(),
          ],
          trailing: LdButton.filled(
            child: const Text('Done'),
            leading: const Icon(LucideIcons.chevronRight),
            onPressed: () {
              Navigator.of(context).pop(widget.selectedDateNotifier.value);
            },
          ),
        ),
      ],
      body: LdScaffoldBody(
        children: [
          LdBundle(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: _buildYearSelect()),
                  previousMonth,
                  ldSpacerS,
                  Expanded(flex: 3, child: _buildMonthSelect()),
                  ldSpacerS,
                  nextMonth,
                ],
              )
            ],
          ),
          ldSpacerL,
          ExpandablePageView(
            controller: _pageController,
            itemBuilder: (context, index) {
              return ValueListenableBuilder<DateTime>(
                valueListenable: widget.selectedDateNotifier,
                builder: (context, selectedDate, child) {
                  return _MonthView(
                    key: Key("month_view_$index"),
                    viewDate: Jiffy.parseFromDateTime(DateTime(0)).add(months: index).dateTime,
                    selectedDate: selectedDate,
                    minDate: widget.minDate,
                    maxDate: widget.maxDate,
                    onSelected: (date) {
                      widget.selectedDateNotifier.value = date;
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime viewDate;
  final DateTime selectedDate;
  final void Function(DateTime) onSelected;
  final DateTime? minDate;
  final DateTime? maxDate;

  const _MonthView({
    required this.viewDate,
    required this.selectedDate,
    required this.onSelected,
    this.minDate,
    this.maxDate,
    super.key,
  });

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool isToday(DateTime date) {
    return isSameDay(DateTime.now(), date);
  }

  bool isSelected(DateTime date) {
    return isSameDay(selectedDate, date);
  }

  bool isValidDate(DateTime date) {
    if (minDate != null) {
      if (date.isBefore(minDate!)) {
        return false;
      }
    }

    if (maxDate != null) {
      if (date.isAfter(maxDate!)) {
        return false;
      }
    }
    return true;
  }

  List<Widget> _buildWeekDayHeaders() {
    return List.generate(7, (index) {
      return Expanded(
        child: LdText.l(
          DateFormat.E().format(DateTime(2000, 1, index + 3)),
          textAlign: TextAlign.center,
        ),
      );
    });
  }

  LdButtonMode _buttonMode(DateTime date) {
    if (isSelected(date)) {
      return LdButtonMode.filled;
    } else if (isToday(date)) {
      return LdButtonMode.outline;
    } else {
      return LdButtonMode.ghost;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, size) {
      // Find the weekday of the first day of the month
      final firstDayWeekday = DateTime(viewDate.year, viewDate.month, 1).weekday;

      final aspectRatio = size.isDesktop || size.isTablet ? 2.0 : 1.0;

      final theme = LdTheme.of(context);

      final monthDays = List.generate(
        firstDayWeekday - 1,
        (index) {
          final day = DateTime(viewDate.year, viewDate.month, 1).subtract(Duration(days: firstDayWeekday - index));
          return Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: LdButton(
                  mode: _buttonMode(day),
                  key: Key("day_${day.year}_${day.month}_${day.day}"),
                  size: LdSize.s,
                  width: double.infinity,
                  disabled: !isValidDate(day),
                  color: theme.palette.neutral,
                  child: Text(day.day.toString()),
                  onPressed: () {
                    onSelected(day);
                  },
                ),
              ),
            ),
          );
        },
      );

      final monthLength = Jiffy.parseFromDateTime(viewDate).daysInMonth;

      for (var i = 0; i < monthLength; i++) {
        final day = DateTime(viewDate.year, viewDate.month, i + 1);
        monthDays.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: LdButton(
                size: LdSize.s,
                width: double.infinity,
                key: Key("day_${day.year}_${day.month}_${day.day}"),
                mode: _buttonMode(day),
                disabled: !isValidDate(day),
                child: Text(day.day.toString()),
                onPressed: () {
                  onSelected(day);
                },
              ),
            ),
          ),
        );
      }

      final nextMonthDays = 7 - (monthDays.length % 7);

      if (nextMonthDays > 0 && nextMonthDays < 7) {
        monthDays.addAll(
          List.generate(nextMonthDays, (index) {
            final day = DateTime(viewDate.year, viewDate.month, monthLength + index + 1);
            return Expanded(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: LdButton.ghost(
                  mode: _buttonMode(day),
                  key: Key("day_${day.year}_${day.month}_${day.day}"),
                  active: isSelected(day),
                  color: theme.palette.neutral,
                  disabled: !isValidDate(day),
                  child: Text(day.day.toString()),
                  onPressed: () {
                    onSelected(day);
                  },
                ),
              ),
            );
          }),
        );
      }

      List<Widget> weeks = [];

      for (var i = 0; i < monthDays.length; i += 7) {
        weeks.add(Row(
          children: monthDays.sublist(i, min(i + 7, monthDays.length)).intersperse<Widget>(ldSpacerS).toList(),
        ));
      }

      return LdAutoSpace(children: [
        Row(
          children: _buildWeekDayHeaders(),
        ),
        ...weeks,
      ]);
    });
  }
}

extension on Iterable {
  Iterable<T> intersperse<T>(T element) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
    }
  }
}
