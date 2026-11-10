import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:liquid_flutter_ai/src/genui/ld_catalog.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

/// Parses ```genui blocks from message text and feeds a [MessageProcessor].
class LdGenuiSurfaceManager {
  LdGenuiSurfaceManager({
    CatalogImplementation? catalog,
    this.catalogId = kLdGenuiCatalogId,
  }) {
    processor = MessageProcessor<ComponentImplementation>(
      catalogs: [catalog ?? buildLdCatalog()],
      // Agents send a surface over several lines, which the strict graph
      // checks would reject.
      validationConfig: ValidationConfig.relaxed,
      reportErrorsOnly: true,
    );
  }

  /// Holds the surfaces. User actions arrive on `processor.model.onAction`
  /// and errors to report to the agent on `processor.model.onError`.
  late final MessageProcessor<ComponentImplementation> processor;
  final String catalogId;

  /// Surface ids in [activeSurfaceIds] order: a surface moves to the end when
  /// it is created or its components are updated.
  final List<String> _surfaceOrder = [];

  /// Anchor (e.g. the piece id of the message) that last created or updated
  /// each active surface, keyed by surface id. Cleared on deleteSurface.
  final Map<String, Object?> _anchorBySurfaceId = {};

  /// The anchor recorded for [surfaceId], or null when unknown / deleted.
  Object? anchorFor(String surfaceId) => _anchorBySurfaceId[surfaceId];

  /// Snapshot of active anchors (surface id -> anchor). Surfaces created or
  /// updated by the same message share that message's anchor.
  Map<String, Object?> get surfaceAnchors =>
      Map<String, Object?>.of(_anchorBySurfaceId);

  /// Processes message text by extracting genui blocks from it.
  /// Returns the cleaned text (with genui blocks removed) for display.
  ///
  /// When [reportErrors] is true (default), JSON / parse failures are reported
  /// on `processor.model.onError` so listeners there can react. Pass `false`
  /// when replaying history so old failures do not auto-submit.
  ///
  /// [anchor] is recorded as the position where every surface created or
  /// updated by this text lives (e.g. the owning message piece id). Surfaces
  /// without an anchor fall back to the end of the transcript.
  String processMessageText(
    String text, {
    bool reportErrors = true,
    Object? anchor,
  }) {
    final blockRegex = RegExp(r'```genui\s*\n([\s\S]*?)```');
    var lastEnd = 0;
    final result = StringBuffer();

    for (final match in blockRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        result.write(text.substring(lastEnd, match.start));
      }

      final blockContent = match.group(1)?.trim();
      if (blockContent != null && blockContent.isNotEmpty) {
        _processGenuiLines(
          blockContent,
          reportErrors: reportErrors,
          anchor: anchor,
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      result.write(text.substring(lastEnd));
    }

    return result.toString().trim();
  }

  void _processGenuiLines(
    String content, {
    required bool reportErrors,
    Object? anchor,
  }) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      Map<String, Object?>? json;
      try {
        json = _decodeGenuiJson(trimmed, reportErrors: reportErrors);
        if (json == null) continue;
        if (json['createSurface'] is Map) {
          final surface = Map<String, Object?>.from(
            json['createSurface'] as Map,
          );
          surface.putIfAbsent('catalogId', () => catalogId);
          json['createSurface'] = surface;
        }
        final message = AgentToRendererMessage.fromJson(json);
        _trackAnchor(message, anchor);
        _trackOrder(message);
        processor.processMessages(message);
      } on A2uiError catch (e) {
        debugPrint('LdGenuiSurfaceManager: failed to handle genui line: $e');
        debugPrint(
          'LdGenuiSurfaceManager: line=${_preview(trimmed)}',
        );
        if (reportErrors) {
          _reportError(e, rawMessage: json);
        }
      }
    }
  }

  void _trackAnchor(AgentToRendererMessage message, Object? anchor) {
    switch (message) {
      case CreateSurfaceMessage(:final surfaceId):
        _anchorBySurfaceId[surfaceId] = anchor;
      case UpdateComponentsMessage(:final surfaceId):
        _anchorBySurfaceId[surfaceId] = anchor;
      case UpdateDataModelMessage(:final surfaceId):
        _anchorBySurfaceId[surfaceId] = anchor;
      case DeleteSurfaceMessage(:final surfaceId):
        _anchorBySurfaceId.remove(surfaceId);
    }
  }

  void _trackOrder(AgentToRendererMessage message) {
    switch (message) {
      case CreateSurfaceMessage(:final surfaceId) ||
          UpdateComponentsMessage(:final surfaceId):
        _surfaceOrder
          ..remove(surfaceId)
          ..add(surfaceId);
      case DeleteSurfaceMessage(:final surfaceId):
        _surfaceOrder.remove(surfaceId);
    }
  }

  /// Reports [error] on `processor.model.onError` the way the processor
  /// reports a message it rejects.
  void _reportError(A2uiError error, {Object? rawMessage}) {
    processor.model.emitError(
      MessageErrorMapper.map(error, rawMessage: rawMessage).error,
    );
  }

  /// Deletes [surfaceId] and drops its anchor, so the surface no longer
  /// renders inline in the transcript.
  ///
  /// Routes through the manager (rather than calling the processor directly)
  /// so [_anchorBySurfaceId] stays in sync with the registry.
  void deleteSurface(String surfaceId) {
    _anchorBySurfaceId.remove(surfaceId);
    _surfaceOrder.remove(surfaceId);
    processor.processMessages(
      DeleteSurfaceMessage(
        version: A2uiProtocolVersion.v0_9.jsonValue,
        surfaceId: surfaceId,
      ),
    );
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
          _reportError(
            A2uiParseError('GenUI JSON parse failed: $e', rawContent: trimmed),
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
          _reportError(
            A2uiParseError('GenUI JSON parse failed: $e2', rawContent: trimmed),
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
        _reportError(
          A2uiParseError(
            'GenUI JSON expected object, got ${decoded.runtimeType}',
            rawContent: trimmed,
          ),
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

  Iterable<String> get activeSurfaceIds => List.unmodifiable([
    for (final id in _surfaceOrder)
      if (processor.model.getSurface(id) != null) id,
  ]);

  /// The surface [surfaceId], or null until the agent creates it.
  SurfaceModel<ComponentImplementation>? surfaceFor(String surfaceId) =>
      processor.model.getSurface(surfaceId);

  void dispose() {
    processor.dispose();
  }
}
