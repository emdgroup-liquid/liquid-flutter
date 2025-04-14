import 'package:flutter/material.dart';
import 'package:liquid/color_selector.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});

  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  LdSize _size = LdSize.m;
  bool _disabled = false;
  bool _active = false;
  LdButtonMode _mode = LdButtonMode.filled;

  late LdColor _color;

  @override
  void initState() {
    _color = LdTheme.of(context).palette.primary;
    super.initState();
  }

  void _changeSize(LdSize? size) {
    setState(() {
      _size = size ?? LdSize.m;
    });
  }

  void _changeActive(bool? active) {
    setState(() {
      _active = active ?? false;
    });
  }

  void _changeDisabled(bool? disabled) {
    setState(() {
      _disabled = disabled ?? false;
    });
  }

  void _changeMode(LdButtonMode? mode) {
    setState(() {
      _mode = mode ?? LdButtonMode.filled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "LdButton",
        apiComponents: const [
          "LdButton",
          "LdButtonGhost",
        ],
        demo: LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdBundle(
              children: [
                ComponentWell(
                    onSurface: true,
                    child: Center(
                      child: Column(
                        children: [
                          /*begin demo:LdButton*/
                          LdButton(
                            color: _color,
                            mode: _mode,
                            active: _active,
                            disabled: _disabled,
                            leading: const Icon(Icons.donut_large),
                            size: _size,
                            onPressed: () async {
                              await Future.delayed(const Duration(seconds: 1));
                            },
                            child: const Text("Button"),
                          ),
                          /*end demo:LdButton*/
                        ],
                      ),
                    )),
                LdBundle(
                  children: [
                    LdSelect<LdButtonMode>(
                        value: _mode,
                        label: "Mode",
                        items: const [
                          LdSelectItem(
                              child: Text("Filled"),
                              value: LdButtonMode.filled),
                          LdSelectItem(
                              child: Text("Outline"),
                              value: LdButtonMode.outline),
                          LdSelectItem(
                              child: Text("Ghost"), value: LdButtonMode.ghost),
                          LdSelectItem(
                              child: Text("Vague"), value: LdButtonMode.vague),
                        ],
                        onChange: _changeMode),
                  ],
                ),
                LdBundle(
                  children: [
                    const LdTextL("Color"),
                    ColorSelctor(
                        active: _color,
                        colors: {
                          "primary": LdTheme.of(context).palette.primary,
                          "secondary": LdTheme.of(context).palette.secondary,
                          "success": LdTheme.of(context).palette.success,
                          "warning": LdTheme.of(context).palette.warning,
                          "error": LdTheme.of(context).palette.error,
                        },
                        onChanged: (p0) {
                          setState(() {
                            _color = p0;
                          });
                        }),
                  ],
                ),
                LdBundle(
                  children: [
                    LdSelect<LdSize>(
                        value: _size,
                        label: "Size",
                        items: const [
                          LdSelectItem(
                              child: Text("Extra Small (XS)"),
                              value: LdSize.xs),
                          LdSelectItem(
                              child: Text("Small (S)"), value: LdSize.s),
                          LdSelectItem(
                              child: Text("Medium (M)"), value: LdSize.m),
                          LdSelectItem(
                              child: Text("Large (L)"), value: LdSize.l),
                        ],
                        onChange: _changeSize),
                  ],
                ),
                LdToggle(
                  checked: _disabled,
                  onChanged: _changeDisabled,
                  label: "Disabled",
                ),
                LdToggle(
                  checked: _active,
                  onChanged: _changeActive,
                  label: "Active",
                ),
              ],
            ),
            LdBundle(
              children: [
                const LdTextH("Variants"),
                const LdTextHs(
                  "Producing error",
                ),
                const LdTextP(
                  "An exception thrown in  the onPressed callback will "
                  "automatically produce an error indication by turning the button red",
                ),
                ComponentWell(
                  child: Center(
                    child: Column(
                      children: [
                        /*begin demo:LdButtonError*/
                        LdButton(
                          mode: LdButtonMode.filled,
                          color: LdTheme.of(context).warning,
                          onPressed: () async {
                            await Future.delayed(
                              const Duration(seconds: 1),
                            );

                            throw LdException(
                              message: "Told you!",
                            );
                          },
                          child: const Text("I won't work"),
                        ),
                        /*end demo:LdButtonError*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
            LdBundle(
              children: [
                const LdTextHs(
                  "Leading and trailing widgets",
                ),
                const LdTextP(
                  "You can add a leading or trailing widget to a button",
                ),
                ComponentWell(
                    child: Column(children: [
                  ldSpacerL,
                  Wrap(
                    spacing: 8,
                    children: [
                      /*begin demo:LdButtonLeadingTrailing*/
                      // leading widget
                      LdButton(
                        leading: const Icon(Icons.square),
                        child: const Text("Primary"),
                        onPressed: () {
                          LdNotificationsController.of(context).addNotification(
                            LdNotification(
                              type: LdNotificationType.success,
                              message:
                                  "You pressed a button with a leading widget!",
                            ),
                          );
                        },
                      ),
                      // trailing widget
                      LdButton(
                        trailing: const Icon(Icons.square),
                        child: const Text("Primary"),
                        onPressed: () {
                          LdNotificationsController.of(context).addNotification(
                            LdNotification(
                              type: LdNotificationType.success,
                              message:
                                  "You pressed a button with a trailing widget!",
                            ),
                          );
                        },
                      ),
                      /*end demo:LdButtonLeadingTrailing*/
                    ],
                  ),
                ])),
              ],
            ),
            LdBundle(
              children: [
                const LdTextH(
                  "Disabled",
                ),
                const LdText(
                  "You can disable a button by setting the disabled property to true",
                ),
                ComponentWell(
                    child: Column(children: [
                  /*begin demo:LdButtonDisabled*/
                  LdButton(
                    onPressed: () {},
                    disabled: true,
                    child: const Text("Primary"),
                  ),
                  /*end demo:LdButtonDisabled*/
                ])),
              ],
            ),
            LdBundle(
              children: [
                const LdTextH(
                  "Circular button",
                ),
                const LdText(
                  "You can either pass an Icon as a child or set the circular property to true to create a circular button",
                ),
                ComponentWell(
                    child: Column(children: [
                  /*begin demo:LdButtonDisabled*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LdButton(
                        size: LdSize.s,
                        mode: LdButtonMode.ghost,
                        child: const Icon(Icons.square),
                        onPressed: () async {
                          await Future.delayed(const Duration(seconds: 1));
                        },
                      ),
                      ldSpacerM,
                      LdButton(
                        child: const Icon(Icons.square),
                        onPressed: () async {
                          await Future.delayed(const Duration(seconds: 1));
                          throw Exception("I'm an error");
                        },
                      ),
                      ldSpacerM,
                      LdButton(
                        size: LdSize.l,
                        mode: LdButtonMode.vague,
                        child: const Icon(Icons.square),
                        onPressed: () async {
                          await Future.delayed(const Duration(seconds: 1));
                        },
                      ),
                    ],
                  ),
                  /*end demo:LdButtonDisabled*/
                ])),
              ],
            ),
            LdBundle(
              children: [
                const LdTextH(
                  "Full width",
                ),
                const LdText(
                    "A button that is full width, will try to expand the child to max width. Leading and trailing are placed at the start and end of the button."),
                ComponentWell(
                  child: Column(
                    children: [
                      LdButton(
                        leading: const Icon(Icons.abc),
                        trailing: const Icon(Icons.arrow_right),
                        mode: LdButtonMode.outline,
                        onPressed: () {
                          LdNotificationsController.of(context).addNotification(
                            LdNotification(
                                message: "You pressed the full width button",
                                type: LdNotificationType.success),
                          );
                        },
                        width: double.infinity,
                        child: const Text("Full width"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
