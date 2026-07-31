import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter_ai/src/genui/ld_catalog.dart';

/// Default catalog id injected into `createSurface` messages.
const kLdGenuiCatalogId = 'com.liquid.catalog';

/// Parses ```genui blocks from message text and feeds a [SurfaceController].
class LdGenuiSurfaceManager {
  LdGenuiSurfaceManager({
    Catalog? catalog,
    this.catalogId = kLdGenuiCatalogId,
  }) {
    controller = SurfaceController(catalogs: [catalog ?? buildLdCatalog()]);
  }

  late final SurfaceController controller;
  final String catalogId;

  /// Processes message text by extracting genui blocks from it.
  /// Returns the cleaned text (with genui blocks removed) for display.
  String processMessageText(String text) {
    final blockRegex = RegExp(r'```genui\s*\n([\s\S]*?)```');
    var lastEnd = 0;
    final result = StringBuffer();

    for (final match in blockRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        result.write(text.substring(lastEnd, match.start));
      }

      final blockContent = match.group(1)?.trim();
      if (blockContent != null && blockContent.isNotEmpty) {
        _processGenuiLines(blockContent);
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      result.write(text.substring(lastEnd));
    }

    return result.toString().trim();
  }

  void _processGenuiLines(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final json = jsonDecode(trimmed) as Map<String, Object?>;
        if (json.containsKey('createSurface') &&
            json['createSurface'] is Map<String, Object?>) {
          final surface = Map<String, Object?>.from(
            json['createSurface'] as Map,
          );
          surface.putIfAbsent('catalogId', () => catalogId);
          json['createSurface'] = surface;
        }
        final message = A2uiMessage.fromJson(json);
        controller.handleMessage(message);
      } catch (e) {
        debugPrint('LdGenuiSurfaceManager: failed to parse genui line: $e');
      }
    }
  }

  /// Convenience wrapper for replaying history.
  String processAndReplay(String content) {
    return processMessageText(content);
  }

  Iterable<String> get activeSurfaceIds => controller.activeSurfaceIds;

  SurfaceContext contextFor(String surfaceId) =>
      controller.contextFor(surfaceId);

  void dispose() {
    controller.dispose();
  }
}
