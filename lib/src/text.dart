import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdTextType {
  headline,
  paragraph,
  label,
  caption,
}

TextStyle ldBuildTextStyle(LdTheme theme, LdTextType type, LdSize size,
    {Color? color, double? lineHeight, FontWeight? fontWeight}) {
  if (fontWeight == null) {
    switch (type) {
      case LdTextType.headline:
        fontWeight = FontWeight.w700;
        break;
      case LdTextType.paragraph:
        fontWeight = FontWeight.w400;
        break;
      case LdTextType.label:
        if (size == LdSize.l) {
          fontWeight = FontWeight.w400;
          break;
        }
        fontWeight = FontWeight.w700;
        break;
      case LdTextType.caption:
        fontWeight = FontWeight.w700;
        break;
      default:
        fontWeight = FontWeight.w400;
        break;
    }
  }

  late double fontSize;

  switch (type) {
    case LdTextType.headline:
      fontSize = theme.headlineSize(size);
      break;
    case LdTextType.paragraph:
      fontSize = theme.paragraphSize(size);
      break;
    case LdTextType.label:
    case LdTextType.caption:
      fontSize = theme.labelSize(size);
      break;
  }

  double _lineHeight = lineHeight ?? ldLineHeight(type, size: size);

  if (color == null) {
    switch (type) {
      case LdTextType.caption:
        color = theme.textMuted;
        break;
      default:
        color = theme.text;
        break;
    }
  }

  String fontFamily = theme.fontFamily;

  if (type == LdTextType.headline) {
    fontFamily = theme.headlineFontFamily;
  }

  return TextStyle(
    package: theme.fontFamilyPackage,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    color: color,
    height: _lineHeight,
    decoration: TextDecoration.none,
    fontSize: fontSize,
  );
}

class LdText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? lineHeight;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final FontWeight? fontWeight;
  final Color? color;

  final LdSize size;

  final LdTextType? type;

  const LdText(this.text,
      {Key? key,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.decoration,
      this.size = LdSize.m,
      this.type = LdTextType.paragraph,
      this.fontWeight,
      this.lineHeight,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if there is an LdMute ancestor
    final LdMute? ldMute = context.findAncestorWidgetOfExactType<LdMute>();
    final theme = LdTheme.of(context, listen: true);

    return Text(
      type == LdTextType.caption ? text.toUpperCase() : text,
      style: ldBuildTextStyle(
        LdTheme.of(context, listen: true),
        type ?? LdTextType.paragraph,
        size,
        color: color ?? (ldMute != null ? theme.textMuted : null),
        lineHeight: lineHeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: TextDirection.ltr,
    );
  }
}

double ldLineHeight(LdTextType? type, {LdSize size = LdSize.m}) {
  switch (type) {
    case LdTextType.headline:
      return switch (size) {
        (LdSize.l) => 1.2,
        (LdSize.m) => 1.3,
        (LdSize.s) => 1.4,
        (LdSize.xs) => 1.5,
      };
    case LdTextType.paragraph:
      return switch (size) {
        (LdSize.l) => 1.5,
        (LdSize.m) => 1.6,
        (LdSize.s) => 1.7,
        (LdSize.xs) => 1.8,
      };
    default:
      return 1;
  }
}
/*
double ldResponsiveFontSize(LdSize size, LdTextType? type) {
  switch (type) {
    case LdTextType.paragraph:
      switch (size) {
        case LdSize.l:
          return 18;
        case LdSize.m:
          return 16;
        case LdSize.s:
          return 14;
        default:
          return 12;
      }
    case LdTextType.headline:
      switch (size) {
        case LdSize.l:
          return 32;
        case LdSize.m:
          return 26;
        case LdSize.s:
          return 22;
        default:
          return 18;
      }
    case LdTextType.label:
    case LdTextType.caption:
      switch (size) {
        case LdSize.l:
          return 20;
        case LdSize.m:
          return 14;
        case LdSize.s:
          return 12;
        default:
          return 10;
      }
    default:
      return 16;
  }
}*/
