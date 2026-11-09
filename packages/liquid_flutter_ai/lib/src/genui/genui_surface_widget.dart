import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter_ai/src/genui/genui_surface_manager.dart';

/// Renders a single GenUI surface from [LdGenuiSurfaceManager].
///
/// Renders nothing until the agent creates the surface, and again after it
/// is deleted.
class LdGenuiSurfaceWidget extends StatefulWidget {
  final LdGenuiSurfaceManager surfaceManager;
  final String surfaceId;

  const LdGenuiSurfaceWidget({
    super.key,
    required this.surfaceManager,
    required this.surfaceId,
  });

  @override
  State<LdGenuiSurfaceWidget> createState() => _LdGenuiSurfaceWidgetState();
}

class _LdGenuiSurfaceWidgetState extends State<LdGenuiSurfaceWidget> {
  late List<Subscription> _subscriptions;

  void _subscribe() {
    final model = widget.surfaceManager.processor.model;
    _subscriptions = [
      model.onSurfaceCreated.subscribe((surface) {
        if (surface.id == widget.surfaceId) setState(() {});
      }),
      model.onSurfaceDeleted.subscribe((surfaceId) {
        if (surfaceId == widget.surfaceId) setState(() {});
      }),
    ];
  }

  void _unsubscribe() {
    for (final subscription in _subscriptions) {
      subscription.unsubscribe();
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant LdGenuiSurfaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surfaceManager != widget.surfaceManager) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.surfaceManager.surfaceFor(widget.surfaceId);
    if (surface == null) {
      return const SizedBox.shrink();
    }
    return A2uiSurface(key: ObjectKey(surface), surface: surface);
  }
}
