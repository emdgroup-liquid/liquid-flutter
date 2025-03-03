import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the
/// controller to configure the submit action.
class LdSubmitController<T> {
  final LdSubmitConfig<T> config;
  final LdExceptionMapper exceptionMapper;
  final _stateController = StreamController<LdSubmitState<T>>.broadcast();

  Stream<LdSubmitState<T>> get stateStream => _stateController.stream;

  Timer? _retryTimer;

  final jitter = Random().nextInt(1500);

  LdSubmitController({
    required this.exceptionMapper,
    required this.config,
  });

  LdSubmitState<T> state = LdSubmitState<T>(type: LdSubmitStateType.idle);

  Future<void> init() async {
    if (config.autoTrigger) {
      Future.delayed(Duration.zero, _trigger);
    }
    _stateController.add(state);
  }

  void _setState(LdSubmitState<T> newState) {
    state = newState;

    if (_stateController.isClosed) return;
    _stateController.add(newState);

    if (newState.remainingRetryTime != null &&
        (_retryTimer == null || _retryTimer?.isActive == false)) {
      _setupRetryTimer();
    } else if (newState.remainingRetryTime == null) {
      _retryTimer?.cancel();
      _retryTimer = null;
    }
  }

  void _setupRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _retryTimerTick();
    });
  }

  bool get showRetryIndicator => _retryTimer?.isActive == true;

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

    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  int get _maxRetryAttempts => config.retryConfig?.maxAttempts ?? 1;

  Duration _getRetryDelay(int attempt) {
    return Duration(milliseconds: pow(2, attempt).toInt() * 1000 + jitter);
  }

  Duration get totalRetryTime => _getRetryDelay(state.attempt);

  Future<void> _trigger() async {
    if (disposed) {
      return;
    }

    _setState(
      LdSubmitState<T>(
        type: LdSubmitStateType.loading,
        attempt: state.attempt + 1,
      ),
    );

    T res;
    try {
      if (config.timeout != null) {
        res = await config.action().timeout(config.timeout!);
      } else {
        res = await config.action();
      }
      if (!_isLoading) return;

      _setState(
        LdSubmitState<T>(type: LdSubmitStateType.result, result: res),
      );
    } catch (e, s) {
      // Somehow the state is not loading anymore...
      if (!_isLoading) return;

      // Convert the exception using the exceptionMapper
      final exception = exceptionMapper.handle(e, stackTrace: s);

      if (ldPrintDebugMessages) {
        debugPrint("An error occured in LdSubmitController: $e \n $s");
      }

      _setState(
        LdSubmitState(
          type: LdSubmitStateType.error,
          attempt: state.attempt,
          error: exception.copyWith(
            attempt: state.attempt,
          ),
        ),
      );

      // Handle the retry logic
      final retryConfig = config.retryConfig;

      final lastAttempt = state.attempt;
      final exhaustedRetries = lastAttempt >= _maxRetryAttempts;

      // Retry logic if automatic retries are configured, the exception can be
      // retried and the retries have not been exhausted yet.
      if (retryConfig != null && exception.canRetry && !exhaustedRetries) {
        var retryDelay = _getRetryDelay(lastAttempt);

        _setState(
          LdSubmitState<T>(
            type: LdSubmitStateType.error,
            attempt: lastAttempt,
            remainingRetryTime: retryDelay,
            error: exception.copyWith(
              attempt: lastAttempt,
            ),
          ),
        );
      }
    }
  }

  bool get _isError => state.type == LdSubmitStateType.error;
  bool get _isLoading => state.type == LdSubmitStateType.loading;
  bool get _isResult => state.type == LdSubmitStateType.result;
  bool get _isIdle => state.type == LdSubmitStateType.idle;

  bool get canRetry {
    if (!_isError) return false;
    if (state.error?.canRetry == false) return false;
    if (config.retryConfig != null) {
      if (config.retryConfig!.disableRetryButton == true) return false;
      if (state.attempt >= _maxRetryAttempts) return false;
    }

    return true;
  }

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

  void _retryTimerTick() {
    if (_isError && state.remainingRetryTime != null) {
      final remaining = state.remainingRetryTime! -
          const Duration(
            milliseconds: 100,
          );

      _setState(
        state.copyWith(
          remainingRetryTime: remaining,
        ),
      );

      if (remaining <= Duration.zero) {
        _nextAttempt();
      }
    }
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
    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  void dispose() {
    if (_isLoading) {
      cancel();
    }
    _retryTimer?.cancel();

    _disposed = true;
    _stateController.close();
  }
}
