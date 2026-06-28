import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class _ArchLayer extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color? color;
  const _ArchLayer({required this.label, required this.items, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LdText.ps(label),
          SizedBox(height: theme.pad(size: LdSize.s).top),
          Wrap(
            spacing: theme.pad(size: LdSize.s).left,
            runSpacing: theme.pad(size: LdSize.s).top,
            children: items.map((e) => LdTag(child: Text(e))).toList(),
          ),
        ],
      ),
    );
  }
}

class _MonkeyArchDiagram extends StatelessWidget {
  const _MonkeyArchDiagram();

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final arrowColor = theme.textMuted;
    return Column(
      children: [
        const _ArchLayer(
          label: "Router / URL layer",
          items: ["GoRouter", "URL state", "location lock", "deep links"],
        ),
        Center(
          child: Icon(LucideIcons.arrowDown, color: arrowColor, size: 20),
        ),
        const _ArchLayer(
          label: "Widget layer",
          items: [
            "LdMonkeyShell",
            "LdMonkeyMasterPage",
            "LdMonkeyDetailPage",
            "LdMonkeyAppBar",
            "LdMonkeyBareChildAction",
          ],
        ),
        Center(
          child: Icon(LucideIcons.arrowDown, color: arrowColor, size: 20),
        ),
        const _ArchLayer(
          label: "Data layer",
          items: [
            "LdCallbackModel",
            "LdModel",
            "filtersBuilder",
            "sortOptionsBuilder",
            "deleteBatchFn",
            "getOffsetByIdFn",
          ],
        ),
      ],
    );
  }
}

class MonkeyDemo extends StatelessWidget {
  const MonkeyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey.dart",
      category: "Patterns",
      title: "LdMonkey",
      demo: LdAutoSpace(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: LdCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          LdCard(child: LdText.p("")),
                          ...List.generate(
                            5,
                            (index) => LdCard(
                              padding: LdTheme.of(context).pad(size: LdSize.s),
                              child: SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ).spaceS(),
                    ),
                    Expanded(
                      flex: 3,
                      child: LdCard(
                        child: SizedBox(
                          height: 200,
                          child: Center(
                            child: LdMute(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [Icon(LucideIcons.plus), Icon(LucideIcons.pen), Icon(LucideIcons.trash)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).spaceM(),
              ),
            ),
          ),
          LdText.hs("Architecture"),
          LdText.p(
            "LdMonkey is composed of three layers. The router owns URL state and drives the shell. The widget layer renders master list, detail panel, and toolbar. The data layer (LdCallbackModel / LdModel) holds items and exposes reactive streams that the widgets observe.",
          ),
          const _MonkeyArchDiagram(),
          LdText.caption("Demos"),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem.trailingForward(
                  title: Text("Task Demo"),
                  onPressed: () {
                    context.push("/task-demo");
                  },
                ),
                LdListItem.trailingForward(
                  title: Text("Movie Demo"),
                  onPressed: () {
                    context.push("/movie-demo");
                  },
                ),
              ],
            ),
          ),

          LdText.hs("About the name"),
          LdText.p(
            "The Monkey name is reference to a Podcast between Lex Fridman and David Heinemeier Hansson where David describes the 'crud monkey' a developer that implements a timeless pattern in Software Engineering.",
          ),
          LdCard(
            footer: LdButton.ghost(
              leading: const Icon(LucideIcons.play),
              size: LdSize.s,
              child: Text("Listen to the podcast"),
              onPressed: () {
                launchUrl(
                  Uri.parse("https://www.youtube.com/watch?v=vagyIcmIGOQ"),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            child: LdAutoSpace(
              children: [
                LdText.p(
                  "It sometimes feels like we’re barely better off. Web pages aren’t that different from what they were in the late ’90s, early 2000s. They’re still just forms. They still just write to databases. A lot of people, I think, are very uncomfortable with the fact that they are essentially crud monkeys.",
                ),
                LdText.ps("David Heinemeier Hansson, Lex Fridman Podcast, July 12th 2025"),
              ],
            ),
          ),

          LdText.hs("Functionality"),
          LdText.p(
            "The goal of the monkey pattern is to provide as many of the core CRUD features needed in common apps. This currently includes:",
          ),
          Wrap(
            spacing: LdTheme.of(context).pad(size: LdSize.s).left,
            runSpacing: LdTheme.of(context).pad(size: LdSize.s).right,
            children: [
              "List of items",
              "Detail view",
              "Reflowing on small screens",
              "Filtering",
              "Sorting",
              "URL state management",
              "Restoration of loaded items",
              "Filters",
              "Sorting",
              "Scroll offset",
              "Multi select",
              "Context menus",
              "Search",
              "Pagination",
              "Loading states",
              "Error states",
              "Empty states",
              "Pull to refresh",
              "Bidirectional infinite scroll",
              "Optimistic updates",
            ].map((e) => LdTag.success(child: Text(e))).toList(),
          ),
          LdText.h("Step by step guide"),
          LdText.p(
            "The Monkey pattern is organized into several sub-pages that cover different aspects of implementation:",
          ),
          LdAutoSpace(
            children: [
              LdText.hs("Data Model"),
              LdText.p(
                "Learn how to set up the data model that handles all CRUD operations, pagination, filtering, and sorting.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Data Model Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/repository");
                  },
                ),
              ),

              LdSpacer(size: LdSize.m),
              LdText.hs("Pattern Configuration"),
              LdText.p(
                "Learn how to configure the LdMonkey pattern, including routing, selection behavior, and layout options.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Pattern Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/pattern");
                  },
                ),
              ),
              LdSpacer(size: LdSize.m),
              LdText.hs("Actions"),
              LdText.p(
                "Learn how to create and configure actions that users can perform on items, including visibility conditions and keyboard shortcuts.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Actions Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/actions");
                  },
                ),
              ),
              LdSpacer(size: LdSize.m),
              LdText.hs("Sorting & Filtering"),
              LdText.p(
                "Learn how to implement advanced sorting and filtering capabilities with optimistic updates and URL state management.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Sorting & Filtering Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/sorting-filtering");
                  },
                ),
              ),
              LdSpacer(size: LdSize.m),
              LdSpacer(size: LdSize.m),
              LdText.hs("Backend API"),
              LdText.p(
                "Learn what your server-side API must look like to be fully compatible with LdMonkey — pagination contract, filter/sort wire format, and the offset-by-id endpoint.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Backend API Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/backend");
                  },
                ),
              ),
              LdSpacer(size: LdSize.m),
              LdText.hs("Detail editing"),
              LdText.p(
                "Learn how to build editable detail views with LdMonkeyReactiveDetailForm, adaptive save, and navigation guards.",
              ),
              LdCard(
                padding: EdgeInsets.zero,
                child: LdListItem.trailingForward(
                  title: Text("View Detail Editing Documentation"),
                  onPressed: () {
                    context.push("/patterns/monkey/detail-edit");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
