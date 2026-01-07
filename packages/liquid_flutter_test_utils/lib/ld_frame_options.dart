import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';

/// Configuration options for creating device frames in golden tests.
///
/// This class defines the appearance and behavior of device frames used to
/// wrap widgets during testing, including dimensions, padding, and UI overlays.
class LdFrameOptions {
  /// An optional label for referencing this frame option in test slugs.
  final String label;

  /// Padding applied to the view inside the frame.
  ///
  /// This represents the safe area insets of the device.
  final EdgeInsets viewPaddig;

  /// Optional builder function to customize the frame's appearance.
  ///
  /// When provided, this function builds the frame UI around the child widget,
  /// allowing for device-specific elements like status bars, notches, etc.
  final Widget Function(
    BuildContext context,
    Orientation orientation,
    Widget child,
    bool dark,
    SystemUiOverlayStyle navigationBarStyle,
  )? build;

  /// The width of the device frame in logical pixels.
  final double width;

  /// The height of the device frame in logical pixels.
  ///
  /// If null, the height will be determined based on the content.
  final double? height;

  /// The corner radius of the device screen in logical pixels.
  ///
  /// If null, no rounding will be applied to the screen corners.
  final double? screenRadius;

  /// The device pixel ratio to use for the frame.
  ///
  /// This affects the rendering density of the frame.
  final double devicePixelRatio;

  final TargetPlatform? targetPlatform;

  /// Creates a configuration for a device frame.
  ///
  /// The [viewPaddig] defaults to [EdgeInsets.zero] if not specified.
  /// The [width] defaults to 500 logical pixels.
  /// The [devicePixelRatio] defaults to 1.0.
  /// The [showBackButton] defaults to false.
  const LdFrameOptions({
    this.label = '',
    this.viewPaddig = EdgeInsets.zero,
    this.build,
    this.width = 500,
    this.height,
    this.devicePixelRatio = 1.0,
    this.screenRadius,
    this.targetPlatform,
  });

  /// Creates a copy of this [LdFrameOptions] but with the given fields replaced
  /// by the new values.
  ///
  /// This is useful for creating modified copies of default configurations (e.g.
  /// [iPhone16Pro]) without having to specify all fields again.
  LdFrameOptions copyWith({
    String? label,
    EdgeInsets? viewPaddig,
    Widget Function(
      BuildContext context,
      Orientation orientation,
      Widget child,
      bool dark,
      SystemUiOverlayStyle navigationBarStyle,
    )? build,
    double? width,
    double? height,
    double? devicePixelRatio,
    double? screenRadius,
    TargetPlatform? targetPlatform,
  }) {
    return LdFrameOptions(
      label: label ?? this.label,
      viewPaddig: viewPaddig ?? this.viewPaddig,
      build: build ?? this.build,
      width: width ?? this.width,
      height: height ?? this.height,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      screenRadius: screenRadius ?? this.screenRadius,
      targetPlatform: targetPlatform ?? this.targetPlatform,
    );
  }
}
