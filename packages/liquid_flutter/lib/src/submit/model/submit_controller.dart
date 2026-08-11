import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/submit/model/devtools.dart';

/// Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the
/// controller to configure the submit action.
/// Updated LdSubmitController that uses LdRetryController
class LdSubmitController<T, Arg> with ChangeNotifier {
  final LdSubmitConfig<T, Arg> config;

  late final String id;

  final _stateController = StreamController<LdSubmitState<T>>.broadcast();
  late final LdRetryController _retryController;
  LdRetryController get retryController => _retryController;

  Stream<LdSubmitState<T>> get stateStream => _stateController.stream;

  ValueNotifier<Arg?>? arg;

  bool _isDisabled = false;

  /// Bumped on each new attempt, cancel, and reset so stale completions are ignored.
  int _generation = 0;

  bool get isDisabled => _isDisabled;

  set disabled(bool value) {
    _isDisabled = value;
    notifyListeners();
  }

  LdSubmitController({required this.config, this.arg}) {
    _retryController = LdRetryController(
      onRetry: _nextAttempt,
      config: config.retryConfig ?? const LdRetryConfig(),
    );

    id = Random().nextInt(1000000).toString();

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

    arg?.addListener(_onArgChanged);
  }

  void _onArgChanged() {
    if (config.autoTrigger && canTrigger) {
      _trigger();
    }
  }

  LdSubmitState<T> state = LdSubmitState<T>(type: LdSubmitStateType.idle);

  Future<void> init() async {
    // init() is scheduled from a post frame callback, so the subtree can
    // already be gone by the time it runs.
    if (_disposed) {
      return;
    }
    if (config.autoTrigger) {
      Future.delayed(Duration.zero, _trigger);
    }
    SubmitDevTools.instance.registerController(this);
    _stateController.add(state);
  }

  void _setState(LdSubmitState<T> newState) {
    // An action can outlive the widget that owns the controller, in which case
    // the completion lands here after dispose() and notifyListeners() throws.
    if (_disposed) {
      return;
    }
    state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
    notifyListeners();
  }

  String get _debugLabel => config.debugLabel ?? 'LdSubmitController#$id';

  void _logDebug(String message) {
    if (ldPrintDebugMessages) {
      // ignore: avoid_print
      print('$_debugLabel: $message');
    }
  }

  /// Returns true if [generation] is still the active attempt.
  bool _isCurrentGeneration(int generation) => generation == _generation;

  void _invalidateInFlight({required String reason}) {
    final hadInFlight = _isLoading;
    final previous = _generation;
    _generation++;
    if (hadInFlight) {
      _logDebug(
        '$reason: invalidated in-flight attempt generation=$previous, '
        'now=$_generation',
      );
    }
  }

  bool get canCancel => config.allowCancel && _isLoading;

  Future<void> cancel() async {
    if (!canCancel) {
      return;
    }

    if (config.onCanceled != null) {
      config.onCanceled!();
    }

    _invalidateInFlight(reason: 'cancel');
    _retryController.reset();
    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  Future<void> _trigger() async {
    if (_disposed) {
      return;
    }

    final generation = ++_generation;

    if (config.hapticsEnabled) {
      LdHaptics.vibrate(HapticsType.light);
    }

    _retryController.notifyOperationStarted();

    _setState(
      LdSubmitState<T>(type: LdSubmitStateType.loading),
    );

    T res;
    try {
      if (config.timeout != null) {
        res = await config.action(arg?.value).timeout(config.timeout!);
      } else {
        res = await config.action(arg?.value);
      }

      if (!_isCurrentGeneration(generation)) {
        _logDebug(
          'ignoring stale success for generation=$generation '
          '(current=$_generation)',
        );
        return;
      }

      _retryController.notifyOperationCompleted();

      _setState(
        LdSubmitState<T>(type: LdSubmitStateType.result, result: res),
      );

      if (config.hapticsEnabled) {
        LdHaptics.vibrate(HapticsType.success);
      }
    } catch (e, s) {
      if (!_isCurrentGeneration(generation)) {
        _logDebug(
          'ignoring stale error for generation=$generation '
          '(current=$_generation): $e',
        );
        return;
      }

      late LdException exception;

      // Convert the exception using the exceptionMapper
      if (e is LdException) {
        exception = e;
      } else {
        exception = LdException(
          exception: e,
          stackTrace: s,
          attempt: _retryController.state.attempt,
        );
      }

      if (config.hapticsEnabled) {
        LdHaptics.vibrate(HapticsType.error);
      }

      if (ldPrintDebugMessages) {
        // ignore: avoid_print
        print("Exception occurred in $this");
        // ignore: avoid_print
        print(exception.toString());
        // ignore: avoid_print
        print(exception.stackTrace.toString());
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

  void debugForceError() {
    if (!canTrigger) {
      return;
    }

    _setState(
      LdSubmitState<T>(type: LdSubmitStateType.error, error: LdException(exception: Exception("Debug error"))),
    );
  }

  bool get _isError => state.type == LdSubmitStateType.error;
  bool get _isLoading => state.type == LdSubmitStateType.loading;
  bool get _isResult => state.type == LdSubmitStateType.result;
  bool get _isIdle => state.type == LdSubmitStateType.idle;

  bool get canRetry => _retryController.state.canRetry;

  bool get canTrigger => !_isDisabled && (_isIdle || canRetry || (_isResult && config.allowResubmit));

  Future<void> trigger() async {
    if (!canTrigger) {
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
    _invalidateInFlight(reason: 'reset');
    _retryController.reset();
    _setState(LdSubmitState<T>(type: LdSubmitStateType.idle));
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    // Set first so _setState stops notifying listeners while the widget owning
    // us is being torn down.
    _disposed = true;
    if (canCancel) {
      config.onCanceled?.call();
    }
    // An in-flight action outlives us, so bump the generation to make its
    // completion stale instead of letting it touch _retryController.
    _invalidateInFlight(reason: 'dispose');
    _retryController.dispose();
    arg?.removeListener(_onArgChanged);
    _stateController.close();
    SubmitDevTools.instance.unregisterController(this);
    super.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": state.type.toString(),
      "retryController": _retryController.toMap(),
      "canRetry": canRetry,
      "isDisabled": isDisabled,
      "canTrigger": canTrigger,
      "isError": _isError,
      "isLoading": _isLoading,
      "isResult": _isResult,
      "isIdle": _isIdle,
      "error": state.error?.toString(),
      "result": state.result?.toString(),
    };
  }
}
