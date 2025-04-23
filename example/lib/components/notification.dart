import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class NotificationDemo extends StatelessWidget {
  const NotificationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdNotification",
      apiComponents: const ["LdNotifier", "LdNotifcationPortal", "LdNotification"],
      text: """
  Allows you to display notifications in a "toast" style. 
  
  To use add a  `LdNotificationPortal` to your widget tree. Then use `LdNotifier.of(context).success("Hello World")` to display a notification.
""",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
              child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LdButton(
                  child: const Text("Success"),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.success,
                      ),
                    );
                  }),
              LdButton(
                  child: const Text("Info"),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.info,
                      ),
                    );
                  }),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.warning,
                      ),
                    );
                  },
                  child: const Text("Warning")),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.error,
                      ),
                    );
                  },
                  child: const Text("Error")),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message:
                            "Oh no something went terribly wrong. We must now take action to fix this issue immediately.",
                        type: LdNotificationType.error,
                      ),
                    );
                  },
                  child: const Text("Long error message")),
              LdButton(
                  child: const Text("Big info"),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.success,
                      ),
                    );
                  }),
              LdButton(
                  child: const Text("Info"),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.info,
                      ),
                    );
                  }),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.warning,
                      ),
                    );
                  },
                  child: const Text("Warning")),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Hello World",
                        type: LdNotificationType.error,
                      ),
                    );
                  },
                  child: const Text("Error")),
              LdButton(
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message:
                            "Oh no something went terribly wrong. We must now take action to fix this issue immediately.",
                        type: LdNotificationType.error,
                      ),
                    );
                  },
                  child: const Text("Long error message")),
              LdButton(
                  child: const Text("Big info"),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(LdNotification(
                        type: LdNotificationType.info, message: "Hello World", subMessage: "This is a submessage"));
                  }),
              LdButton(
                  child: const Text("Loading"),
                  onPressed: () async {
                    final notification = await LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        type: LdNotificationType.loading,
                        canDismiss: false,
                        duration: null,
                        message: "Waiting for something",
                        subMessage: "We are waiting for something to happen",
                      ),
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    // ignore: use_build_context_synchronously
                    LdNotificationsController.of(context).onDismissNotification(
                      notification,
                    );
                    // ignore: use_build_context_synchronously
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                        message: "Done",
                        type: LdNotificationType.success,
                      ),
                    );
                  }),
            ],
          )),
          const LdTextH("Complex interactions"),
          const LdTextP(
            "Notifications can also be interactive, requiring user input or confirmation. The following examples demonstrate different types of interactive notifications.",
          ),
          ComponentWell(
            child: Center(
              child: LdButton(
                child: const Text("Confirm"),
                onPressed: () {
                  LdNotificationsController.of(context).addNotification(
                    LdConfirmNotification(
                        type: LdNotificationType.confirm, message: "Hello World", subMessage: "This is a submessage"),
                  );
                },
              ),
            ),
          ),
          const LdTextP(
            "To indefinitely display a notification you can use the `LdNotificationType.acknowledge` type.",
          ),
          ComponentWell(
            child: Center(
              child: LdButton(
                child: const Text("Acknowledge"),
                onPressed: () {
                  LdNotificationsController.of(context).addNotification(
                    LdAcknowledgeNotification(
                        type: LdNotificationType.acknowledge,
                        message: "Hello World",
                        subMessage: "This is a submessage"),
                  );
                },
              ),
            ),
          ),
          const LdTextP(
            "To prompt some simple text you can use the `LdNotificationType.enterText` type.",
          ),
          ComponentWell(
            child: Center(
              child: LdButton(
                child: const Text("Enter text"),
                onPressed: () async {
                  final notification = (await LdNotificationsController.of(context).addNotification(
                    LdInputNotification(
                      inputHint: "John Doe",
                      inputLabel: "Your name",
                      type: LdNotificationType.enterText,
                      message: "Some input is required...",
                    ),
                  )) as LdInputNotification;
                  final result = await notification.inputCompleter.future;
                  if (!context.mounted) return;
                  LdNotificationsController.of(context).addNotification(
                    LdNotification(
                      message: "You entered: $result",
                      type: LdNotificationType.success,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
