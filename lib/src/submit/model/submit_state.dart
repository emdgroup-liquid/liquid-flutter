import 'package:liquid_flutter/liquid_flutter.dart';

class LdSubmitState<T> {
  LdSubmitState({
    required LdSubmitStateType type,
    LdException? error,
    T? result,
    LdSubmitRetryState? retryState,
  })  : _type = type,
        _error = error,
        _result = result,
        _retryState = retryState;

  final LdSubmitStateType _type;
  final LdException? _error;
  final T? _result;
  final LdSubmitRetryState? _retryState;

  LdSubmitStateType get type => _type;
  LdException? get error => _error;
  T? get result => _result;

  /// Typically, when a retry attempt is in progress, [type] will be [LdSubmitStateType.loading].
  /// While we are waiting for a new retry, [type] will be [LdSubmitStateType.error].
  LdSubmitRetryState? get retryState => _retryState;
}

/// The state of the retry mechanism.
class LdSubmitRetryState {
  /// The current retry count
  final int retryCount;

  /// The left time to retry in milliseconds.
  /// It will be decremented each second by the [LdSubmitController].
  final int delay;

  LdSubmitRetryState({
    required this.retryCount,
    required this.delay,
  });

  copyWith({
    int? retryCount,
    int? delay,
  }) {
    return LdSubmitRetryState(
      retryCount: retryCount ?? this.retryCount,
      delay: delay ?? this.delay,
    );
  }
}
