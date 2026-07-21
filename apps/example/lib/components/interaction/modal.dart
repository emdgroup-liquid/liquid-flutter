import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
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
  final double insetValue;
  final bool enableFooter;
  final bool useRootNavigator;

  const _DemoSheet({
    required this.mode,
    required this.enableScaling,
    required this.fixedDialogSize,
    required this.useScreenRadius,
    required this.enableHeader,
    required this.userDismissable,
    required this.insetValue,
    required this.useRootNavigator,
    required this.enableFooter,
  });

  @override
  Widget build(BuildContext context) {
    return LdModalBuilder(
      useRootNavigator: useRootNavigator,
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
        scaleParent: enableScaling,
        fixedDialogSize: fixedDialogSize ? const Size(400, 400) : null,
        sheetInsets: insetValue > 0 ? EdgeInsets.all(insetValue) : EdgeInsets.zero,
        sheetBorderRadius: useScreenRadius ? BorderRadius.circular(LdTheme.of(context).screenRadius / 2) : null,
        pageBuilder: (context) {
          final modalBody = LdScaffoldBody(
            children: [
              LdText.p(
                "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position.",
              ),
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: LdText.p(
                  "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position.",
                ),
              ),
              LdText.p(
                "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position.",
              ),
              LdText.ps("Filler text by http://officeipsum.com/index.php"),
              Row(
                children: [
                  _DemoSheet(
                    useRootNavigator: useRootNavigator,
                    enableHeader: enableHeader,
                    insetValue: insetValue,
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
          );

          // Build the footer bar conditionally
          final Widget bodyWithFooter = enableFooter
              ? LdAppBar(
                  positionMode: LdAppBarPositionMode.bottom,
                  actions: [
                    LdFlexibleChild(
                      child: LdButton.vague(
                        width: double.infinity,
                        size: LdSize.l,
                        color: LdTheme.of(context).error,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    LdFlexibleChild(
                      child: LdButton.vague(
                        size: LdSize.l,
                        width: double.infinity,
                        onPressed: () {
                          Navigator.of(context).pop("Hello world");
                        },
                        child: const Text("Confirm"),
                      ),
                    ),
                  ],
                  child: modalBody,
                )
              : modalBody;

          // Build the header bar conditionally
          final Widget scaffoldBody = enableHeader
              ? LdAppBar(title: const Text("Modal"), debugName: "Modal Demo", child: bodyWithFooter)
              : bodyWithFooter;

          return LdScaffold(body: scaffoldBody);
        },
      ),
    );
  }
}

enum _TextModalKeyboardType { text, email, number }

enum _TextModalInputAction { done, next, search }

enum _TextModalValidator { none, minLength, noSpaces }

class _EnterTextModalDemo extends StatefulWidget {
  const _EnterTextModalDemo();

  @override
  State<_EnterTextModalDemo> createState() => _EnterTextModalDemoState();
}

class _EnterTextModalDemoState extends State<_EnterTextModalDemo> {
  final TextEditingController _titleController = TextEditingController(text: "Rename item");
  final TextEditingController _descriptionController = TextEditingController(
    text: "Enter a new name for the selected item.",
  );
  final TextEditingController _initialValueController = TextEditingController(text: "Draft item");
  final TextEditingController _hintController = TextEditingController(text: "Item name");
  final TextEditingController _labelController = TextEditingController(text: "Name");

  bool _useCustomTitle = true;
  bool _showDescription = true;
  bool _showAdditionalContent = true;
  bool _allowEmpty = false;
  bool _obscureText = false;
  bool _allowDismiss = true;
  bool _requireChange = false;
  bool _useRootNavigator = true;
  _TextModalKeyboardType _keyboardType = _TextModalKeyboardType.text;
  _TextModalInputAction _textInputAction = _TextModalInputAction.done;
  _TextModalValidator _validator = _TextModalValidator.none;
  String? _lastResult;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _initialValueController.dispose();
    _hintController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  TextInputType get _selectedKeyboardType {
    return switch (_keyboardType) {
      _TextModalKeyboardType.text => TextInputType.text,
      _TextModalKeyboardType.email => TextInputType.emailAddress,
      _TextModalKeyboardType.number => TextInputType.number,
    };
  }

  TextInputAction get _selectedTextInputAction {
    return switch (_textInputAction) {
      _TextModalInputAction.done => TextInputAction.done,
      _TextModalInputAction.next => TextInputAction.next,
      _TextModalInputAction.search => TextInputAction.search,
    };
  }

  bool Function(String input)? get _selectedValidator {
    return switch (_validator) {
      _TextModalValidator.none => null,
      _TextModalValidator.minLength => (input) => input.trim().length >= 4,
      _TextModalValidator.noSpaces => (input) => !input.contains(" "),
    };
  }

  Widget? _buildAdditionalContent(BuildContext context) {
    if (!_showAdditionalContent) return null;

    return LdHint(
      type: LdHintType.info,
      child: LdText.p("Additional content can explain validation rules or provide context before the input."),
    );
  }

  Future<void> _openTextModal() async {
    final result = await ldEnterTextModal(
      context: context,
      title: _useCustomTitle ? Text(_titleController.text) : null,
      description: _showDescription ? _descriptionController.text : null,
      additionalContent: _buildAdditionalContent(context),
      initialValue: _initialValueController.text,
      inputHint: _hintController.text,
      inputLabel: _labelController.text,
      allowEmpty: _allowEmpty,
      obscureText: _obscureText,
      keyboardType: _selectedKeyboardType,
      textInputAction: _selectedTextInputAction,
      validate: _selectedValidator,
      allowDismiss: _allowDismiss,
      requireChange: _requireChange,
      useRootNavigator: _useRootNavigator,
    );

    if (!mounted) return;

    setState(() {
      _lastResult = result;
    });

    if (result == null) {
      LdNotificationsController.of(context).error("Text modal cancelled");
    } else {
      LdNotificationsController.of(context).success("Submitted: $result");
    }
  }

  void _updateTextPreview(String _) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final resultText = switch (_lastResult) {
      null => "No value submitted yet.",
      "" => "Last result: empty string",
      _ => "Last result: $_lastResult",
    };

    return LdAutoSpace(
      children: [
        LdText.h("Text input modal"),
        LdText.p(
          "Play with the parameters passed to ldEnterTextModal and open the modal to see how they affect the title, input, validation, buttons, and result.",
        ),
        ComponentWell(
          child: Center(
            child: LdButton(onPressed: _openTextModal, child: const Text("Open text input modal")),
          ),
        ),
        LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              LdListItem(
                title: const Text("Result"),
                subtitle: Text(resultText),
                leading: const Icon(LucideIcons.messageSquareText),
              ),
            ],
          ),
        ),
        LdText.l("Content"),
        LdInput(controller: _titleController, label: "Title", hint: "Modal title", onChanged: _updateTextPreview),
        LdInput(
          controller: _descriptionController,
          label: "Description",
          hint: "Helpful modal description",
          onChanged: _updateTextPreview,
        ),
        LdInput(
          controller: _initialValueController,
          label: "Initial value",
          hint: "Initial value",
          onChanged: _updateTextPreview,
        ),
        LdInput(
          controller: _hintController,
          label: "Input hint",
          hint: "Placeholder text",
          onChanged: _updateTextPreview,
        ),
        LdInput(controller: _labelController, label: "Input label", hint: "Input label", onChanged: _updateTextPreview),
        Wrap(
          spacing: theme.pad().horizontal / 2,
          runSpacing: theme.pad().vertical / 2,
          children: [
            LdToggle(
              label: "Custom title",
              checked: _useCustomTitle,
              onChanged: (value) {
                setState(() {
                  _useCustomTitle = value;
                });
              },
            ),
            LdToggle(
              label: "Description",
              checked: _showDescription,
              onChanged: (value) {
                setState(() {
                  _showDescription = value;
                });
              },
            ),
            LdToggle(
              label: "Additional content",
              checked: _showAdditionalContent,
              onChanged: (value) {
                setState(() {
                  _showAdditionalContent = value;
                });
              },
            ),
          ],
        ),
        LdText.l("Submission rules"),
        Wrap(
          spacing: theme.pad().horizontal / 2,
          runSpacing: theme.pad().vertical / 2,
          children: [
            LdToggle(
              label: "Allow empty",
              checked: _allowEmpty,
              onChanged: (value) {
                setState(() {
                  _allowEmpty = value;
                });
              },
            ),
            LdToggle(
              label: "Require change",
              checked: _requireChange,
              onChanged: (value) {
                setState(() {
                  _requireChange = value;
                });
              },
            ),
          ],
        ),
        LdSwitch<_TextModalValidator>(
          label: "Validator",
          children: const {
            _TextModalValidator.none: Text("None"),
            _TextModalValidator.minLength: Text("Min 4"),
            _TextModalValidator.noSpaces: Text("No spaces"),
          },
          value: _validator,
          onChanged: (value) {
            setState(() {
              _validator = value;
            });
          },
        ),
        LdText.l("Input behavior"),
        Wrap(
          spacing: theme.pad().horizontal / 2,
          runSpacing: theme.pad().vertical / 2,
          children: [
            LdToggle(
              label: "Obscure text",
              checked: _obscureText,
              onChanged: (value) {
                setState(() {
                  _obscureText = value;
                });
              },
            ),
          ],
        ),
        LdSwitch<_TextModalKeyboardType>(
          label: "Keyboard type",
          children: const {
            _TextModalKeyboardType.text: Text("Text"),
            _TextModalKeyboardType.email: Text("Email"),
            _TextModalKeyboardType.number: Text("Number"),
          },
          value: _keyboardType,
          onChanged: (value) {
            setState(() {
              _keyboardType = value;
            });
          },
        ),
        LdSwitch<_TextModalInputAction>(
          label: "Text input action",
          children: const {
            _TextModalInputAction.done: Text("Done"),
            _TextModalInputAction.next: Text("Next"),
            _TextModalInputAction.search: Text("Search"),
          },
          value: _textInputAction,
          onChanged: (value) {
            setState(() {
              _textInputAction = value;
            });
          },
        ),
        LdText.l("Route behavior"),
        Wrap(
          spacing: theme.pad().horizontal / 2,
          runSpacing: theme.pad().vertical / 2,
          children: [
            LdToggle(
              label: "Allow dismiss",
              checked: _allowDismiss,
              onChanged: (value) {
                setState(() {
                  _allowDismiss = value;
                });
              },
            ),
            LdToggle(
              label: "Use root navigator",
              checked: _useRootNavigator,
              onChanged: (value) {
                setState(() {
                  _useRootNavigator = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ModalDemoState extends State<ModalDemo> {
  bool _enableScaling = true;

  bool _useScreenRadius = false;

  bool _userDismissable = true;

  bool _useRootNavigator = true;

  bool _fixedDialogSize = false;

  bool _enableHeader = true;

  bool _enableFooter = true;

  double _insetValue = 0;

  LdModalTypeMode mode = LdModalTypeMode.auto;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/interaction/modal.dart",
      title: "LdModal",
      apiComponents: const ["LdModalRoute", "LdModalBuilder", "LdModalPage"],
      demo: LdAutoSpace(
        children: [
          LdText(
            "Allows to place content in a modal that overlays the current screen.",
            onLinkTap: (link) {
              launchUrl(Uri.parse(link));
            },
          ),
          ComponentWell(
            child: Center(
              child: _DemoSheet(
                useRootNavigator: _useRootNavigator,
                insetValue: _insetValue,
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
          LdText.l("Sheet insets"),
          LdSwitch(
            children: {0.0: const Text("0"), 8.0: const Text("8"), 16.0: const Text("16"), 32.0: const Text("32")},
            value: _insetValue,
            onChanged: (value) {
              setState(() {
                _insetValue = value;
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
          LdToggle(
            label: "Use root navigator",
            checked: _useRootNavigator,
            onChanged: (value) {
              setState(() {
                _useRootNavigator = value;
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
              setState(() {
                mode = value;
              });
            },
          ),
          LdText.h("LdModalBuilder"),
          const LdText(
            "The LdModalBuilder is a utility widget that displays a modal when a button is pressed. It takes a builder function that creates a button and an LdModalRoute that defines the modal content.",
          ),
          const CodeBlock(
            code: """
                LdModalBuilder(
                  builder: (context, openModal) {
                    return LdButton(
                      onPressed: openModal,
                      child: const Text("Open Modal"),
                    );
                  },
                  modal: LdModalRoute(
                    context: context,
                    pageBuilder: (context) => LdScaffold(
                      body: LdScaffoldBody(
                        children: [
                          LdText("My content"),
                        ],
                      ),
                    ),
                  ),
                ),
            """,
          ),
          LdText.h("LdModalPage"),
          LdText.p(
            "If your application uses GoRouter, you can use the LdModalPage to open a modal when a route is visited.",
          ),
          LdText.p("This has the advantage that the modal is automatically in sync with the current navigation path."),
          const CodeBlock(
            code: """
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
                      builder: (context) => LdModalRoute(
                        context: context,
                        pageBuilder: (context) => LdScaffold(
                          body: LdAppBar(
                            title: const Text("This is a title"),
                            child: LdScaffoldBody(
                              children: [
                                LdText("This is modal content"),
                              ],
                            ),
                          ),
                         ),
                      ),
                    ),
                  )
                ]
              ),
            """,
          ),
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
              if (result == true) {
                LdNotificationsController.of(context).success("Confirmed");
              } else if (result == false) {
                LdNotificationsController.of(context).error("Cancelled");
              } else {
                LdNotificationsController.of(context).error("Modal dismissed");
              }
            },
          ),
          const LdDivider(),
          const _EnterTextModalDemo(),
          LdText.h("Modal with aspect ratio"),
          LdModalBuilder(
            useRootNavigator: true,
            builder: (context, openModal) {
              return LdButton(onPressed: openModal, child: const Text("Open modal"));
            },
            modal: LdModalRoute(
              context: context,
              scaleParent: false,
              sheetAspectRatio: 1,
              sheetInsets: const EdgeInsets.all(4),
              sheetBorderRadius: BorderRadius.circular(LdTheme.of(context).screenRadius * 2 - 4),
              pageBuilder: (context2) => LdScaffold(body: Center(child: LdText("This is a modal with screen radius"))),
            ),
          ),
          LdText.h("Modal with action button"),
          LdModalBuilder(
            useRootNavigator: true,
            builder: (context, openModal) {
              return LdButton(onPressed: openModal, child: const Text("Open modal"));
            },
            modal: LdModalRoute(
              context: context,
              pageBuilder: (context) => LdScaffold(
                body: LdAppBar(
                  title: const Text("This is a modal with action button"),
                  child: LdScaffoldBody(
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
          ),
          LdText.h("Modal with list items"),
          LdModalBuilder(
            useRootNavigator: true,
            builder: (context, openModal) {
              return LdButton(onPressed: openModal, child: const Text("Open modal"));
            },
            modal: LdModalRoute(
              context: context,
              pageBuilder: (context) => LdScaffold(
                body: LdAppBar(
                  title: const Text("Modal with list items"),
                  child: LdScaffoldBody(
                    shrinkWrap: true,
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
          ),
        ],
      ),
    );
  }
}
