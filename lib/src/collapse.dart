import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/spring.dart';

/// A utility to collapse some content
class LdCollapse extends StatefulWidget {
  /// Widget to collapse
  final Widget child;

  final bool collapsed;

  /// Which direction to collapse
  final Axis axis;

  const LdCollapse({
    required this.child,
    required this.collapsed,
    this.axis = Axis.vertical,
    super.key,
  });
  @override
  _LdCollapseState createState() => _LdCollapseState();
}

class _LdCollapseState extends State<LdCollapse>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional alignment;
    if (widget.axis == Axis.vertical) {
      alignment = const AlignmentDirectional(-1.0, 0);
    } else {
      alignment = const AlignmentDirectional(0, -1.0);
    }
    return LdSpring(
        mass: 20,
        position: widget.collapsed ? 0 : 1,
        springConstant: 50,
        dampingCoefficient: 50,
        initialPosition: widget.collapsed ? 0 : 1,
        builder: (context, state) {
          if (!state.isMoving) {
            if (widget.collapsed) {
              return const SizedBox.shrink();
            } else {
              return widget.child;
            }
          }

          return ClipRect(
            child: Align(
              alignment: alignment,
              heightFactor: widget.axis == Axis.vertical
                  ? max(state.position, 0.0)
                  : null,
              widthFactor: widget.axis == Axis.horizontal
                  ? max(state.position, 0.0)
                  : null,
              child: widget.child,
            ),
          );
        });
  }
}
