import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAnimatedLoadingGradient extends StatefulWidget {
  final double height;
  final double? width;

  const LdAnimatedLoadingGradient({Key? key, this.width, required this.height})
      : super(key: key);

  @override
  _LdAnimatedLoadingGradientState createState() =>
      _LdAnimatedLoadingGradientState();
}

class _LdAnimatedLoadingGradientState extends State<LdAnimatedLoadingGradient> {
  late List<Color> colorList = [];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  late Color bottomColor;
  late Color topColor;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  void initState() {
    super.initState();
    final theme = LdTheme.of(context);
    colorList = [
      theme.palette.neutral.relative(theme.isDark, 2),
      theme.palette.neutral.relative(theme.isDark, 3),
      theme.palette.neutral.relative(theme.isDark, 4),
    ];
    bottomColor = colorList[0];
    topColor = colorList[1];
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          index++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bottomColor = colorList[index % colorList.length];
    topColor = colorList[(index + 1) % colorList.length];

    final theme = LdTheme.of(context);

    return AnimatedContainer(
      height: widget.height,
      curve: Curves.easeInOut,
      width: widget.width,
      duration: const Duration(seconds: 2),
      onEnd: () {
        setState(() {
          index++;

          //// animate the alignment
          // begin = alignmentList[index % alignmentList.length];
          // end = alignmentList[(index + 2) % alignmentList.length];
        });
      },
      decoration: BoxDecoration(
        borderRadius: theme.radius(LdSize.s),
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [bottomColor, topColor],
        ),
      ),
    );
  }
}
