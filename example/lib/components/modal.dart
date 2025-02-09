import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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

  const _DemoSheet({
    required this.mode,
    required this.enableScaling,
    required this.fixedDialogSize,
    required this.useScreenRadius,
    required this.enableHeader,
    required this.userDismissable,
    required this.enableInsets,
  });

  @override
  Widget build(BuildContext context) {
    return LdModalBuilder(
      builder: (context, openSheet) {
        return LdButton(
          onPressed: () async {
            final result = (await openSheet()) as String?;

            LdNotificationsController.of(context).success(result.toString());
          },
          child: const Text("Open modal"),
        );
      },
      modal: LdModal(
          mode: mode,
          enableScaling: enableScaling,

          //showDragHandle: true,
          userCanDismiss: userDismissable,
          fixedDialogSize: fixedDialogSize ? const Size(400, 400) : null,
          useSafeArea: !useScreenRadius,
          title: !enableHeader ? null : const Text("Title"),
          insets: useScreenRadius
              ? EdgeInsets.only(
                  left: 0,
                  right: 5,
                  bottom: MediaQuery.paddingOf(
                              Scaffold.maybeOf(context)?.context ?? context)
                          .bottom /
                      2,
                )
              : (enableInsets
                  ? const EdgeInsets.symmetric(horizontal: 32)
                  : EdgeInsets.zero),
          topRadius:
              useScreenRadius ? LdTheme.of(context).screenRadius - 2.5 : null,
          bottomRadius:
              useScreenRadius ? LdTheme.of(context).screenRadius - 2.5 : null,
          modalContent: (
            context,
          ) =>
              LdAutoSpace(
                children: [
                  _DemoSheet(
                    enableHeader: enableHeader,
                    enableInsets: enableInsets,
                    enableScaling: enableScaling,
                    fixedDialogSize: fixedDialogSize,
                    mode: mode,
                    useScreenRadius: useScreenRadius,
                    userDismissable: userDismissable,
                  ),
                  const LdTextP(
                      "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                  const LdTextP(
                      "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                  const LdTextPs(
                      "Filler text by http://officeipsum.com/index.php"),
                  LdButton(
                    child: const Text("Return a result"),
                    onPressed: () {
                      Navigator.of(context).pop("Hello world");
                    },
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                ],
              )),
    );
  }
}

class _ModalDemoState extends State<ModalDemo> {
  bool _enableScaling = true;

  bool _useScreenRadius = false;

  bool _userDismissable = true;

  bool _fixedDialogSize = false;

  bool _enableHeader = true;

  bool _enableInset = false;

  LdModalTypeMode mode = LdModalTypeMode.auto;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "LdModal",
        apiComponents: const ["LdModal", "LdModalBuilder", "LdModalPage"],
        demo: LdAutoSpace(
          children: [
            const LdText(
              "Allows to place content in a modal that overlays the current screen. "
              "Liquid Modals are based on the https://pub.dev/packages/wolt_modal_sheet package. The LdModal components provide an easy wrapper around the existing APIs to make it easier to use in Liquid applications.",
            ),
            const LdTextH("LdModalBuilder"),
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
            const LdTextH("LdModalPage"),
            const LdTextP(
                "If your application uses GoRouter, you can use the LdModalPage to open a modal when a route is visited."),
            const LdTextP(
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
                child: const Text("Open route example"),
                leading: const Icon(Icons.open_in_new),
                onPressed: () {
                  context.push("/components/modal/my-modal");
                }),
          ],
        ));
  }
}
