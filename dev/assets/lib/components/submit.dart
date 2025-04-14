import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid/components/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SubmitDemo extends StatefulWidget {
  const SubmitDemo({super.key});

  @override
  State<SubmitDemo> createState() => _SubmitDemoState();
}

class _SubmitDemoState extends State<SubmitDemo> {
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdSubmit",
      apiComponents: const ["LdSubmit"],
      demo: LdAutoSpace(
        children: [
          const LdTextP(
            "LdSubmit is a helper that makes asynchronous work easier. "
            "It handles common use cases where a function is dispatched by "
            "a button or on mount and the result is displayed.\n\n"
            "It also handles loading and error states and  supports several"
            " methods to display the loading and error states "
            "(inline, centered and dialog).\n\n"
            "You can either use the widget directly or provide"
            " an LdSubmitController as a parameter to interact "
            "with the state programatically.",
          ),
          const CodeBlock(code: """
            LdSubmit<int>(
              config: LdSubmitConfig<int>(
                exceptionMapper: LdExceptionMapper(
                  localizations: LiquidLocalizations.of(context),
                ),
                action: () async {
                  await Future.delayed(const Duration(seconds: 2));

                  // calculate a random number
                  final random = Random();
                  final randomNumber = random.nextInt(100);

                  if (randomNumber < 50) {
                    throw LdException(
                      message: "Something went wrong",
                      moreInfo: "Nothing actually happened",
                    );
                  }
                  return randomNumber;
                },
              ),
              
            );
          """),
          const LdDivider(),
          LdBundle(
            children: [
              const LdTextH("Inline builder"),
              const LdTextP(
                "The LdSubmitInlineBuilder will display the loading and error states inline. It is perfect for forms or other inline components.",
              ),
              const ComponentsAccordion(components: {"LdSubmitInlineBuilder"}),
              ComponentWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdSubmit<int>(
                      config: LdSubmitConfig<int>(
                        allowResubmit: true,
                        allowCancel: true,
                        loadingText: ("Trying nuclear fusion"),
                        action: () async {
                          await Future.delayed(const Duration(seconds: 2));

                          // calculate a random number
                          final random = Random();
                          final randomNumber = random.nextInt(100);

                          if (randomNumber < 50) {
                            throw LdException(
                              message: "Something went wrong",
                              moreInfo: "Nothing actually happened",
                            );
                          }
                          return randomNumber;
                        },
                      ),
                      builder: LdSubmitInlineBuilder<int>(
                        resultBuilder: (context, result, controller) {
                          return Text("The result is $result");
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              const LdTextH("Centered builder"),
              const LdTextP(
                "The LdSubmitCenteredBuilder will center the loading and error states. It is perfect for loading a new page (e.g. a detail view). ",
              ),
              const ComponentsAccordion(
                  components: {"LdSubmitCenteredBuilder"}),
              ComponentWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: LdSubmit<int>(
                        config: LdSubmitConfig<int>(
                          allowResubmit: true,
                          allowCancel: true,
                          loadingText: ("Trying nuclear fusion"),
                          action: () async {
                            await Future.delayed(const Duration(seconds: 2));

                            // calculate a random number
                            final random = Random();
                            final randomNumber = random.nextInt(100);

                            if (randomNumber < 50) {
                              throw LdException(
                                message: "Something went wrong",
                                moreInfo: "Nothing actually happened",
                              );
                            }
                            return randomNumber;
                          },
                        ),
                        builder: LdSubmitCenteredBuilder<int>(
                          resultBuilder: (context, result, controller) {
                            return Text("The result is $result");
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              const LdTextH("Dialog builder"),
              const LdTextP(
                "The LdSubmitDialogBuilder will display the loading and error states in a dialog. It is usefull to prevent the user from interacting with the rest of the app while the action is being processed.",
              ),
              const ComponentsAccordion(components: {"LdSubmitDialogBuilder"}),
              ComponentWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdSubmit<int>(
                      config: LdSubmitConfig<int>(
                        allowResubmit: true,
                        allowCancel: true,
                        loadingText: ("Trying nuclear fusion"),
                        action: () async {
                          await Future.delayed(const Duration(seconds: 2));

                          // calculate a random number
                          final random = Random();
                          final randomNumber = random.nextInt(100);

                          if (randomNumber < 50) {
                            throw LdException(
                              message: "Something went wrong",
                              moreInfo: "Nothing actually happened",
                            );
                          }
                          return randomNumber;
                        },
                      ),
                      builder: LdSubmitDialogBuilder<int>(
                        resultBuilder: (context, result, controller) {
                          return Column(
                            children: [
                              Text("The result is $result"),
                              LdButton(
                                onPressed: controller.reset,
                                child: const Text("Reset"),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              const LdTextH("Auto trigger"),
              LdSubmit(
                config: LdSubmitConfig(
                    autoTrigger: true,
                    action: () {
                      return Future.delayed(
                          const Duration(seconds: 2), () => 42);
                    }),
              )
            ],
          ),
          LdBundle(
            children: [
              const LdTextH("(Automatic) Retries"),
              const LdTextP(
                "You can pass an LdSubmitRetryConfig to the LdSubmitConfig to enable (automatic) retries, or to block the retry button for a certain amount of time before allowing the user to trigger it again. The delay between retries will increase exponentially.",
              ),
              ComponentWell(
                child: LdSubmit<void>(
                  builder: const LdSubmitCenteredBuilder<void>(),
                  config: LdSubmitConfig<void>(
                    retryConfig: LdRetryConfig.defaultAutomaticRetries(),
                    action: () {
                      return Future.delayed(
                        const Duration(seconds: 2),
                        () {
                          throw LdException(
                            message: "Something went wrong",
                            moreInfo: "Nothing actually happened",
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
          const LdBundle(
            children: [
              LdTextH("LdSubmitConfig"),
              LdTextP(
                "The LdSubmitConfig is used to configure the LdSubmit widget.",
              ),
              ComponentsAccordion(components: {"LdSubmitConfig"}),
              LdTextH("LdSubmitController"),
              LdTextP(
                "The LdSubmitController handles the state of the LdSubmit component. It posesses a .state property of type LdSubmitState.",
              ),
              LdTextP(
                  "You can observe the controller through its .stateStream property."),
              ComponentsAccordion(components: {
                "LdSubmitController",
                "LdSubmitState",
              }),
            ],
          ),
          const LdBundle(
            children: [
              LdTextH("Exception Handling"),
              LdTextP(
                "Exceptions are caught, handled by an LdExceptionMapper and displayed in an LdExceptionView. The Exception mapper can be used to configure how a specific exception is displayed. To add a custom exception you can either throw an LdException directly or provide a custom LdExceptionMapper to the LdSubmitConfig.",
              ),
              ComponentsAccordion(components: {
                "LdException",
                "LdExceptionMapper",
                "LdExceptionView",
              }),
            ],
          ),
        ],
      ),
    );
  }
}
