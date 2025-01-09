import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdTabs extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;

  const LdTabs({Key? key, required this.children, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tabController = controller ?? DefaultTabController.of(context);

    final theme = LdTheme.of(context, listen: true);

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        return Column(
          children: [
            Text(tabController.animation.toString()),
            Row(
              children: [
                for (var child in children)
                  Expanded(
                      child: Padding(
                    padding: theme.balPad(LdSize.s),
                    child: LdButton(
                        child: child,
                        mode: tabController.index == children.indexOf(child)
                            ? LdButtonMode.filled
                            : LdButtonMode.ghost,
                        onPressed: () {
                          tabController.animateTo(children.indexOf(child));
                        }),
                  ))
              ],
            ),
          ],
        );
      },
    );
  }
}
