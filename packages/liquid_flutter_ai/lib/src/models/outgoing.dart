import 'package:flutter/foundation.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';

/// When the host should persist file attachments.
enum LdAttachmentPersistWhen {
  /// Persist after send. Compose stays optimistic; the bubble owns progress.
  submit,

  /// Persist as soon as files are picked. Send waits for remote ids.
  pick,
}

/// Delivery state of an outgoing [LdUserMessageItem].
enum LdMessageDelivery { local, persisting, sending, sent, error }

/// Progress or completion event from [LdAttachmentPersister].
@immutable
sealed class LdPersistEvent {
  const LdPersistEvent();

  const factory LdPersistEvent.progress(double fraction) = LdPersistProgress;

  const factory LdPersistEvent.done(String remoteId) = LdPersistDone;
}

/// Upload/persist progress in `[0, 1]`.
final class LdPersistProgress extends LdPersistEvent {
  final double fraction;

  const LdPersistProgress(this.fraction);
}

/// Persist finished with a backend id.
final class LdPersistDone extends LdPersistEvent {
  final String remoteId;

  const LdPersistDone(this.remoteId);
}

/// Host-provided persist implementation. Yield progress, then a final id.
typedef LdAttachmentPersister =
    Stream<LdPersistEvent> Function(LdComposeAttachment attachment);

/// A draft attachment after persist, ready for [LdSendMessage].
@immutable
class LdPersistedAttachment {
  final String localId;
  final String remoteId;

  const LdPersistedAttachment({required this.localId, required this.remoteId});
}

/// Payload handed to the host [LdSendMessage] callback.
@immutable
class LdOutgoingMessage {
  final String id;
  final String text;
  final List<LdPersistedAttachment> attachments;

  const LdOutgoingMessage({
    required this.id,
    required this.text,
    this.attachments = const [],
  });
}

/// Host-provided send. May take time or throw; the package maps failures.
typedef LdSendMessage = Future<void> Function(LdOutgoingMessage message);
