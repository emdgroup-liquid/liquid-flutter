import 'package:flutter/gestures.dart';
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

  final bool processLinks;

  final LdSize size;

  final LdTextType? type;

  final void Function(String)? onLinkTap;

  const LdText(this.text,
      {Key? key,
      this.textAlign,
      required this.maxLines,
      this.overflow,
      this.decoration,
      this.size = LdSize.m,
      this.type = LdTextType.paragraph,
      this.onLinkTap,
      this.fontWeight,
      this.lineHeight,
      this.processLinks = false,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if there is an LdMute ancestor
    final LdMute? ldMute = context.findAncestorWidgetOfExactType<LdMute>();
    final theme = LdTheme.of(context, listen: true);

    final text =
        type == LdTextType.caption ? this.text.toUpperCase() : this.text;

    final style = ldBuildTextStyle(
      LdTheme.of(context, listen: true),
      type ?? LdTextType.paragraph,
      size,
      color: color ?? (ldMute != null ? theme.textMuted : null),
      lineHeight: lineHeight,
    );

    if (processLinks) {
      return RichText(
        text: _buildTextSpanWithLinks(
          text,
          style: style,
          theme: theme,
          onTap: (p0) {
            if (onLinkTap != null) {
              onLinkTap!(p0);
            }
          },
        ),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        textDirection: TextDirection.ltr,
      );
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: TextDirection.ltr,
    );
  }
}

TextSpan _buildTextSpanWithLinks(
  String text, {
  TextStyle? style,
  required LdTheme theme,
  void Function(String)? onTap,
}) {
  final List<TextSpan> children = [];
  final RegExp urlRegex = RegExp(
    r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
    caseSensitive: false,
  );

  final RegExp markdownLinkRegex = RegExp(r'\[(.*?)\]\((.*?)\)');

  int lastMatchEnd = 0;
  text.splitMapJoin(
    RegExp('${urlRegex.pattern}|${markdownLinkRegex.pattern}'),
    onMatch: (Match match) {
      final matchedText = match.group(0)!;
      final markdownMatch = markdownLinkRegex.firstMatch(matchedText);

      if (markdownMatch != null) {
        final linkText = markdownMatch.group(1)!;
        final url = markdownMatch.group(2)!;
        children.add(
          TextSpan(
            text: linkText,
            style: style?.copyWith(
              color: theme.primaryColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap(url);
                }
              },
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: matchedText,
            style: style?.copyWith(
              color: theme.primaryColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap(matchedText);
                }
              },
          ),
        );
      }
      lastMatchEnd = match.end;
      return '';
    },
    onNonMatch: (String text) {
      if (text.isNotEmpty) {
        children.add(TextSpan(
          text: text,
          style: style,
        ));
      }
      return '';
    },
  );

  if (lastMatchEnd < text.length) {
    children.add(TextSpan(
      text: text.substring(lastMatchEnd),
      style: style,
    ));
  }

  return TextSpan(children: children);
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
