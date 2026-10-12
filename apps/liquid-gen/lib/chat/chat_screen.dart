import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../ai/genui_service.dart';
import '../preview/preview_provider.dart';
import 'chat_provider.dart';
import 'components/user_message.dart';
import 'components/ai_message.dart';
import 'components/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController(
    text: "A simple login screen with a username and password field.",
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGenUI();
    });
  }

  Future<void> _initializeGenUI() async {
    if (!mounted) return;
    try {
      GenUIService.instance.setCallbacks(
        onSurfaceAdded: (update) {
          if (!mounted) return;
          final chatProvider = context.read<ChatProvider>();
          final previewProvider = context.read<PreviewProvider>();
          chatProvider.addSurface(update.surfaceId);
          previewProvider.setSurfaceIds(chatProvider.surfaceIds);
        },
        onSurfaceDeleted: (update) {
          if (!mounted) return;
          final chatProvider = context.read<ChatProvider>();
          final previewProvider = context.read<PreviewProvider>();
          chatProvider.removeSurface(update.surfaceId);
          previewProvider.setSurfaceIds(chatProvider.surfaceIds);
        },
      );
      await GenUIService.instance.initialize();
    } catch (e) {
      if (mounted) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.addMessage(
          'Error initializing GenUI: $e',
          isUser: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final chatProvider = context.read<ChatProvider>();
    final text = _inputController.text.trim();
    if (text.isEmpty || chatProvider.isGenerating) return;

    chatProvider.addMessage(text, isUser: true);
    _inputController.clear();
    _scrollToBottom();

    chatProvider.setGenerating(true);
    _scrollToBottom();

    try {
      await GenUIService.instance.sendMessage(text);
      chatProvider.addMessage(
        'Generating UI...',
        isUser: false,
      );
    } catch (e) {
      chatProvider.addMessage(
        'Error: ${e.toString()}',
        isUser: false,
      );
    } finally {
      chatProvider.setGenerating(false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Padding(
      padding: MediaQuery.paddingOf(context).add(EdgeInsets.all(8)),
      child: Column(
        children: [
          // Messages list
          Expanded(
            child: provider.messages.isEmpty
                ? Center(
                    child: LdText.p(
                      'Start a conversation to generate UI screens',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: LdTheme.of(context).pad(size: LdSize.m),
                    itemCount:
                        provider.messages.length +
                        (provider.isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length) {
                        return const LoadingIndicator();
                      }
                      final message = provider.messages[index];
                      return message.isUser
                          ? UserMessage(message: message)
                          : AIMessage(message: message);
                    },
                  ),
          ),
          const LdDivider(height: 1),
          // Input area
          Container(
            padding: LdTheme.of(context).pad(size: LdSize.m),
            child: Row(
              children: [
                Expanded(
                  child: LdInput(
                    controller: _inputController,
                    hint: 'Describe the UI you want to generate...',
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                LdButton(
                  onPressed: _sendMessage,
                  disabled: provider.isGenerating,
                  child: const Icon(LucideIcons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
