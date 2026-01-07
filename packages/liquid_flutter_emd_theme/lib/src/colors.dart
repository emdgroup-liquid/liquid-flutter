import 'dart:ui';

import 'package:liquid_flutter/liquid_flutter.dart';

const richBlue = LdColor(
  [
    Color.fromRGBO(244, 250, 255, 1),
    Color.fromRGBO(236, 245, 252, 1),
    Color.fromRGBO(216, 234, 248, 1),
    Color.fromRGBO(173, 210, 241, 1),
    Color.fromRGBO(129, 187, 233, 1),
    Color.fromRGBO(80, 160, 222, 1),
    Color.fromRGBO(43, 141, 216, 1),
    Color.fromRGBO(15, 105, 175, 1),
    Color.fromRGBO(8, 88, 151, 1),
    Color.fromRGBO(10, 59, 97, 1),
    Color.fromRGBO(0, 28, 56, 1),
  ],
  7,
  5,
);

const richGreen = LdColor([
  Color.fromRGBO(244, 251, 248, 1),
  Color.fromRGBO(222, 251, 228, 1),
  Color.fromRGBO(198, 244, 205, 1),
  Color.fromRGBO(139, 233, 154, 1),
  Color.fromRGBO(121, 221, 149, 1),
  Color.fromRGBO(80, 192, 115, 1),
  Color.fromRGBO(48, 164, 90, 1),
  Color.fromRGBO(1, 136, 76, 1),
  Color.fromRGBO(4, 100, 46, 1),
  Color.fromRGBO(5, 76, 32, 1),
  Color.fromRGBO(0, 45, 14, 1),
], 5, 7);

const richPurple = LdColor([
  Color.fromRGBO(250, 247, 255, 1),
  Color.fromRGBO(242, 236, 253, 1),
  Color.fromRGBO(235, 228, 252, 1),
  Color.fromRGBO(212, 195, 248, 1),
  Color.fromRGBO(192, 155, 251, 1),
  Color.fromRGBO(158, 126, 224, 1),
  Color.fromRGBO(138, 104, 210, 1),
  Color.fromRGBO(113, 78, 187, 1),
  Color.fromRGBO(80, 50, 145, 1),
  Color.fromRGBO(60, 34, 116, 1),
  Color.fromRGBO(35, 24, 61, 1),
], 7, 5);

const richRed = LdColor([
  Color.fromRGBO(255, 246, 248, 1),
  Color.fromRGBO(255, 237, 238, 1),
  Color.fromRGBO(255, 218, 220, 1),
  Color.fromRGBO(255, 179, 184, 1),
  Color.fromRGBO(244, 137, 150, 1),
  Color.fromRGBO(250, 97, 120, 1),
  Color.fromRGBO(244, 58, 102, 1),
  Color.fromRGBO(230, 30, 80, 1),
  Color.fromRGBO(172, 21, 59, 1),
  Color.fromRGBO(117, 12, 36, 1),
  Color.fromRGBO(75, 5, 23, 1),
], 5, 7);

const vibrantCyan = LdColor([
  Color.fromRGBO(248, 253, 254, 1),
  Color.fromRGBO(221, 252, 255, 1),
  Color.fromRGBO(191, 242, 247, 1),
  Color.fromRGBO(125, 225, 236, 1),
  Color.fromRGBO(83, 212, 225, 1),
  Color.fromRGBO(45, 190, 205, 1),
  Color.fromRGBO(8, 163, 176, 1),
  Color.fromRGBO(0, 132, 144, 1),
  Color.fromRGBO(0, 99, 108, 1),
  Color.fromRGBO(1, 66, 72, 1),
  Color.fromRGBO(0, 31, 35, 1),
], 5, 5);

const vibrantGreen = LdColor([
  Color.fromRGBO(250, 253, 242, 1),
  Color.fromRGBO(233, 248, 203, 1),
  Color.fromRGBO(221, 238, 184, 1),
  Color.fromRGBO(194, 221, 136, 1),
  Color.fromRGBO(165, 205, 80, 1),
  Color.fromRGBO(110, 159, 0, 1),
  Color.fromRGBO(89, 131, 0, 1),
  Color.fromRGBO(82, 121, 0, 1),
  Color.fromRGBO(58, 86, 1, 1),
  Color.fromRGBO(41, 60, 0, 1),
  Color.fromRGBO(18, 31, 0, 1),
], 4, 4);

const vibrantMagenta = LdColor([
  Color.fromRGBO(255, 245, 250, 1),
  Color.fromRGBO(255, 236, 241, 1),
  Color.fromRGBO(255, 216, 229, 1),
  Color.fromRGBO(255, 176, 206, 1),
  Color.fromRGBO(255, 141, 200, 1),
  Color.fromRGBO(230, 97, 166, 1),
  Color.fromRGBO(235, 60, 150, 1),
  Color.fromRGBO(190, 34, 123, 1),
  Color.fromRGBO(150, 16, 91, 1),
  Color.fromRGBO(108, 9, 63, 1),
  Color.fromRGBO(62, 0, 32, 1),
], 5, 6);

const vibrantYellow = LdColor([
  Color.fromRGBO(254, 251, 245, 1),
  Color.fromRGBO(255, 243, 217, 1),
  Color.fromRGBO(253, 229, 166, 1),
  Color.fromRGBO(255, 200, 50, 1),
  Color.fromRGBO(228, 182, 56, 1),
  Color.fromRGBO(191, 140, 0, 1),
  Color.fromRGBO(163, 115, 3, 1),
  Color.fromRGBO(128, 90, 3, 1),
  Color.fromRGBO(97, 69, 5, 1),
  Color.fromRGBO(61, 46, 10, 1),
  Color.fromRGBO(39, 30, 7, 1),
], 4, 4);

final emdLightBlue = LdPalette(
  isDark: false,
  primary: richBlue,
  secondary: vibrantCyan,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);

final emdDarkBlue = LdPalette(
  isDark: true,
  primary: richBlue,
  secondary: vibrantCyan,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);

final emdDarkForest = LdPalette(
  isDark: true,
  primary: richGreen,
  secondary: vibrantGreen,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);

final emdDarkPurple = LdPalette(
  isDark: true,
  primary: richPurple,
  secondary: vibrantMagenta,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);

final emdLightPurple = LdPalette(
  isDark: false,
  primary: richPurple,
  secondary: vibrantYellow,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);

final emdNightRunner = LdPalette(
  isDark: true,
  primary: richRed,
  secondary: vibrantMagenta,
  success: richGreen,
  warning: vibrantYellow,
  error: richRed,
);
