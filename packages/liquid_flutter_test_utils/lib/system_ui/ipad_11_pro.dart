import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

final iPadPro11 = LdFrameOptions(
  width: 834,
  label: 'iPadPro11',
  height: 1210,
  viewPaddig: EdgeInsets.all(25),
  targetPlatform: TargetPlatform.iOS,
  screenRadius: 30,
  build: (
    BuildContext context,
    Orientation orientation,
    Widget child,
    bool dark,
    SystemUiOverlayStyle navigationBarStyle,
  ) {
    return Stack(
      children: [
        child,
        _StatusBar(
          style: navigationBarStyle,
        ),
        _WindowHandle(
          style: navigationBarStyle,
        ),
      ],
    );
  },
);

class _WindowHandle extends StatelessWidget {
  const _WindowHandle({
    required this.style,
  });

  final SystemUiOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.5),
        child: Icon(
          Icons.more_horiz,
          size: 28,
          color: (style.statusBarIconBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black)
              .withAlpha(200),
        ),
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
    final statusHeight = 10.0;
    final statusTop = 8.0;
    return Container(
      padding: EdgeInsets.only(left: 28, right: 28, top: statusTop),
      color: style.statusBarColor ?? Colors.transparent,
      child: Row(
        children: [
          SvgPicture.asset(
            height: statusHeight,
            package: 'liquid_flutter_test_utils',
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_left_light.svg'
                : 'assets/status_bar_left_dark.svg',
          ),
          Spacer(),
          SvgPicture.asset(
            height: statusHeight,
            package: 'liquid_flutter_test_utils',
            style.statusBarIconBrightness == Brightness.light
                ? 'assets/status_bar_right_light.svg'
                : 'assets/status_bar_right_dark.svg',
          ),
        ],
      ),
    );
  }
}
