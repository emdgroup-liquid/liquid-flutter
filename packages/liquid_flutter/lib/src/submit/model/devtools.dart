import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/model/submit_controller_dto.dart';

class SubmitDevTools {
  static final SubmitDevTools _instance = SubmitDevTools._();
  static SubmitDevTools get instance => _instance;

  final List<StreamSubscription> _subscriptions = [];

  SubmitDevTools._() {
    _registerDevToolsExtension();
  }

  static bool _initialized = false;

  final List<LdSubmitController> _controllers = [];

  void _registerDevToolsExtension() {
    if (_initialized) return;

    _initialized = true;

    registerExtension('ext.liquid_flutter.submit.getControllers', (method, parameters) async {
      return ServiceExtensionResponse.result(
        jsonEncode({
          "controllers": _controllers
              .map(
                (e) => SubmitControllerDto.fromLdSubmitController(e).toMap(),
              )
              .toList(),
        }),
      );
    });

    registerExtension('ext.liquid_flutter.submit.triggerController', (method, parameters) async {
      try {
        final controllerId = parameters['controllerId'];

        final controller = _controllers.firstWhere(
          (controller) => controller.id == controllerId,
          orElse: () => throw Exception('Controller with ID $controllerId not found'),
        );

        await controller.trigger();

        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": true,
            "controllerId": controllerId,
          }),
        );
      } catch (e) {
        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": false,
            "error": e.toString(),
          }),
        );
      }
    });

    registerExtension('ext.liquid_flutter.submit.resetController', (method, parameters) async {
      try {
        final controllerId = parameters['controllerId'];

        final controller = _controllers.firstWhere(
          (controller) => controller.id == controllerId,
          orElse: () => throw Exception('Controller with ID $controllerId not found'),
        );

        controller.reset();

        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": true,
            "controllerId": controllerId,
          }),
        );
      } catch (e) {
        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": false,
            "error": e.toString(),
          }),
        );
      }
    });

    registerExtension('ext.liquid_flutter.submit.forceError', (method, parameters) async {
      try {
        final controllerId = parameters['controllerId'];

        final controller = _controllers.firstWhere(
          (controller) => controller.id == controllerId,
          orElse: () => throw Exception('Controller with ID $controllerId not found'),
        );

        controller.debugForceError();

        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": true,
            "controllerId": controllerId,
          }),
        );
      } catch (e) {
        return ServiceExtensionResponse.result(
          jsonEncode({
            "success": false,
            "error": e.toString(),
          }),
        );
      }
    });
  }

  void registerController(LdSubmitController controller) {
    _controllers.add(controller);

    postEvent('ext.liquid_flutter.submit.controllers', {
      "controllers": _controllers.map((e) => e.toMap()).toList(),
    });

    _subscriptions.add(controller.stateStream.listen((state) {
      postEvent('ext.liquid_flutter.submit.state', {
        "controller": SubmitControllerDto.fromLdSubmitController(controller).toMap(),
      });
    }));
  }

  void unregisterController(LdSubmitController controller) {
    _controllers.remove(controller);

    postEvent('ext.liquid_flutter.submit.removedController', {
      "controller": controller.id,
    });
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
