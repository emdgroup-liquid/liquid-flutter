import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BentoGallery extends StatelessWidget {
  const BentoGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      appBar: LdAppBar(
        addContainer: true,
        blurOnScroll: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bento Gallery"),
            LdBreadcrumb.fromStrings([
              "Components",
              "Bento Gallery",
            ]),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: LdContainer(
                child: LdAutoSpace(
                  children: [
                    const LdTextP(
                      "Explore all available components in an organized gallery view. "
                      "Click on any component to view its documentation and examples.",
                    ),
                    ldSpacerL,
                    _buildBentoGrid(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _bentoItems.length,
          itemBuilder: (context, index) {
            final item = _bentoItems[index];
            return _BentoCard(
              title: item.title,
              description: item.description,
              icon: item.icon,
              route: item.route,
              category: item.category,
              colorIndex: item.colorIndex,
            );
          },
        );
      },
    );
  }

  static const List<_BentoItem> _bentoItems = [
    // Layout Components
    _BentoItem(
      title: "Button",
      description: "Interactive elements for user actions",
      icon: LucideIcons.pointer,
      route: "/components/button",
      category: "Layout",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Card",
      description: "Container for grouping related content",
      icon: LucideIcons.square,
      route: "/components/card",
      category: "Layout",
      colorIndex: 1,
    ),
    _BentoItem(
      title: "Accordion",
      description: "Collapsible content sections",
      icon: LucideIcons.listCollapse,
      route: "/components/accordion",
      category: "Layout",
      colorIndex: 2,
    ),
    _BentoItem(
      title: "Drawer",
      description: "Side navigation panel",
      icon: LucideIcons.menu,
      route: "/components/drawer",
      category: "Layout",
      colorIndex: 3,
    ),
    _BentoItem(
      title: "List",
      description: "Organized collection of items",
      icon: LucideIcons.list,
      route: "/components/list",
      category: "Layout",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Autospace",
      description: "Automatic spacing between elements",
      icon: LucideIcons.alignVerticalDistributeCenter,
      route: "/components/autospace",
      category: "Layout",
      colorIndex: 1,
    ),

    // Form Elements
    _BentoItem(
      title: "Input",
      description: "Text input fields",
      icon: LucideIcons.textCursorInput,
      route: "/components/input",
      category: "Form Elements",
      colorIndex: 2,
    ),
    _BentoItem(
      title: "Select",
      description: "Dropdown selection component",
      icon: LucideIcons.arrowDown,
      route: "/components/select",
      category: "Form Elements",
      colorIndex: 3,
    ),
    _BentoItem(
      title: "Checkbox",
      description: "Binary choice selection",
      icon: LucideIcons.circleCheck,
      route: "/components/checkbox",
      category: "Form Elements",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Radio",
      description: "Single choice from multiple options",
      icon: LucideIcons.circle,
      route: "/components/radio",
      category: "Form Elements",
      colorIndex: 1,
    ),
    _BentoItem(
      title: "Switch",
      description: "Toggle between two states",
      icon: LucideIcons.betweenHorizontalStart,
      route: "/components/switch",
      category: "Form Elements",
      colorIndex: 2,
    ),
    _BentoItem(
      title: "Slider",
      description: "Range selection control",
      icon: LucideIcons.gitCommitHorizontal,
      route: "/components/slider",
      category: "Form Elements",
      colorIndex: 3,
    ),

    // Feedback & Indicators
    _BentoItem(
      title: "Badge",
      description: "Small status indicators",
      icon: LucideIcons.tag,
      route: "/components/badge",
      category: "Feedback",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Loader",
      description: "Loading state indicators",
      icon: LucideIcons.loaderCircle,
      route: "/components/loader",
      category: "Feedback",
      colorIndex: 1,
    ),
    _BentoItem(
      title: "Notification",
      description: "System messages and alerts",
      icon: LucideIcons.bell,
      route: "/components/notification",
      category: "Feedback",
      colorIndex: 2,
    ),
    _BentoItem(
      title: "Exception",
      description: "Error state display",
      icon: LucideIcons.circleAlert,
      route: "/components/exception",
      category: "Feedback",
      colorIndex: 3,
    ),
    _BentoItem(
      title: "Hint",
      description: "Contextual help text",
      icon: LucideIcons.info,
      route: "/components/hint",
      category: "Feedback",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Indicator",
      description: "Status and progress indicators",
      icon: LucideIcons.circleAlert,
      route: "/components/indicator",
      category: "Feedback",
      colorIndex: 1,
    ),

    // Navigation & Interaction
    _BentoItem(
      title: "Modal",
      description: "Overlay dialogs and popups",
      icon: LucideIcons.messageSquare,
      route: "/components/modal",
      category: "Interaction",
      colorIndex: 2,
    ),
    _BentoItem(
      title: "Context Menu",
      description: "Right-click context actions",
      icon: LucideIcons.squareMousePointer,
      route: "/components/context-menu",
      category: "Interaction",
      colorIndex: 3,
    ),
    _BentoItem(
      title: "Breadcrumb",
      description: "Navigation path display",
      icon: LucideIcons.arrowRight,
      route: "/components/breadcrumb",
      category: "Interaction",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Orb",
      description: "Floating action element",
      icon: LucideIcons.droplet,
      route: "/components/orb",
      category: "Interaction",
      colorIndex: 1,
    ),
    _BentoItem(
      title: "Action Runner",
      description: "Execute actions and commands",
      icon: LucideIcons.tableOfContents,
      route: "/components/action-runner",
      category: "Interaction",
      colorIndex: 2,
    ),

    // Data Display
    _BentoItem(
      title: "Table",
      description: "Structured data presentation",
      icon: LucideIcons.grid3x3,
      route: "/components/table",
      category: "Data Display",
      colorIndex: 3,
    ),
    _BentoItem(
      title: "Tag",
      description: "Label and categorization",
      icon: LucideIcons.tag,
      route: "/components/tag",
      category: "Data Display",
      colorIndex: 0,
    ),
    _BentoItem(
      title: "Icon",
      description: "Visual symbols and graphics",
      icon: LucideIcons.image,
      route: "/components/icon",
      category: "Data Display",
      colorIndex: 1,
    ),
  ];
}

class _BentoItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String category;
  final int colorIndex;

  const _BentoItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.category,
    required this.colorIndex,
  });
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String category;
  final int colorIndex;

  const _BentoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.category,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    // Define color palette using proper theme colors
    final colors = [
      theme.primary.idle(theme.isDark),
      theme.success.idle(theme.isDark),
      theme.warning.idle(theme.isDark),
      theme.error.idle(theme.isDark),
    ];

    final color = colors[colorIndex % colors.length];

    return GestureDetector(
      onTap: () => context.go(route),
      child: LdCard(
        child: LdAutoSpace(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(10),
                    borderRadius: theme.radius(LdSize.s),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                ldSpacerS,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LdText(
                        title,
                        type: LdTextType.paragraph,
                        fontWeight: FontWeight.bold,
                      ),
                      LdText(
                        category,
                        type: LdTextType.caption,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            LdText(
              description,
              type: LdTextType.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
