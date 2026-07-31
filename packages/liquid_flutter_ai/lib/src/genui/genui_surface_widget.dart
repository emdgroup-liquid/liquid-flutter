import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter_ai/src/genui/genui_surface_manager.dart';

/// Renders a single GenUI surface from [LdGenuiSurfaceManager].
class LdGenuiSurfaceWidget extends StatelessWidget {
  final LdGenuiSurfaceManager surfaceManager;
  final String surfaceId;

  const LdGenuiSurfaceWidget({
    super.key,
    required this.surfaceManager,
    required this.surfaceId,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      surfaceContext: surfaceManager.contextFor(surfaceId),
      defaultBuilder: (_) => const SizedBox.shrink(),
    );
  }
}
