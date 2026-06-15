import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Static submit options for [LdMonkeySubmitAction] (no action callback).
class LdMonkeySubmitConfig extends Equatable {
  final Key? key;
  final String? loadingText;
  final String? submitText;
  final bool allowResubmit;
  final bool? withHaptics;
  final bool autoTrigger;
  final Duration? timeout;
  final bool allowCancel;
  final VoidCallback? onCanceled;
  final LdRetryConfig? retryConfig;
  final String? debugLabel;

  const LdMonkeySubmitConfig({
    this.key,
    this.loadingText,
    this.submitText,
    this.allowResubmit = true,
    this.withHaptics,
    this.autoTrigger = false,
    this.timeout,
    this.allowCancel = false,
    this.onCanceled,
    this.retryConfig,
    this.debugLabel,
  });

  LdSubmitConfig<R, LdMonkeyActionContext<T, I>> toSubmitConfig<T extends Identifiable<I>, I, R>({
    required Future<R> Function(LdMonkeyActionContext<T, I> ctx) onSubmit,
  }) {
    return LdSubmitConfig<R, LdMonkeyActionContext<T, I>>(
      key: key,
      loadingText: loadingText,
      submitText: submitText,
      allowResubmit: allowResubmit,
      withHaptics: withHaptics,
      autoTrigger: autoTrigger,
      timeout: timeout,
      allowCancel: allowCancel,
      onCanceled: onCanceled,
      retryConfig: retryConfig,
      debugLabel: debugLabel,
      action: (ctx) => onSubmit(ctx!),
    );
  }

  @override
  List<Object?> get props => [
        key,
        loadingText,
        submitText,
        allowResubmit,
        withHaptics,
        autoTrigger,
        timeout,
        allowCancel,
        onCanceled,
        retryConfig,
        debugLabel,
      ];
}
