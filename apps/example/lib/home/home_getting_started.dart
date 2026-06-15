import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeGettingStarted extends StatelessWidget {
  const HomeGettingStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdText.h('Getting Started'),
        LdText.p('To get started using liquid flutter please add it as a dependency to your project:'),
        const CodeBlock(language: 'sh', code: """flutter pub add liquid_flutter"""),
        LdAccordion.fromList([
          LdAccordionItem(
            child: const CodeBlock(
              language: 'sh',
              code: """
                flutter pub add liquid_flutter_emd_theme
                """,
            ),
            header: const Text('EMD Corporate theme installation'),
          ),
        ], wrapActiveInCard: true),
        LdText.p(
          'Setup a Liquid Theme at the top of your application. This will  be used to provide the color theme to all components via context.',
        ),
        const CodeBlock(
          code: """
                LdThemeProvider(
                  theme: // Optionally provide an instance of LdTheme(),
                  child: ...
                )""",
        ),
        LdText.p(
          'To automatically keep the material theme in sync with the Liquid theme use the LdThemedAppBuilder. This will also rebuild the entire app in case you change the liquid theme at runtime.',
        ),
        const CodeBlock(
          code: """
                LdThemeProvider(
                  child: LdThemedAppBuilder(appBuilder: (context, theme) {
                    return MaterialApp(
                      title: 'Liquid Design Demo',
                      theme: theme,
                    );
                  })
                )""",
        ),
        LdText.p(
          'You can now also access the Liquid theme via the LdTheme.of(context) method. This will return the LdTheme object which contains all the colors and other theme related properties.',
        ),
        const CodeBlock(code: """var theme = LdTheme.of(context);"""),
        LdText.p('You can now use the components in your app. Please refer to the documentation for more information.'),
      ],
    );
  }
}
