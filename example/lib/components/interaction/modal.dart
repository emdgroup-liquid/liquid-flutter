import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ModalDemo extends StatefulWidget {
  const ModalDemo({super.key});

  @override
  State<ModalDemo> createState() => _ModalDemoState();
}

class _DemoSheet extends StatelessWidget {
  final bool enableScaling;
  final bool fixedDialogSize;
  final LdModalTypeMode mode;
  final bool useScreenRadius;
  final bool enableHeader;
  final bool userDismissable;
  final bool enableInsets;
  final bool enableFooter;

  const _DemoSheet({
    required this.mode,
    required this.enableScaling,
    required this.fixedDialogSize,
    required this.useScreenRadius,
    required this.enableHeader,
    required this.userDismissable,
    required this.enableInsets,
    required this.enableFooter,
  });

  @override
  Widget build(BuildContext context) {
    return LdModalBuilder(
        useRootNavigator: true,
        builder: (context, openSheet) {
          return LdButton(
            onPressed: () async {
              final result = (await openSheet()) as String?;
              if (!context.mounted) return;
              LdNotificationsController.of(context).success(result.toString());
            },
            child: const Text("Open modal"),
          );
        },
        modal: LdModalRoute(
            context: context,
            modalTypeMode: mode,
            barrierDismissible: userDismissable,
            fixedDialogSize: fixedDialogSize ? const Size(400, 400) : null,
            pageBuilder: (context) => LdScaffold(
                  appBars: [
                    LdAppBar(
                      title: const Text("Modal"),
                    ),
                    LdAppBar(
                      positionMode: LdAppBarPositionMode.bottom,
                      actions: [
                        LdFlexibleChild(
                          child: LdButton.vague(
                            width: double.infinity,
                            color: LdTheme.of(context).error,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                        ),
                        LdFlexibleChild(
                          child: LdButton.vague(
                            width: double.infinity,
                            onPressed: () {
                              Navigator.of(context).pop("Hello world");
                            },
                            child: const Text("Confirm"),
                          ),
                        ),
                      ],
                    ),
                  ],
                  body: LdScaffoldBody(
                    children: [
                      LdText.p(
                          "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                      Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: LdText.p(
                            "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                      ),
                      LdText.p(
                          "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                      LdText.ps("Filler text by http://officeipsum.com/index.php"),
                      Row(
                        children: [
                          _DemoSheet(
                            enableHeader: enableHeader,
                            enableInsets: enableInsets,
                            enableScaling: enableScaling,
                            fixedDialogSize: fixedDialogSize,
                            enableFooter: enableFooter,
                            mode: mode,
                            useScreenRadius: useScreenRadius,
                            userDismissable: userDismissable,
                          ),
                          ldSpacerM,
                          LdButton(
                            child: const Text("Return a result"),
                            onPressed: () {
                              Navigator.of(context).pop("Hello world");
                            },
                          ),
                        ],
                      ),
                      LdSelect(
                        items: [
                          LdSelectItem(value: "item1", child: const Text("Item 1")),
                          LdSelectItem(value: "item2", child: const Text("Item 2")),
                          LdSelectItem(value: "item3", child: const Text("Item 3")),
                        ],
                      ),
                    ],
                  ),
                )));
  }
}

class _ModalDemoState extends State<ModalDemo> {
  bool _enableScaling = true;

  bool _useScreenRadius = false;

  bool _userDismissable = true;

  bool _fixedDialogSize = false;

  bool _enableHeader = true;

  bool _enableFooter = true;

  bool _enableInset = false;

  LdModalTypeMode mode = LdModalTypeMode.auto;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        path: "lib/components/interaction/modal.dart",
        title: "LdModal",
        apiComponents: const ["LdModal", "LdModalBuilder", "LdModalPage"],
        demo: LdAutoSpace(
          children: [
            LdText(
              "Allows to place content in a modal that overlays the current screen. "
              "Liquid Modals are based on the [wolt_modal_sheet](https://pub.dev/packages/wolt_modal_sheet) package. The LdModal components provide an easy wrapper around the existing APIs to make it easier to use in Liquid applications.",
              processLinks: true,
              onLinkTap: (link) {
                launchUrl(Uri.parse(link));
              },
            ),
            LdText.h("LdModalBuilder"),
            const LdText(
              "The LdModalBuilder is a utility widget that displays a modal when a button is pressed. Attention: This requries a LdPortal at the root of your application if you want to enable the scaling effect.",
            ),
            const CodeBlock(code: """
                LdModalBuilder(
                  builder: (context, openModal) {
                    return LdButton(
                      onPressed: openSheet,
                      child: const Text("Open Modal"),
                    );
                  },
                  modal: LdModal(
                    modalContent: (
                      context,
                    ) =>
                       Text("My content")
                    ),
                  ),
                ),
            """),
            ComponentWell(
              child: Center(
                child: _DemoSheet(
                  enableInsets: _enableInset,
                  fixedDialogSize: _fixedDialogSize,
                  enableHeader: _enableHeader,
                  enableFooter: _enableFooter,
                  mode: mode,
                  enableScaling: _enableScaling,
                  useScreenRadius: _useScreenRadius,
                  userDismissable: _userDismissable,
                ),
              ),
            ),
            LdToggle(
              label: "Header enabled",
              checked: _enableHeader,
              onChanged: (value) {
                setState(() {
                  _enableHeader = value;
                });
              },
            ),
            LdToggle(
              label: "Insets enabled",
              checked: _enableInset,
              onChanged: (value) {
                setState(() {
                  _enableInset = value;
                });
              },
            ),
            LdToggle(
              label: "Use screen radius",
              checked: _useScreenRadius,
              onChanged: (value) {
                setState(() {
                  _useScreenRadius = value;
                  if (value) {
                    _enableFooter = false;
                  }
                });
              },
            ),
            LdToggle(
              label: "Fixed size (dialog only)",
              checked: _fixedDialogSize,
              onChanged: (value) {
                setState(() {
                  _fixedDialogSize = value;
                });
              },
            ),
            LdToggle(
              label: "User dismissable",
              checked: _userDismissable,
              onChanged: (value) {
                setState(() {
                  _userDismissable = value;
                });
              },
            ),
            LdToggle(
              label: "Enable scaling (by default enabled on iOS)",
              checked: _enableScaling,
              onChanged: (value) {
                setState(() {
                  _enableScaling = value;
                });
              },
            ),
            LdToggle(
              label: "Enable footer",
              checked: _enableFooter,
              onChanged: (value) {
                setState(() {
                  _enableFooter = value;
                });
              },
            ),
            LdSwitch(
              children: const {
                LdModalTypeMode.auto: Text("Auto"),
                LdModalTypeMode.sheet: Text("Sheet"),
                LdModalTypeMode.dialog: Text("Dialog"),
              },
              value: mode,
              onChanged: (value) {
                setState(
                  () {
                    mode = value;
                  },
                );
              },
            ),
            LdText.h("LdModalPage"),
            LdText.p(
                "If your application uses GoRouter, you can use the LdModalPage to open a modal when a route is visited."),
            LdText.p(
              "This has the advantage that the modal is automatically in sync with the current navigation path.",
            ),
            const CodeBlock(code: """
              GoRoute(
                path: "/my-page",
                pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: /// The normal page to display
                    ),
                routes: [
                  GoRoute(
                    path: "my-modal",
                    pageBuilder: (context, state) => LdModalPage(
                      builder: LdModal(
                        title: const Text("This is a title"),
                        modalContent: (context) {
                          return const Text("This is modal content");
                        },
                      ),
                    ),
                  )
                ]
              ),
            """),
            LdButton(
              leading: const Icon(LucideIcons.squareArrowOutUpRight),
              onPressed: () {
                context.push("/components/modal/my-modal");
              },
              child: const Text("Open route example"),
            ),
            const LdDivider(),
            LdText.h("Confirm modal"),
            LdButton(
              child: const Text("Open confirm modal"),
              onPressed: () async {
                final result = await ldConfirmModal(
                  context: context,
                  description: "Are you sure you want to delete this item?",
                  confirmColor: LdTheme.of(context).error,
                  cancelColor: LdTheme.of(context).primary,
                  positive: const Text("Delete"),
                  negative: const Text("Cancel"),
                  useRootNavigator: true,
                );

                if (!context.mounted) return;
                if (result) {
                  LdNotificationsController.of(context).success("Confirmed");
                } else {
                  LdNotificationsController.of(context).error("Cancelled");
                }
              },
            ),
            LdText.h("Modal with aspect ratio"),
            LdModalBuilder(
              useRootNavigator: true,
              builder: (context, openModal) {
                return LdButton(
                  onPressed: openModal,
                  child: const Text("Open modal"),
                );
              },
              modal: LdModalRoute(
                context: context,
                scaleParent: false,
                sheetAspectRatio: 1.1,
                sheetInsets: const EdgeInsets.all(10),
                sheetBorderRadius: BorderRadius.circular(LdTheme.of(context).screenRadius / 2 - 5),
                pageBuilder: (context2) => LdScaffold(
                  body: Center(
                    child: LdText("This is a modal with screen radius"),
                  ),
                ),
              ),
            ),
            LdText.h("Modal with action button"),
            LdModalBuilder(
              useRootNavigator: true,
              builder: (context, openModal) {
                return LdButton(
                  onPressed: openModal,
                  child: const Text("Open modal"),
                );
              },
              modal: LdModalRoute(
                context: context,
                pageBuilder: (context) => LdScaffold(
                  appBars: [
                    LdAppBar(
                      title: const Text("This is a modal with action button"),
                    ),
                  ],
                  body: LdScaffoldBody(
                    children: [
                      LdText("This is a modal with action button"),
                      LdButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LdText.h("Modal with list items"),
            LdModalBuilder(
              useRootNavigator: true,
              builder: (context, openModal) {
                return LdButton(
                  onPressed: openModal,
                  child: const Text("Open modal"),
                );
              },
              modal: LdModalRoute(
                context: context,
                pageBuilder: (context) => LdScaffold(
                  appBars: [
                    LdAppBar(
                      title: const Text("Modal with list items"),
                    ),
                  ],
                  body: LdScaffoldBody(
                    minimumPadding: EdgeInsets.zero,
                    children: [
                      LdListItem(
                        title: const Text("Item 1"),
                        subtitle: const Text("Subtitle"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      LdListItem(
                        title: const Text("Item 2"),
                        subtitle: const Text("Subtitle"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
