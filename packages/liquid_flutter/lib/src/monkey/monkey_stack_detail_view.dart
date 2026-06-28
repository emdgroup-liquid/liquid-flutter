import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyStackDetailView<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;
  const LdMonkeyStackDetailView({super.key, required this.buildDetail});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyStreamSelection<T, IdType>(
      buildItem: (context, item) => switch (item.state) {
        LdPaginatorItemState.deleting || LdPaginatorItemState.deleted => LdReveal.quick(
            revealed: false,
            initialRevealed: true,
            child: buildDetail(context, item),
          ),
        _ => buildDetail(context, item),
      },
      builder: (context, itemWidgets) => Stack(
        children: [
          ...itemWidgets.mapIndexed(
            (index, child) => LdSpring(
              initialPosition: 0,
              builder: (context, state, springChild) {
                final position = max(0, state.position);
                return Transform.scale(
                  scale: 1 - (position * 0.02),
                  child: Transform.rotate(
                    angle: index % 3 * 0.02,
                    child: Transform.translate(
                      offset: Offset(0, position * 5),
                      child: springChild,
                    ),
                  ),
                );
              },
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
