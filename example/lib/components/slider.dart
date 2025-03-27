import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'component_page.dart';
import 'component_well/component_well.dart';

class LdSliderDemo extends StatefulWidget {
  const LdSliderDemo({Key? key}) : super(key: key);

  @override
  State<LdSliderDemo> createState() => _LdSliderDemoState();
}

class _LdSliderDemoState extends State<LdSliderDemo> {
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdSlider",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            child: Column(
              children: [
                LdSlider(
                  hint: "Swipe right...",
                  label: "Confirm account deletion",
                  disabled: _disabled,
                  onSlideComplete: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(
                          message: "You slid the slider!",
                          type: LdNotificationType.info),
                    );
                  },
                )
              ],
            ),
          ),
          LdToggle(
            checked: _disabled,
            label: "Disabled",
            onChanged: (p0) {
              setState(() {
                _disabled = p0;
              });
            },
          )
        ],
      ),
    );
  }
}
