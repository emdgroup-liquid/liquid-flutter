import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';

import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum PaymentStatus { paid, due, sent }

class _Payment {
  final String reference;
  final double amount;

  final PaymentStatus status;
  _Payment(this.reference, this.amount, this.status);
}

var payments = [
  _Payment("REF-1390", 100, PaymentStatus.paid),
  _Payment("REF-1230", 200, PaymentStatus.due),
  _Payment("REF-1231", 300, PaymentStatus.sent),
  _Payment("REF-1232", 400, PaymentStatus.paid),
  _Payment("REF-1233", 500, PaymentStatus.due),
  _Payment("REF-1234", 600, PaymentStatus.sent),
  _Payment("REF-1235", 700, PaymentStatus.paid),
  _Payment("REF-1236", 800, PaymentStatus.due),
  _Payment("REF-1237", 900, PaymentStatus.sent),
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return LdScaffoldBody(
      addContainer: true,
      children: [
        LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m)),
              clipBehavior: Clip.hardEdge,
              child: Image.asset("liquid_flutter_icon.jpg", width: 64, height: 64),
            ),
            ldSpacerM,
            Flexible(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LdText.hl("Build for every platform \n with Liquid Flutter", textAlign: TextAlign.center),
                  LdMute(
                    child: LdText.ll(
                      "Cross platform design system for Flutter. With first class support for desktop and mobile.",
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LdTag(child: Text("Web")),
                      LdTag(child: Text("MacOS")),
                      LdTag(child: Text("Windows")),
                      LdTag(child: Text("Linux")),
                      LdTag(child: Text("Android")),
                      LdTag(child: Text("iOS")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).padL().padL().padL(),

        // Kitchen sink
        Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First column
                      Expanded(
                        child: LdAutoSpace(
                          children: [
                            LdCard(
                              footer: Row(
                                children: [
                                  LdButton.ghost(child: Icon(LucideIcons.star), onPressed: () {}),
                                  LdButton.ghost(child: Icon(LucideIcons.messageCircle), onPressed: () {}),
                                  LdButton.ghost(child: Icon(LucideIcons.userPlus), onPressed: () {}),
                                  LdButton.ghost(child: Icon(LucideIcons.share), onPressed: () {}),
                                  Spacer(),
                                  LdTag(child: Text("100")),
                                ],
                              ),
                              child: LdAutoSpace(
                                children: [
                                  Image.asset("assets/molecule.png"),
                                  LdText.h("GCGR Antagonist 13K"),
                                  LdText.p("Automatic Retrosynthesis"),
                                  LdMute(child: LdText.ls("11/01/24, 4:28 AM")),
                                ],
                              ),
                            ),
                            LdCard(
                              child: LdAutoSpace(
                                children: [
                                  LdText.l("Your download has started"),
                                  Row(
                                    children: [
                                      LdAvatar(child: LdLoader(size: 24)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LdText.p("Downloading..."),
                                            LdMute(child: LdText.ls("129MB / 1000MB ")),
                                          ],
                                        ),
                                      ),
                                      LdButton.outline(child: Text("Cancel"), onPressed: () {}),
                                    ],
                                  ).spaceM(),
                                ],
                              ),
                            ),
                            LdCard(
                              child: LdAutoSpace(
                                children: [
                                  LdText.h("Report an issue"),
                                  LdText.p("What area are you having problems with?"),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LdSelect(
                                          label: "Area",
                                          value: "ui",
                                          items: [
                                            LdSelectItem(child: Text("UI"), value: "ui"),
                                            LdSelectItem(child: Text("Functionality"), value: "functionality"),
                                            LdSelectItem(child: Text("Performance"), value: "performance"),
                                            LdSelectItem(child: Text("Other"), value: "other"),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: LdSelect(
                                          label: "Severity",
                                          value: "medium",
                                          items: [
                                            LdSelectItem(child: Text("Low"), value: "low"),
                                            LdSelectItem(child: Text("Medium"), value: "medium"),
                                            LdSelectItem(child: Text("High"), value: "high"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).spaceM(),
                                  LdInput(hint: "I need help with...", label: "Subject"),

                                  LdInput(
                                    hint: "Describe your issue in detail...",
                                    label: "Description",
                                    minLines: 3,
                                    maxLines: 5,
                                    textInputAction: TextInputAction.done,
                                  ),

                                  Row(
                                    children: [
                                      LdButton.ghost(child: Text("Cancel"), onPressed: () {}),
                                      LdButton(child: Text("Submit"), onPressed: () {}),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Second column
                      Expanded(
                        child: LdAutoSpace(
                          children: [
                            LdCard(
                              child: LdAutoSpace(
                                children: [
                                  LdText.h("Get Started"),
                                  LdInput(hint: "Email", label: "Email"),
                                  LdInput(hint: "Password", label: "Password"),
                                  LdCheckbox(checked: true, label: "Keep me signed in"),
                                  LdButton(onPressed: () {}, width: double.infinity, child: Text("Sign in")),
                                  Align(
                                    alignment: Alignment.center,
                                    child: LdMute(
                                      child: LdText(
                                        "Don't have an account? [Sign up](https://example.com/signup)",
                                        processLinks: true,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  LdDivider(),
                                  Align(
                                    alignment: Alignment.center,
                                    child: LdText.p("Or sign in with", textAlign: TextAlign.center),
                                  ),

                                  LdButton.outline(
                                    leading: Icon(LucideIcons.mail),
                                    onPressed: () {},
                                    width: double.infinity,
                                    alignment: MainAxisAlignment.center,
                                    child: Text("SSO"),
                                  ),
                                  LdButton.outline(
                                    leading: Icon(LucideIcons.github),
                                    onPressed: () {},
                                    alignment: MainAxisAlignment.center,
                                    width: double.infinity,
                                    child: Text("Github"),
                                  ),
                                ],
                              ),
                            ),
                            LdCard(
                              footer: Row(
                                children: [
                                  Expanded(
                                    child: LdAutoSpace(children: [LdText.l("v1.2.0"), LdText.caption("Firmware")]),
                                  ),
                                  Expanded(
                                    child: LdAutoSpace(
                                      children: [LdText.l("3 months ago"), LdText.caption("Last update")],
                                    ),
                                  ),
                                ],
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 100),
                                child: Image.asset("assets/scanner.png"),
                              ),
                            ),
                            LdCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [LdText.l("Sales"), Spacer(), Icon(LucideIcons.arrowRight, size: 16)]),
                                  ldSpacerL,
                                  LdCounter.l(value: 9452002),
                                  LdText.ls("+13% from last month"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).spaceL(),
                ),
                Expanded(
                  child: LdAutoSpace(
                    children: [
                      LdCard(
                        child: LdAutoSpace(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LdText.h("Payments", lineHeight: 1),
                                    LdMute(child: LdText.ls("Manage your payments")),
                                  ],
                                ),
                                Spacer(),
                                LdButton(
                                  trailing: Icon(LucideIcons.arrowDown),
                                  onPressed: () {},
                                  child: Text("Export"),
                                ),
                              ],
                            ),
                            LdTable<_Payment>(
                              columns: [
                                LdCol(title: "Status"),
                                LdCol(title: "Date", weight: 2),
                                LdCol(title: "Amount", weight: 2),
                              ],
                              rowCount: payments.length,
                              rows: payments,
                              buildRow: (row) {
                                return [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: switch (row.status) {
                                      PaymentStatus.paid => LdTag(child: Text("Paid")),
                                      PaymentStatus.due => LdTag.error(child: Text("Due")),
                                      PaymentStatus.sent => LdTag.success(child: Text("Sent")),
                                    },
                                  ),
                                  Text(row.reference),
                                  Text(row.amount.toString()),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LdCard(
                              child: LdAutoSpace(
                                children: [
                                  Row(
                                    children: [
                                      LdAvatar(child: Text("S")),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LdText.hs("Sarah Johnson"),
                                            LdMute(child: LdText.ls("sarah.johnson@example.com")),
                                          ],
                                        ),
                                      ),

                                      LdButton.ghost(child: Icon(LucideIcons.plus), onPressed: () {}),
                                    ],
                                  ).spaceM(),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: theme.radius(LdSize.m),
                                      color: theme.background,
                                    ),
                                    padding: theme.pad(size: LdSize.m),
                                    child: Text("Hi, how can I help you today?"),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: theme.radius(LdSize.m),
                                        color: theme.primaryColor,
                                      ),
                                      padding: theme.pad(size: LdSize.m),
                                      child: Text(
                                        "Hello, I'm having trouble signing in",
                                        style: TextStyle(color: theme.primaryColorText),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: theme.radius(LdSize.m),
                                      color: theme.background,
                                    ),
                                    padding: theme.pad(size: LdSize.m),
                                    child: Text("Okay, I'll help you with that"),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: theme.radius(LdSize.m),
                                        color: theme.primaryColor,
                                      ),
                                      padding: theme.pad(size: LdSize.m),
                                      child: Text(
                                        "Thank you for helping me!",
                                        style: TextStyle(color: theme.primaryColorText),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: LdInput(hint: "Type your message...")),
                                      LdButton(child: Icon(LucideIcons.send), onPressed: () {}),
                                    ],
                                  ).spaceM(),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: LdCard(
                              child: LdAutoSpace(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  LdText.h("Stock level", textAlign: TextAlign.center),
                                  LdMute(child: LdText.ls("0.5l remaining.", textAlign: TextAlign.center)),
                                  LdOrb(0.5),
                                  LdDivider(),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      LdButton(child: Text("Add stock"), onPressed: () {}),
                                      LdButton.outline(child: Text("Refill"), onPressed: () {}),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).spaceL(),
                    ],
                  ),
                ),
              ],
            ).spaceL().padS(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 0.8],
                      colors: [theme.background.withAlpha(0), theme.background],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Intro
        LdAutoSpace(
          children: [
            const LdDivider(),
            ldSpacerL,
            LdText.hs("Demos"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LdButton(
                  mode: LdButtonMode.outline,
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {
                    context.push("/chemical");
                  },
                  child: const Text("Chemical Inventory"),
                ),
                LdButton(
                  mode: LdButtonMode.outline,
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {
                    context.go("/task-demo");
                  },
                  child: const Text("Task Demo"),
                ),
                LdButton(
                  mode: LdButtonMode.outline,
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {
                    context.go("/components/bento-gallery");
                  },
                  child: const Text("Widget Gallery"),
                ),
              ],
            ),
            const LdDivider(),
            LdText.h("Getting Started"),
            LdText.p("To get started using liquid flutter please add it as a dependency to your project:"),
            const CodeBlock(language: "sh", code: """flutter pub add liquid_flutter"""),
            LdAccordion.fromList([
              LdAccordionItem(
                child: const CodeBlock(
                  language: "sh",
                  code: """
                flutter pub add liquid_flutter_emd_theme
                """,
                ),
                header: const Text("EMD Corporate theme installation"),
              ),
            ], wrapActiveInCard: true),
            LdText.p(
              "Setup a Liquid Theme at the top of your application. This will  be used to provide the color theme to all components via context.",
            ),
            const CodeBlock(
              code: """
                LdThemeProvider(
                  theme: // Optionally provide an instance of LdTheme(),
                  child: ...
                )""",
            ),
            LdText.p(
              "To automatically keep the material theme in sync with the Liquid theme use the LdThemedAppBuilder. This will also rebuild the entire app in case you change the liquid theme at runtime.",
            ),
            const CodeBlock(
              code: """
                LdThemeProvider(
                  child: LdThemedAppBuilder(appBuilder: (context, theme) {
                    return MaterialApp(
                      title: 'Liquid Design Demo',
                      theme: theme,
                    );
                  })
                )""",
            ),
            LdText.p(
              "You can now also access the Liquid theme via the LdTheme.of(context) method. This will return the LdTheme object which contains all the colors and other theme related properties.",
            ),
            const CodeBlock(code: """var theme = LdTheme.of(context);"""),
            LdText.p(
              "You can now use the components in your app. Please refer to the documentation for more information.",
            ),
          ],
        ),
      ],
    );
  }
}
