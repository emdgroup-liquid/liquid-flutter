import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

final iPhone16Pro = LdFrameOptions(
  label: 'iPhone16Pro',
  viewPaddig: EdgeInsets.only(top: 44, bottom: 34),
  width: 393,
  height: 852,
  targetPlatform: TargetPlatform.iOS,
  screenRadius: 55,
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
            child: _HomeIndicator(
              dark: dark,
            ),
          ),
        ] else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _DynamicIsland(orientation: orientation),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _HomeIndicator(
              dark: dark,
            ),
          ),
        ],
      ],
    );
  },
);

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland({
    this.orientation = Orientation.portrait,
  });

  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    Size dimensions = Size(125, 37);

    if (orientation == Orientation.landscape) {
      dimensions = Size(dimensions.height, dimensions.width);
    }

    return Container(
      margin: EdgeInsets.all(11),
      width: dimensions.width,
      height: dimensions.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(dimensions.height)),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.style,
  });

  final SystemUiOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    final notchMiddle = (37 + 12) / 2;
    final statusHeight = 13.0;
    final statusTop = notchMiddle;
    return Container(
      padding: EdgeInsets.only(left: 32, right: 32, top: statusTop),
      color: style.statusBarColor ?? Colors.transparent,
      child: Row(
        children: [
          SvgPicture.asset(
            package: 'liquid_flutter_test_utils',
            height: statusHeight,
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_left_light.svg'
                : 'assets/status_bar_left_dark.svg',
          ),
          Expanded(
            child: SizedBox.shrink(),
          ),
          SvgPicture.asset(
            package: 'liquid_flutter_test_utils',
            height: statusHeight,
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_right_light.svg'
                : 'assets/status_bar_right_dark.svg',
          ),
        ],
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator({
    required this.dark,
  });

  final bool dark;
  @override
  Widget build(BuildContext context) {
    final indicator = SvgPicture.asset(
      fit: BoxFit.fitWidth,
      package: 'liquid_flutter_test_utils',
      // invert to have contrast
      !dark
          ? 'assets/home_indicator_dark.svg'
          : 'assets/home_indicator_light.svg',
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: indicator,
    );
  }
}
