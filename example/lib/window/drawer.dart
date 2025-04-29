import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/router.dart';
import 'package:liquid/window/font_selector.dart';
import 'package:liquid/window/headline_font_selector.dart';
import 'package:liquid/window/radius_selector.dart';
import 'package:liquid/window/size_selector.dart';
import 'package:liquid/window/theme_selector.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationDrawer extends StatefulWidget {
  final bool persistent;
  const MainNavigationDrawer({super.key, this.persistent = false});

  @override
  State<MainNavigationDrawer> createState() => _MainNavigationDrawerState();
}

enum ComponentCategory { layout, formElements, feedback, interaction, dataDisplay }

class _Component {
  final String title;
  final String route;
  final IconData icon;
  final ComponentCategory category;

  const _Component(this.title, this.route, this.icon, this.category);
}

const components = [
  // Layout
  _Component("Accordion", "/components/accordion", LucideIcons.listCollapse, ComponentCategory.layout),
  _Component("Autospace", "/components/autospace", LucideIcons.alignVerticalDistributeCenter, ComponentCategory.layout),
  _Component("Card", "/components/card", LucideIcons.square, ComponentCategory.layout),
  _Component("Divider", "/components/divider", LucideIcons.minus, ComponentCategory.layout),
  _Component("Drawer", "/components/drawer", LucideIcons.menu, ComponentCategory.layout),
  _Component("Master detail", "/components/master-detail", LucideIcons.list, ComponentCategory.layout),
  _Component("Spring", "/components/spring", LucideIcons.shell, ComponentCategory.layout),
  _Component("List Item", "/components/list-item", LucideIcons.listTree, ComponentCategory.layout),
  _Component("List Demo", "/components/list-full-screen", LucideIcons.list, ComponentCategory.layout),
  _Component("Selectable List", "/components/selectable-list", LucideIcons.listCheck, ComponentCategory.layout),

  // Form Elements
  _Component("Checkbox", "/components/checkbox", LucideIcons.circleCheck, ComponentCategory.formElements),
  _Component("Choose", "/components/choose", LucideIcons.textSelect, ComponentCategory.formElements),
  _Component("Date/Time Picker", "/components/date-time-picker", LucideIcons.calendar, ComponentCategory.formElements),
  _Component("Form", "/components/form", LucideIcons.penTool, ComponentCategory.formElements),
  _Component("Input", "/components/input", LucideIcons.textCursorInput, ComponentCategory.formElements),
  _Component("Radio", "/components/radio", LucideIcons.circle, ComponentCategory.formElements),
  _Component("Reactive Form", "/components/reactive_form", LucideIcons.signature, ComponentCategory.formElements),
  _Component("Select", "/components/select", LucideIcons.arrowDown, ComponentCategory.formElements),
  _Component("Slider", "/components/slider", LucideIcons.gitCommitHorizontal, ComponentCategory.formElements),
  _Component("Submit", "/components/submit", LucideIcons.send, ComponentCategory.formElements),
  _Component("Switch", "/components/switch", LucideIcons.betweenHorizontalStart, ComponentCategory.formElements),
  _Component("Toggle", "/components/toggle", Icons.toggle_on, ComponentCategory.formElements),

  // Feedback & Indicators
  _Component("Badge", "/components/badge", LucideIcons.tag, ComponentCategory.feedback),
  _Component("Exception", "/components/exception", LucideIcons.circleAlert, ComponentCategory.feedback),
  _Component("Hint", "/components/hint", LucideIcons.info, ComponentCategory.feedback),
  _Component("Indicator", "/components/indicator", LucideIcons.circleAlert, ComponentCategory.feedback),
  _Component("Loader", "/components/loader", LucideIcons.loaderCircle, ComponentCategory.feedback),
  _Component("Notification", "/components/notification", LucideIcons.bell, ComponentCategory.feedback),
  _Component("Reveal", "/components/reveal", LucideIcons.eye, ComponentCategory.feedback),

  // Navigation & Interaction
  _Component("Action Runner", "/components/action-runner", LucideIcons.tableOfContents, ComponentCategory.interaction),
  _Component("Breadcrumb", "/components/breadcrumb", LucideIcons.arrowRight, ComponentCategory.interaction),
  _Component("Button", "/components/button", LucideIcons.pointer, ComponentCategory.interaction),
  _Component("Context Menu", "/components/context-menu", LucideIcons.squareMousePointer, ComponentCategory.interaction),
  _Component("Modal", "/components/modal", LucideIcons.messageSquare, ComponentCategory.interaction),
  _Component("Orb", "/components/orb", LucideIcons.droplet, ComponentCategory.interaction),

  // Data Display
  _Component("Icon", "/components/icon", LucideIcons.image, ComponentCategory.dataDisplay),
  _Component("Table", "/components/table", LucideIcons.grid3x3, ComponentCategory.dataDisplay),
  _Component("Tag", "/components/tag", LucideIcons.tag, ComponentCategory.dataDisplay),
];

class _MainNavigationDrawerState extends State<MainNavigationDrawer> {
  AppRouter? appRouter;

  List<_Component> _componentsFiltered = components;

  late TextEditingController _search;

  final _fuzzy = Fuzzy<_Component>(components,
      options: FuzzyOptions(
        isCaseSensitive: false,
        threshold: 0.3,
        tokenSeparator: ",",
        tokenize: true,
        keys: [
          WeightedKey(
            name: "title",
            getter: (e) => e.title,
            weight: 1,
          ),
        ],
      ));

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

  void _onQueryChanged(String query) {
    setState(() {
      _componentsFiltered = _fuzzy.search(query).map((e) => e.item).toList();
    });
  }

  Widget _renderComponent(
    BuildContext context,
    _Component component,
  ) {
    final isActive = GoRouterState.of(context).uri.path.startsWith(component.route);

    return LdDrawerItemSection(
      active: isActive,
      leading: Icon(component.icon),
      onTap: () {
        _showPage(context, component.route);
      },
      child: Text(component.title),
    );
  }

  String _categoryTitle(ComponentCategory category) {
    switch (category) {
      case ComponentCategory.layout:
        return "Layout";
      case ComponentCategory.formElements:
        return "Form Elements";
      case ComponentCategory.feedback:
        return "Feedback & Indicators";
      case ComponentCategory.interaction:
        return "Navigation & Interaction";
      case ComponentCategory.dataDisplay:
        return "Data Display";
    }
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
                        decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m)),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset("liquid_flutter_icon.jpg", width: 32, height: 32),
                      ),
                      ldSpacerS,
                      Expanded(
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Liquid Flutter",
                            ),
                            LdTextCaption(ldVersion)
                          ],
                        ),
                      ),
                    ],
                  ).padM(),
                ),
              ),
              sliver: SliverPadding(
                padding: LdTheme.of(context).pad(),
                sliver: SliverList.list(key: const PageStorageKey('drawer_list_key'), children: [
                  LdContextMenu(
                      positionMode: LdContextPositionMode.relativeTrigger,
                      builder: (context, shuttle, trigger) => Row(
                            children: [
                              LdButtonVague(
                                  trailing: const Icon(LucideIcons.squareMousePointer),
                                  onPressed: () {
                                    trigger();
                                  },
                                  child: const Text("Theme")),
                            ],
                          ),
                      menuBuilder: (context, openMenu) => SizedBox(
                            height: 400,
                            width: 300,
                            child: SingleChildScrollView(
                              child: LdAutoSpace(
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
                                ],
                              ).padL(),
                            ),
                          )),
                  ldSpacerM,
                  LdAutoSpace(children: [
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/",
                      leading: const Icon(LucideIcons.house),
                      onTap: () => _showPage(context, "/"),
                      child: const Text("Home"),
                    ),
                    const LdSectionHeader("Demos"),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/chemical",
                      leading: const Icon(LdIcons.beaker),
                      onTap: () => _showPage(context, "/chemical"),
                      child: const Text("Magic"),
                    ),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/task-demo",
                      leading: const Icon(LucideIcons.check),
                      onTap: () => _showPage(context, "/task-demo"),
                      child: const Text("Task"),
                    ),
                    const LdSectionHeader("Documentation"),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/theme",
                      leading: const Icon(LucideIcons.paintbrush),
                      onTap: () => _showPage(context, "/theme"),
                      child: const Text("Theme"),
                    ),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/layout",
                      leading: const Icon(LucideIcons.layoutDashboard),
                      onTap: () => _showPage(context, "/layout"),
                      child: const Text("Layout"),
                    ),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/radius",
                      leading: const Icon(LucideIcons.radius),
                      onTap: () => _showPage(context, "/radius"),
                      child: const Text("Border Radius"),
                    ),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/typography",
                      leading: const Icon(LucideIcons.text),
                      onTap: () => _showPage(context, "/typography"),
                      child: const Text("Typography"),
                    ),
                    LdDrawerItemSection(
                      active: GoRouterState.of(context).uri.path == "/material",
                      leading: const Icon(LucideIcons.sprayCan),
                      onTap: () => _showPage(context, "/material"),
                      child: const Text("Material"),
                    ),
                    const LdSectionHeader("Components"),
                    LdInput(
                      hint: "Search...",
                      controller: _search,
                      onChanged: (query) {
                        if (query != null) {
                          _onQueryChanged(query);
                        }
                      },
                    ),
                    ...ComponentCategory.values.expand((category) {
                      final categoryComponents = _componentsFiltered.where((c) => c.category == category).toList();
                      if (categoryComponents.isEmpty) {
                        return [];
                      }
                      return [
                        LdSectionHeader(_categoryTitle(category)),
                        ...categoryComponents.map((e) => _renderComponent(context, e)),
                      ];
                    }),
                    const LdDivider(),
                    LdDrawerItemSection(
                      onTap: () => launchUrl(Uri.parse("https://emd.design/imprint")),
                      trailing: const Icon(LucideIcons.externalLink),
                      child: const Text("Imprint"),
                    ),
                    LdDrawerItemSection(
                      onTap: () => launchUrl(Uri.parse("https://emd.design/privacy")),
                      trailing: const Icon(LucideIcons.externalLink),
                      child: const Text("Privacy"),
                    ),
                    LdDrawerItemSection(
                      onTap: () => launchUrl(Uri.parse("https://emd.design/terms")),
                      trailing: const Icon(LucideIcons.externalLink),
                      child: const Text("Terms of use"),
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
