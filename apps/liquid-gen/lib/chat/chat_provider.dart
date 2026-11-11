import 'package:flutter/foundation.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  final Set<String> _surfaceIds = {};

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  Set<String> get surfaceIds => Set.unmodifiable(_surfaceIds);

  void addMessage(String content, {required bool isUser}) {
    _messages.add(ChatMessage(content: content, isUser: isUser));
    notifyListeners();
  }

  void setGenerating(bool generating) {
    if (_isGenerating != generating) {
      _isGenerating = generating;
      notifyListeners();
    }
  }

  void addSurface(String surfaceId) {
    _surfaceIds.add(surfaceId);
    notifyListeners();
  }

  void removeSurface(String surfaceId) {
    _surfaceIds.remove(surfaceId);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _surfaceIds.clear();
    notifyListeners();
  }
}
