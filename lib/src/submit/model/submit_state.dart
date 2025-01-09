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

  LdSubmitStateType get type => _type;
  LdException? get error => _error;
  T? get result => _result;
}
