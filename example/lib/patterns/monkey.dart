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
                    LdCard(child: LdTextP("")),
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
        LdTextH("🐵 LdMonkey"),
        LdTextP(
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
              LdTextP(
                  "It sometimes feels like we’re barely better off. Web pages aren’t that different from what they were in the late ’90s, early 2000s. They’re still just forms. They still just write to databases. A lot of people, I think, are very uncomfortable with the fact that they are essentially crud monkeys."),
              LdTextPs(
                  "David Heinemeier Hansson, Lex Fridman Podcast, July 12th 2025"),
              LdButtonGhost(
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
        LdTextH("Overview"),
        LdTextP(
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
                          child: LdTextP(
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
                      child: LdTextP(
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
                child: LdTextP(
              "Mount the Monkey pattern in a go router config by calling the buildRoute() method.",
            )),
          ),
          Center(child: Icon(LucideIcons.arrowDown)),
          LdCard(
            header: Column(
              children: [
                Text("LdMonkeyShell"),
                LdMute(
                  child: LdTextP(
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
                                  child: LdTextP(
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
                                      Text(
                                          "LdMonkeyActionLocation.masterAppBar"),
                                      LdMute(
                                        child: LdTextP(
                                          "Primary AppBar for actions.",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                LdCard(
                                  child: Column(
                                    children: [
                                      Text(
                                          "LdMonkeyActionLocation.masterSecondary AppBar"),
                                      LdMute(
                                        child: LdTextP(
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
                                        child: LdTextP(
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
                                        child: LdTextP(
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
                              child: LdTextP(
                                "The detail page is the page that displays the details of an item.",
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            LdCard(
                              child: Text(
                                  "LdMonkeyActionLocation.detailAppBar AppBar"),
                            ),
                            LdCard(
                              child: Text(
                                  "LdMonkeyActionLocation.detailSecondary AppBar"),
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
        LdTextHs("Functionality"),
        LdTextP(
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
        LdTextH("Step by step guide"),
        LdTextP(
            "The Monkey pattern is organized into several sub-pages that cover different aspects of implementation:"),
        LdAutoSpace(children: [
          LdTextHs("Repository"),
          LdTextP(
              "Learn how to set up the data repository that handles all CRUD operations, pagination, filtering, and sorting."),
          LdButton(
            child: const Text("View Repository Documentation"),
            onPressed: () {
              context.push("/patterns/monkey/repository");
            },
          ),
        ]),
      ]),
    );
  }
}
