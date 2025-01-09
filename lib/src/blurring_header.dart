import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdBlurringHeader extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final BorderRadius? borderRadius;

  const LdBlurringHeader({
    super.key,
    required this.child,
    required this.scrollController,
    this.borderRadius,
  });

  @override
  State<LdBlurringHeader> createState() => _LdBlurringHeaderState();
}

class _LdBlurringHeaderState extends State<LdBlurringHeader> {
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollOffset);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollOffset);
    super.dispose();
  }

  void _updateScrollOffset() {
    if (widget.scrollController.hasClients) {
      setState(() {
        scrollOffset = widget.scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double scrollOffset = 0;

    if (widget.scrollController.hasClients) {
      scrollOffset = widget.scrollController.offset;
    }

    final sigma = scrollOffset.abs().clamp(0.0, 10.0);

    final theme = LdTheme.of(
      context,
      listen: true,
    );

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface.withAlpha(100),
            border: Border(
              bottom: BorderSide(
                color: theme.border.withAlpha(scrollOffset > 10 ? 255 : 0),
                width: 1,
              ),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
