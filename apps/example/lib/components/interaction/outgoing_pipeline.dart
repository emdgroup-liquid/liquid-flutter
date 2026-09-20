import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _FailMode { never, once, always }

class _OutgoingScenario {
  const _OutgoingScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.persistWhen,
    this.persistFail = _FailMode.never,
    this.sendFail = _FailMode.never,
  });

  final String id;
  final String title;
  final String subtitle;
  final LdAttachmentPersistWhen persistWhen;
  final _FailMode persistFail;
  final _FailMode sendFail;
}

const _scenarios = [
  _OutgoingScenario(
    id: 'submit-ok',
    title: 'On send · all succeed',
    subtitle: 'Optimistic send. Persist progress and send live on the bubble.',
    persistWhen: LdAttachmentPersistWhen.submit,
  ),
  _OutgoingScenario(
    id: 'submit-persist-once',
    title: 'On send · persist fails once',
    subtitle: 'Retry on the bubble chip, then send continues.',
    persistWhen: LdAttachmentPersistWhen.submit,
    persistFail: _FailMode.once,
  ),
  _OutgoingScenario(
    id: 'submit-send-once',
    title: 'On send · send fails once',
    subtitle: 'Persist succeeds. Retry send without re-uploading.',
    persistWhen: LdAttachmentPersistWhen.submit,
    sendFail: _FailMode.once,
  ),
  _OutgoingScenario(
    id: 'submit-send-always',
    title: 'On send · send always fails',
    subtitle: 'Use bubble retry to watch the send Future keep failing.',
    persistWhen: LdAttachmentPersistWhen.submit,
    sendFail: _FailMode.always,
  ),
  _OutgoingScenario(
    id: 'pick-ok',
    title: 'On pick · all succeed',
    subtitle: 'Upload starts on attach. Send stays disabled until remoteId.',
    persistWhen: LdAttachmentPersistWhen.pick,
  ),
  _OutgoingScenario(
    id: 'pick-persist-once',
    title: 'On pick · persist fails once',
    subtitle: 'Retry on the compose chip. Send stays blocked until it works.',
    persistWhen: LdAttachmentPersistWhen.pick,
    persistFail: _FailMode.once,
  ),
  _OutgoingScenario(
    id: 'pick-persist-always',
    title: 'On pick · persist always fails',
    subtitle: 'Send stays disabled. Remove the chip or keep retrying.',
    persistWhen: LdAttachmentPersistWhen.pick,
    persistFail: _FailMode.always,
  ),
  _OutgoingScenario(
    id: 'pick-send-once',
    title: 'On pick · send fails once',
    subtitle: 'Already persisted. Only send retry appears on the bubble.',
    persistWhen: LdAttachmentPersistWhen.pick,
    sendFail: _FailMode.once,
  ),
];

class OutgoingPipelineDemo extends StatefulWidget {
  const OutgoingPipelineDemo({super.key});

  @override
  State<OutgoingPipelineDemo> createState() => _OutgoingPipelineDemoState();
}

class _OutgoingPipelineDemoState extends State<OutgoingPipelineDemo> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _persistAttempts = <String, int>{};
  final _sendAttempts = <String, int>{};

  var _scenario = _scenarios.first;
  var _seq = 0;
  var _attachments = <LdComposeAttachment>[];
  var _items = <LdConversationItem>[_introItem(_scenarios.first)];
  var _logLines = <String>[];
  final _pendingFly = <String>{};

  static LdSystemPromptItem _introItem(_OutgoingScenario scenario) {
    return LdSystemPromptItem(
      id: 'sys',
      title: scenario.title,
      content:
          '${scenario.subtitle}\n\nAttach a demo file, then send. Location '
          'attachments skip persist and pass their local id through as the '
          'remote id.',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectScenario(_OutgoingScenario scenario) {
    _controller.clear();
    setState(() {
      _scenario = scenario;
      _seq = 0;
      _attachments = [];
      _items = [_introItem(scenario)];
      _logLines = [];
      _persistAttempts.clear();
      _sendAttempts.clear();
      _pendingFly.clear();
    });
  }

  void _log(String line) {
    if (!mounted) {
      return;
    }
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _logLines = ['$stamp  $line', ..._logLines.take(9)];
    });
  }

  void _onMessage(LdUserMessageItem item, LdSendFlyScopeState fly) {
    final exists = _items.any((existing) => existing.id == item.id);
    if (!exists && !_pendingFly.contains(item.id)) {
      _pendingFly.add(item.id);
      fly.dispatch(
        item,
        bubble: LdUserBubble(text: item.text, attachments: item.attachments, fill: true),
        onCommitted: () {
          _pendingFly.remove(item.id);
          if (!_items.any((existing) => existing.id == item.id)) {
            _upsertItem(item);
          }
        },
      );
      return;
    }
    _upsertItem(item);
  }

  Widget _buildItem(BuildContext context, LdConversationItem item, bool isSingleton) {
    return switch (item) {
      LdUserMessageItem() => LdSendFlyTarget(
        id: item.id,
        child: LdUserBubble(
          text: item.text,
          attachments: item.attachments,
          delivery: item.delivery,
          deliveryError: item.deliveryError,
          onRetry: () => LdOutgoingScope.maybeOf(context, listen: false)?.retry(item.id),
          onRetryAttachment: (attachmentId) =>
              LdOutgoingScope.maybeOf(context, listen: false)?.retryMessageAttachment(item.id, attachmentId),
        ),
      ),
      _ => LdConversation.defaultItemBuilder(context, item, isSingleton),
    };
  }

  void _upsertItem(LdUserMessageItem item) {
    setState(() {
      final index = _items.indexWhere((existing) => existing.id == item.id);
      if (index < 0) {
        _items = [..._items, item];
      } else {
        final next = [..._items];
        next[index] = item;
        _items = next;
      }
    });
  }

  void _upsertDraft(LdComposeAttachment attachment) {
    setState(() {
      final index = _attachments.indexWhere((existing) => existing.id == attachment.id);
      if (index < 0) {
        _attachments = [..._attachments, attachment];
      } else {
        final next = [..._attachments];
        next[index] = attachment;
        _attachments = next;
      }
    });
  }

  bool _shouldFail(_FailMode mode, int attempt) {
    return switch (mode) {
      _FailMode.never => false,
      _FailMode.once => attempt == 1,
      _FailMode.always => true,
    };
  }

  Stream<LdPersistEvent> _persist(LdComposeAttachment attachment) async* {
    final attempt = _persistAttempts[attachment.id] = (_persistAttempts[attachment.id] ?? 0) + 1;
    _log('persist ${attachment.name} (attempt $attempt)');
    yield const LdPersistEvent.progress(0.2);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    yield const LdPersistEvent.progress(0.65);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (_shouldFail(_scenario.persistFail, attempt)) {
      _log('persist failed');
      throw Exception('Upload failed');
    }
    final remoteId = 'remote-${attachment.id}';
    _log('persist done → $remoteId');
    yield LdPersistEvent.done(remoteId);
  }

  Future<void> _send(LdOutgoingMessage message) async {
    final attempt = _sendAttempts[message.id] = (_sendAttempts[message.id] ?? 0) + 1;
    _log('send ${message.id} (attempt $attempt)');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_shouldFail(_scenario.sendFail, attempt)) {
      _log('send failed');
      throw Exception('Backend rejected the message');
    }
    _log('send ok');
  }

  LdComposeAttachment _demoFile() {
    return LdComposeAttachment(
      id: 'file-${++_seq}',
      name: 'notes.md',
      mimeType: 'text/markdown',
      kind: LdAttachmentKind.file,
      size: 2048,
      file: XFile.fromData(Uint8List.fromList(const [1, 2, 3]), name: 'notes.md', mimeType: 'text/markdown'),
    );
  }

  LdComposeAttachment _demoLocation() {
    return LdComposeAttachment(id: 'loc-${++_seq}', name: 'Office', kind: LdAttachmentKind.location);
  }

  void _attachFile(LdOutgoingScopeState outgoing) {
    final attachment = _demoFile();
    _upsertDraft(attachment);
    if (_scenario.persistWhen == LdAttachmentPersistWhen.pick) {
      unawaited(outgoing.persistDraft(attachment));
    }
  }

  void _attachLocation() {
    _upsertDraft(_demoLocation());
  }

  @override
  Widget build(BuildContext context) {
    return LdSendFlyScope(
      child: Builder(
        builder: (context) {
          final fly = LdSendFlyScope.of(context);
          return LdOutgoingScope(
            key: ValueKey(_scenario.id),
            persistWhen: _scenario.persistWhen,
            persistAttachment: _persist,
            send: _send,
            onMessage: (item) => _onMessage(item, fly),
            onDraftAttachment: _upsertDraft,
            onSubmitted: () {
              _controller.clear();
              setState(() => _attachments = []);
            },
            child: Builder(
              builder: (context) {
                final outgoing = LdOutgoingScope.of(context);
                return LdScaffold(
                  body: LdAppBar.top(
                    title: LdText.h('Outgoing pipeline'),
                    actions: [
                      LdButton.ghost(
                        size: LdSize.s,
                        onPressed: () => _selectScenario(_scenario),
                        child: const Text('Reset'),
                      ),
                    ],
                    bottom: _buildControls(context),
                    child: LdComposeBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      attachments: _attachments,
                      hintText: 'Message',
                      leading: Row(
                        children: [
                          LdButton.outline(
                            size: LdSize.l,
                            onPressed: () => _attachFile(outgoing),
                            child: const Icon(LucideIcons.file),
                          ),
                          ldHSpacerXS,
                          LdButton.outline(
                            size: LdSize.l,
                            onPressed: _attachLocation,
                            child: const Icon(LucideIcons.mapPin),
                          ),
                        ],
                      ),
                      onRemoveAttachment: (attachment) {
                        setState(() {
                          _attachments = [
                            for (final existing in _attachments)
                              if (existing.id != attachment.id) existing,
                          ];
                        });
                      },
                      child: LdConversation(
                        items: _items,
                        itemBuilder: _buildItem,
                        padding: LdTheme.of(context).pad(size: LdSize.m),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = LdTheme.of(context);
    return ColoredBox(
      color: theme.surface,
      child: LdAutoSpace(
        children: [
          LdSelect<_OutgoingScenario>(
            label: 'Scenario',
            value: _scenario,
            items: [for (final scenario in _scenarios) LdSelectItem(value: scenario, child: Text(scenario.title))],
            onChanged: _selectScenario,
          ),
          LdText.p(_scenario.subtitle),
          LdText.lxs(switch (_scenario.persistWhen) {
            LdAttachmentPersistWhen.submit => 'persistWhen: submit — chips and send retry live on the bubble.',
            LdAttachmentPersistWhen.pick => 'persistWhen: pick — persist on compose chips; send waits for remoteId.',
          }, color: theme.textMuted),
          if (_logLines.isNotEmpty) LdText.lxs(_logLines.join('\n'), color: theme.textMuted),
        ],
      ).padM(),
    );
  }
}
