import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:liquid_flutter_ai/src/models/outgoing.dart';
import 'package:provider/provider.dart';

/// Coordinates persist + send for outgoing user messages.
///
/// Host owns transcript and draft lists; this scope upserts them through
/// [onMessage] / [onDraftAttachment].
class LdOutgoingScope extends StatefulWidget {
  final Widget child;
  final LdAttachmentPersistWhen persistWhen;
  final LdAttachmentPersister? persistAttachment;
  final LdSendMessage? send;
  final ValueChanged<LdUserMessageItem> onMessage;
  final ValueChanged<LdComposeAttachment>? onDraftAttachment;
  final VoidCallback? onSubmitted;

  const LdOutgoingScope({
    super.key,
    required this.child,
    required this.onMessage,
    this.persistWhen = LdAttachmentPersistWhen.submit,
    this.persistAttachment,
    this.send,
    this.onDraftAttachment,
    this.onSubmitted,
  });

  /// Reads the controller if a scope is above.
  static LdOutgoingScopeState? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return Provider.of<LdOutgoingScopeState>(context, listen: listen);
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// Reads the controller. Throws if no scope is above.
  static LdOutgoingScopeState of(BuildContext context, {bool listen = false}) {
    return Provider.of<LdOutgoingScopeState>(context, listen: listen);
  }

  @override
  State<LdOutgoingScope> createState() => _LdOutgoingScopeWidgetState();
}

class _LdOutgoingScopeWidgetState extends State<LdOutgoingScope> {
  late final LdOutgoingScopeState _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdOutgoingScopeState(
      persistWhen: widget.persistWhen,
      persistAttachment: widget.persistAttachment,
      send: widget.send,
      onMessage: widget.onMessage,
      onDraftAttachment: widget.onDraftAttachment,
      onSubmitted: widget.onSubmitted,
    );
  }

  @override
  void didUpdateWidget(covariant LdOutgoingScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateHost(
      persistWhen: widget.persistWhen,
      persistAttachment: widget.persistAttachment,
      send: widget.send,
      onMessage: widget.onMessage,
      onDraftAttachment: widget.onDraftAttachment,
      onSubmitted: widget.onSubmitted,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdOutgoingScopeState>.value(
      value: _controller,
      child: widget.child,
    );
  }
}

/// Persist/send coordinator provided by [LdOutgoingScope].
class LdOutgoingScopeState extends ChangeNotifier {
  LdOutgoingScopeState({
    required LdAttachmentPersistWhen persistWhen,
    required ValueChanged<LdUserMessageItem> onMessage,
    LdAttachmentPersister? persistAttachment,
    LdSendMessage? send,
    ValueChanged<LdComposeAttachment>? onDraftAttachment,
    VoidCallback? onSubmitted,
  }) : _persistWhen = persistWhen,
       _persistAttachment = persistAttachment,
       _send = send,
       _onMessage = onMessage,
       _onDraftAttachment = onDraftAttachment,
       _onSubmitted = onSubmitted;

  LdAttachmentPersistWhen _persistWhen;
  LdAttachmentPersister? _persistAttachment;
  LdSendMessage? _send;
  ValueChanged<LdUserMessageItem> _onMessage;
  ValueChanged<LdComposeAttachment>? _onDraftAttachment;
  VoidCallback? _onSubmitted;

  var _seq = 0;
  var _disposed = false;

  final _items = <String, LdUserMessageItem>{};
  final _inFlight = <String>{};
  final _messagePersistSubs = <String, StreamSubscription<LdPersistEvent>>{};
  final _drafts = <String, LdComposeAttachment>{};
  final _draftSubs = <String, StreamSubscription<LdPersistEvent>>{};

  LdAttachmentPersistWhen get persistWhen => _persistWhen;

  void updateHost({
    required LdAttachmentPersistWhen persistWhen,
    required ValueChanged<LdUserMessageItem> onMessage,
    LdAttachmentPersister? persistAttachment,
    LdSendMessage? send,
    ValueChanged<LdComposeAttachment>? onDraftAttachment,
    VoidCallback? onSubmitted,
  }) {
    _persistWhen = persistWhen;
    _persistAttachment = persistAttachment;
    _send = send;
    _onMessage = onMessage;
    _onDraftAttachment = onDraftAttachment;
    _onSubmitted = onSubmitted;
  }

  /// Send is allowed when there is nothing left to persist (pick mode).
  bool canSend(List<LdComposeAttachment> attachments) {
    if (_persistWhen != LdAttachmentPersistWhen.pick) {
      return true;
    }
    for (final attachment in attachments) {
      if (!attachment.needsPersist && !attachment.hasPersistError) {
        continue;
      }
      return false;
    }
    return true;
  }

  /// Optimistic submit (submit mode) or send-only (pick mode).
  Future<void> submit({
    required String text,
    required List<LdComposeAttachment> attachments,
  }) async {
    if (_persistWhen == LdAttachmentPersistWhen.pick && !canSend(attachments)) {
      return;
    }

    final prepared = _prepareForSubmit(attachments);
    final needsPersist = prepared.any((attachment) => attachment.needsPersist);
    final id = 'outgoing-${++_seq}-${DateTime.now().microsecondsSinceEpoch}';
    final delivery = switch (needsPersist) {
      true => LdMessageDelivery.persisting,
      false => LdMessageDelivery.sending,
    };
    final item = LdUserMessageItem(
      id: id,
      text: text,
      attachments: prepared,
      delivery: delivery,
    );
    _emit(item);
    _onSubmitted?.call();
    await _runPipeline(id);
  }

  /// Pick-mode persist for a compose chip. No-op in submit mode.
  Future<void> persistDraft(LdComposeAttachment attachment) {
    if (_persistWhen != LdAttachmentPersistWhen.pick) {
      return Future.value();
    }
    return _persistDraftAttachment(attachment);
  }

  /// Cancel an in-flight draft persist (host removed the chip).
  void cancelDraft(String attachmentId) {
    unawaited(_draftSubs.remove(attachmentId)?.cancel());
    _drafts.remove(attachmentId);
  }

  /// Retry failed persist on a compose chip (pick mode).
  Future<void> retryDraft(String attachmentId) async {
    final attachment = _drafts[attachmentId];
    if (attachment == null) {
      return;
    }
    await _persistDraftAttachment(
      attachment.copyWith(persistError: null, persistProgress: 0.0),
    );
  }

  /// Retry failed persist (if any) then send for a transcript message.
  Future<void> retry(String messageId) async {
    final item = _items[messageId];
    if (item == null || _inFlight.contains(messageId)) {
      return;
    }
    if (item.delivery != LdMessageDelivery.error) {
      return;
    }
    final reset = [
      for (final attachment in item.attachments)
        attachment.hasPersistError
            ? attachment.copyWith(persistError: null, persistProgress: 0.0)
            : attachment,
    ];
    final needsPersist = reset.any((attachment) => attachment.needsPersist);
    _emit(
      item.copyWith(
        attachments: reset,
        delivery: needsPersist
            ? LdMessageDelivery.persisting
            : LdMessageDelivery.sending,
        deliveryError: null,
      ),
    );
    await _runPipeline(messageId);
  }

  /// Retry a single failed attachment on a bubble, then send if all succeeded.
  Future<void> retryMessageAttachment(
    String messageId,
    String attachmentId,
  ) async {
    final item = _items[messageId];
    if (item == null || _inFlight.contains(messageId)) {
      return;
    }
    if (_attachmentOf(messageId, attachmentId) == null) {
      return;
    }
    _emit(
      item.copyWith(
        attachments: [
          for (final attachment in item.attachments)
            if (attachment.id == attachmentId)
              attachment.copyWith(persistError: null, persistProgress: 0.0)
            else
              attachment,
        ],
        delivery: LdMessageDelivery.persisting,
        deliveryError: null,
      ),
    );
    await _runPipeline(messageId);
  }

  Future<void> _runPipeline(String messageId) async {
    if (!_inFlight.add(messageId)) {
      return;
    }
    try {
      await _persistPending(messageId);
      final latest = _items[messageId];
      if (latest == null) {
        return;
      }
      final persistFailed = latest.attachments.any(
        (attachment) => attachment.hasPersistError || attachment.needsPersist,
      );
      if (persistFailed) {
        _emit(
          latest.copyWith(
            delivery: LdMessageDelivery.error,
            deliveryError: _asException(
              Exception('Failed to persist attachments'),
            ),
          ),
        );
        return;
      }
      await _sendMessage(messageId);
    } finally {
      _inFlight.remove(messageId);
    }
  }

  Future<void> _persistPending(String messageId) async {
    final item = _items[messageId];
    if (item == null) {
      return;
    }
    final pending = [
      for (final attachment in item.attachments)
        if (attachment.needsPersist) attachment.id,
    ];
    if (pending.isEmpty) {
      return;
    }
    await Future.wait([
      for (final attachmentId in pending)
        _persistMessageAttachment(messageId, attachmentId),
    ]);
  }

  Future<void> _persistMessageAttachment(
    String messageId,
    String attachmentId,
  ) {
    final subKey = '$messageId/$attachmentId';
    unawaited(_messagePersistSubs.remove(subKey)?.cancel());

    final attachment = _attachmentOf(messageId, attachmentId);
    if (attachment == null) {
      return Future.value();
    }

    final persister = _persistAttachment;
    if (persister == null || attachment.file == null) {
      _patchAttachment(
        messageId,
        attachmentId,
        (current) => current.copyWith(
          remoteId: current.remoteId ?? current.id,
          persistProgress: null,
          persistError: null,
        ),
      );
      return Future.value();
    }

    _patchAttachment(
      messageId,
      attachmentId,
      (current) => current.copyWith(
        persistProgress: current.persistProgress ?? 0.0,
        persistError: null,
      ),
    );

    final done = Completer<void>();
    _messagePersistSubs[subKey] = persister(attachment).listen(
      (event) {
        switch (event) {
          case LdPersistProgress(:final fraction):
            _patchAttachment(
              messageId,
              attachmentId,
              (current) => current.copyWith(persistProgress: fraction),
            );
          case LdPersistDone(:final remoteId):
            _patchAttachment(
              messageId,
              attachmentId,
              (current) => current.copyWith(
                remoteId: remoteId,
                persistProgress: null,
                persistError: null,
              ),
            );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _patchAttachment(
          messageId,
          attachmentId,
          (current) =>
              current.copyWith(persistError: error, persistProgress: null),
        );
        if (!done.isCompleted) {
          done.complete();
        }
      },
      onDone: () {
        _messagePersistSubs.remove(subKey);
        final latest = _attachmentOf(messageId, attachmentId);
        if (latest != null &&
            latest.remoteId == null &&
            latest.persistError == null) {
          _patchAttachment(
            messageId,
            attachmentId,
            (current) => current.copyWith(
              persistError: StateError(
                'persist stream ended without a remote id',
              ),
              persistProgress: null,
            ),
          );
        }
        if (!done.isCompleted) {
          done.complete();
        }
      },
      cancelOnError: true,
    );
    return done.future;
  }

  Future<void> _persistDraftAttachment(LdComposeAttachment attachment) {
    unawaited(_draftSubs.remove(attachment.id)?.cancel());

    final persister = _persistAttachment;
    if (persister == null || attachment.file == null) {
      _emitDraft(
        attachment.copyWith(
          remoteId: attachment.remoteId ?? attachment.id,
          persistProgress: null,
          persistError: null,
        ),
      );
      return Future.value();
    }

    final seed = attachment.copyWith(
      persistError: null,
      persistProgress: attachment.persistProgress ?? 0.0,
      remoteId: null,
    );
    _emitDraft(seed);

    final done = Completer<void>();
    _draftSubs[attachment.id] = persister(attachment).listen(
      (event) {
        switch (event) {
          case LdPersistProgress(:final fraction):
            final current = _drafts[attachment.id] ?? seed;
            _emitDraft(current.copyWith(persistProgress: fraction));
          case LdPersistDone(:final remoteId):
            final current = _drafts[attachment.id] ?? seed;
            _emitDraft(
              current.copyWith(
                remoteId: remoteId,
                persistProgress: null,
                persistError: null,
              ),
            );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        final current = _drafts[attachment.id] ?? seed;
        _emitDraft(
          current.copyWith(persistError: error, persistProgress: null),
        );
        if (!done.isCompleted) {
          done.complete();
        }
      },
      onDone: () {
        _draftSubs.remove(attachment.id);
        final latest = _drafts[attachment.id];
        if (latest != null &&
            latest.remoteId == null &&
            latest.persistError == null) {
          _emitDraft(
            latest.copyWith(
              persistError: StateError(
                'persist stream ended without a remote id',
              ),
              persistProgress: null,
            ),
          );
        }
        if (!done.isCompleted) {
          done.complete();
        }
      },
      cancelOnError: true,
    );
    return done.future;
  }

  Future<void> _sendMessage(String messageId) async {
    final item = _items[messageId];
    if (item == null) {
      return;
    }
    _emit(
      item.copyWith(delivery: LdMessageDelivery.sending, deliveryError: null),
    );
    final send = _send;
    if (send == null) {
      _emit(_items[messageId]!.copyWith(delivery: LdMessageDelivery.sent));
      return;
    }
    try {
      await send(
        LdOutgoingMessage(
          id: item.id,
          text: item.text,
          attachments: [
            for (final attachment in item.attachments)
              LdPersistedAttachment(
                localId: attachment.id,
                remoteId: attachment.remoteId ?? attachment.id,
              ),
          ],
        ),
      );
      final latest = _items[messageId];
      if (latest == null) {
        return;
      }
      _emit(
        latest.copyWith(delivery: LdMessageDelivery.sent, deliveryError: null),
      );
    } catch (error, stackTrace) {
      final latest = _items[messageId];
      if (latest == null) {
        return;
      }
      _emit(
        latest.copyWith(
          delivery: LdMessageDelivery.error,
          deliveryError: _asException(error, stackTrace),
        ),
      );
    }
  }

  List<LdComposeAttachment> _prepareForSubmit(
    List<LdComposeAttachment> attachments,
  ) {
    return [
      for (final attachment in attachments)
        if (attachment.file == null && attachment.remoteId == null)
          attachment.copyWith(remoteId: attachment.id)
        else if (_persistAttachment == null && attachment.remoteId == null)
          attachment.copyWith(remoteId: attachment.id)
        else
          attachment,
    ];
  }

  void _patchAttachment(
    String messageId,
    String attachmentId,
    LdComposeAttachment Function(LdComposeAttachment current) update,
  ) {
    final item = _items[messageId];
    if (item == null) {
      return;
    }
    _emit(
      item.copyWith(
        attachments: [
          for (final attachment in item.attachments)
            if (attachment.id == attachmentId)
              update(attachment)
            else
              attachment,
        ],
      ),
    );
  }

  LdComposeAttachment? _attachmentOf(String messageId, String attachmentId) {
    final item = _items[messageId];
    if (item == null) {
      return null;
    }
    for (final attachment in item.attachments) {
      if (attachment.id == attachmentId) {
        return attachment;
      }
    }
    return null;
  }

  void _emit(LdUserMessageItem item) {
    if (_disposed) {
      return;
    }
    _items[item.id] = item;
    _onMessage(item);
    notifyListeners();
  }

  void _emitDraft(LdComposeAttachment attachment) {
    if (_disposed) {
      return;
    }
    _drafts[attachment.id] = attachment;
    _onDraftAttachment?.call(attachment);
    notifyListeners();
  }

  LdException _asException(Object error, [StackTrace? stackTrace]) {
    if (error is LdException) {
      return error;
    }
    return LdException(exception: error, stackTrace: stackTrace);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _messagePersistSubs.values) {
      unawaited(sub.cancel());
    }
    _messagePersistSubs.clear();
    for (final sub in _draftSubs.values) {
      unawaited(sub.cancel());
    }
    _draftSubs.clear();
    super.dispose();
  }
}
