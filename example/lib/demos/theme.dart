import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/color_selector.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/components_accordion.dart';
import 'package:liquid/demos/ld_color_swatches.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';

class ThemeDemo extends StatefulWidget {
  const ThemeDemo({Key? key}) : super(key: key);

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  late LdColor e;

  @override
  void initState() {
    super.initState();
    e = LdTheme.of(context).palette.neutral;
  }

  Color? _selectedShade;

  final colorNames = {
    shadSky: "shadSky",
    shadAmber: "shadAmber",
    shadGreen: "shadGreen",
    shadRed: "shadRed",
    richRed: "richRed",
    richGreen: "richGreen",
    richBlue: "richBlue",
    vibrantYellow: "vibrantYellow",
    vibrantCyan: "vibrantCyan",
    vibrantMagenta: "vibrantMagenta",
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "Theme & Colors",
      apiComponents: const [
        "LdTheme",
        "LdThemeProvider",
        "LdColorNames",
        "LdReactiveColorBundle",
        "LdReactiveColor"
      ],
      demo: LdAutoSpace(
        children: [
          const LdBundle(
            children: [
              LdTextHs("LdTheme"),
              LdTextP(
                "Some more underlying contexts are explained below. For simple usage you can use the LdTheme to handle most of the coloring for you.",
              ),
              ComponentsAccordion(components: {"LdTheme"}),
            ],
          ),
          LdBundle(
            children: [
              const LdTextHs("Color names"),
              const LdTextP(
                "Liquid comes with several predefined colors from the popular ShadCN color palette.",
              ),
              const LdTextP(
                  "For each color there are different shades available. There is a center color (which is  main shade) for each brightness (dark and light)."),
              LdCard(
                child: LdAutoSpace(
                  children: [
                    ColorSelctor(
                        active: e,
                        colors: const {
                          "shadSky": shadSky,
                          "shadAmber": shadAmber,
                          "shadGreen": shadGreen,
                          "shadRed": shadRed,
                        },
                        onChanged: (v) {
                          setState(() {
                            e = v;
                            _selectedShade = null;
                          });
                        }),
                    const LdDivider(),
                    const LdTextP(
                        "EMD Brand Colors (liquid_flutter_emd_theme package (see notes on license))"),
                    ColorSelctor(
                        active: e,
                        colors: const {
                          "richRed": richRed,
                          "richGreen": richGreen,
                          "richBlue": richBlue,
                          "vibrantYellow": vibrantYellow,
                          "vibrantCyan": vibrantCyan,
                          "vibrantMagenta": vibrantMagenta,
                        },
                        onChanged: (v) {
                          setState(() {
                            e = v;
                            _selectedShade = null;
                          });
                        }),
                    const LdDivider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                    height: 32,
                                    child:
                                        Center(child: LdTextL("Dark center"))),
                                LdDivider(),
                                SizedBox(
                                    height: 53,
                                    child: Center(child: LdTextL("Shades"))),
                                LdDivider(),
                                SizedBox(
                                    height: 32,
                                    child:
                                        Center(child: LdTextL("Light center"))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LdSpring(
                                position: e.shades.indexOf(e.center(true)) * 33,
                                builder: (context, state) =>
                                    Transform.translate(
                                  offset: Offset(state.position, 0),
                                  child: const SizedBox(
                                    height: 32,
                                    child: Icon(Icons.arrow_downward),
                                  ),
                                ),
                              ),
                              _buildShades(),
                              LdSpring(
                                position:
                                    e.shades.indexOf(e.center(false)) * 33,
                                builder: (context, state) =>
                                    Transform.translate(
                                  offset: Offset(state.position, 0),
                                  child: const SizedBox(
                                    height: 32,
                                    child: Icon(Icons.arrow_upward),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_selectedShade != null)
                      LdAutoSpace(
                        children: [
                          LdTextHs(
                              "Selected shade: ${e.shades.indexOf(_selectedShade!)}"),
                          CodeBlock(
                            code:
                                "final absoluteColor = ${colorNames[e]}.shades[${e.shades.indexOf(_selectedShade!)}];",
                          ),
                          const LdTextHs("Relative colors:"),
                          const LdTextP(
                              "Use the relative methods to get colors depending on the brightness."),
                          const LdHint(
                              type: LdHintType.warning,
                              child: Text(
                                  "To not oversaturate the dark theme it is recommended to use center offsets where possible.")),
                          CodeBlock(
                            code: "final isDark = false;\n"
                                "final relativeShade = ${colorNames[e]}.relative(isDark,${e.shades.indexOf(_selectedShade!)});\n"
                                "final relativeCenterShade = ${colorNames[e]}.relativeFromCenter(isDark,${e.shades.indexOf(_selectedShade!) - e.shades.indexOf(e.center(false))});",
                          ),
                          CodeBlock(
                            code: "final isDark = true;\n"
                                "final relativeShade = ${colorNames[e]}.relative(isDark,${e.shades.length - 1 - e.shades.indexOf(_selectedShade!)});\n"
                                "final relativeCenterShade = ${colorNames[e]}.relativeFromCenter(isDark,${e.shades.indexOf(_selectedShade!) - e.shades.indexOf(e.center(true))});",
                          ),
                        ],
                      )
                    else
                      const LdHint(
                        type: LdHintType.info,
                        child: LdText(
                          "Select a shade to view more information.",
                        ),
                      )
                  ],
                ),
              ),
              LdColorSwatches(
                color: e,
              ),
            ],
          ),
          const LdBundle(
            children: [
              LdTextH("Reactive values"),
              LdTextP(
                "For common interaction patterns, you can use the "
                "reactive values for each color.",
              ),
              CodeBlock(code: """
                final theme = LdTheme.of(context);
                
                theme.primary.idle(theme.isDark);
                theme.primary.hover(theme.isDark);
                theme.primary.active(theme.isDark);
                theme.primary.focus(theme.isDark);
              """),
            ],
          ),
          const LdBundle(
            children: [
              LdTextH("Global Configuration Flags"),
              LdTextP(
                "Liquid provides several global configuration flags that can be used to customize the behavior of the framework.",
              ),
              CodeBlock(
                code: """
                /// This variable defines whether TextStyle should use the `liquid_flutter`
                /// package prefix when defining the font family.
                ///
                /// If a font is defined in a package, this will be prefixed with
                /// 'packages/package_name/' (e.g. 'packages/cool_fonts/Roboto'). The
                /// prefixing is done by the constructor when the `package` argument is
                /// provided.
                ///
                /// This is particularly useful when:
                /// - You're using a package that provides custom fonts
                /// - You're creating a package that includes custom fonts
                /// - You want to keep your fonts organized in separate packages
                ///
                /// Defaults to true
                var ldIncludeFontPackage = true;
                
                /// This flag is used to disable animations in the library.
                /// This is useful for golden tests, as animations can cause flakiness
                /// and take time until they complete and the screen or widget is stable.
                ///
                /// Defaults to false
                var ldDisableAnimations = false;
                
                /// Whether LiquidFlutter should print debug messages.
                ///
                /// Defaults to [kDebugMode]
                var ldPrintDebugMessages = kDebugMode;
              """,
                expanded: true,
              ),
              LdHint(
                type: LdHintType.info,
                child: LdText(
                  "These flags should be set early in your application's lifecycle, ideally before any widgets are built.",
                ),
              ),
              LdTextP(
                "Example usage in your main.dart file:",
              ),
              CodeBlock(code: """
                // Import the liquid_flutter package
                import 'package:liquid_flutter/liquid_flutter.dart';
                
                void main() {
                  // Configure global flags
                  ldIncludeFontPackage = false;
                  ldDisableAnimations = false;
                  ldPrintDebugMessages = true; 
                  
                  runApp(MyApp());
                }
              """),
            ],
          ),
          const LdBundle(
            children: [
              LdTextH("Building interactive components"),
              LdTextP(
                "To build custom interactive components, you can use the `LdTouchableSurface`. This handles the different states of the component and will automatically change the color based on the theme.",
              ),
              ComponentsAccordion(components: {"LdTouchableSurface"}),
              CodeBlock(
                code: """
                  LdTouchableSurface(
                    onTap: () {
                      // Called when the user taps the surface
                    },
                    // Use the reactive primary color from  the theme.
                    color: LdTheme.of(context).primary,
                    // Builder for your custom component
                    builder: (context, colors, status) => Container(
                        padding: LdTheme.of(context).pad(),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: theme.radius(LdSize.m),
                        ),
                        child: Center(
                          child: Text(
                            "Hello World",
                            // Apply the text color from the color bundle
                            style: TextStyle(color: colors.text, height: 1),
                          ),
                    ))
                  );
                """,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _buildShades() {
    final theme = LdTheme.of(context, listen: true);
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ...e.shades
          .mapIndexed((index, shade) => SizedBox(
                width: 32,
                child: Column(
                  children: [
                    const LdDivider(),
                    SizedBox(
                      height: 53,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: "${shade.toString()} \n",
                            child: LdTouchableSurface(
                              active: _selectedShade == shade,
                              color: e,
                              onTap: () {
                                setState(() {
                                  _selectedShade = shade;
                                });
                              },
                              builder: (context, colors, status) => Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: shade,
                                  border: Border.all(
                                    color: status.active
                                        ? theme.absolute
                                        : theme.border,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const LdDivider(),
                  ],
                ),
              ))
          .toList(),
    ]);
  }
}
