import 'dart:async';
import 'dart:math';

import 'package:liquid_flutter/liquid_flutter.dart';

/// State object for retry operations
class LdRetryState {
  /// Current attempt number (1-based)
  final int attempt;

  /// Remaining time until next retry
  final Duration? remainingRetryTime;

  /// Whether retry is in progress
  final bool isRetrying;

  /// Whether retry is enabled
  final bool canRetry;

  /// The total delay for the current retry
  final Duration? totalRetryDelay;

  const LdRetryState({
    this.attempt = 0,
    this.remainingRetryTime,
    this.isRetrying = false,
    this.canRetry = false,
    this.totalRetryDelay,
  });

  /// Creates a copy of this state with the given fields replaced
  LdRetryState copyWith({
    int? attempt,
    Duration? remainingRetryTime,
    bool? isRetrying,
    bool? canRetry,
    Duration? totalRetryDelay,
  }) {
    return LdRetryState(
      attempt: attempt ?? this.attempt,
      remainingRetryTime: remainingRetryTime ?? this.remainingRetryTime,
      isRetrying: isRetrying ?? this.isRetrying,
      canRetry: canRetry ?? this.canRetry,
      totalRetryDelay: totalRetryDelay ?? this.totalRetryDelay,
    );
  }
}

/// Controller for managing retry operations
class LdRetryController {
  final LdRetryConfig config;
  final _stateController = StreamController<LdRetryState>.broadcast();
  Timer? _retryTimer;
  LdRetryState _state = const LdRetryState();
  final int _jitter;

  /// Function to be called when a retry should be executed
  final void Function() onRetry;

  /// Whether an error happened that can be retried
  bool _canRetryError = false;

  /// Stream of retry states
  Stream<LdRetryState> get stateStream => _stateController.stream;

  /// Current retry state
  LdRetryState get state => _state;

  /// Whether the timer is currently active
  bool get showRetryIndicator => _retryTimer?.isActive == true;

  /// Whether the retry button should be shown
  bool get showRetryButton => !config.disableRetryButton && _state.canRetry;

  LdRetryController({
    required this.onRetry,
    required this.config,
  }) : _jitter = Random().nextInt(1500);

  /// Sets the internal state and notifies listeners
  void _setState(LdRetryState newState) {
    _state = newState;

    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }

    if (newState.remainingRetryTime != null &&
        (_retryTimer == null || !_retryTimer!.isActive)) {
      _setupRetryTimer();
    } else if (newState.remainingRetryTime == null) {
      _retryTimer?.cancel();
      _retryTimer = null;
    }
  }

  /// Sets up the retry timer
  void _setupRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _retryTimerTick();
    });
  }

  /// Calculates the retry delay based on the attempt number
  Duration _getRetryDelay(int attempt) {
    final baseMs = config.baseDelay.inMilliseconds;
    final jitterMs = config.useJitter ? _jitter : 0;
    return Duration(milliseconds: pow(2, attempt).toInt() * baseMs + jitterMs);
  }

  /// Handles the timer tick for updating remaining time
  void _retryTimerTick() {
    if (_state.remainingRetryTime != null) {
      final remaining =
          _state.remainingRetryTime! - const Duration(milliseconds: 100);

      _setState(
        _state.copyWith(
          remainingRetryTime: remaining > Duration.zero ? remaining : null,
        ),
      );

      if (remaining <= Duration.zero) {
        _executeRetry();
      }
    }
  }

  /// Executes the retry operation
  void _executeRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (_canRetryError && _state.attempt < config.maxAttempts) {
      _setState(
        _state.copyWith(
          isRetrying: true,
        ),
      );
      onRetry();
    }
  }

  /// Called when an error occurs that might be retried
  void handleError({required bool canRetry}) {
    if (showRetryIndicator) {
      return; // we are already counting down, we cannot handle another error
    }
    _canRetryError = canRetry;
    final attempt = _state.attempt + 1;
    final exhaustedRetries = attempt >= config.maxAttempts;

    if (config.enableAutomaticRetries && canRetry && !exhaustedRetries) {
      final retryDelay =
          _getRetryDelay(_state.attempt); // use old attempt count for delay

      _setState(
        LdRetryState(
          attempt: attempt,
          remainingRetryTime: retryDelay,
          isRetrying: false,
          canRetry: canRetry && !exhaustedRetries,
          totalRetryDelay: retryDelay,
        ),
      );
    } else {
      _setState(
        LdRetryState(
          attempt: attempt,
          isRetrying: false,
          canRetry: canRetry && !exhaustedRetries,
        ),
      );
    }
  }

  /// Manually triggers a retry
  void retry() {
    if (_state.canRetry) {
      onRetry();
    }
  }

  /// Resets the retry state
  void reset() {
    _retryTimer?.cancel();
    _setState(const LdRetryState());
    _canRetryError = false;
  }

  /// Notifies the controller that an operation has started
  void notifyOperationStarted() {
    _setState(
      LdRetryState(
        attempt: _state.attempt,
        isRetrying: true,
        canRetry: true,
      ),
    );
  }

  /// Notifies the controller that an operation has completed successfully
  void notifyOperationCompleted() {
    reset();
  }

  /// Disposes of the controller
  void dispose() {
    _retryTimer?.cancel();
    _stateController.close();
  }
}
