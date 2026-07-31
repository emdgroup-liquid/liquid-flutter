import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConversationDemo extends StatefulWidget {
  const ConversationDemo({super.key});

  @override
  State<ConversationDemo> createState() => _ConversationDemoState();
}

enum _SimStreamKind { reasoning, reply }

class _ConversationDemoState extends State<ConversationDemo> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _attachments = <LdComposeAttachment>[];
  final _random = Random();
  var _isBusy = false;

  var _messageSeq = 0;

  late List<LdConversationItem> _items = _seedItems();
  var _tasks = <LdAgentTask>[];
  LdToolAllowRule? _seedAllowRule;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<LdConversationItem> _seedItems() {
    return [
      const LdSystemPromptItem(
        id: 'sys1',
        content:
            'You are a helpful release-notes assistant for Liquid Flutter. '
            'Prefer concise summaries, cite file paths when you used tools, '
            'and ask before opening pull requests.',
      ),
      const LdUserMessageItem(id: 'u1', text: 'Can you look up the release notes and summarize them?'),
      const LdReasoningItem(
        id: 'r1',
        content: 'I should search docs then open the latest release file.',
        duration: Duration(seconds: 4),
      ),
      const LdToolCallItem(
        id: 't1',
        name: 'search_docs',
        toolCallId: 'tc1',
        status: LdToolCallStatus.done,
        argsPreview: '{"query": "release notes"}',
        resultPreview: 'Found 3 matching documents.',
      ),
      const LdToolCallItem(
        id: 't2',
        name: 'read_file',
        toolCallId: 'tc2',
        status: LdToolCallStatus.done,
        argsPreview: '{"path": "CHANGELOG.md"}',
        resultPreview: '## 23.0.0\n- Conversation UI\n- Send fly animation',
      ),
      const LdReasoningItem(
        id: 'r2',
        content: 'Enough context to write a short summary.',
        duration: Duration(seconds: 2),
      ),
      const LdAgentMarkdownItem(
        id: 'a1',
        markdown:
            '### Summary\n\nVersion **23.0.0** adds conversation UI pieces and an opt-in send-fly animation.\n\nWant me to draft a changelog blurb?',
      ),
      const LdApprovalItem(
        id: 'ap1',
        title: 'Create pull request?',
        description: 'Open a PR titled “feat: liquid_flutter_ai conversation widgets”.',
        toolName: 'create_pull_request',
        arguments: '''
{
  "title": "feat: liquid_flutter_ai conversation widgets",
  "draft": true,
  "base": "main",
  "head": "feat/liquid-flutter-ai",
  "labels": ["ui", "ai"],
  "repo": {
    "owner": "mtrust",
    "name": "liquid-flutter",
    "visibility": "private"
  },
  "reviewers": {
    "users": ["alice", "bob"],
    "team": {
      "slug": "design-system",
      "required": true
    }
  },
  "options": {
    "squash": true,
    "delete_branch": false,
    "checks": {
      "ci": "required",
      "lint": "optional"
    }
  }
}
''',
        inputSchema: '''
{
  "type": "object",
  "required": ["title", "base", "head", "repo"],
  "properties": {
    "title": { "type": "string" },
    "body": { "type": "string" },
    "draft": { "type": "boolean" },
    "base": { "type": "string" },
    "head": { "type": "string" },
    "labels": { "type": "array", "items": { "type": "string" } },
    "assignees": { "type": "array", "items": { "type": "string" } },
    "repo": {
      "type": "object",
      "required": ["owner", "name"],
      "properties": {
        "owner": { "type": "string" },
        "name": { "type": "string" },
        "visibility": {
          "type": "string",
          "enum": ["public", "private", "internal"]
        }
      }
    },
    "reviewers": {
      "type": "object",
      "properties": {
        "users": { "type": "array", "items": { "type": "string" } },
        "team": {
          "type": "object",
          "properties": {
            "slug": { "type": "string" },
            "required": { "type": "boolean" }
          }
        }
      }
    },
    "options": {
      "type": "object",
      "properties": {
        "squash": { "type": "boolean" },
        "delete_branch": { "type": "boolean" },
        "checks": {
          "type": "object",
          "properties": {
            "ci": {
              "type": "string",
              "enum": ["required", "optional", "skip"]
            },
            "lint": {
              "type": "string",
              "enum": ["required", "optional", "skip"]
            }
          }
        }
      }
    }
  }
}
''',
        status: LdApprovalStatus.pending,
      ),
    ];
  }

  void _beginTasks(String prompt, {required int seq}) {
    final topic = prompt.trim().isEmpty ? 'your request' : prompt.trim();
    final short = topic.length > 42 ? '${topic.substring(0, 42)}…' : topic;
    setState(() {
      _tasks = [
        LdAgentTask(id: 'task-$seq-understand', label: 'Understand “$short”', status: LdAgentTaskStatus.inProgress),
        LdAgentTask(id: 'task-$seq-draft', label: 'Draft reply', status: LdAgentTaskStatus.pending),
        LdAgentTask(id: 'task-$seq-check', label: 'Check draft', status: LdAgentTaskStatus.pending),
        LdAgentTask(id: 'task-$seq-deliver', label: 'Deliver response', status: LdAgentTaskStatus.pending),
      ];
    });
  }

  void _advanceTask(String fromId, {String? toId}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = [
        for (final task in _tasks)
          if (task.id == fromId)
            LdAgentTask(id: task.id, label: task.label, status: LdAgentTaskStatus.done)
          else if (toId != null && task.id == toId)
            LdAgentTask(id: task.id, label: task.label, status: LdAgentTaskStatus.inProgress)
          else
            task,
      ];
    });
  }

  void _finishTasks() {
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = [for (final task in _tasks) LdAgentTask(id: task.id, label: task.label, status: LdAgentTaskStatus.done)];
    });
  }

  void _handleSend(String text, LdSendFlyScopeState flyScope) {
    final trimmed = text.trim();
    if (trimmed.isEmpty && _attachments.isEmpty) {
      return;
    }

    final id = 'local-${++_messageSeq}';
    final message = LdUserMessageItem(
      id: id,
      text: trimmed.isEmpty ? '(attachment)' : trimmed,
      attachments: List.of(_attachments),
    );
    final bubble = LdUserBubble(text: message.text, attachments: message.attachments, fill: true);

    _controller.clear();
    setState(() => _attachments.clear());

    void commitMessage() {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = [..._items, message];
        _isBusy = true;
      });
      _simulateAgentReply(id, trimmed);
    }

    flyScope.dispatch(message, bubble: bubble, onCommitted: commitMessage);
  }

  void _handleVoiceRecorded(LdVoiceRecording recording, LdSendFlyScopeState flyScope) {
    final seconds = (recording.length.inMilliseconds / 1000).toStringAsFixed(1);
    final attachment = LdComposeAttachment(
      id: 'voice-${++_messageSeq}',
      name: recording.file.name,
      mimeType: recording.file.mimeType ?? 'audio/mp4',
      preview: const Icon(LucideIcons.mic),
    );

    final id = 'local-${++_messageSeq}';
    final text = 'Voice message (${seconds}s)';
    final message = LdUserMessageItem(id: id, text: text, attachments: [attachment]);
    final bubble = LdUserBubble(text: text, attachments: [attachment], fill: true);

    flyScope.dispatch(
      message,
      bubble: bubble,
      onCommitted: () {
        if (!mounted) {
          return;
        }
        setState(() {
          _items = [..._items, message];
          _isBusy = true;
        });
        _simulateAgentReply(id, text);
      },
    );
  }

  Future<void> _simulateAgentReply(String userMessageId, String trimmed) async {
    final seq = _messageSeq;
    final understandId = 'task-$seq-understand';
    final draftId = 'task-$seq-draft';
    final checkId = 'task-$seq-check';
    final deliverId = 'task-$seq-deliver';

    final fullReasoning =
        '''
Considering how to answer “$trimmed”.

First I should restate the ask in plain language so I do not drift.
Then check whether any tool output is required before drafting.
A short outline will keep the reply skimmable in this conversation UI.

I will stream this reasoning past five lines so the ticker can scroll,
keeping only the newest window visible with fades at both edges.

After that I will call draft_reply, wait for completion, collapse this
activity group into a summary header, and finally stream the markdown reply.
''';
    final fullMarkdown =
        '''
### Got it — working on “$trimmed”

Here is a longer draft so you can watch the stream reveal settle across real markdown blocks.

#### Plan
1. Capture the intent behind **“$trimmed”**
2. Pull the smallest useful context
3. Reply in short, skimmable sections

#### Findings
- The ask is clear enough to answer without more clarification.
- A compact outline beats a wall of prose for this UI demo.
- Streaming should keep older lines sharp while the leading edge fades.

#### Suggested reply

> Sure — I can help with **“$trimmed”**. Below is a first pass you can edit.

```dart
void greet(String topic) {
  print('Working on: \$topic');
}
```

| Step | Owner | Status |
| --- | --- | --- |
| Clarify scope | You | Done |
| Draft answer | Agent | In progress |
| Polish copy | You | Todo |

#### Next actions
- [ ] Confirm tone (casual vs formal)
- [ ] Decide whether to include code samples
- [ ] Ship the final blurb

Call out if you want this expanded into a full changelog entry, a PR description, or a customer-facing note.
''';

    await Future<void>.delayed(_jitter(120, 420));
    if (!mounted) {
      return;
    }

    _beginTasks(trimmed, seq: seq);

    await _streamText(
      fullReasoning,
      kind: _SimStreamKind.reasoning,
      initialDelay: _jitter(450, 1100),
      minChunkSize: 8,
      maxChunkSize: 12,
      minDelayMs: 48,
      maxDelayMs: 92,
    );

    await _streamText(
      "I understand, let me work on it...",
      kind: _SimStreamKind.reply,
      initialDelay: _jitter(350, 1200),
      minChunkSize: 10,
      maxChunkSize: 28,
      minDelayMs: 24,
      maxDelayMs: 200,
    );

    _advanceTask(understandId, toId: draftId);

    await Future<void>.delayed(_jitter(950, 1200));

    await _simulateToolCall(
      name: 'draft_reply',
      toolCallId: 'tc-$userMessageId-draft',
      argsPreview: '{"prompt": "$trimmed"}',
      resultPreview: 'Draft ready.',
      duration: _jitter(900, 2800),
    );

    _advanceTask(draftId, toId: checkId);

    await _streamText(
      "Draft succeeded.. let me check it",
      kind: _SimStreamKind.reasoning,
      initialDelay: _jitter(350, 1200),
      minChunkSize: 10,
      maxChunkSize: 28,
      minDelayMs: 24,
      maxDelayMs: 200,
    );

    await _simulateToolCall(
      name: 'draft_check',
      toolCallId: 'tc-$userMessageId-check',
      argsPreview: '{"draft": "Draft ready."}',
      resultPreview: 'Draft checked.',
      duration: _jitter(900, 2800),
    );

    _advanceTask(checkId, toId: deliverId);

    await Future<void>.delayed(_jitter(950, 1200));

    await _streamText(
      "Left me present the final result to the user...",
      kind: _SimStreamKind.reasoning,
      initialDelay: _jitter(350, 1200),
      minChunkSize: 10,
      maxChunkSize: 28,
      minDelayMs: 24,
      maxDelayMs: 200,
    );

    await Future<void>.delayed(_jitter(950, 1200));

    await _streamText(
      fullMarkdown,
      kind: _SimStreamKind.reply,
      initialDelay: _jitter(350, 1200),
      minChunkSize: 10,
      maxChunkSize: 28,
      minDelayMs: 24,
      maxDelayMs: 200,
    );

    _finishTasks();

    if (mounted) {
      setState(() => _isBusy = false);
    }
  }

  Duration _jitter(int minMs, int maxMs) {
    return Duration(milliseconds: minMs + _random.nextInt(maxMs - minMs + 1));
  }

  String _nextId(String prefix) => '$prefix-${++_messageSeq}';

  /// Inserts a streaming [reasoning] or [reply] item, waits [initialDelay], then streams [full].
  Future<void> _streamText(
    String full, {
    required _SimStreamKind kind,
    Duration? initialDelay,
    int minChunkSize = 10,
    int maxChunkSize = 20,
    int minDelayMs = 30,
    int maxDelayMs = 70,
  }) async {
    if (!mounted) {
      return;
    }

    final id = _nextId(kind.name);
    setState(() {
      _items = [
        ..._items,
        switch (kind) {
          _SimStreamKind.reasoning => LdReasoningItem(id: id, content: '', isStreaming: true),
          _SimStreamKind.reply => LdAgentMarkdownItem(id: id, markdown: '', isStreaming: true),
        },
      ];
    });

    if (initialDelay != null) {
      await Future<void>.delayed(initialDelay);
    }

    var offset = 0;
    while (offset < full.length) {
      await Future<void>.delayed(_jitter(minDelayMs, maxDelayMs));
      if (!mounted) {
        return;
      }
      final chunkSize = minChunkSize + _random.nextInt(maxChunkSize - minChunkSize + 1);
      offset = (offset + chunkSize).clamp(0, full.length);
      final slice = full.substring(0, offset);
      final done = offset >= full.length;

      setState(() {
        _items = [
          for (final item in _items)
            if (kind == _SimStreamKind.reasoning && item is LdReasoningItem && item.id == id)
              LdReasoningItem(
                id: item.id,
                content: slice,
                isStreaming: !done,
                duration: done ? Duration(milliseconds: 4200 + _random.nextInt(3200)) : null,
              )
            else if (kind == _SimStreamKind.reply && item is LdAgentMarkdownItem && item.id == id)
              LdAgentMarkdownItem(id: item.id, markdown: slice, isStreaming: !done)
            else
              item,
        ];
      });
    }
  }

  /// Inserts a running tool call, waits [duration], then marks it done.
  Future<void> _simulateToolCall({
    required String name,
    required String toolCallId,
    String? argsPreview,
    String resultPreview = 'Done.',
    Duration? duration,
  }) async {
    if (!mounted) {
      return;
    }

    final id = _nextId('tool');
    setState(() {
      _items = [
        ..._items,
        LdToolCallItem(
          id: id,
          name: name,
          toolCallId: toolCallId,
          status: LdToolCallStatus.running,
          argsPreview: argsPreview,
        ),
      ];
    });

    await Future<void>.delayed(duration ?? _jitter(900, 2800));
    if (!mounted) {
      return;
    }

    setState(() {
      _items = [
        for (final item in _items)
          if (item is LdToolCallItem && item.id == id)
            LdToolCallItem(
              id: item.id,
              name: item.name,
              toolCallId: item.toolCallId,
              status: LdToolCallStatus.done,
              argsPreview: item.argsPreview,
              resultPreview: resultPreview,
            )
          else
            item,
      ];
    });
  }

  void _setApproval(String id, LdApprovalStatus status) {
    setState(() {
      _items = [
        for (final item in _items)
          if (item is LdApprovalItem && item.id == id)
            LdApprovalItem(
              id: item.id,
              title: item.title,
              description: item.description,
              toolCallId: item.toolCallId,
              toolName: item.toolName,
              arguments: item.arguments,
              inputSchema: item.inputSchema,
              status: status,
            )
          else
            item,
      ];
    });
  }

  LdConversationApprovalActions get _approvalActions =>
      LdConversationApprovalActions(
        onApprove: (item) => _setApproval(item.id, LdApprovalStatus.approved),
        onDeny: (item) => _setApproval(item.id, LdApprovalStatus.denied),
        seedRuleFor: (item) {
          final seed = _seedAllowRule;
          if (seed == null || seed.toolName != item.toolName) {
            return null;
          }
          return seed;
        },
        onApproveWithRule: (item, result) {
          // Demo: rule would be persisted by the host app.
          debugPrint('Saved allow rule: ${result.savedRule}');
          if (result.savedRule != null) {
            _seedAllowRule = result.savedRule;
          }
          _setApproval(item.id, LdApprovalStatus.approved);
        },
      );

  Widget _buildItem(
    BuildContext context,
    LdConversationItem item,
    bool isSingleton,
  ) {
    return switch (item) {
      LdUserMessageItem(:final id, :final text, :final attachments) =>
        LdSendFlyTarget(
          id: id,
          child: LdUserBubble(text: text, attachments: attachments),
        ),
      _ => LdConversation.defaultItemBuilder(
        context,
        item,
        isSingleton,
        approval: _approvalActions,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LdSendFlyScope(
      child: Builder(
        builder: (context) {
          final fly = LdSendFlyScope.of(context);
          final conversation = LdAgentTaskPanel(
            tasks: _tasks,

            child: LdConversation(
              items: _items,
              approval: _approvalActions,
              itemBuilder: _buildItem,
            ),
          );
          final composeBar = LdComposeBar(
            controller: _controller,
            focusNode: _focusNode,
            attachments: _attachments,
            isBusy: _isBusy,
            leading: LdContextUsageIndicator(
              contextUsage: const LdContextUsage(estimatedTokens: 12400, contextLimit: 128000, lastPromptTokens: 9800),
              onTap: () {
                final pricing = ldModelPricingLookup(const [
                  LdModelPricing(
                    modelId: 'openai/gpt-4o-mini',
                    displayName: 'GPT-4o Mini',
                    promptPricePerToken: 0.00000015,
                    completionPricePerToken: 0.0000006,
                  ),
                ]);
                final totals = ldComputeUsage(
                  pricingByModelId: pricing,
                  records: const [
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 2200,
                      totalTokens: 2200,
                      kind: LdUsageKind.user,
                    ),
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 1200,
                      totalTokens: 1200,
                      kind: LdUsageKind.tools,
                      toolName: 'bash',
                    ),
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 450,
                      totalTokens: 450,
                      kind: LdUsageKind.tools,
                      toolName: 'read_file',
                    ),
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 150,
                      totalTokens: 150,
                      kind: LdUsageKind.tools,
                      toolName: 'grep',
                    ),
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 4800,
                      completionTokens: 900,
                      totalTokens: 5700,
                      kind: LdUsageKind.agent,
                    ),
                    LdTokenUsageRecord(
                      modelId: 'openai/gpt-4o-mini',
                      promptTokens: 1000,
                      completionTokens: 300,
                      totalTokens: 1300,
                      kind: LdUsageKind.reasoning,
                    ),
                  ],
                );
                LdModalRoute(
                  context: context,
                  pageBuilder: (modalContext) => LdUsageCostModal(
                    totals: totals,
                    contextUsage: const LdContextUsage(
                      estimatedTokens: 12400,
                      contextLimit: 128000,
                      lastPromptTokens: 9800,
                    ),
                  ),
                ).show(context, useRootNavigator: true);
              },
            ),
            onSend: (text) => _handleSend(text, fly),
            onStop: () => setState(() => _isBusy = false),
            onPickFile: () {
              setState(() {
                _attachments.add(
                  LdComposeAttachment(id: 'file-${_attachments.length}', name: 'notes.md', mimeType: 'text/markdown'),
                );
              });
            },
            onPickImage: () {
              setState(() {
                _attachments.add(
                  LdComposeAttachment(
                    id: 'img-${_attachments.length}',
                    name: 'shot.png',
                    mimeType: 'image/png',
                    preview: ColoredBox(
                      color: LdTheme.of(context).primaryColor.withValues(alpha: 0.3),
                      child: const Icon(LucideIcons.image),
                    ),
                  ),
                );
              });
            },
            onCustomPaste: () async {
              // Intercept paste to handle image data from clipboard.
              // Use a platform-specific clipboard reader (e.g. super_clipboard)
              // to read image bytes, then create an LdComposeAttachment with
              // a thumbnail preview and return true.
              // Returning false falls back to default text paste.
              return false;
            },
            onRemoveAttachment: (attachment) {
              setState(() {
                _attachments.removeWhere((a) => a.id == attachment.id);
              });
            },
            onVoiceRecorded: (recording) => _handleVoiceRecorded(recording, fly),
            child: conversation,
          );

          return LdScaffold(body: composeBar);
        },
      ),
    );
  }
}
