import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class BadgeDemo extends StatelessWidget {
  const BadgeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return ComponentPage(
      title: "LdBadge",
      demo: ComponentWell(
        child: LdAutoSpace(children: [
          ...LdSize.values
              .map(
                (e) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      LdTextL(e.toString()),
                      LdBadge(
                        color: theme.primary,
                        size: e,
                        child: const Text("Hello"),
                      ),
                      LdBadge(
                        color: theme.warning,
                        size: e,
                        child: const Text("Hello"),
                      ),
                      LdBadge(
                        color: theme.success,
                        size: e,
                        child: const Text("Hello"),
                      ),
                      LdBadge(
                        color: theme.secondary,
                        size: e,
                        child: const Text("Hello"),
                      ),
                      LdBadge(
                        color: theme.error,
                        size: e,
                        child: const Text("Hello"),
                      ),
                    ]),
              )
              ,
          const LdDivider(),
          const LdTextP("symmetric = true, causes the badge to be a circle"),
          const LdBadge(
            symmetric: true,
            child: Icon(Icons.photo),
          ),
        ]),
      ),
    );
  }
}
