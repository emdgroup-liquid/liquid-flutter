import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdTextListType {
  bulleted,
  enumerated,
}

class LdTextList extends StatelessWidget {
  final List<String> items;
  final LdTextListType type;
  final LdSize size;
  final Color? color;
  final double? lineHeight;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LdTextList(
    this.items, {
    Key? key,
    this.type = LdTextListType.bulleted,
    this.size = LdSize.m,
    this.color,
    this.lineHeight,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final LdMute? ldMute = context.findAncestorWidgetOfExactType<LdMute>();

    final textStyle = ldBuildTextStyle(
      theme,
      LdTextType.paragraph,
      size,
      color: color ?? (ldMute != null ? theme.textMuted : null),
      lineHeight: lineHeight,
      fontWeight: fontWeight,
    );

    final List<TextSpan> spans = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Add bullet or number
      spans.add(
        TextSpan(
          text: _getBulletOrNumber(i),
          style: textStyle,
        ),
      );

      // Add space after bullet/number
      spans.add(
        TextSpan(
          text: '  ',
          style: textStyle,
        ),
      );

      // Add the item text
      spans.add(
        TextSpan(
          text: item,
          style: textStyle,
        ),
      );

      // Add line break if not the last item
      if (i < items.length - 1) {
        spans.add(
          TextSpan(
            text: '\n',
            style: textStyle,
          ),
        );
      }
    }

    return Padding(
      padding: LdTheme.of(context).pad(size: size.adjust(-1)).copyWith(bottom: 0, top: 0, right: 0),
      child: RichText(
        text: TextSpan(
          children: spans,
        ),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        textDirection: TextDirection.ltr,
      ),
    );
  }

  String _getBulletOrNumber(int index) {
    switch (type) {
      case LdTextListType.bulleted:
        return '•';
      case LdTextListType.enumerated:
        return '${index + 1}.';
    }
  }
}
