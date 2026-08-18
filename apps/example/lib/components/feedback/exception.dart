import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class MyCustomException implements Exception {}

class ExceptionDemo extends StatefulWidget {
  const ExceptionDemo({super.key});

  @override
  State<ExceptionDemo> createState() => _ExceptionDemoState();
}

class _ExceptionDemoState extends State<ExceptionDemo> {
  late LdRetryController retryController;
  Timer? errorTriggerTimer;

  @override
  void initState() {
    super.initState();
    retryController = LdRetryController(
      onRetry: () async {
        final retry = await ldConfirmModal(context: context, description: "Fire another automatic retry?");

        if (retry == true) {
          retryController.handleError(canRetry: true);
          return;
        }
        retryController.notifyOperationCompleted();
      },
      config: LdRetryConfig(enableAutomaticRetries: true, maxAttempts: 999, baseDelay: const Duration(seconds: 1)),
    );
    retryController.handleError(canRetry: true);
  }

  @override
  void dispose() {
    errorTriggerTimer?.cancel();
    retryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<LdRetryController>.value(
      value: retryController,
      child: ComponentPage(
        path: "lib/components/feedback/exception.dart",
        apiComponents: const ["LdExceptionView", "LdException", "LdExceptionLocalizer"],
        title: "LdException",
        demo: ComponentWell(
          child: Center(
            child: Consumer<LdRetryController>(
              builder: (context, retryController, child) {
                return LdAutoSpace(
                  children: [
                    LdText.h("Basic Example"),
                    LdExceptionView(
                      exception: LdLocalizedException(
                        message: "Error message",
                        moreInfo: "Nothing actually went wrong, this is just a demo",
                        stackTrace: StackTrace.current,
                      ),
                      retryController: retryController,
                    ),
                    const LdDivider(),
                    LdText.h("Custom Mapper Example"),
                    LdText.p(
                      "LdExceptionLocalizer maps exceptions for every LdSubmit/LdExceptionView "
                      "below it in the tree. If a mapper only applies to a single LdSubmit, prefer "
                      "passing onException directly to that LdSubmit instead (see the LdSubmit "
                      "docs) so the mapping does not leak to sibling widgets.",
                    ),
                    LdExceptionLocalizer(
                      onException: (context, e) {
                        if (e.exception is MyCustomException) {
                          return LdLocalizedException(
                            message: "Caught Custom Exception",
                            moreInfo: "The custom mapper successfully intercepted this exception.",
                            type: LdHintType.success,
                          );
                        }
                        return null;
                      },
                      child: Builder(
                        builder: (context) {
                          return LdExceptionView(
                            exception: LdException(exception: MyCustomException(), stackTrace: StackTrace.current),
                            retryController: retryController,
                          );
                        },
                      ),
                    ),
                    const LdDivider(),
                    LdText.h("Custom Builders Example"),
                    LdExceptionView(
                      exception: LdLocalizedException(
                        message: "With Custom Builders",
                        moreInfo: "This exception has custom widgets in its builders.",
                        customIconBuilder: (context) {
                          return const Icon(Icons.star, color: Colors.amber);
                        },
                        additionalBuilder: (context) {
                          return const LdHint(type: LdHintType.info, child: Text("Additional inline content"));
                        },
                        additionalDetailsBuilder: (context) {
                          return const LdCard(child: Text("Detailed content in dialog"));
                        },
                        stackTrace: StackTrace.current,
                      ),
                      retryController: retryController,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
