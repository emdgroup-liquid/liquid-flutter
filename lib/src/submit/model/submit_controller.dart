import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the
/// controller to configure the submit action.
/// Updated LdSubmitController that uses LdRetryController
class LdSubmitController<T> {
  final LdSubmitConfig<T> config;
  final LdExceptionMapper exceptionMapper;
  final _stateController = StreamController<LdSubmitState<T>>.broadcast();
  late final LdRetryController _retryController;
  LdRetryController get retryController => _retryController;

  Stream<LdSubmitState<T>> get stateStream => _stateController.stream;

  LdSubmitController({
    required this.exceptionMapper,
    required this.config,
  }) {
    _retryController = LdRetryController(
      onRetry: _nextAttempt,
      config: config.retryConfig ?? const LdRetryConfig(),
    );

    // Listen to retry state changes to update submit state
    _retryController.stateStream.listen((retryState) {
      if (state.type == LdSubmitStateType.error) {
        _stateController.add(
          LdSubmitState<T>(
            type: LdSubmitStateType.error,
            error: state.error?.copyWith(
              attempt: retryState.attempt,
            ),
          ),
        );
      }
    });
  }

  LdSubmitState<T> state = LdSubmitState<T>(type: LdSubmitStateType.idle);

  Future<void> init() async {
    if (config.autoTrigger) {
      Future.delayed(Duration.zero, _trigger);
    }
    _stateController.add(state);
  }

  void _setState(LdSubmitState<T> newState) {
    state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  bool get canCancel => config.allowCancel == true && _isLoading;

  Future<void> cancel() async {
    if (!canCancel) {
      if (ldPrintDebugMessages) {
        debugPrint("Cannot cancel, allowCancel is false");
      }
      return;
    }

    if (config.onCanceled != null) {
      config.onCanceled!();
    }

    if (ldPrintDebugMessages) {
      debugPrint("Cancelling submit controller");
    }

    _retryController.reset();
    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  Future<void> _trigger() async {
    if (_disposed) {
      return;
    }

    _retryController.notifyOperationStarted();

    _setState(
      LdSubmitState<T>(type: LdSubmitStateType.loading),
    );

    T res;
    try {
      if (config.timeout != null) {
        res = await config.action().timeout(config.timeout!);
      } else {
        res = await config.action();
      }

      if (!_isLoading) return;

      _retryController.notifyOperationCompleted();

      _setState(
        LdSubmitState<T>(type: LdSubmitStateType.result, result: res),
      );
    } catch (e, s) {
      // Somehow the state is not loading anymore...
      if (!_isLoading) return;

      // Convert the exception using the exceptionMapper
      final exception = exceptionMapper.handle(e, stackTrace: s);

      if (ldPrintDebugMessages) {
        debugPrint(
          "An error occurred in LdSubmitController<${T.toString()}>: $e \n $s",
        );
      }

      _setState(
        LdSubmitState(
          type: LdSubmitStateType.error,
          error: exception.copyWith(
            attempt: _retryController.state.attempt,
          ),
        ),
      );

      // Handle the retry logic through the retry controller
      _retryController.handleError(canRetry: exception.canRetry);
    }
  }

  bool get _isError => state.type == LdSubmitStateType.error;
  bool get _isLoading => state.type == LdSubmitStateType.loading;
  bool get _isResult => state.type == LdSubmitStateType.result;
  bool get _isIdle => state.type == LdSubmitStateType.idle;

  bool get canRetry => _retryController.state.canRetry;

  bool get canRetrigger => _isError && state.error?.canRetry == true;

  bool get canTrigger =>
      _isIdle || canRetry || (_isResult && config.allowResubmit == true);

  Future<void> trigger() async {
    if (!canTrigger) {
      if (ldPrintDebugMessages) {
        debugPrint("Cannot trigger, state is ${state.type}");
      }
      return;
    }
    await _trigger();
  }

  void _nextAttempt() {
    if (_isError) {
      _trigger();
    }
  }

  void reset() {
    if (ldPrintDebugMessages) {
      debugPrint("Resetting submit controller");
    }
    _retryController.reset();
    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  void dispose() {
    if (_isLoading) {
      cancel();
    }
    _retryController.dispose();
    _disposed = true;
    _stateController.close();
  }
}
