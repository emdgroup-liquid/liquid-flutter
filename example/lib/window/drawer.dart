import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/main.dart';
import 'package:liquid/router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_state.dart';
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
  _Component("Bento Gallery", "/components/bento-gallery", LucideIcons.grid3x3, ComponentCategory.layout),
  _Component("Accordion", "/components/accordion", LucideIcons.listCollapse, ComponentCategory.layout),
  _Component("Autospace", "/components/autospace", LucideIcons.alignVerticalDistributeCenter, ComponentCategory.layout),
  _Component("Card", "/components/card", LucideIcons.square, ComponentCategory.layout),
  _Component("Divider", "/components/divider", LucideIcons.minus, ComponentCategory.layout),
  _Component("Drawer", "/components/drawer", LucideIcons.menu, ComponentCategory.layout),

  _Component("Spring", "/components/spring", LucideIcons.shell, ComponentCategory.layout),
  _Component("List Item", "/components/list-item", LucideIcons.listTree, ComponentCategory.layout),
  _Component(
    "List",
    "/components/list",
    LucideIcons.list,
    ComponentCategory.layout,
  ),
  _Component("Selectable List", "/components/selectable-list", LucideIcons.listCheck, ComponentCategory.layout),

  // Form Elements
  _Component("Checkbox", "/components/checkbox", LucideIcons.circleCheck, ComponentCategory.formElements),
  _Component("Choose", "/components/choose", LucideIcons.textSelect, ComponentCategory.formElements),
  _Component("Date/Time Picker", "/components/date-time-picker", LucideIcons.calendar, ComponentCategory.formElements),
  _Component("Form", "/components/form", LucideIcons.penTool, ComponentCategory.formElements),
  _Component("Input", "/components/input", LucideIcons.textCursorInput, ComponentCategory.formElements),
  _Component("Radio", "/components/radio", LucideIcons.circle, ComponentCategory.formElements),
  //_Component("Reactive Form", "/components/reactive_form",
  //    LucideIcons.signature, ComponentCategory.formElements),
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
  _Component("Speed Reader", "/components/speed-reader", LucideIcons.bookOpen, ComponentCategory.interaction),

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
    final state = context.read<LdDrawerState>();
    if (!state.isSideBySide) {
      Navigator.of(context).maybePop();
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
      onPressed: () {
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
    return LdScaffold(
      appBar: LdAppBar(
        title: Text("Navigation"),
        debugName: "Drawer AppBar",
      ),
      body: Builder(builder: (context) {
        return LdScaffoldBody(children: [
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/",
            leading: const Icon(LucideIcons.house),
            onPressed: () => _showPage(context, "/"),
            child: const Text("Home"),
          ),
          const LdSectionHeader("Demos"),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/chemical",
            leading: const Icon(LdIcons.beaker),
            onPressed: () => _showPage(context, "/chemical"),
            child: const Text("Magic"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/task-demo",
            leading: const Icon(LucideIcons.check),
            onPressed: () => _showPage(context, "/task-demo"),
            child: const Text("Task"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/movie-demo",
            leading: const Icon(LucideIcons.film),
            onPressed: () => _showPage(context, "/movie-demo"),
            child: const Text("Movie"),
          ),
          const LdSectionHeader("Documentation"),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/theme",
            leading: const Icon(LucideIcons.paintbrush),
            onPressed: () => _showPage(context, "/theme"),
            child: const Text("Theme"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/layout",
            leading: const Icon(LucideIcons.layoutDashboard),
            onPressed: () => _showPage(context, "/layout"),
            child: const Text("Layout"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/radius",
            leading: const Icon(LucideIcons.radius),
            onPressed: () => _showPage(context, "/radius"),
            child: const Text("Border Radius"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/typography",
            leading: const Icon(LucideIcons.text),
            onPressed: () => _showPage(context, "/typography"),
            child: const Text("Typography"),
          ),
          LdDrawerItemSection(
            active: GoRouterState.of(context).uri.path == "/material",
            leading: const Icon(LucideIcons.sprayCan),
            onPressed: () => _showPage(context, "/material"),
            child: const Text("Material"),
          ),
          const LdSectionHeader("Patterns"),
          LdDrawerItemSection(
            onPressed: () => _showPage(context, "/patterns/monkey"),
            active: GoRouterState.of(context).uri.path.startsWith("/patterns/monkey"),
            leading: Text(
              "🐵",
            ),
            child: const Text("Monkey"),
            children: [
              LdDrawerItemSection(
                active: GoRouterState.of(context).uri.path == ("/patterns/monkey"),
                onPressed: () => _showPage(context, "/patterns/monkey"),
                child: const Text("Overview"),
              ),
              LdDrawerItemSection(
                active: GoRouterState.of(context).uri.path == ("/patterns/monkey/repository"),
                onPressed: () => _showPage(context, "/patterns/monkey/repository"),
                child: const Text("Repository"),
              ),
              LdDrawerItemSection(
                active: GoRouterState.of(context).uri.path == ("/patterns/monkey/pattern"),
                onPressed: () => _showPage(context, "/patterns/monkey/pattern"),
                child: const Text("Pattern Configuration"),
              ),
              LdDrawerItemSection(
                active: GoRouterState.of(context).uri.path == ("/patterns/monkey/actions"),
                onPressed: () => _showPage(context, "/patterns/monkey/actions"),
                child: const Text("Actions"),
              ),
              LdDrawerItemSection(
                active: GoRouterState.of(context).uri.path == ("/patterns/monkey/sorting-filtering"),
                onPressed: () => _showPage(context, "/patterns/monkey/sorting-filtering"),
                child: const Text("Sorting & Filtering"),
              ),
            ],
          ),
          const LdSectionHeader("Components"),
          LdInput(
            hint: "Search... ",
            controller: _search,
            focusNode: searchFocusNode,
            showClear: true,
            trailingHint: const LdShortcutIndicator(
              shortcut: SingleActivator(LogicalKeyboardKey.keyK, meta: true),
            ),
            onChanged: (query) {
              _onQueryChanged(query);
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
          LdDrawerItemSection(
            onPressed: () => launchUrl(Uri.parse("https://emd.design/imprint")),
            trailing: const Icon(LucideIcons.externalLink),
            child: const Text("Imprint"),
          ),
          LdDrawerItemSection(
            onPressed: () => launchUrl(Uri.parse("https://emd.design/privacy")),
            trailing: const Icon(LucideIcons.externalLink),
            child: const Text("Privacy"),
          ),
          LdDrawerItemSection(
            onPressed: () => launchUrl(Uri.parse("https://emd.design/terms")),
            trailing: const Icon(LucideIcons.externalLink),
            child: const Text("Terms of use"),
          ),
        ]);
      }),
    );
  }
}
