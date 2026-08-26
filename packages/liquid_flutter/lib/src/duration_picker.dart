import 'package:flutter/cupertino.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

export 'duration/ld_duration.dart';
export 'duration/ld_duration_format.dart';

/// Which wheels a [LdDurationPicker] shows, plus steps, bounds, and presets.
class LdDurationConfig {
  const LdDurationConfig({
    this.units = const {LdDurationUnit.hours, LdDurationUnit.minutes},
    this.minuteStep = 15,
    this.secondStep = 1,
    this.min,
    this.max,
    this.presets,
  });

  /// Hours, minutes, and seconds.
  const LdDurationConfig.timer({
    this.minuteStep = 1,
    this.secondStep = 1,
    this.min,
    this.max,
    this.presets,
  }) : units = const {
          LdDurationUnit.hours,
          LdDurationUnit.minutes,
          LdDurationUnit.seconds,
        };

  /// Days, hours, and minutes.
  const LdDurationConfig.span({
    this.minuteStep = 15,
    this.secondStep = 1,
    this.min,
    this.max,
    this.presets,
  }) : units = const {
          LdDurationUnit.days,
          LdDurationUnit.hours,
          LdDurationUnit.minutes,
        };

  /// Years and months.
  const LdDurationConfig.calendar({
    this.minuteStep = 15,
    this.secondStep = 1,
    this.min,
    this.max,
    this.presets,
  }) : units = const {
          LdDurationUnit.years,
          LdDurationUnit.months,
        };

  final Set<LdDurationUnit> units;
  final int minuteStep;
  final int secondStep;
  final LdDuration? min;
  final LdDuration? max;

  /// `null` uses defaults derived from [units]. An empty list hides presets.
  final List<LdDuration>? presets;

  Set<LdDurationUnit> get resolvedUnits {
    if (units.isEmpty) {
      return const {LdDurationUnit.hours, LdDurationUnit.minutes};
    }
    return units;
  }

  List<LdDurationUnit> get enabledUnits {
    return LdDurationUnit.values.where(resolvedUnits.contains).toList();
  }

  List<LdDuration> get resolvedPresets {
    if (presets != null) {
      return presets!;
    }
    return defaultPresets(resolvedUnits);
  }

  int stepFor(LdDurationUnit unit) {
    return switch (unit) {
      LdDurationUnit.minutes => minuteStep < 1 ? 1 : minuteStep,
      LdDurationUnit.seconds => secondStep < 1 ? 1 : secondStep,
      _ => 1,
    };
  }

  bool hasLargerUnit(LdDurationUnit unit) {
    return enabledUnits.any((candidate) => candidate.index < unit.index);
  }

  int maxValue(LdDurationUnit unit) {
    final wrap = hasLargerUnit(unit);
    return switch (unit) {
      LdDurationUnit.years => 99,
      LdDurationUnit.months => wrap ? 11 : 24,
      LdDurationUnit.weeks => 52,
      LdDurationUnit.days => resolvedUnits.contains(LdDurationUnit.weeks)
          ? 6
          : wrap
              ? 30
              : 99,
      LdDurationUnit.hours => wrap ? 23 : 99,
      LdDurationUnit.minutes => wrap ? 59 : 99,
      LdDurationUnit.seconds => wrap ? 59 : 99,
    };
  }

  int wheelItemCount(LdDurationUnit unit) {
    final step = stepFor(unit);
    return (maxValue(unit) ~/ step) + 1;
  }

  LdDuration constrain(LdDuration value) {
    return value
        .alignTo(resolvedUnits)
        .snap(minuteStep: stepFor(LdDurationUnit.minutes), secondStep: stepFor(LdDurationUnit.seconds))
        .clamp(min: min, max: max);
  }

  static List<LdDuration> defaultPresets(Set<LdDurationUnit> units) {
    if (units.contains(LdDurationUnit.years) || units.contains(LdDurationUnit.months)) {
      return const [
        LdDuration(months: 1),
        LdDuration(months: 3),
        LdDuration(months: 6),
        LdDuration(years: 1),
      ];
    }
    if (units.contains(LdDurationUnit.days) || units.contains(LdDurationUnit.weeks)) {
      return const [
        LdDuration(hours: 1),
        LdDuration(hours: 4),
        LdDuration(days: 1),
        LdDuration(days: 7),
        LdDuration(days: 30),
      ];
    }
    if (units.contains(LdDurationUnit.seconds) && units.contains(LdDurationUnit.hours)) {
      return const [
        LdDuration(seconds: 30),
        LdDuration(minutes: 1),
        LdDuration(minutes: 5),
        LdDuration(minutes: 15),
        LdDuration(hours: 1),
      ];
    }
    return const [
      LdDuration(minutes: 15),
      LdDuration(minutes: 30),
      LdDuration(hours: 1),
      LdDuration(hours: 2),
      LdDuration(hours: 4),
    ];
  }
}

/// Labeled field that opens a modal to pick an [LdDuration].
class LdDurationPicker extends StatelessWidget {
  const LdDurationPicker({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.size = LdSize.m,
    this.disabled = false,
    this.useRootNavigator = false,
    this.config = const LdDurationConfig(),
    this.focusNode,
  });

  final LdDuration? value;
  final ValueChanged<LdDuration> onChanged;
  final String? label;
  final LdSize size;
  final bool disabled;
  final bool useRootNavigator;
  final LdDurationConfig config;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context, listen: true);
    final lineBoxHeight = theme.labelSize(size) * ldLineHeight(LdTextType.label, size: size);
    final fieldPadding = theme.controlContentPadding(size) - EdgeInsets.all(theme.borderWidth);
    final display = value == null
        ? l10n.selectDuration
        : ldFormatDuration(value!, l10n: l10n, compact: true);

    return LdBundle(
      children: [
        if (label != null)
          LdText.l(
            label!,
            size: size,
          ),
        LdTouchableSurface(
          allowTapOutside: true,
          disabled: disabled,
          focusNode: focusNode,
          key: const Key('duration_picker_button'),
          onPressed: () async {
            final navigator = useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);
            final next = await navigator.push(
              LdModalRoute(
                context: context,
                pageBuilder: (context) => LdDurationPickerModal(
                  initialValue: value,
                  config: config,
                ),
              ),
            ) as LdDuration?;
            if (next != null) {
              onChanged(next);
            }
          },
          builder: (context, status, _) => Builder(
            builder: (context) {
              final colorBundle = inputColor(theme, status, isValid: true);
              return Container(
                clipBehavior: Clip.hardEdge,
                padding: fieldPadding,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorBundle.surface,
                  borderRadius: theme.radius(LdSize.s),
                  border: Border.all(
                    color: colorBundle.border,
                    width: theme.borderWidth,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: lineBoxHeight,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: LdText.l(
                      display,
                      size: size,
                      color: colorBundle.text,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LdDurationPickerModal extends StatefulWidget {
  const LdDurationPickerModal({
    super.key,
    this.initialValue,
    this.config = const LdDurationConfig(),
  });

  final LdDuration? initialValue;
  final LdDurationConfig config;

  @override
  State<LdDurationPickerModal> createState() => _LdDurationPickerModalState();
}

class _LdDurationPickerModalState extends State<LdDurationPickerModal> {
  late LdDuration _value = widget.config.constrain(widget.initialValue ?? const LdDuration());

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    return LdScaffold(
      key: const Key('duration_picker_sheet'),
      body: LdAppBar(
        title: Text(l10n.selectDuration),
        child: LdAppBar.bottom(
          actions: [
            LdFlexibleChild(
              child: LdButton.vague(
                width: double.infinity,
                child: Text(l10n.done),
                onPressed: () => Navigator.pop(context, _value),
              ),
            ),
          ],
          child: LdScaffoldBody(
            children: [
              LdDurationPickerWidget(
                value: _value,
                config: widget.config,
                onChanged: (next) {
                  setState(() {
                    _value = next;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline duration editor: presets, wheels, and numeric fields.
class LdDurationPickerWidget extends StatefulWidget {
  const LdDurationPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.config = const LdDurationConfig(),
  });

  final LdDuration value;
  final ValueChanged<LdDuration> onChanged;
  final LdDurationConfig config;

  @override
  State<LdDurationPickerWidget> createState() => _LdDurationPickerWidgetState();
}

class _LdDurationPickerWidgetState extends State<LdDurationPickerWidget> {
  late LdDuration _value;
  final Map<LdDurationUnit, FixedExtentScrollController> _wheelControllers = {};
  final Map<LdDurationUnit, TextEditingController> _textControllers = {};
  final Map<LdDurationUnit, FocusNode> _focusNodes = {};
  bool _syncingWheels = false;

  List<LdDurationUnit> get _units => widget.config.enabledUnits;

  @override
  void initState() {
    super.initState();
    _value = widget.config.constrain(widget.value);
    _createControllers();
    _applyText();
  }

  @override
  void didUpdateWidget(covariant LdDurationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.resolvedUnits != widget.config.resolvedUnits ||
        oldWidget.config.minuteStep != widget.config.minuteStep ||
        oldWidget.config.secondStep != widget.config.secondStep) {
      _disposeControllers();
      _value = widget.config.constrain(widget.value);
      _createControllers();
      _applyText();
    } else if (oldWidget.value != widget.value) {
      _value = widget.config.constrain(widget.value);
      _applyText();
      _jumpWheels();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _createControllers() {
    for (final unit in _units) {
      final step = widget.config.stepFor(unit);
      final index = (_value.component(unit) ~/ step).clamp(0, widget.config.wheelItemCount(unit) - 1);
      _wheelControllers[unit] = FixedExtentScrollController(initialItem: index);
      _textControllers[unit] = TextEditingController();
      _focusNodes[unit] = FocusNode();
    }
  }

  void _disposeControllers() {
    for (final controller in _wheelControllers.values) {
      controller.dispose();
    }
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _wheelControllers.clear();
    _textControllers.clear();
    _focusNodes.clear();
  }

  void _applyText() {
    for (final unit in _units) {
      _textControllers[unit]?.text = _value.component(unit).toString();
    }
  }

  void _jumpWheels() {
    _syncingWheels = true;
    for (final unit in _units) {
      final controller = _wheelControllers[unit];
      if (controller == null || !controller.hasClients) {
        continue;
      }
      final step = widget.config.stepFor(unit);
      final index = (_value.component(unit) ~/ step).clamp(0, widget.config.wheelItemCount(unit) - 1);
      controller.jumpToItem(index);
    }
    _syncingWheels = false;
  }

  void _emit(LdDuration next) {
    _value = widget.config.constrain(next);
    _applyText();
    _jumpWheels();
    widget.onChanged(_value);
  }

  void _onWheelChanged(LdDurationUnit unit, int index) {
    if (_syncingWheels) {
      return;
    }
    if (_focusNodes[unit]?.hasFocus ?? false) {
      return;
    }
    final step = widget.config.stepFor(unit);
    _emit(_value.withComponent(unit, index * step));
  }

  void _onTextChanged(LdDurationUnit unit, String raw) {
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      return;
    }
    final step = widget.config.stepFor(unit);
    final max = widget.config.maxValue(unit);
    var next = parsed.clamp(0, max);
    if (step > 1) {
      next = ((next / step).round() * step).clamp(0, max - (max % step));
    }
    _emit(_value.withComponent(unit, next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context);
    final presets = widget.config.resolvedPresets;
    final gap = theme.paddingSize(size: LdSize.s);

    return LdAutoSpace(
      children: [
        LdText.hs(
          ldFormatDuration(_value, l10n: l10n, compact: false),
        ),
        if (presets.isNotEmpty)
          Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final preset in presets)
                LdButton.ghost(
                  active: widget.config.constrain(preset) == _value,
                  size: LdSize.s,
                  onPressed: () => _emit(preset),
                  child: Text(ldFormatDuration(preset, l10n: l10n, compact: true)),
                ),
            ],
          ),
        Row(
          children: [
            for (var i = 0; i < _units.length; i++) ...[
              if (i > 0) ldSpacerS,
              Expanded(child: _buildWheel(context, _units[i])),
            ],
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < _units.length; i++) ...[
              if (i > 0) ldSpacerS,
              Expanded(child: _buildInput(context, _units[i], l10n)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWheel(BuildContext context, LdDurationUnit unit) {
    final theme = LdTheme.of(context);
    final step = widget.config.stepFor(unit);
    final count = widget.config.wheelItemCount(unit);
    return Container(
      height: 128,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.border,
          width: theme.borderWidth,
        ),
        borderRadius: theme.radius(LdSize.s),
        color: theme.surface,
      ),
      child: CupertinoPicker(
        scrollController: _wheelControllers[unit],
        selectionOverlay: Container(),
        squeeze: 1.4,
        itemExtent: 32,
        useMagnifier: true,
        onSelectedItemChanged: (index) => _onWheelChanged(unit, index),
        children: List.generate(count, (index) {
          final label = (index * step).toString().padLeft(2, '0');
          return Container(
            height: 32,
            padding: const EdgeInsets.all(4),
            color: theme.surface,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    LdDurationUnit unit,
    LiquidLocalizations l10n,
  ) {
    final isFirst = unit == _units.first;
    return LdInput(
      hint: ldDurationUnitHint(unit, l10n),
      autofocus: isFirst && LdTheme.of(context).platform.isDesktop,
      focusNode: _focusNodes[unit],
      controller: _textControllers[unit],
      size: LdSize.l,
      keyboardType: TextInputType.number,
      onChanged: (text) => _onTextChanged(unit, text),
    );
  }
}
