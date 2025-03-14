import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ExceptionDemo extends StatelessWidget {
  const ExceptionDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        apiComponents: const ["LdExceptionView", "LdException"],
        title: "Drawer",
        demo: ComponentWell(
          child: Center(
            child: LdExceptionView(
              exception: LdException(
                message: "Error message",
                moreInfo: "Nothing actually went wrong, this is just a demo",
                stackTrace: StackTrace.current,
              ),
              retry: () {
                LdNotificationsController.of(context).addNotification(
                  LdNotification(
                    message: "Retry pressed",
                    type: LdNotificationType.acknowledge,
                  ),
                );
              },
            ),
          ),
        ));
  }
}
