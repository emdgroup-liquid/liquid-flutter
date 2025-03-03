import 'package:liquid_flutter/liquid_flutter.dart';

class LdSubmitState<T> {
  LdSubmitState({
    required LdSubmitStateType type,
    LdException? error,
    int attempt = 0,
    Duration? remainingRetryTime,
    T? result,
  })  : _type = type,
        _error = error,
        _attempt = attempt,
        _remainingRetryTime = remainingRetryTime,
        _result = result;

  final LdSubmitStateType _type;
  final LdException? _error;
  final T? _result;

  final int _attempt;

  final Duration? _remainingRetryTime;

  /// The number of attempts made. Will reset to 0 if the submit action is
  /// successful.
  int get attempt => _attempt;

  /// The remaining duration to retry. Will be null if no next retry is planned.
  Duration? get remainingRetryTime => _remainingRetryTime;

  /// The type of the submit state.
  LdSubmitStateType get type => _type;

  /// The error that occurred during the submit action.
  LdException? get error => _error;

  /// The result of the submit action. Only is not null if [type] is
  /// [LdSubmitStateType.success].
  T? get result => _result;

  @override
  String toString() {
    return "LdSubmitState( \n"
        "type: $_type, \n"
        "error: $_error, \n"
        "result: $_result, \n"
        "attempt: $_attempt)";
  }

  LdSubmitState<T> copyWith({
    LdSubmitStateType? type,
    LdException? error,
    int? attempt,
    Duration? remainingRetryTime,
    T? result,
  }) {
    return LdSubmitState<T>(
      type: type ?? _type,
      error: error ?? _error,
      attempt: attempt ?? _attempt,
      remainingRetryTime: remainingRetryTime ?? _remainingRetryTime,
      result: result ?? _result,
    );
  }
}
