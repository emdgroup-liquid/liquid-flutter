import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BentoGallery extends StatelessWidget {
  const BentoGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar(
        addContainer: true,
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
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: LdContainer(
                child: LdAutoSpace(
                  children: [
                    LdText.p(
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
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
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

  Widget _buildPreview(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    switch (title) {
      case "Button":
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...LdButtonMode.values.map((e) => LdButton(
                  mode: e,
                  onPressed: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Text("Press me"),
                )),
          ],
        );

      case "Card":
        return LdCard(
          child: LdAutoSpace(
            children: [
              const LdText("Card Preview"),
              LdText.caption("Sample content"),
            ],
          ),
        );

      case "Input":
        return LdInput(
          hint: "Preview input",
        );

      case "Select":
        return LdSelect<String>(
          placeholder: "Preview select",
          items: const [
            LdSelectItem(value: "option1", child: LdText("Option 1")),
            LdSelectItem(value: "option2", child: LdText("Option 2")),
          ],
          value: "option1",
          onChanged: (_) {},
        );

      case "Checkbox":
        return LdAutoSpace(
          children: [
            LdCheckbox(
              checked: true,
              label: "Preview",
            ),
            LdCheckbox(
              checked: false,
              label: "Preview",
            ),
          ],
        );

      case "Radio":
        return LdAutoSpace(
          children: [
            LdRadio(
              checked: true,
              label: "Preview",
            ),
            LdRadio(
              checked: false,
              label: "Preview",
            ),
          ],
        );

      case "List":
        return LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              LdListItem(
                leading: LdAvatar(child: Icon(LucideIcons.list)),
                title: Text("Preview"),
                subtitle: Text("Preview"),
                onPressed: () {},
              ),
              LdDivider(),
              LdListItem(
                leading: LdAvatar(child: Icon(LucideIcons.list)),
                title: Text("Preview"),
                subtitle: Text("Preview"),
                tradeLeadingForSelectionControl: true,
                selectionControl: LdSelectionControl.checkbox,
                onPressed: () {},
              ),
              LdDivider(),
              LdListItem(
                leading: LdAvatar(child: Icon(LucideIcons.list)),
                title: Text("Preview"),
                subtitle: Text("Preview"),
                trailing: Icon(LucideIcons.trash),
                onPressed: () {},
              ),
            ],
          ),
        );

      case "Switch":
        return LdSwitch<String>(
          children: const {"on": Text("On"), "off": Text("Off")},
          value: "on",
          onChanged: (_) {},
        );

      case "Badge":
        return LdBadge(
          child: const Text("Preview"),
        );

      case "Loader":
        return const LdLoader(size: 32);

      case "Accordion":
        return LdAccordion.fromList(
          [
            LdAccordionItem(
              header: const Text("Preview"),
              child: const LdText("Content"),
            ),
          ],
          wrapActiveInCard: true,
        );

      case "Tag":
        return LdTag(
          child: const Text("Preview"),
        );

      case "Modal":
        return LdButton(
          onPressed: () async {
            await LdModalRoute(
              context: context,
              pageBuilder: (context) => const Text("Modal content"),
            ).show(context, useRootNavigator: true);
          },
          child: const Text("Open Modal"),
        );

      case "Breadcrumb":
        return LdBreadcrumb.fromStrings(["Home", "Preview"]);

      case "Orb":
        return LdOrb(0.5, size: 140);

      case "Notification":
        return LdNotificationWidget(
          notification: LdNotification(message: "Notification", type: LdNotificationType.info),
          onDismiss: () {},
        );

      case "Exception":
        return LdExceptionView(
          exception: LdLocalizedException(
            message: "Preview Error",
            type: LdHintType.error,
          ),
        );

      case "Hint":
        return LdHint(
          type: LdHintType.info,
          child: const Text("Preview hint text"),
        );

      case "Indicator":
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...LdIndicatorType.values.map((e) => LdIndicator(type: e, size: LdSize.s)),
          ],
        );

      case "Icon":
        return Icon(
          LucideIcons.star,
          size: theme.labelSize(LdSize.s),
        );

      case "Autospace":
        return LdAutoSpace(
          children: [
            LdBadge(child: Text("Wow")),
            LdText.h("This is magic"),
            LdText("Automatically spacing"),
            LdText("Vertically"),
          ],
        );

      case "Slider":
        return LdConfirmationSlider(
          onSlideComplete: () {},
          hint: "Slide to complete",
        );

      case "Context Menu":
        return LdContextMenu(
          builder: (context, isShuttle, open, isOpen, child) => child!,
          menuBuilder: (context) => SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: Text("Im a context menu"),
            ),
          ),
          child: LdButton(
            size: LdSize.l,
            onPressed: () {},
            child: const Text("Right Click"),
          ),
        );

      case "Action Runner":
        return Column(
          children: [
            LdRunnerStep(
              title: Text("Demo"),
              status: LdIndicatorType.success,
            ),
            LdRunnerStep(
              title: Text("Demo"),
              status: LdIndicatorType.loading,
            ),
          ],
        );

      default:
        return Container(
          height: 20,
          width: 60,
          decoration: BoxDecoration(
            color: theme.neutralShade(3),
            borderRadius: theme.radius(LdSize.xs),
          ),
          child: const Center(
            child: Text(
              "Preview under construction",
            ),
          ),
        );
    }
  }

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
        expandChild: true,
        footer: LdAutoSpace(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                ldSpacerM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LdText.p(
                        title,
                        fontWeight: FontWeight.bold,
                      ),
                      LdText.caption(
                        category,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPreview(context),
            ],
          ),
        ).padL(),
      ),
    );
  }
}
