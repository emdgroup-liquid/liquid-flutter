import 'package:liquid_flutter/liquid_flutter.dart';

class LdSubmitState<T> {
  LdSubmitState({
    required LdSubmitStateType type,
    LdException? error,
    T? result,
  })  : _type = type,
        _error = error,
        _result = result;

  final LdSubmitStateType _type;
  final LdException? _error;
  final T? _result;

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
        "result: $_result)";
  }

  LdSubmitState<T> copyWith({
    LdSubmitStateType? type,
    LdException? error,
    T? result,
  }) {
    return LdSubmitState<T>(
      type: type ?? _type,
      error: error ?? _error,
      result: result ?? _result,
    );
  }
}
