import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class AppBarDemo extends StatelessWidget {
  const AppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdAppBar",
      text: """
`LdAppBar` is a cross-platform app bar widget that adapts its appearance to the Liquid Design system. It supports all standard AppBar features and is styled to match the current theme. Use it as a drop-in replacement for Flutter's AppBar for a consistent look and feel across your app.
""",
      demo: ComponentWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LdAppBar(
              title: const Text("Home"),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("This is a simple example of LdAppBar in use."),
            ),
          ],
        ),
      ),
      apiComponents: ["LdAppBar"],
    );
  }
}
