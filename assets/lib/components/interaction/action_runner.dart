import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ActionRunnerDemo extends StatefulWidget {
  const ActionRunnerDemo({super.key});

  @override
  State<ActionRunnerDemo> createState() => _ActionRunnerDemoState();
}

class _ActionRunnerDemoState extends State<ActionRunnerDemo> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        path: "lib/components/interaction/action_runner.dart",
        title: "Action Runner",
        apiComponents: const [
          "LdRunnerStep",
          "LdRunnerLog",
        ],
        demo: LdAutoSpace(
          animate: true,
          children: [
            LdRunnerStep(
              title: const Text("I'm a step "),
              trailing: const Text("Foo"),
              isExpanded: expanded,
              onPress: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              status: LdIndicatorType.loading,
              children: [
                Row(
                  children: [
                    LdButton(child: const Text("Copy logs"), onPressed: () {}),
                    ldSpacerS,
                    LdButtonOutline(
                        child: const Text("Cancel"), onPressed: () {}),
                  ],
                ),
                const LdRunnerLog(
                  messages: [
                    "Current runner version: '2.315.0'",
                    "Operating System",
                    "Ubuntu",
                    "22.04.4",
                    "LTS",
                    "Runner Image",
                    "Image: ubuntu-22.04",
                    "Version: 20240422.1.0",
                    "Included Software: https://github.com/actions/runner-images/blob/ubuntu22/20240422.1/images/ubuntu/Ubuntu2204-Readme.md",
                    "Image Release: https://github.com/actions/runner-images/releases/tag/ubuntu22%2F20240422.1",
                    "Runner Image Provisioner",
                    "2.0.369.1",
                    "GITHUB_TOKEN Permissions",
                    "Contents: read",
                    "Metadata: read",
                    "Pages: write",
                    "Secret source: Actions",
                    "Prepare workflow directory",
                    "Prepare all required actions",
                    "Getting action download info",
                    "Download action repository 'actions/checkout@v4' (SHA:0ad4b8fadaa221de15dcec353f45205ec38ea70b)",
                    "Download action repository 'actions/upload-pages-artifact@v3' (SHA:56afc609e74202658d3ffba0e8f6dda462b719fa)",
                    "Getting action download info",
                    "Download action repository 'actions/upload-artifact@v4' (SHA:65462800fd760344b1a7b4382951275a0abb4808)",
                    "Complete job name: build",
                  ],
                )
              ],
            ),
            const LdRunnerStep(
              title: Text("I'm a step 2 "),
              trailing: Text("Foo"),
              status: LdIndicatorType.warning,
              children: [],
            ),
            const LdRunnerStep(
                title: Text("Wont execute"),
                status: LdIndicatorType.canceled,
                disabled: true,
                children: [])
          ],
        ));
  }
}
