import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/animation.dart';
import 'package:liquid_flutter/src/preview_wrapper.dart';

part 'hint.variants.g.dart';

/// The semantic type of an [LdHint], which controls its color and icon.
enum LdHintType {
  /// Neutral informational message.
  info,

  /// Something requires the user's attention.
  warning,

  /// An operation completed successfully.
  success,

  /// An operation failed or is in an error state.
  error,

  /// An operation was canceled.
  canceled,

  /// An operation is currently in progress.
  loading,

  /// An operation has not started yet.
  pending,

  /// An operation is ongoing (started but not finished).
  ongoing,
}

@LiquidMultiPreview(name: 'LdHint – all types')
Widget ldHintPreview() {
  return LdAutoSpace(
    children: [
      const LdHint(type: LdHintType.info, child: Text('Info')),
      const LdHint(type: LdHintType.warning, child: Text('Warning')),
      const LdHint(type: LdHintType.success, child: Text('Success')),
      const LdHint(type: LdHintType.error, child: Text('Error')),
      const LdHint(type: LdHintType.canceled, child: Text('Canceled')),
      const LdHint(type: LdHintType.loading, child: Text('Loading')),
      const LdHint(type: LdHintType.pending, child: Text('Pending')),
      const LdHint(type: LdHintType.ongoing, child: Text('Ongoing')),
    ],
  );
}

@LiquidMultiPreview(name: 'LdHint – with background')
Widget ldHintWithBackgroundPreview() {
  return LdAutoSpace(
    children: [
      const LdHint(type: LdHintType.info, withBackground: true, child: Text('Info')),
      const LdHint(type: LdHintType.warning, withBackground: true, child: Text('Warning')),
      const LdHint(type: LdHintType.success, withBackground: true, child: Text('Success')),
      const LdHint(type: LdHintType.error, withBackground: true, child: Text('Error')),
    ],
  );
}

/// A status indicator paired with an optional text label.
///
/// [LdHint] combines an [LdIndicator] icon with a text child to communicate
/// the state of an operation or piece of content. The color and icon are
/// driven by the [type] parameter.
///
/// ## Basic usage
///
/// ```dart
/// LdHint(
///   type: LdHintType.success,
///   child: const Text('Saved successfully'),
/// )
/// ```
///
/// ## All types
///
/// <!-- demo:LdHintVariants -->
///
/// ## With background
///
/// Set [withBackground] to `true` to add a tinted background and border,
/// useful for drawing attention to the hint inside a form or card.
///
/// <!-- demo:LdHintWithBackground -->
@Variants([
  Variant('info', defaults: {'type': 'LdHintType.info'}),
  Variant('warning', defaults: {'type': 'LdHintType.warning'}),
  Variant('success', defaults: {'type': 'LdHintType.success'}),
  Variant('error', defaults: {'type': 'LdHintType.error'}),
  Variant('canceled', defaults: {'type': 'LdHintType.canceled'}),
  Variant('loading', defaults: {'type': 'LdHintType.loading'}),
  Variant('pending', defaults: {'type': 'LdHintType.pending'}),
  Variant('ongoing', defaults: {'type': 'LdHintType.ongoing'}),
])
class _LdHintWidget extends StatelessWidget {
  /// The label or content displayed next to the indicator icon.
  final Widget? child;

  /// Controls the color and icon of the hint.
  final LdHintType type;

  /// Size of the indicator and label text. Defaults to [LdSize.m].
  final LdSize size;

  /// How the icon and text are aligned on the cross axis.
  /// Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// When `true`, renders a tinted background and border around the hint.
  final bool withBackground;

  /// When `true`, the hint will animate in.
  final bool animate;

  const _LdHintWidget({
    this.child,
    required this.type,
    this.withBackground = false,
    this.animate = false,
    this.size = LdSize.m,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  Color _getColor(LdTheme theme) => switch (type) {
        LdHintType.error => theme.errorColor,
        LdHintType.info || LdHintType.loading || LdHintType.pending || LdHintType.ongoing => theme.primaryColor,
        LdHintType.success => theme.successColor,
        LdHintType.warning => theme.warningColor,
        LdHintType.canceled => theme.surface,
      };

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Container(
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
      padding: withBackground ? theme.pad() : null,
      decoration: withBackground
          ? BoxDecoration(
              borderRadius: theme.radius(LdSize.s),
              color: _getColor(theme).withAlpha(20),
              border: Border.all(color: _getColor(theme).withAlpha(100)),
            )
          : null,
      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAxisAlignment, children: [
        LdIndicator(
          type: switch (type) {
            LdHintType.error => LdIndicatorType.error,
            LdHintType.info => LdIndicatorType.info,
            LdHintType.success => LdIndicatorType.success,
            LdHintType.warning => LdIndicatorType.warning,
            LdHintType.canceled => LdIndicatorType.canceled,
            LdHintType.loading => LdIndicatorType.loading,
            LdHintType.pending => LdIndicatorType.pending,
            LdHintType.ongoing => LdIndicatorType.ongoing,
          },
        ).conditionallyAnimateScaleXY(animate),
        if (child != null) ...[
          Flexible(
            child: DefaultTextStyle(
              style: ldBuildTextStyle(
                theme,
                LdTextType.paragraph,
                LdSize.m,
                lineHeight: 1.2,
              ),
              child: child!,
            ),
          ),
        ]
      ]).spaceS(),
    );
  }
}

/// Draws an i in emd shapes
class LdInfoIcon extends StatelessWidget {
  const LdInfoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const RotatedBox(quarterTurns: 2, child: LdExclamationIcon());
  }
}

/// An exclamation icon in emd shapes
class LdExclamationIcon extends StatelessWidget {
  const LdExclamationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;

    var size = style.fontSize ?? 14.0;

    return SizedBox(
      height: size,
      width: size,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size * 0.15),
                  bottomLeft: Radius.circular(size * 0.15),
                )),
            height: size * 0.60,
            width: size * 0.25,
          ),
          SizedBox(height: size * 0.12),
          Container(
            decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(size * 0.15)),
            height: size * 0.25,
            width: size * 0.25,
          )
        ],
      ),
    );
  }
}

/// A cross icon.
class LdCrossIcon extends StatelessWidget {
  const LdCrossIcon({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle style = DefaultTextStyle.of(context).style;

    var size = style.fontSize ?? 14.0;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: -0.25 * pi,
              child: Container(
                decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(size * 0.2)),
                height: size * 1,
                width: size * 0.2,
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: 0.25 * pi,
              child: Container(
                decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(size * 0.2)),
                height: size * 1,
                width: size * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
