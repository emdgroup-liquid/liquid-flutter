import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid/router.dart';
import 'package:liquid/window/size_selector.dart';
import 'package:liquid/window/theme_selector.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationDrawer extends StatefulWidget {
  final bool persistent;
  const MainNavigationDrawer({Key? key, this.persistent = false})
      : super(key: key);

  @override
  State<MainNavigationDrawer> createState() => _MainNavigationDrawerState();
}

class _Component {
  final String title;
  final String route;
  final IconData icon;
  const _Component(this.title, this.route, this.icon);
}

const components = [
  _Component("Action Runner", "/components/action-runner",
      Icons.settings_backup_restore),
  _Component("Autospace", "/components/autospace", LdIcons.arrow_up_n_down),
  _Component("Accordion", "/components/accordion", LdIcons.arrow_up_n_down),
  _Component("Badge", "/components/badge", Icons.tag),
  _Component("Breadcrumb", "/components/breadcrumb", LdIcons.arrow_right),
  _Component("Button", "/components/button", LdIcons.add),
  _Component("Card", "/components/card", LdIcons.cards),
  _Component("Checkbox", "/components/checkbox", LdIcons.checkmark),
  _Component("Context Menu", "/components/context-menu", Icons.mouse),
  _Component("Choose", "/components/choose", Icons.select_all),
  _Component(
    "Date/Time Picker",
    "/components/date-time-picker",
    Icons.calendar_month,
  ),
  _Component("Divider", "/components/divider", Icons.horizontal_rule),
  _Component("Drawer", "/components/drawer", Icons.menu),
  _Component("Form", "/components/form", LdIcons.pen),
  _Component("Hint", "/components/hint", Icons.info),
  _Component("Icon", "/components/icon", Icons.image),
  _Component("Indicator", "/components/indicator", Icons.warning),
  _Component("Input", "/components/input", LdIcons.pen),
  _Component("List", "/components/list", Icons.list),
  _Component("List Demo", "/components/list-full-screen", Icons.list),
  _Component("Loader", "/components/loader", Icons.donut_large),
  _Component("Notification", "/components/notification", Icons.alarm),
  _Component("Master detail", "/components/master-detail", Icons.list_alt),
  _Component("Modal", "/components/modal", Icons.window),
  _Component("Orb", "/components/orb", Icons.circle),
  _Component("Radio", "/components/radio", Icons.radio_button_checked_rounded),
  _Component("Reveal", "/components/reveal", Icons.remove_red_eye),
  _Component("Select", "/components/select", Icons.arrow_drop_down),
  _Component("Slider", "/components/slider", Icons.touch_app),
  _Component("Submit", "/components/submit", Icons.send),
  _Component("Spring", "/components/spring", Icons.motion_photos_auto),
  _Component("Switch", "/components/switch", Icons.square_rounded),
  _Component("Table", "/components/table", Icons.grid_3x3),
  //_Component("Tabs", "/components/tabs", Icons.tab),
  _Component("Tag", "/components/tag", Icons.tag),
  _Component("Toggle", "/components/toggle", Icons.toggle_on),
];

class _MainNavigationDrawerState extends State<MainNavigationDrawer> {
  AppRouter? appRouter;

  List<_Component> _componentsFiltered = components;

  late TextEditingController _search;

  final _fuzzy = Fuzzy<_Component>(components,
      options: FuzzyOptions(keys: [
        WeightedKey(
          name: "title",
          getter: (e) => e.title,
          weight: 1,
        ),
      ]));

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _search = TextEditingController();
    appRouter = context.read<AppRouter>();

    appRouter?.router.routeInformationProvider.addListener(_routeChange);

    super.initState();
  }

  @override
  void dispose() {
    appRouter?.router.routeInformationProvider.removeListener(_routeChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _routeChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showPage(BuildContext context, String name) {
    if (!widget.persistent) {
      Navigator.of(context).pop();
    }

    context.read<AppRouter>().router.go(name);

    setState(() {});
  }

  void _onSearchChange(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _componentsFiltered = components;
      });
      return;
    }
    setState(() {
      _componentsFiltered = _fuzzy
          .search(
            query,
          )
          .map((e) => e.item)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      backgroundColor: theme.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: theme.border, width: 1),
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverStickyHeader(
              header: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  appWindow.startDragging();
                },
                onDoubleTap: () => appWindow.maximizeOrRestore(),
                child: LdDrawerHeader(
                  scrollController: _scrollController,
                  showBack: !widget.persistent,
                  title: Row(
                    children: [
                      Container(
                        child: Image.asset("liquid_flutter_icon.jpg",
                            width: 32, height: 32),
                        decoration:
                            BoxDecoration(borderRadius: theme.radius(LdSize.m)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      ldSpacerS,
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Liquid Flutter",
                          ),
                          LdTextCaption(ldVersion)
                        ],
                      ),
                    ],
                  ).padM(),
                ),
              ),
              sliver: SliverPadding(
                padding: LdTheme.of(context).pad(),
                sliver: SliverList.list(
                    key: const PageStorageKey('drawer_list_key'),
                    children: [
                      const ThemeSelector(),
                      ldSpacerM,
                      const SizeSelector(),
                      ldSpacerM,
                      const RadiusSelector(),
                      ldSpacerM,
                      const FontSelector(),
                      ldSpacerM,
                      const HeadlineFontSelector(),
                      ldSpacerM,
                      LdAutoSpace(children: [
                        ldSpacerL,
                        LdDrawerItemSection(
                          active: GoRouterState.of(context).uri.path == "/",
                          leading: const Icon(Icons.home),
                          onTap: () => _showPage(context, "/"),
                          child: const Text("Home"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        const LdSectionHeader("Demos"),
                        LdDrawerItemSection(
                          active:
                              GoRouterState.of(context).uri.path == "/chemical",
                          leading: const Icon(LdIcons.beaker),
                          onTap: () => _showPage(context, "/chemical"),
                          child: const Text("Magic"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        LdDrawerItemSection(
                          active: GoRouterState.of(context).uri.path ==
                              "/task-demo",
                          leading: const Icon(Icons.check),
                          onTap: () => _showPage(context, "/task-demo"),
                          child: const Text("Task"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        const LdSectionHeader("Documentation"),
                        LdDrawerItemSection(
                          active:
                              GoRouterState.of(context).uri.path == "/theme",
                          leading: const Icon(Icons.format_paint),
                          onTap: () => _showPage(context, "/theme"),
                          child: const Text("Theme"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        LdDrawerItemSection(
                          active:
                              GoRouterState.of(context).uri.path == "/layout",
                          leading: const Icon(Icons.token),
                          onTap: () => _showPage(context, "/layout"),
                          child: const Text("Layout"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        LdDrawerItemSection(
                          active:
                              GoRouterState.of(context).uri.path == "/radius",
                          leading: const Icon(Icons.rounded_corner),
                          onTap: () => _showPage(context, "/radius"),
                          child: const Text("Border Radius"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        LdDrawerItemSection(
                          active: GoRouterState.of(context).uri.path ==
                              "/typography",
                          leading: const Icon(Icons.text_format),
                          onTap: () => _showPage(context, "/typography"),
                          child: const Text("Typography"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        LdDrawerItemSection(
                          active:
                              GoRouterState.of(context).uri.path == "/material",
                          leading: const Icon(Icons.text_format),
                          onTap: () => _showPage(context, "/material"),
                          child: const Text("Material"),
                          trailing: const Icon(LdIcons.arrow_right),
                        ),
                        const LdSectionHeader("Components"),
                        LdInput(
                          hint: "Search...",
                          controller: _search,
                          onChanged: (query) {
                            _onSearchChange(query ?? "");
                          },
                        ),
                        ..._componentsFiltered.map(
                          (e) => LdDrawerItemSection(
                            child: Text(e.title),
                            active:
                                GoRouterState.of(context).uri.path == e.route,
                            leading: Icon(e.icon),
                            //trailing: Icon(LdIcons.arrow_right),
                            onTap: () => _showPage(context, e.route),
                          ),
                        ),
                        const LdDivider(),
                        LdDrawerItemSection(
                          onTap: () => launchUrl(
                              Uri.parse("https://emd.design/imprint")),
                          child: const Text("Imprint"),
                          trailing: const Icon(Icons.north_east),
                        ),
                        LdDrawerItemSection(
                          onTap: () => launchUrl(
                              Uri.parse("https://emd.design/privacy")),
                          child: const Text("Privacy"),
                          trailing: const Icon(Icons.north_east),
                        ),
                        LdDrawerItemSection(
                          onTap: () =>
                              launchUrl(Uri.parse("https://emd.design/terms")),
                          child: const Text("Terms of use"),
                          trailing: const Icon(Icons.north_east),
                        ),
                      ]),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

double defaultRadiusXs = 2.0;
double defaultRadiusS = 4.0;
double defaultRadiusM = 8.0;
double defaultRadiusL = 16.0;

double sharpRadius = 0.0;

double roundedRadiusXs = 4.0;
double roundedRadiusS = 8.0;
double roundedRadiusM = 16.0;
double roundedRadiusL = 32.0;

enum RadiusMode {
  sharp,
  standard,
  rounded,
}

class RadiusSelector extends StatefulWidget {
  const RadiusSelector({super.key});

  @override
  State<RadiusSelector> createState() => _RadiusSelectorState();
}

class _RadiusSelectorState extends State<RadiusSelector> {
  RadiusMode _mode = RadiusMode.standard;

  @override
  Widget build(BuildContext context) {
    return LdSwitch<RadiusMode>(
        label: "Radius Mode",
        onChanged: (p0) {
          final theme = LdTheme.of(context);

          switch (p0) {
            case RadiusMode.sharp:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: sharpRadius,
                radiusS: sharpRadius,
                radiusM: sharpRadius,
                radiusL: sharpRadius,
              );
              break;
            case RadiusMode.standard:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: defaultRadiusXs,
                radiusS: defaultRadiusS,
                radiusM: defaultRadiusM,
                radiusL: defaultRadiusL,
              );
              break;
            case RadiusMode.rounded:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: roundedRadiusXs,
                radiusS: roundedRadiusS,
                radiusM: roundedRadiusM,
                radiusL: roundedRadiusL,
              );
              break;
          }
          setState(() {
            _mode = p0;
          });
        },
        children: const {
          RadiusMode.sharp: Text("Sharp", maxLines: 1),
          RadiusMode.standard: Text("Standard", maxLines: 1),
          RadiusMode.rounded: Text("Rounded", maxLines: 1),
        },
        value: _mode);
  }
}

class FontSelector extends StatefulWidget {
  const FontSelector({super.key});

  @override
  State<FontSelector> createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {
  String _family = "Lato";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdChoose<String>(
      label: "Font family",
      mode: LdChooseMode.modal,
      items: GoogleFonts.asMap().keys.map(
            (font) => LdSelectItem(
              value: font,
              child: Text(font),
            ),
          ),
      onChange: (p0) async {
        final font = GoogleFonts.getFont(p0.first);

        await GoogleFonts.pendingFonts();

        LdNotificationsController.of(context).success(
          "Font changed to ${p0.first}",
        );

        theme.fontFamily = font.fontFamily!;

        theme.fontFamilyPackage = null;

        setState(() {
          _family = p0.first;
        });
      },
      value: {_family},
    );
  }
}

class HeadlineFontSelector extends StatefulWidget {
  const HeadlineFontSelector({super.key});

  @override
  State<HeadlineFontSelector> createState() => _HeadlineFontSelectorState();
}

class _HeadlineFontSelectorState extends State<HeadlineFontSelector> {
  String _family = "Lato";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdChoose<String>(
      mode: LdChooseMode.modal,
      label: "Headline font family",
      items: GoogleFonts.asMap().entries.map(
            (entry) => LdSelectItem(
              value: entry.key,
              child: Text(entry.key),
            ),
          ),
      onChange: (p0) async {
        final font = GoogleFonts.getFont(p0.first);

        await GoogleFonts.pendingFonts();

        LdNotificationsController.of(context).success(
          "Font changed to ${p0.first}",
        );

        theme.headlineFontFamily = font.fontFamily!;

        theme.fontFamilyPackage = null;

        setState(() {
          _family = p0.first;
        });
      },
      value: {_family},
    );
  }
}
