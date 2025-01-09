// Liquid only provides rem values. These seem appropiate (sm based on actual values from figma)
import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/spacer.dart';
import 'package:liquid_flutter/src/theme/theme.dart';

enum LdSize {
  xs,
  s,
  m,
  l,
}

extension Modifier on LdSize {
  LdSize adjust(int steps) {
    return LdSize.values[(index + steps).clamp(0, LdSize.values.length - 1)];
  }

  LdSize clamp(LdSize min, LdSize max) {
    return LdSize.values[index.clamp(min.index, max.index)];
  }
}

extension LdRadius on LdSize {
  BorderRadius radius(BuildContext context) => LdTheme.of(context).radius(this);
}

// Shadows
BoxShadow ldShadowDefault = const BoxShadow(
  color: Color.fromRGBO(9, 23, 52, 0.15),
  offset: Offset(0, 2),
  blurRadius: 4,
);

BoxShadow ldShadowSticky = const BoxShadow(
  color: Color.fromRGBO(9, 23, 52, 0.15),
  offset: Offset(0, 12),
  blurRadius: 20,
);

BoxShadow ldShadowHover = const BoxShadow(
  color: Color.fromRGBO(9, 23, 52, 0.15),
  offset: Offset(0, 16),
  blurRadius: 32,
);

const ldHSpacerXS = LdSpacer(size: LdSize.xs, direction: Axis.horizontal);
const ldHSpacerS = LdSpacer(size: LdSize.s, direction: Axis.horizontal);
const ldHSpacerM = LdSpacer(size: LdSize.m, direction: Axis.horizontal);
const ldHSpacerL = LdSpacer(size: LdSize.l, direction: Axis.horizontal);

const ldVSpacerXS = LdSpacer(size: LdSize.xs, direction: Axis.vertical);
const ldVSpacerS = LdSpacer(size: LdSize.s, direction: Axis.vertical);
const ldVSpacerM = LdSpacer(size: LdSize.m, direction: Axis.vertical);
const ldVSpacerL = LdSpacer(size: LdSize.l, direction: Axis.vertical);

const ldSpacerXS = LdSpacer(size: LdSize.xs);
const ldSpacerS = LdSpacer(size: LdSize.s);
const ldSpacerM = LdSpacer(size: LdSize.m);
const ldSpacerL = LdSpacer(size: LdSize.l);
