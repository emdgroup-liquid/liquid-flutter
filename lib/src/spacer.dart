import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

var ldDebugSpacings = false;
var ldDebugSpacingsColor = Colors.blue.withAlpha(100);

class LdSpacer extends StatelessWidget {
  final LdSize size;
  final Axis? direction;

  const LdSpacer({Key? key, required this.size, this.direction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = LdTheme.of(context, listen: true).paddingSize(size: this.size);

    var height = size;
    var width = size;

    if (direction == Axis.vertical) {
      width = 0;
    }

    if (direction == Axis.horizontal) {
      height = 0;
    }

    if (ldDebugSpacings) {
      return Container(
        color: ldDebugSpacingsColor,
        height: height,
        width: width,
      );
    }

    return SizedBox(
      height: height,
      width: width,
    );
  }
}
