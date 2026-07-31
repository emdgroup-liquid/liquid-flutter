import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/genui_surface_manager.dart';
import 'package:liquid_flutter_ai/src/genui/genui_surface_widget.dart';

/// Stacks active GenUI surfaces (typically above the compose bar).
class LdGenuiSurfaceStrip extends StatelessWidget {
  final LdGenuiSurfaceManager surfaceManager;
  final Iterable<String> surfaceIds;
  final EdgeInsetsGeometry? padding;

  const LdGenuiSurfaceStrip({
    super.key,
    required this.surfaceManager,
    required this.surfaceIds,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ids = surfaceIds.toList();
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = LdTheme.of(context);
    return Padding(
      padding: padding ?? theme.pad(size: LdSize.m),
      child: LdAutoSpace(
        children: [
          for (final surfaceId in ids)
            LdGenuiSurfaceWidget(
              surfaceManager: surfaceManager,
              surfaceId: surfaceId,
            ),
        ],
      ),
    );
  }
}
