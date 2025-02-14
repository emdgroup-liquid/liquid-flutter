import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the
/// controller to configure the submit action.
class LdSubmitController<T> {
  final LdSubmitConfig<T> config;

  final LdExceptionMapper exceptionMapper;

  final StreamController<LdSubmitState<T>> _stateController =
      StreamController<LdSubmitState<T>>.broadcast();

  Stream<LdSubmitState<T>> get stateStream => _stateController.stream;

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
  }

  bool get canCancel =>
      config.allowCancel == true && state.type == LdSubmitStateType.loading;

  Future<void> cancel() async {
    if (config.allowCancel == false) {
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

  Future<void> _trigger() async {
    _setState(
      LdSubmitState<T>(
        type: LdSubmitStateType.loading,
        retryState: state.retryState,
      ),
    );

    T res;
    try {
      if (config.timeout != null) {
        res = await config.action().timeout(config.timeout!);
      } else {
        res = await config.action();
      }
      if (state.type != LdSubmitStateType.loading) return;

      _setState(LdSubmitState<T>(type: LdSubmitStateType.result, result: res));
    } catch (e, s) {
      final exception = exceptionMapper.handle(e, stackTrace: s);

      if (ldPrintDebugMessages) {
        debugPrint("An error occured in LdSubmitController: $e \n $s");
      }

      if (state.type != LdSubmitStateType.loading) return;

      // Retry logic if automatic retries are configured
      if (config.automaticRetry != null) {
        final retryCount = (state.retryState?.retryCount ?? 0) + 1;
        final retryDelay = config.automaticRetry!.initialAutomaticRetryDelay *
            (1 << (retryCount - 1)); // Exponential backoff delay
        final shouldRetry =
            retryCount <= config.automaticRetry!.maxAutomaticRetryAttempts;

        if (shouldRetry) {
          if (ldPrintDebugMessages) {
            debugPrint("Retrying in ${retryDelay ~/ 1000} seconds");
          }

          // We want to update the state each second (in order to update the UI)
          for (var i = 0; i < retryDelay ~/ 1000; i++) {
            final currentRetryState = LdSubmitRetryState(
              retryCount: retryCount,
              delay: retryDelay - (i * 1000),
            );

            _setState(
              LdSubmitState<T>(
                type: LdSubmitStateType.error,
                retryState: currentRetryState,
                error: exception,
              ),
            );

            await Future.delayed(const Duration(seconds: 1));

            if (state.type != LdSubmitStateType.error) {
              return; // User canceled or state changed for some reason
            }
          }

          // Handle the remaining milliseconds after the loop
          await Future.delayed(Duration(milliseconds: retryDelay % 1000));

          // Trigger the action again
          await _trigger();
          return;
        }
      }

      _setState(
        LdSubmitState(
          type: LdSubmitStateType.error,
          error: exception,
          retryState: state.retryState?.copyWith(
            delay: 0,
          ),
        ),
      );
    }
  }

  bool get canRetry =>
      state.type == LdSubmitStateType.error && state.error?.canRetry == true;

  bool get canRetrigger =>
      state.type == LdSubmitStateType.error && state.error?.canRetry == true;

  bool get canTrigger =>
      state.type == LdSubmitStateType.idle ||
      canRetry ||
      (state.type == LdSubmitStateType.result && config.allowResubmit == true);

  Future<void> trigger() async {
    if (!canTrigger) {
      if (ldPrintDebugMessages) {
        debugPrint("Cannot trigger, state is ${state.type}");
      }
      return;
    }
    await _trigger();
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
    if (state.type == LdSubmitStateType.loading) {
      cancel();
    }
    _disposed = true;
    _stateController.close();
  }
}
