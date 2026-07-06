import 'package:liquid_flutter/liquid_flutter.dart';

class SubmitControllerDto {
  final String id;

  final SubmitControllerStateDto state;

  final String type;
  final bool canRetry;
  final bool isDisabled;
  final bool canTrigger;
  final bool autoTrigger;
  final bool allowCancel;
  final bool allowResubmit;
  final String? debugLabel;
  final bool withHaptics;

  SubmitControllerDto({
    required this.id,
    required this.state,
    required this.type,
    required this.canRetry,
    required this.isDisabled,
    required this.allowCancel,
    required this.allowResubmit,
    required this.canTrigger,
    required this.autoTrigger,
    required this.withHaptics,
    required this.debugLabel,
  });

  Map<String, dynamic> toMap() {
    return {
      "allowCancel": allowCancel,
      "allowResubmit": allowResubmit,
      "autoTrigger": autoTrigger,
      "isDisabled": isDisabled,
      "canRetry": canRetry,
      "canTrigger": canTrigger,
      "id": id,
      "state": state.toMap(),
      "type": type,
      "withHaptics": withHaptics,
      "debugLabel": debugLabel,
    };
  }

  static SubmitControllerDto fromMap(Map<String, dynamic> map) {
    return SubmitControllerDto(
      allowCancel: map["allowCancel"],
      allowResubmit: map["allowResubmit"],
      autoTrigger: map["autoTrigger"],
      isDisabled: map["isDisabled"],
      canRetry: map["canRetry"],
      canTrigger: map["canTrigger"],
      id: map["id"],
      state: SubmitControllerStateDto.fromMap(map["state"]),
      type: map["type"],
      withHaptics: map["withHaptics"],
      debugLabel: map["debugLabel"],
    );
  }

  static SubmitControllerDto fromLdSubmitController(LdSubmitController<dynamic, dynamic> controller) {
    return SubmitControllerDto(
      id: controller.id,
      state: SubmitControllerStateDto.fromLdSubmitState(controller.state),
      type: controller.runtimeType.toString(),
      canRetry: controller.canRetry,
      isDisabled: controller.isDisabled,
      canTrigger: controller.canTrigger,
      autoTrigger: controller.config.autoTrigger,
      withHaptics: controller.config.hapticsEnabled,
      allowCancel: controller.config.allowCancel,
      allowResubmit: controller.config.allowResubmit,
      debugLabel: controller.config.debugLabel,
    );
  }
}

class SubmitControllerStateDto {
  final LdSubmitStateType type;
  final String? error;
  final String? result;

  SubmitControllerStateDto({
    required this.type,
    this.error,
    this.result,
  });

  Map<String, dynamic> toMap() {
    return {
      "type": type.toString(),
      "error": error,
      "result": result,
    };
  }

  static SubmitControllerStateDto fromMap(Map<String, dynamic> map) {
    return SubmitControllerStateDto(
      type: LdSubmitStateType.values.firstWhere((e) => e.toString() == map["type"]),
      error: map["error"],
      result: map["result"],
    );
  }

  static SubmitControllerStateDto fromLdSubmitState(LdSubmitState<dynamic> state) {
    return SubmitControllerStateDto(
      type: state.type,
      error: state.error?.toString(),
      result: state.result?.toString(),
    );
  }
}

class RetryControllerDto {
  final int attempt;
  final Duration? remainingRetryTime;
  final bool isRetrying;
  final bool canRetry;
  final Duration? totalRetryDelay;

  RetryControllerDto({
    required this.attempt,
    required this.remainingRetryTime,
    required this.isRetrying,
    required this.canRetry,
    required this.totalRetryDelay,
  });

  Map<String, dynamic> toMap() {
    return {
      "attempt": attempt,
      "remainingRetryTime": remainingRetryTime?.toString(),
      "isRetrying": isRetrying,
      "canRetry": canRetry,
      "totalRetryDelay": totalRetryDelay,
    };
  }

  static RetryControllerDto fromMap(Map<String, dynamic> map) {
    return RetryControllerDto(
      attempt: map["attempt"],
      remainingRetryTime: map["remainingRetryTime"],
      isRetrying: map["isRetrying"],
      canRetry: map["canRetry"],
      totalRetryDelay: map["totalRetryDelay"],
    );
  }
}

class SubmitConfigDto {
  final bool autoTrigger;
  final bool allowCancel;
  final bool allowResubmit;
  final bool hapticsEnabled;
  final String? timeout;
  final LdSubmitCallback<dynamic, dynamic>? action;

  SubmitConfigDto({
    required this.autoTrigger,
    required this.allowCancel,
    required this.allowResubmit,
    required this.hapticsEnabled,
    required this.timeout,
    required this.action,
  });

  Map<String, dynamic> toMap() {
    return {
      "autoTrigger": autoTrigger,
      "allowCancel": allowCancel,
      "allowResubmit": allowResubmit,
      "hapticsEnabled": hapticsEnabled,
      "timeout": timeout,
      "action": action,
    };
  }

  static SubmitConfigDto fromMap(Map<String, dynamic> map) {
    return SubmitConfigDto(
      autoTrigger: map["autoTrigger"],
      allowCancel: map["allowCancel"],
      allowResubmit: map["allowResubmit"],
      hapticsEnabled: map["hapticsEnabled"],
      timeout: map["timeout"],
      action: map["action"],
    );
  }

  static SubmitConfigDto fromLdSubmitConfig(LdSubmitConfig<dynamic, dynamic> config) {
    return SubmitConfigDto(
      autoTrigger: config.autoTrigger,
      allowCancel: config.allowCancel,
      allowResubmit: config.allowResubmit,
      hapticsEnabled: config.hapticsEnabled,
      timeout: config.timeout?.toString(),
      action: config.action,
    );
  }
}
