part of 'text.dart';

class LdText extends StatelessWidget {
  const LdText(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.size = LdSize.m,
    this.type = LdTextType.paragraph,
    this.onLinkTap,
    this.fontWeight,
    this.lineHeight,
    this.processLinks = false,
    this.color,
  });

  factory LdText.p(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: size,
      type: LdTextType.paragraph,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.pl(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.l,
      type: LdTextType.paragraph,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.ps(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.s,
      type: LdTextType.paragraph,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.pxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.xs,
      type: LdTextType.paragraph,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.hl(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.l,
      type: LdTextType.headline,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.h(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.m,
      type: LdTextType.headline,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.hs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.s,
      type: LdTextType.headline,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.hxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.xs,
      type: LdTextType.headline,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.l(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: size,
      type: LdTextType.label,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.ls(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.s,
      type: LdTextType.label,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.ll(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.l,
      type: LdTextType.label,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.lxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: LdSize.xs,
      type: LdTextType.label,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

  factory LdText.caption(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) {
    return LdText(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: size,
      type: LdTextType.caption,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return LdTextWidget(
      text,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      decoration: decoration,
      size: size,
      type: type,
      onLinkTap: onLinkTap,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      processLinks: processLinks,
      color: color,
    );
  }
}
