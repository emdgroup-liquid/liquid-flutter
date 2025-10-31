import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SpacingPaddingDocumentation extends StatelessWidget {
  const SpacingPaddingDocumentation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdBundle(
      children: [
        LdBundle(
          children: [
            LdText.h(
              "💢 Symmetric Padding",
            ),
            LdText.p(
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
            LdText.hs(
              "⚖️ Balanced Padding",
            ),
            LdText.p(
              "You can get a balanced padding (horizontally stronger padded than vertical) using the `balPad` function of the LdTheme.",
            ),
            CodeBlock(code: "LdTheme.of(context).balPad(LdSize.m),"),
            LdHint(
              type: LdHintType.info,
              child: LdText.p(
                ".pad and .balPad will respect the Theme Size and change accordingly",
              ),
            ),
          ],
        ),
        LdBundle(
          children: [
            LdText.h(
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
            LdText.p(
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
              type: LdHintType.info,
              child: LdText.p(
                "LdSpacer will respect the Theme Size and change accordingly",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
