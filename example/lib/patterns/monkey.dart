import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class MonkeyDemo extends StatelessWidget {
  const MonkeyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey.dart",
      category: "Patterns",
      title: "LdMonkey",
      demo: LdAutoSpace(children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LdCard(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(children: [
                    LdCard(child: LdText.p("")),
                    ...List.generate(
                      5,
                      (index) => LdCard(
                        padding: LdTheme.of(context).pad(size: LdSize.s),
                        child: SizedBox.shrink(),
                      ),
                    )
                  ]).spaceS(),
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
                            children: [
                              Icon(LucideIcons.plus),
                              Icon(LucideIcons.pen),
                              Icon(LucideIcons.trash),
                            ],
                          ),
                        )),
                      ),
                    ))
              ],
            ).spaceM()),
          ),
        ),
        LdText.h("🐵 LdMonkey"),
        LdText.p(
            "The Monkey name is reference to a Podcast between Lex Fridman and David Heinemeier Hansson where David describes the 'crud monkey' a developer that implements a timeless pattern in Software Engineering."),
        Row(
          children: [
            LdButton(
              child: Text("Task Demo"),
              onPressed: () {
                context.push("/task-demo");
              },
            ),
            LdButton(
              child: Text("Movie Demo"),
              onPressed: () {
                context.push("/movie-demo");
              },
            ),
          ],
        ).spaceS(),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.p(
                  "It sometimes feels like we’re barely better off. Web pages aren’t that different from what they were in the late ’90s, early 2000s. They’re still just forms. They still just write to databases. A lot of people, I think, are very uncomfortable with the fact that they are essentially crud monkeys."),
              LdText.ps("David Heinemeier Hansson, Lex Fridman Podcast, July 12th 2025"),
              LdButton.ghost(
                leading: const Icon(LucideIcons.play),
                child: Text("Listen to the podcast"),
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://www.youtube.com/watch?v=vagyIcmIGOQ"),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ],
          ),
        ),
        LdText.h("Overview"),
        LdText.p(
          "It consists of the following core components:\n\n"
          "The LdMonkey class is the main wrapper around all functionality, it is used to configure the pattern. "
          "It is responsible for configuring the routes, the naming, the selection behaviour, as well as the actions the user can perform on the items.\n\n"
          "The LdRepository class is an extension of the LdPaginator. It is responsible for fetching the data from a data source like a backend. "
          "It also manages the state of the data, like loading, errors, updates etc.",
        ),
        LdAutoSpace(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    LdCard(
                      header: Text("LdMonkey"),
                      child: LdMute(
                          child: LdText.p(
                        "Main wrapper, configures pattern, tracks selection, provides actions",
                      )),
                    ),
                  ],
                ).spaceM(),
              ),
              Icon(LucideIcons.arrowRight),
              Expanded(
                child: LdCard(
                  header: Text("LdRepository"),
                  child: LdMute(
                      child: LdText.p(
                    "Handles data fetching, filtering, sorting, pagination, and state management.",
                  )),
                ),
              ),
            ],
          ).spaceM(),
          Icon(LucideIcons.arrowDown).padL(),
          LdCard(
            header: Text("GoRouter"),
            child: LdMute(
                child: LdText.p(
              "Mount the Monkey pattern in a go router config by calling the buildRoute() method.",
            )),
          ),
          Center(child: Icon(LucideIcons.arrowDown)),
          LdCard(
            header: Column(
              children: [
                Text("LdMonkeyShell"),
                LdMute(
                  child: LdText.p(
                    "The shell route that wraps the master and detail pages. Decides on the responsive layout, Keeps the url state in sync with the Monkey pattern.",
                  ),
                ),
              ],
            ),
            child: LdAutoSpace(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LdAutoSpace(
                        children: [
                          LdCard(
                            header: Column(
                              children: [
                                Text("LdMonkeyMasterPage"),
                                LdMute(
                                  child: LdText.p(
                                    "The master page is the main page that displays the list of items.",
                                  ),
                                ),
                              ],
                            ),
                            child: LdAutoSpace(
                              children: [
                                LdCard(
                                  child: Column(
                                    children: [
                                      Text("LdMonkeyActionLocation.masterAppBar"),
                                      LdMute(
                                        child: LdText.p(
                                          "Primary AppBar for actions.",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                LdCard(
                                  child: Column(
                                    children: [
                                      Text("LdMonkeyActionLocation.masterSecondary AppBar"),
                                      LdMute(
                                        child: LdText.p(
                                          "Secondary AppBar for actions and search.",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                LdCard(
                                  child: Column(
                                    children: [
                                      Text("LdMonkeyMultiShortcuts"),
                                      LdMute(
                                        child: LdText.p(
                                          "Provides keyboard shortcuts for the actions.",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                LdCard(
                                  child: Column(
                                    children: [
                                      Text("LdSelectableList"),
                                      LdMute(
                                        child: LdText.p(
                                          "The list that displays the list of items.",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LdCard(
                        header: Column(
                          children: [
                            Text("LdMonkeyDetailPage"),
                            LdMute(
                              child: LdText.p(
                                "The detail page is the page that displays the details of an item.",
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            LdCard(
                              child: Text("LdMonkeyActionLocation.detailAppBar AppBar"),
                            ),
                            LdCard(
                              child: Text("LdMonkeyActionLocation.detailSecondary AppBar"),
                            ),
                          ],
                        ).spaceS(),
                      ),
                    ),
                  ],
                ).spaceM(),
              ],
            ),
          ),
        ]),
        LdDivider(),
        LdText.hs("Functionality"),
        LdText.p(
            "The goal of the monkey pattern is to provide as many of the core CRUD features needed in common apps. This currently includes:"),
        Wrap(
          spacing: LdTheme.of(context).pad(size: LdSize.s).left,
          runSpacing: LdTheme.of(context).pad(size: LdSize.s).right,
          children: [
            "List of items",
            "Detail view",
            "Reflowing on small screens",
            "Filtering",
            "Sorting",
            "URL state management, restoration of loaded items, filters, sorting, scroll offset",
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
          ].map((e) => LdTag(child: Text(e))).toList(),
        ),
        LdText.h("Step by step guide"),
        LdText.p(
            "The Monkey pattern is organized into several sub-pages that cover different aspects of implementation:"),
        LdAutoSpace(children: [
          LdText.hs("Repository"),
          LdText.p(
              "Learn how to set up the data repository that handles all CRUD operations, pagination, filtering, and sorting."),
          LdButton(
            child: const Text("View Repository Documentation"),
            onPressed: () {
              context.push("/patterns/monkey/repository");
            },
          ),
          LdSpacer(size: LdSize.m),
          LdText.hs("Pattern Configuration"),
          LdText.p(
              "Learn how to configure the LdMonkey pattern, including routing, selection behavior, and layout options."),
          LdButton(
            child: const Text("View Pattern Documentation"),
            onPressed: () {
              context.push("/patterns/monkey/pattern");
            },
          ),
          LdSpacer(size: LdSize.m),
          LdText.hs("Actions"),
          LdText.p(
              "Learn how to create and configure actions that users can perform on items, including visibility conditions and keyboard shortcuts."),
          LdButton(
            child: const Text("View Actions Documentation"),
            onPressed: () {
              context.push("/patterns/monkey/actions");
            },
          ),
          LdSpacer(size: LdSize.m),
          LdText.hs("Sorting & Filtering"),
          LdText.p(
              "Learn how to implement advanced sorting and filtering capabilities with optimistic updates and URL state management."),
          LdButton(
            child: const Text("View Sorting & Filtering Documentation"),
            onPressed: () {
              context.push("/patterns/monkey/sorting-filtering");
            },
          ),
        ]),
      ]),
    );
  }
}
