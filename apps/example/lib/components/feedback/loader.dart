import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LoaderDemo extends StatelessWidget {
  const LoaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/feedback/loader.dart",
      title: "LdLoader",
      demo: ComponentWell(
        child: Column(
          children: [
            Text("Colored (default)"),
            ldSpacerM,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdLoader(
                  size: 64,
                ),
                ldSpacerM,
                LdLoader(
                  size: 32,
                ),
                ldSpacerM,
                LdLoader(
                  size: 16,
                ),
              ],
            ),
            ldSpacerM,
            Text("Neutral"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdLoader(
                  size: 64,
                  neutral: true,
                ),
                ldSpacerM,
                LdLoader(
                  size: 32,
                  neutral: true,
                ),
                ldSpacerM,
                LdLoader(
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
