import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

final fairphone6 = LdFrameOptions(
  label: 'Fairphone6',
  viewPaddig: EdgeInsets.only(top: 28, bottom: 20),
  width: 360,
  height: 800,
  platform: LdPlatform.android,
  screenRadius: 24,
  devicePixelRatio: 3.0,
  build: (
    BuildContext context,
    Orientation orientation,
    Widget child,
    bool dark,
    SystemUiOverlayStyle navigationBarStyle,
  ) {
    final isPortrait = orientation == Orientation.portrait;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isPortrait) ...[
          Align(
            alignment: Alignment.topCenter,
            child: _StatusBar(
              style: navigationBarStyle,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _DynamicIsland(orientation: orientation),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _NavigationBar(
              dark: dark,
            ),
          ),
        ] else ...[
          Align(
            alignment: Alignment.topCenter,
            child: _StatusBar(
              style: navigationBarStyle,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _DynamicIsland(orientation: orientation),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _NavigationBar(
              dark: dark,
            ),
          ),
        ],
      ],
    );
  },
);

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.style,
  });

  final SystemUiOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    final statusTop = 12.0;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 24, top: statusTop),
      color: style.statusBarColor ?? Colors.transparent,
      child: Row(
        children: [
          SvgPicture.asset(
            package: 'liquid_flutter_test_utils',
            height: 10,
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_left_android_light.svg'
                : 'assets/status_bar_left_android_dark.svg',
          ),
          Expanded(
            child: SizedBox.shrink(),
          ),
          SvgPicture.asset(
            package: 'liquid_flutter_test_utils',
            height: 14,
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_right_android_light.svg'
                : 'assets/status_bar_right_android_dark.svg',
          ),
        ],
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    // Android gesture navigation indicator
    final indicator = Container(
      width: 120,
      height: 5,
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withAlpha(77) : Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );

    return indicator;
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland({
    this.orientation = Orientation.portrait,
  });

  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    Size dimensions = Size(22, 22);

    if (orientation == Orientation.landscape) {
      dimensions = Size(dimensions.height, dimensions.width);
    }

    return Container(
      margin: EdgeInsets.all(8),
      width: dimensions.width,
      height: dimensions.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(dimensions.height)),
      ),
    );
  }
}
