import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SubmitDemo extends StatefulWidget {
  const SubmitDemo({super.key});

  @override
  State<SubmitDemo> createState() => _SubmitDemoState();
}

class _SubmitDemoState extends State<SubmitDemo> {
  double _arg = 42;

  void setArg(double arg) {
    setState(() {
      _arg = arg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/submit.dart",
      title: "LdSubmit",
      apiComponents: const ["LdSubmit"],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            "LdSubmit is a helper that makes asynchronous work easier. "
            "It handles common use cases where a function is dispatched by "
            "a button or on mount and the result is displayed.\n"
            "It also handles loading and error states and  supports several"
            " methods to display the loading and error states "
            "(inline, centered and dialog).\n"
            "You can either use the widget directly or provide"
            " an LdSubmitController as a parameter to interact "
            "with the state programatically.",
          ),
          LdBundle(
            children: [
              ComponentWell(
                title: LdText.h("Inline builder"),
                description: LdText.p(
                  "The LdSubmitInlineBuilder will display the loading and error states inline. It is perfect for forms or other inline components.",
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdSubmit<int, void>(
                      config: LdSubmitConfig<int, void>(
                        allowResubmit: true,
                        allowCancel: true,
                        loadingText: ("Trying nuclear fusion"),
                        action: (arg) async {
                          await Future.delayed(const Duration(seconds: 2));

                          // calculate a random number
                          final random = Random();
                          final randomNumber = random.nextInt(100);

                          if (randomNumber < 50) {
                            throw LdLocalizedException(
                              message: "Something went wrong",
                              moreInfo: "Nothing actually happened",
                            );
                          }
                          return randomNumber;
                        },
                      ),
                      child: LdSubmitInlineBuilder<int, void>(
                        resultBuilder: (context, result, controller) {
                          return Text("The result is $result");
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const ComponentsAccordion(components: {"LdSubmitInlineBuilder"}),
            ],
          ),
          ldSpacerL,
          ldSpacerL,
          LdBundle(
            children: [
              ComponentWell(
                title: LdText.h("Centered builder"),
                description: LdText.p(
                  "The LdSubmitCenteredBuilder will center the loading and error states. It is perfect for loading a new page (e.g. a detail view). ",
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: LdSubmit<int, void>(
                        config: LdSubmitConfig<int, void>(
                          allowResubmit: true,
                          allowCancel: true,
                          loadingText: ("Trying nuclear fusion"),
                          action: (arg) async {
                            await Future.delayed(const Duration(seconds: 2));

                            // calculate a random number
                            final random = Random();
                            final randomNumber = random.nextInt(100);

                            if (randomNumber < 50) {
                              throw LdLocalizedException(
                                message: "Something went wrong",
                                moreInfo: "Nothing actually happened",
                              );
                            }
                            return randomNumber;
                          },
                        ),
                        child: LdSubmitCenteredBuilder<int, void>(
                          resultBuilder: (context, result, controller) {
                            return Text("The result is $result");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const ComponentsAccordion(components: {"LdSubmitCenteredBuilder"}),
            ],
          ),
          ldSpacerL,
          ldSpacerL,
          LdBundle(
            children: [
              ComponentWell(
                title: LdText.h("Dialog builder"),
                description: LdText.p(
                  "The LdSubmitDialogBuilder will display the loading and error states in a dialog. It is usefull to prevent the user from interacting with the rest of the app while the action is being processed.",
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdSubmit<int, void>(
                      config: LdSubmitConfig<int, void>(
                        allowResubmit: true,
                        allowCancel: true,
                        loadingText: ("Trying nuclear fusion"),
                        action: (arg) async {
                          await Future.delayed(const Duration(seconds: 2));

                          // calculate a random number
                          final random = Random();
                          final randomNumber = random.nextInt(100);

                          if (randomNumber < 50) {
                            throw LdLocalizedException(
                              message: "Something went wrong",
                              moreInfo: "Nothing actually happened",
                            );
                          }
                          return randomNumber;
                        },
                      ),
                      child: LdSubmitDialogBuilder<int, void>(
                        resultBuilder: (context, result, controller) {
                          return LdAutoSpace(
                            children: [
                              Text("The result is $result"),
                              LdButton(onPressed: controller.reset, child: const Text("Reset")),
                              LdDivider(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const ComponentsAccordion(components: {"LdSubmitDialogBuilder"}),
            ],
          ),
          ldSpacerL,
          ldSpacerL,
          LdBundle(
            children: [
              ComponentWell(
                title: LdText.h("Notification builder"),
                description: LdText.p(
                  "The LdSubmitNotificationBuilder will display the loading and error states in a notification. It is usefull to display a loading or error state without blocking the user from interacting with the rest of the app.",
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdSubmit<int, void>(
                      config: LdSubmitConfig<int, void>(
                        allowResubmit: true,
                        allowCancel: true,
                        loadingText: ("Trying nuclear fusion"),
                        action: (arg) async {
                          await Future.delayed(const Duration(seconds: 2));

                          // calculate a random number
                          final random = Random();
                          final randomNumber = random.nextInt(100);

                          if (randomNumber < 50) {
                            throw LdLocalizedException(
                              message: "Something went wrong",
                              moreInfo: "Nothing actually happened",
                            );
                          }
                          return randomNumber;
                        },
                      ),
                      child: LdSubmitNotificationBuilder<int, void>(
                        successMessage: "Successfully performed action",
                        resultBuilder: (context, result, controller) {
                          return Text("The result is $result");
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const ComponentsAccordion(components: {"LdSubmitNotificationBuilder"}),
            ],
          ),
          ldSpacerL,
          ldSpacerL,
          LdBundle(
            children: [
              LdText.h("Auto trigger"),
              LdSubmit<void, void>(
                config: LdSubmitConfig<void, void>(
                  autoTrigger: true,
                  action: (_) {
                    return Future.delayed(const Duration(seconds: 2), () => 42);
                  },
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.h("(Automatic) Retries"),
              LdText.p(
                "You can pass an LdSubmitRetryConfig to the LdSubmitConfig to enable (automatic) retries, or to block the retry button for a certain amount of time before allowing the user to trigger it again. The delay between retries will increase exponentially.",
              ),
              ComponentWell(
                child: LdSubmit<void, void>(
                  config: LdSubmitConfig<void, void>(
                    retryConfig: LdRetryConfig.defaultAutomaticRetries(),
                    action: (_) {
                      return Future.delayed(const Duration(seconds: 2), () {
                        throw LdLocalizedException(
                          message: "Something went wrong",
                          moreInfo: "Nothing actually happened",
                        );
                      });
                    },
                  ),
                  child: LdSubmitCenteredBuilder<void, void>(),
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.h("LdSubmitConfig"),
              LdText.p("The LdSubmitConfig is used to configure the LdSubmit widget."),
              ComponentsAccordion(components: {"LdSubmitConfig"}),
              LdText.h("LdSubmitController"),
              LdText.p(
                "The LdSubmitController handles the state of the LdSubmit component. It posesses a .state property of type LdSubmitState.",
              ),
              LdText.p("You can observe the controller through its .stateStream property."),
              ComponentsAccordion(components: {"LdSubmitController", "LdSubmitState"}),
            ],
          ),
          ComponentWell(
            title: LdText.h("Passing an arg"),
            description: Text("You can pass an arg to the LdSubmit widget to be used in the action."),
            child: LdSubmit<double, double>(
              arg: _arg,
              config: LdSubmitConfig<double, double>(
                action: (arg) async {
                  return arg!;
                },
              ),
              child: LdSubmitInlineBuilder<double, double>(
                resultBuilder: (context, result, controller) {
                  return Text("The result is $result");
                },
              ),
            ),
          ),
          Slider(value: _arg, onChanged: setArg, min: 0, max: 42),
          LdBundle(
            children: [
              LdText.h("Exception Handling"),
              LdText.p(
                "Exceptions are caught, handled by an LdExceptionMapper and displayed in an LdExceptionView. The Exception mapper can be used to configure how a specific exception is displayed. To add a custom exception you can either throw an LdException directly or provide a custom LdExceptionMapper to the LdSubmitConfig.",
              ),
              ComponentsAccordion(components: {"LdException", "LdExceptionMapper", "LdExceptionView"}),
            ],
          ),
        ],
      ),
    );
  }
}
