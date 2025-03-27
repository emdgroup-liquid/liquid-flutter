import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ExceptionDemo extends StatefulWidget {
  const ExceptionDemo({Key? key}) : super(key: key);

  @override
  _ExceptionDemoState createState() => _ExceptionDemoState();
}

class _ExceptionDemoState extends State<ExceptionDemo> {
  late LdRetryController retryController;
  Timer? errorTriggerTimer;

  @override
  void initState() {
    super.initState();
    retryController = LdRetryController(
      onRetry: () async {
        final retry = await LdNotificationsController.of(context).confirm(
          "Fire another automatic retry?",
        );
        if (retry == true) {
          retryController.handleError(canRetry: true);
          return;
        }
        retryController.notifyOperationCompleted();
      },
      config: LdRetryConfig(
        enableAutomaticRetries: true,
        maxAttempts: 999,
        baseDelay: const Duration(seconds: 1),
      ),
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
        apiComponents: const ["LdExceptionView", "LdException"],
        title: "Drawer",
        demo: ComponentWell(
          child: Center(
            child: Consumer<LdRetryController>(
              builder: (context, retryController, child) {
                return LdExceptionView(
                  exception: LdException(
                    message: "Error message",
                    moreInfo:
                        "Nothing actually went wrong, this is just a demo",
                    stackTrace: StackTrace.current,
                  ),
                  retryController: retryController,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
