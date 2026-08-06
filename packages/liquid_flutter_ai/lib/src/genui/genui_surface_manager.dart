import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter_ai/src/genui/ld_catalog.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

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
  ///
  /// When [reportErrors] is true (default), JSON / parse failures are reported
  /// via [SurfaceController.reportError] so listeners on [onSubmit] can react.
  /// Pass `false` when replaying history so old failures do not auto-submit.
  String processMessageText(String text, {bool reportErrors = true}) {
    final blockRegex = RegExp(r'```genui\s*\n([\s\S]*?)```');
    var lastEnd = 0;
    final result = StringBuffer();

    for (final match in blockRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        result.write(text.substring(lastEnd, match.start));
      }

      final blockContent = match.group(1)?.trim();
      if (blockContent != null && blockContent.isNotEmpty) {
        _processGenuiLines(blockContent, reportErrors: reportErrors);
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      result.write(text.substring(lastEnd));
    }

    return result.toString().trim();
  }

  void _processGenuiLines(String content, {required bool reportErrors}) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final json = _decodeGenuiJson(trimmed, reportErrors: reportErrors);
        if (json == null) continue;
        if (json['createSurface'] is Map) {
          final surface = Map<String, Object?>.from(
            json['createSurface'] as Map,
          );
          surface.putIfAbsent('catalogId', () => catalogId);
          json['createSurface'] = surface;
        }
        final message = A2uiMessage.fromJson(json);
        controller.handleMessage(message);
      } catch (e, stack) {
        debugPrint('LdGenuiSurfaceManager: failed to handle genui line: $e');
        debugPrint(
          'LdGenuiSurfaceManager: line=${_preview(trimmed)}',
        );
        if (reportErrors) {
          controller.reportError(e, stack);
        }
      }
    }
  }

  /// Decodes a genui action line, tolerating a common LLM mistake of one or
  /// more trailing `}` characters after an otherwise valid object.
  Map<String, Object?>? _decodeGenuiJson(
    String trimmed, {
    required bool reportErrors,
  }) {
    Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException catch (e) {
      final repaired = _stripTrailingExtraBraces(trimmed);
      if (repaired == null) {
        debugPrint('LdGenuiSurfaceManager: failed to parse genui JSON: $e');
        debugPrint('LdGenuiSurfaceManager: line=${_preview(trimmed)}');
        if (reportErrors) {
          controller.reportError(
            FormatException('GenUI JSON parse failed: $e'),
            StackTrace.current,
          );
        }
        return null;
      }
      try {
        decoded = jsonDecode(repaired);
        debugPrint(
          'LdGenuiSurfaceManager: repaired genui JSON by stripping trailing braces',
        );
      } on FormatException catch (e2) {
        debugPrint('LdGenuiSurfaceManager: failed to parse genui JSON: $e2');
        if (reportErrors) {
          controller.reportError(
            FormatException('GenUI JSON parse failed: $e2'),
            StackTrace.current,
          );
        }
        return null;
      }
    }

    if (decoded is! Map) {
      debugPrint(
        'LdGenuiSurfaceManager: expected JSON object, got ${decoded.runtimeType}',
      );
      if (reportErrors) {
        controller.reportError(
          FormatException(
            'GenUI JSON expected object, got ${decoded.runtimeType}',
          ),
          StackTrace.current,
        );
      }
      return null;
    }
    return Map<String, Object?>.from(decoded);
  }

  /// Returns [trimmed] with trailing `}` removed until `{`/`}` counts match,
  /// or null if that cannot produce balanced braces.
  String? _stripTrailingExtraBraces(String trimmed) {
    var candidate = trimmed;
    while (candidate.endsWith('}')) {
      final open = '{'.allMatches(candidate).length;
      final close = '}'.allMatches(candidate).length;
      if (close <= open) {
        return null;
      }
      candidate = candidate.substring(0, candidate.length - 1);
      final openAfter = '{'.allMatches(candidate).length;
      final closeAfter = '}'.allMatches(candidate).length;
      if (openAfter == closeAfter) {
        return candidate;
      }
    }
    return null;
  }

  static String _preview(String s) {
    final end = s.length < 120 ? s.length : 120;
    return '${s.substring(0, end)}…';
  }

  /// Convenience wrapper for replaying history.
  String processAndReplay(String content) {
    return processMessageText(content, reportErrors: false);
  }

  Iterable<String> get activeSurfaceIds => controller.activeSurfaceIds;

  SurfaceContext contextFor(String surfaceId) =>
      controller.contextFor(surfaceId);

  void dispose() {
    controller.dispose();
  }
}
