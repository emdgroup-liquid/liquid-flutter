import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/spacer.dart';
import 'package:liquid_flutter/src/text.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';

/// A label for a form field. This is a convenience widget that wraps a [Text]
/// and [ldSpacerS]. THIS WIDGET contains outer padding.!
class LdFormLabel extends StatelessWidget {
  final String? label;
  final LdSize size;

  final bool disabled;

  final Axis direction;

  const LdFormLabel({
    this.label,
    required this.size,
    this.direction = Axis.vertical,
    this.disabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const SizedBox.shrink();
    }

    Widget text = LdText(
      label!,
      size: size,
      type: LdTextType.label,
      color: disabled ? LdTheme.of(context, listen: true).textMuted : null,
    );

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [text, LdSpacer(size: size)],
      );
    } else {
      return Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LdSpacer(size: size),
          Flexible(child: text),
        ],
      );
    }
  }
}
