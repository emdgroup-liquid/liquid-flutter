import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdListItemAnimation extends StatelessWidget {
  final LdPaginatorItemState state;
  final Widget child;

  const LdListItemAnimation({required this.state, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      LdPaginatorItemState.fetching || LdPaginatorItemState.pendingRefresh => child
          .animate(
            key: const Key('index.fetching'),
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(
            padding: 0,
            color: LdTheme.of(context).primaryColor,
            duration: const Duration(milliseconds: 1000),
          ),
      LdPaginatorItemState.loaded => child,
      LdPaginatorItemState.updating => child
          .animate(
            key: const Key('index.updating'),
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(
            padding: 0,
            color: LdTheme.of(context).primaryColor,
            duration: const Duration(milliseconds: 1000),
          ),
      LdPaginatorItemState.rolledBackUpdate => child
          .animate(
            key: const Key('index.rolledBackUpdate'),
          )
          .shimmer(
            color: LdTheme.of(context).warningColor,
            duration: const Duration(milliseconds: 1000),
          )
          .shakeX(hz: 3),
      LdPaginatorItemState.deleting => LdReveal.quick(
          revealed: false,
          initialRevealed: true,
          child: child,
        ),
      LdPaginatorItemState.rolledBackDeletion => LdReveal.quick(
          revealed: true,
          initialRevealed: false,
          child: child,
        ),
      _ => child,
    };
  }
}
