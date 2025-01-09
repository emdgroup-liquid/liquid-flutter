import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid/chemical_screen.dart';
import 'package:liquid/code_block.dart';

import 'package:go_router/go_router.dart';
import 'package:liquid/window/drawer.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final background = theme.background;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      primary: true,
      child: LdContainer(
        child: LdAutoSpace(
          children: [
            Container(
              decoration: BoxDecoration(
                color: background,
              ),
              padding: EdgeInsets.zero,
              child: AspectRatio(
                aspectRatio: 4 / 2,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ClipRect(
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Stack(
                        children: [
                          Transform(
                            filterQuality: FilterQuality.high,
                            transform: Matrix4.identity()
                              ..rotateX(-0.8)
                              ..rotateZ(-0.4)
                              ..translate(-80.0, 200.0, 1.0),
                            child: Transform.scale(
                              alignment: Alignment.topLeft,
                              scale: 0.8,
                              child: const LdCard(
                                expandChild: true,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          height: 1000,
                                          width: 2000,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: 250,
                                                  child:
                                                      MainNavigationDrawer()),
                                              Expanded(child: ChemicalScreen()),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                background.withAlpha(0),
                                background.withAlpha(200),
                                background
                              ],
                              stops: const [0, 0.8, 0.85],
                            ),
                          )))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ldSpacerL,
            const LdDivider(),
            ldSpacerL,
            Row(
              children: [
                Container(
                  child: Image.asset("liquid_flutter_icon.jpg",
                      width: 48, height: 48),
                  decoration:
                      BoxDecoration(borderRadius: theme.radius(LdSize.m)),
                  clipBehavior: Clip.hardEdge,
                ),
                ldSpacerM,
                const Flexible(
                  child: LdAutoSpace(
                    children: [
                      LdTextHl(
                        "Liquid Flutter",
                      ),
                      LdTextL(
                        "Cross platform design system for Flutter.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LdTag(
                  child: Text("Web"),
                ),
                LdTag(
                  child: Text("MacOS"),
                ),
                LdTag(
                  child: Text("Windows"),
                ),
                LdTag(
                  child: Text("Linux"),
                ),
                LdTag(
                  child: Text("Android"),
                ),
                LdTag(
                  child: Text("iOS"),
                ),
              ],
            ),
            const LdTextP(
              "Liquid Flutter is a Flutter implementation of the liquid "
              "design system used at EMD. "
              "It is designed to be used in desktop and mobile applications."
              " While the design system is licensed under Apache 2.0 please "
              "note that EMD Branding elements are provided with a"
              "proprietary license.",
            ),
            const LdDivider(),
            ldSpacerL,
            const LdTextHs("Demos"),
            Wrap(spacing: 8, runSpacing: 8, children: [
              LdButton(
                  child: const Text("Chemical Inventory"),
                  mode: LdButtonMode.outline,
                  trailing: const Icon(LdIcons.arrow_right),
                  onPressed: () {
                    context.go("/chemical");
                  }),
              LdButton(
                child: const Text("Task Demo"),
                mode: LdButtonMode.outline,
                trailing: const Icon(LdIcons.arrow_right),
                onPressed: () {
                  context.go("/task-demo");
                },
              ),
            ]),
            const LdDivider(),
            const LdTextH("Getting Started"),
            const LdTextP(
              "To get started using liquid flutter please add it as a dependency to your project:",
            ),
            const CodeBlock(
              language: "yaml",
              code: """
                dependencies:
                  liquid_flutter:
                    version: ^$ldVersion
                """,
            ),
            LdAccordion.fromList([
              LdAccordionItem(
                  child: const CodeBlock(
                    language: "yaml",
                    code: """
                dependencies:
                  liquid_flutter_emd_theme:
                    version: ^$ldVersion
                """,
                  ),
                  header: const Text("EMD Corporate theme installation"))
            ]),
            const LdTextP(
                "Setup a Liquid Theme at the top of your application. This will  be used to provide the color theme to all components via context."),
            const CodeBlock(
              code: """
                LdThemeProvider(
                  theme: [provide a custom theme here or leave out use the default]
                  child: ...
                )""",
            ),
            const LdTextP(
                "To automatically keep the material theme in sync with the Liquid theme use the LdThemedAppBuilder. This will also rebuild the entire app in case you change the liquid theme at runtime."),
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
            const LdTextP(
                "You can now also access the Liquid theme via the LdTheme.of(context) method. This will return the LdTheme object which contains all the colors and other theme related properties."),
            const CodeBlock(
              code: """var theme = LdTheme.of(context);""",
            ),
            const LdTextP(
              "Some components will require a portal to work. Please add a Portal to your app/screen at the top level.",
            ),
            const CodeBlock(code: "LdPortal(child: Scaffold(...),))"),
            const LdTextP(
              "You can now use the components in your app. Please refer to the documentation for more information.",
            ),
            const LdTextHl("Changing the theme size"),
            const LdTextP(
                "Liquid Flutter supports three different base sizes that try to make it suitable for desktop and mobile use cases. The default size is not the LdSize passed to components directly, rather it scales the entire user interface."
                " This is done to preserve the visual hierarchy of the components. On Desktop LdThemeSize.s is reccomended, on mobile LdThemeSize.m is reccomended."),
            const CodeBlock(
              code: """LdTheme.of(context).setThemeSize(LdThemeSize.s/m/l);""",
            ),
          ],
        ),
      ),
    );
  }
}
