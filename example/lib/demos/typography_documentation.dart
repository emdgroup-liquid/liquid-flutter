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
    return const ComponentPage(
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
              LdTextHl("Headline Large"),
              LdTextH("Headline Medium"),
              LdTextHs("Headline Small"),
              LdTextHxs("Headline Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdTextPl("Paragraph Large"),
              LdTextP("Paragraph Medium"),
              LdTextPs("Paragraph Small"),
              LdTextPxs("Paragraph Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdTextLl("Label Large"),
              LdTextL("Label Medium"),
              LdTextLs("Label Small"),
              LdTextLxs("Label Extra Small"),
            ],
          ),
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdTextCaption("Caption"),
            ],
          ),
        ),
        LdTextP("You can also use the LdMute widget to create a muted text."),
        CodeBlock(
          code: """
            LdMute(
              child: LdText("Muted Text"),
            );
          """,
        ),
        LdTextP(
            "There are also utility constructors for creating text with a specific size and type."),
        CodeBlock(code: """
          LdTextHl("LdTextHl L Headline"),
          LdTextH("LdTextHm M Headline"),
          LdTextHs("LdTextHs S Headline"),
          LdTextHxs("LdTextHxs XS Headline"),
          
          LdTextPl("LdTextPl Paragraph Large"),
          LdTextP("LdTextP Paragraph Medium"),
          LdTextPs("LdTextPs Paragraph Small"),
          LdTextPxs("LdTextPxs Paragraph Extra Small"),

          LdTextLl("LdTextLl L Label"),
          LdTextL("LdTextL M Label"),
          LdTextLs("LdTextLs S Label"),
          LdTextLxs("LdTextLxs XS Label"),
"""),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdTextCaption("This is the caption"),
              LdTextHl("The big headline is very big"),
              LdTextHs("Make sure you read this story \nto the end"),
              LdTextP(
                  "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
            ],
          ),
        ),
      ]),
    );
  }
}
