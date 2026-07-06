import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/liquid_flutter_devtools.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  runApp(
    DevToolsExtension(
      child: LdThemeProvider(
        child: LdThemedAppBuilder(
          appBuilder: (context, theme) {
            return MaterialApp(
              theme: theme,
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: LdScaffold(
                body: LdAppBar(title: Text('Liquid Flutter Extension'), child: const LiquidFlutterExtension()),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class LiquidFlutterExtension extends StatefulWidget {
  const LiquidFlutterExtension({super.key});

  @override
  State<LiquidFlutterExtension> createState() => _LiquidFlutterExtensionState();
}

class _LiquidFlutterExtensionState extends State<LiquidFlutterExtension> {
  String message = 'unknown event';

  Map<String, SubmitControllerDto> controllers = {};

  Future<void> _triggerController(String controllerId) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.liquid_flutter.submit.triggerController',
      args: {'controllerId': controllerId},
    );
  }

  Future<void> _forceErrorController(String controllerId) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.liquid_flutter.submit.forceError',
      args: {'controllerId': controllerId},
    );
  }

  Future<void> _resetController(String controllerId) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.liquid_flutter.submit.resetController',
      args: {'controllerId': controllerId},
    );
  }

  Future<void> _getControllers() async {
    final response = await serviceManager.callServiceExtensionOnMainIsolate('ext.liquid_flutter.submit.getControllers');

    final controllersList = response.json!["controllers"] as List<dynamic>;

    final controllersParsed = controllersList.map((e) => SubmitControllerDto.fromMap(e)).toList();

    setState(() {
      controllers = Map.fromEntries(controllersParsed.map((e) => MapEntry<String, SubmitControllerDto>(e.id, e)));
    });
  }

  @override
  initState() {
    super.initState();
    _getControllers();

    _listenToControllers();
  }

  void _listenToControllers() async {
    await Future.delayed(Duration(seconds: 2));

    final vmService = await serviceManager.onServiceAvailable;

    serviceManager.isolateManager.mainIsolate.addListener(() {
      _getControllers();
    });

    vmService.onExtensionEvent.listen((event) {
      if (event.extensionKind == "ext.liquid_flutter.submit.state") {
        final controller = event.extensionData?.data["controller"] as Map<String, dynamic>;

        setState(() {
          controllers[controller["id"]] = SubmitControllerDto.fromMap(controller);
        });
      }

      if (event.extensionKind == "ext.liquid_flutter.submit.removedController") {
        final controller = event.extensionData?.data["controller"];

        setState(() {
          controllers.remove(controller);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: LdTheme.of(context).pad(),
      children: [
        ...controllers.values.map(
          (item) => LdCard(
            header: LdText.l("${item.id} ${item.debugLabel != null ? " - ${item.debugLabel}" : ""} - ${item.type}"),
            child: LdAutoSpace(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          LdAvatar(
                            child: LdIndicator(
                              type: switch (item.state.type) {
                                LdSubmitStateType.idle => LdIndicatorType.pending,
                                LdSubmitStateType.loading => LdIndicatorType.loading,
                                LdSubmitStateType.error => LdIndicatorType.error,
                                LdSubmitStateType.result => LdIndicatorType.success,
                              },
                            ),
                          ),
                          ldSpacerM,
                          LdText.l(switch (item.state.type) {
                            LdSubmitStateType.idle => "Idle",
                            LdSubmitStateType.loading => "Loading",
                            LdSubmitStateType.error => "Error",
                            LdSubmitStateType.result => "Success",
                          }),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (item.isDisabled) Tooltip(message: "Disabled", child: Icon(LucideIcons.pause, size: 14)),
                        if (item.canTrigger) Tooltip(message: "Can trigger", child: Icon(LucideIcons.play, size: 14)),
                        if (item.allowCancel) Tooltip(message: "Can cancel", child: Icon(LucideIcons.x, size: 14)),
                        if (item.allowResubmit)
                          Tooltip(message: "Can resubmit", child: Icon(LucideIcons.repeat, size: 14)),
                        if (item.withHaptics)
                          Tooltip(message: "With haptics", child: Icon(LucideIcons.volume, size: 14)),
                        if (item.autoTrigger) Tooltip(message: "Auto trigger", child: Icon(LucideIcons.car, size: 14)),
                      ],
                    ),
                  ],
                ),

                if (item.state.error != null) ...[LdText.l("Error:"), LdText.ps(item.state.error!)],
                if (item.state.result != null) ...[LdText.l("Result:"), LdText.ps(item.state.result!)],

                //Text(item["state"]),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    LdButton(size: LdSize.m, onPressed: () => _triggerController(item.id), child: Text("Trigger")),
                    LdButton.error(
                      mode: LdButtonMode.outline,
                      size: LdSize.m,
                      onPressed: () => _forceErrorController(item.id),
                      child: Text("Force Error"),
                    ),
                    LdButton.vague(size: LdSize.m, onPressed: () => _resetController(item.id), child: Text("Reset")),
                  ],
                ),
              ],
            ),
          ).padM(),
        ),
        ldSpacerM,
      ],
    );
  }
}
