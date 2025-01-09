import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SpacingPaddingDocumentation extends StatelessWidget {
  const SpacingPaddingDocumentation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LdBundle(
      children: [
        LdBundle(
          children: [
            LdTextH(
              "💢 Symmetric Padding",
            ),
            LdTextP(
              "You can get a symmetric padding (same padding on all sides) using the `pad` function of the LdTheme.",
            ),
            CodeBlock(
              code: """
          LdTheme.of(context).pad(LdSize.m),
        """,
            ),
          ],
        ),
        LdBundle(
          children: [
            LdTextHs(
              "⚖️ Balanced Padding",
            ),
            LdTextP(
              "You can get a balanced padding (horizontally stronger padded than vertical) using the `balPad` function of the LdTheme.",
            ),
            CodeBlock(code: "LdTheme.of(context).balPad(LdSize.m),"),
            LdHint(
              child: LdTextP(
                ".pad and .balPad will respect the Theme Size and change accordingly",
              ),
              type: LdHintType.info,
            ),
          ],
        ),
        LdBundle(
          children: [
            LdTextH(
              "Spacing",
            ),
            ComponentsAccordion(components: {"LdSpacer"}),
            MarkdownBody(
              data: "To space elements you can use the `LdSpacer` widget.",
            ),
            CodeBlock(code: """
            LdSpacer(
              size: LdSize.m,
              // optionally specify a direction to only space in one axis
              direction: Axis.horizontal,
            );
                  """),
            LdTextP(
              "for convenience, there are also preconfigured spacers:",
            ),
            CodeBlock(code: """
            ldSpacerXS,
            ldSpacerS,
            ldSpacerM,
            ldSpacerL,
            
            ldHSpacerXS,
            ldHSpacerS,
            ldHSpacerM,
            ldHSpacerL,
            
            ldVSpacerXS,
            ldVSpacerS,
            ldVSpacerM,
            ldVSpacerL,
                  """),
            LdHint(
              child: LdTextP(
                "LdSpacer will respect the Theme Size and change accordingly",
              ),
              type: LdHintType.info,
            ),
          ],
        ),
      ],
    );
  }
}
