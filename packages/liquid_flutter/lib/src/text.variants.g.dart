part of 'text.dart';

class LdText extends StatelessWidget {
  const LdText(
    this.text, {
    this.color,
    this.decoration,
    this.fontWeight,
    this.lineHeight,
    this.maxLines,
    this.onLinkTap,
    this.overflow,
    this.processLinks = false,
    this.size = LdSize.m,
    this.textAlign,
    this.type = LdTextType.paragraph,
    super.key,
  });

  factory LdText.caption(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: size,
      textAlign: textAlign,
      type: LdTextType.caption,
    );
  }

  factory LdText.h(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.m,
      textAlign: textAlign,
      type: LdTextType.headline,
    );
  }

  factory LdText.hl(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.l,
      textAlign: textAlign,
      type: LdTextType.headline,
    );
  }

  factory LdText.hs(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.s,
      textAlign: textAlign,
      type: LdTextType.headline,
    );
  }

  factory LdText.hxs(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.xs,
      textAlign: textAlign,
      type: LdTextType.headline,
    );
  }

  factory LdText.l(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: size,
      textAlign: textAlign,
      type: LdTextType.label,
    );
  }

  factory LdText.ll(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.l,
      textAlign: textAlign,
      type: LdTextType.label,
    );
  }

  factory LdText.ls(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.s,
      textAlign: textAlign,
      type: LdTextType.label,
    );
  }

  factory LdText.lxs(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.xs,
      textAlign: textAlign,
      type: LdTextType.label,
    );
  }

  factory LdText.p(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: size,
      textAlign: textAlign,
      type: LdTextType.paragraph,
    );
  }

  factory LdText.pl(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.l,
      textAlign: textAlign,
      type: LdTextType.paragraph,
    );
  }

  factory LdText.ps(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.s,
      textAlign: textAlign,
      type: LdTextType.paragraph,
    );
  }

  factory LdText.pxs(
    String text, {
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? lineHeight,
    int? maxLines,
    void Function(String)? onLinkTap,
    TextOverflow? overflow,
    bool processLinks = false,
    LdSize size = LdSize.m,
    TextAlign? textAlign,
    LdTextType? type = LdTextType.paragraph,
    Key? key,
  }) {
    return LdText(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: LdSize.xs,
      textAlign: textAlign,
      type: LdTextType.paragraph,
    );
  }

  final bool processLinks;

  final Color? color;

  final double? lineHeight;

  final FontWeight? fontWeight;

  final int? maxLines;

  final LdSize size;

  final LdTextType? type;

  final String text;

  final TextAlign? textAlign;

  final TextDecoration? decoration;

  final TextOverflow? overflow;

  final void Function(String)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return _LdTextWidget(
      text,
      color: color,
      decoration: decoration,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      maxLines: maxLines,
      onLinkTap: onLinkTap,
      overflow: overflow,
      processLinks: processLinks,
      size: size,
      textAlign: textAlign,
      type: type,
    );
  }
}
