import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart' as genui;
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';

import '../catalog/liquid_catalog.dart';
import '../services/api_key_service.dart';
import 'system_instructions.dart';

/// GenUI service that manages the conversation and content generation
class GenUIService {
  static final GenUIService instance = GenUIService._();
  GenUIService._();

  genui.GenUiConversation? _conversation;
  genui.A2uiMessageProcessor? _messageProcessor;
  GoogleGenerativeAiContentGenerator? _contentGenerator;
  ValueChanged<genui.SurfaceAdded>? _onSurfaceAdded;
  ValueChanged<genui.SurfaceRemoved>? _onSurfaceDeleted;

  /// Set callbacks for surface events
  void setCallbacks({
    ValueChanged<genui.SurfaceAdded>? onSurfaceAdded,
    ValueChanged<genui.SurfaceRemoved>? onSurfaceDeleted,
  }) {
    _onSurfaceAdded = onSurfaceAdded;
    _onSurfaceDeleted = onSurfaceDeleted;
  }

  /// Initialize the GenUI conversation with Google Gemini
  ///
  /// Note: You may see a warning about "Unsupported keyword 'minItems'" when
  /// GenUI adapts the catalog schema to function tool schemas. This is a known
  /// GenUI limitation where `minItems` constraints are added to the `components`
  /// property, which Gemini's function calling API doesn't support in that context.
  /// The warning says "It will be ignored" and can be safely ignored - functionality
  /// is not affected. See: https://github.com/flutter/genui/issues/428
  Future<void> initialize() async {
    // Get API key
    final apiKey = await ApiKeyService.instance.getApiKey('gemini');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please set it in settings.');
    }

    // Create message processor with Liquid Flutter catalog
    _messageProcessor = genui.A2uiMessageProcessor(
      catalogs: [LiquidCatalog.catalog],
    );

    // Create content generator
    _contentGenerator = GoogleGenerativeAiContentGenerator(
      catalog: LiquidCatalog.catalog,
      systemInstruction: systemInstructions,
      modelName: 'models/gemini-2.5-flash',
      apiKey: apiKey,
    );

    // Create conversation
    _conversation = genui.GenUiConversation(
      contentGenerator: _contentGenerator!,
      a2uiMessageProcessor: _messageProcessor!,
      onSurfaceAdded: _onSurfaceAdded,
      onSurfaceDeleted: _onSurfaceDeleted,
    );
  }

  /// Get the GenUI conversation instance
  genui.GenUiConversation? get conversation => _conversation;

  /// Get the message processor (host) for GenUiSurface
  genui.A2uiMessageProcessor? get host => _messageProcessor;

  /// Send a message to the AI
  Future<void> sendMessage(String text) async {
    if (_conversation == null) {
      await initialize();
    }
    _conversation?.sendRequest(genui.UserMessage.text(text));
  }

  /// Dispose resources
  void dispose() {
    _conversation?.dispose();
    _contentGenerator?.dispose();
    _messageProcessor?.dispose();
    _conversation = null;
    _contentGenerator = null;
    _messageProcessor = null;
  }

  /// Reinitialize with new API key if needed
  Future<void> reinitialize() async {
    dispose();
    await initialize();
  }
}
