import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

const _counterTextHeightBehavior =
    TextHeightBehavior(applyHeightToFirstAscent: false);

({double baseline, double lineHeight}) _counterTextMetrics(TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: '0', style: style),
    textDirection: TextDirection.ltr,
    textHeightBehavior: _counterTextHeightBehavior,
  )..layout();

  return (
    baseline: painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
    lineHeight: painter.height,
  );
}

bool _isRollableDigit(String value) {
  return value.length == 1 && value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
}

class _DigitSlot {
  _DigitSlot({
    required this.id,
    required this.digit,
    required this.revealed,
    required this.animateIn,
  });

  final int id;
  String digit;
  bool revealed;
  final bool animateIn;
}

class LdCounter extends StatefulWidget {
  final double value;

  final int precision;
  final TextStyle? style;
  final LdSize size;
  final LdTextType type;
  final int? minDigits;
  final bool inline;

  const LdCounter({
    super.key,
    required this.value,
    this.precision = 0,
    this.style,
    this.size = LdSize.m,
    this.type = LdTextType.headline,
    this.minDigits,
    this.inline = false,
  });

  @override
  State<LdCounter> createState() => _LdCounterState();
}

class _LdCounterState extends State<LdCounter> {
  final List<_DigitSlot> _digits = [];
  bool _ascending = true;
  int _nextId = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _generateDigits();
    _initialized = true;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _ascending = widget.value >= oldWidget.value;
    }
    if (oldWidget.value != widget.value ||
        oldWidget.precision != widget.precision ||
        oldWidget.minDigits != widget.minDigits) {
      _generateDigits();
      setState(() {});
    }
  }

  TextStyle _getStyle() {
    if (widget.style != null) {
      return widget.style!;
    }
    return ldBuildTextStyle(
      LdTheme.of(context),
      widget.type,
      widget.size,
    );
  }

  String _formatValue() {
    final fixed = widget.value.toStringAsFixed(widget.precision);
    final minDigits = widget.minDigits;
    if (minDigits == null) {
      return fixed;
    }

    final decimalIndex = fixed.indexOf('.');
    final integerEnd = decimalIndex == -1 ? fixed.length : decimalIndex;

    var integerPart = fixed.substring(0, integerEnd);
    var sign = '';
    if (integerPart.startsWith('-')) {
      sign = '-';
      integerPart = integerPart.substring(1);
    }

    final paddedInteger = integerPart.padLeft(minDigits, '0');
    final decimalPart = decimalIndex == -1 ? '' : fixed.substring(decimalIndex);

    return '$sign$paddedInteger$decimalPart';
  }

  /// Sync digit slots using right-aligned place values so 9→10 inserts a
  /// leading "1" and rolls the ones place 9→0, instead of remapping indices.
  void _generateDigits() {
    final next = _formatValue().split('');
    final alive = _digits.where((slot) => slot.revealed).toList();

    final common = next.length < alive.length ? next.length : alive.length;
    for (var i = 0; i < common; i++) {
      final aliveIndex = alive.length - 1 - i;
      final nextIndex = next.length - 1 - i;
      alive[aliveIndex].digit = next[nextIndex];
    }

    if (next.length > alive.length) {
      final insertCount = next.length - alive.length;
      for (var i = 0; i < insertCount; i++) {
        _digits.insert(
          i,
          _DigitSlot(
            id: _nextId++,
            digit: next[i],
            revealed: true,
            animateIn: _initialized,
          ),
        );
      }
    } else if (next.length < alive.length) {
      final removeCount = alive.length - next.length;
      for (var i = 0; i < removeCount; i++) {
        alive[i].revealed = false;
      }
    }
  }

  void _removeSlot(int id) {
    final index = _digits.indexWhere((slot) => slot.id == id);
    if (index == -1) {
      return;
    }
    setState(() {
      _digits.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.inline
          ? CrossAxisAlignment.baseline
          : CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        for (final slot in _digits)
          LdReveal(
            key: ValueKey(slot.id),
            revealed: slot.revealed,
            initialRevealed: slot.animateIn ? false : slot.revealed,
            axes: const {Axis.horizontal},
            mass: 8,
            springConstant: 14,
            dampingCoefficient: 16,
            bufferSprings: 3,
            onAnimationEnd: (context, states) {
              if (!slot.revealed) {
                _removeSlot(slot.id);
              }
            },
            child: _LdCounterDigit(
              digit: slot.digit,
              inline: widget.inline,
              style: _getStyle(),
              ascending: _ascending,
            ),
          ),
      ],
    );
  }
}

class _LdCounterDigit extends StatefulWidget {
  final String digit;
  final TextStyle style;
  final bool inline;
  final bool ascending;

  const _LdCounterDigit({
    required this.digit,
    this.inline = false,
    required this.style,
    required this.ascending,
  });

  @override
  State<_LdCounterDigit> createState() => _LdCounterDigitState();
}

class _LdCounterDigitState extends State<_LdCounterDigit> {
  late String _current;
  String? _outgoing;
  String? _incoming;
  Key _springKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _current = widget.digit;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.digit == widget.digit) {
      return;
    }

    final from = _incoming ?? _current;
    _startTransition(from, widget.digit);
  }

  void _startTransition(String from, String to) {
    if (from == to) {
      _current = to;
      _outgoing = null;
      _incoming = null;
      return;
    }

    if (!_isRollableDigit(from) || !_isRollableDigit(to)) {
      setState(() {
        _current = to;
        _outgoing = null;
        _incoming = null;
      });
      return;
    }

    setState(() {
      _outgoing = from;
      _incoming = to;
      _current = to;
      _springKey = UniqueKey();
    });
  }

  void _onRollEnd() {
    if (!mounted || _incoming == null) {
      return;
    }
    setState(() {
      _current = _incoming!;
      _outgoing = null;
      _incoming = null;
    });
  }

  double _textWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textHeightBehavior: _counterTextHeightBehavior,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  Widget _buildDigitText(String text) {
    return Text(
      text,
      style: widget.style,
      textHeightBehavior: _counterTextHeightBehavior,
    );
  }

  Widget _buildDigitCell(String text, {required double height}) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildDigitText(text),
      ),
    );
  }

  Widget _buildRollingContent({
    required double height,
    required double width,
    required double progress,
  }) {
    final outgoing = _outgoing!;
    final incoming = _incoming!;

    // Increment: next digit sits below, content moves up.
    // Decrement: next digit sits above, content moves down.
    final children = widget.ascending
        ? [
            _buildDigitCell(outgoing, height: height),
            _buildDigitCell(incoming, height: height),
          ]
        : [
            _buildDigitCell(incoming, height: height),
            _buildDigitCell(outgoing, height: height),
          ];

    final translateY = widget.ascending
        ? -progress * height
        : -(1 - progress) * height;

    return SizedBox(
      height: height,
      width: width,
      child: ClipRect(
        child: OverflowBox(
          maxHeight: height * 2,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettledContent({
    required double height,
    required double width,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: _buildDigitCell(_current, height: height),
    );
  }

  Widget _wrapInline({
    required Widget child,
    required ({double baseline, double lineHeight}) metrics,
    required double width,
  }) {
    return Baseline(
      baseline: metrics.baseline,
      baselineType: TextBaseline.alphabetic,
      child: SizedBox(
        height: metrics.lineHeight,
        width: width,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _counterTextMetrics(widget.style);
    final height = metrics.lineHeight;
    final rolling = _outgoing != null && _incoming != null;

    if (!rolling) {
      final width = _textWidth(_current);
      final content = _buildSettledContent(height: height, width: width);
      if (widget.inline) {
        return _wrapInline(child: content, metrics: metrics, width: width);
      }
      return content;
    }

    final fromWidth = _textWidth(_outgoing!);
    final toWidth = _textWidth(_incoming!);

    return LdSpring(
      key: _springKey,
      mass: 30,
      springConstant: 8,
      dampingCoefficient: 20,
      initialPosition: 0,
      position: 1,
      onAnimationEnd: (context, state) => _onRollEnd(),
      builder: (context, state, child) {
        final progress = state.position.clamp(0.0, 1.0);
        final width = fromWidth + (toWidth - fromWidth) * progress;
        final content = _buildRollingContent(
          height: height,
          width: width,
          progress: progress,
        );

        if (widget.inline) {
          return _wrapInline(child: content, metrics: metrics, width: width);
        }
        return content;
      },
    );
  }
}

/// Inline text with an animated [LdCounter] between [before] and [after].
///
/// Lays out text and counter on a shared alphabetic baseline so the number sits
/// naturally in a sentence. For custom [RichText], embed [LdCounter] with
/// [LdCounter.inline] in a [WidgetSpan] using
/// [PlaceholderAlignment.baseline] and [TextBaseline.alphabetic], and match the
/// counter [TextStyle] (and preferably [TextHeightBehavior]) to the surrounding
/// spans.
class LdCounterText extends StatelessWidget {
  const LdCounterText({
    required this.value,
    this.before = '',
    this.after = '',
    this.type = LdTextType.paragraph,
    this.size = LdSize.m,
    this.precision = 0,
    this.minDigits,
    this.color,
    this.lineHeight,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  /// Splits [template] on `%value%` and builds an [LdCounterText].
  factory LdCounterText.template(
    String template, {
    required double value,
    LdTextType type = LdTextType.paragraph,
    LdSize size = LdSize.m,
    int precision = 0,
    int? minDigits,
    Color? color,
    double? lineHeight,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Key? key,
  }) {
    const placeholder = '%value%';
    final index = template.indexOf(placeholder);
    if (index == -1) {
      throw ArgumentError.value(
        template,
        'template',
        'Must contain exactly one %value% placeholder',
      );
    }

    return LdCounterText(
      before: template.substring(0, index),
      after: template.substring(index + placeholder.length),
      value: value,
      type: type,
      size: size,
      precision: precision,
      minDigits: minDigits,
      color: color,
      lineHeight: lineHeight,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  final String before;
  final String after;
  final double value;
  final LdTextType type;
  final LdSize size;
  final int precision;
  final int? minDigits;
  final Color? color;
  final double? lineHeight;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final ldMute = context.findAncestorWidgetOfExactType<LdMute>();
    final theme = LdTheme.of(context, listen: true);

    final style = ldBuildTextStyle(
      theme,
      type,
      size,
      color: color ?? (ldMute != null ? theme.textMuted : null),
      lineHeight: lineHeight,
      fontWeight: fontWeight,
    );

    // Row + shared TextHeightBehavior keeps surrounding copy and digits on
    // the same alphabetic baseline (WidgetSpan defaults to bottom alignment).
    return DefaultTextStyle(
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (before.isNotEmpty)
            Text(
              before,
              style: style,
              textHeightBehavior: _counterTextHeightBehavior,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow ?? TextOverflow.clip,
            ),
          LdCounter(
            value: value,
            style: style,
            precision: precision,
            minDigits: minDigits,
            inline: true,
          ),
          if (after.isNotEmpty)
            Text(
              after,
              style: style,
              textHeightBehavior: _counterTextHeightBehavior,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow ?? TextOverflow.clip,
            ),
        ],
      ),
    );
  }
}

/// Animated clock-style duration built from [LdCounter] segments.
///
/// Under one hour shows `MM:SS`. At one hour and above shows `H:MM:SS` (hours
/// unpadded, minutes and seconds always two digits). When [showTenths] is true,
/// appends `.T` as plain text (tenths update too quickly for digit springs).
class LdCounterDuration extends StatelessWidget {
  const LdCounterDuration({
    required this.duration,
    this.style,
    this.size = LdSize.m,
    this.type = LdTextType.headline,
    this.inline = false,
    this.showTenths = false,
    super.key,
  });

  final Duration duration;
  final TextStyle? style;
  final LdSize size;
  final LdTextType type;
  final bool inline;

  /// When true, appends `.T` (plain text tenths digit) after seconds.
  final bool showTenths;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style ??
        ldBuildTextStyle(
          LdTheme.of(context),
          type,
          size,
        );

    final totalMs = duration.isNegative ? 0 : duration.inMilliseconds;
    final totalSeconds = totalMs ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final tenths = (totalMs % 1000) ~/ 100;
    final showHours = hours >= 1;

    Widget plain(String text) {
      return Text(
        text,
        style: resolvedStyle,
        textHeightBehavior: _counterTextHeightBehavior,
      );
    }

    Widget segment(double value, {int? minDigits}) {
      return LdCounter(
        value: value,
        style: resolvedStyle,
        size: size,
        type: type,
        precision: 0,
        minDigits: minDigits,
        inline: inline,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          inline ? CrossAxisAlignment.baseline : CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (showHours) ...[
          segment(hours.toDouble()),
          plain(':'),
        ],
        segment(minutes.toDouble(), minDigits: 2),
        plain(':'),
        segment(seconds.toDouble(), minDigits: 2),
        if (showTenths) plain('.$tenths'),
      ],
    );
  }
}
