import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/components/component_api.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
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
        LdTextHs("Data repository"),
        LdTextP(
            "The data repository is a class that is responsible for fetching and caching data using the provided data source."),
        ComponentsAccordion(components: {"LdRepository"}),
      ]),
    );
  }
}
