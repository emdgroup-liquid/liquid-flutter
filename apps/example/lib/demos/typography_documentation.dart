import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class TypographyDocumentation extends StatelessWidget {
  const TypographyDocumentation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/demos/typography_documentation.dart",
      title: "Typography",
      apiComponents: [
        "LdText",
      ],
      demo: LdAutoSpace(children: [
        Text(
            "Liquid uses a set of predefined text styles that can be used to create consistent typography across the app."),
        MarkdownBody(
            data:
                "The LdText widget allows you to create a text with a predefined style."),
        CodeBlock(
          code: """
            LdText(
              "Hello World",
              size: LdSize.m,
              type: LdTextType.label, //   headline, paragraph, label, caption,
            );
          """,
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.hl("Headline Large"),
              LdText.h("Headline Medium"),
              LdText.hs("Headline Small"),
              LdText.hxs("Headline Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.pl("Paragraph Large"),
              LdText.p("Paragraph Medium"),
              LdText.ps("Paragraph Small"),
              LdText.pxs("Paragraph Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.ll("Label Large"),
              LdText.l("Label Medium"),
              LdText.ls("Label Small"),
              LdText.lxs("Label Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.caption("Caption"),
            ],
          ),
        ),
        LdText.p("You can also use the LdMute widget to create a muted text."),
        CodeBlock(
          code: """
            LdMute(
              child: LdText("Muted Text"),
            );
          """,
        ),
        LdText.p(
            "There are also utility constructors for creating text with a specific size and type."),
        CodeBlock(code: """
          LdText.hl("LdText.hl L Headline"),
          LdText.h("LdText.hm M Headline"),
          LdText.hs("LdText.hs S Headline"),
          LdText.hxs("LdText.hxs XS Headline"),
          
          LdText.pl("LdText.pl Paragraph Large"),
          LdText.p("LdText.p Paragraph Medium"),
          LdText.ps("LdText.ps Paragraph Small"),
          LdText.pxs("LdText.pxs Paragraph Extra Small"),

          LdText.ll("LdText.ll L Label"),
          LdText.l("LdText.l M Label"),
          LdText.ls("LdText.ls S Label"),
          LdText.lxs("LdText.lxs XS Label"),
"""),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.caption("This is the caption"),
              LdText.hl("The big headline is very big"),
              LdText.hs("Make sure you read this story \nto the end"),
              LdText.p(
                  "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
            ],
          ),
        ),
      ]),
    );
  }
}
