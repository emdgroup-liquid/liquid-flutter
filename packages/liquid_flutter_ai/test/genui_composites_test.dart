import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

void main() {
  setUp(() {
    ldDisableAnimations = true;
  });

  tearDown(() {
    ldDisableAnimations = false;
  });

  testWidgets('GenUI composites render from catalog JSON', (tester) async {
    final manager = LdGenuiSurfaceManager();
    addTearDown(manager.dispose);

    const block = '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"mc"}}
{"version":"v0.9","updateDataModel":{"surfaceId":"mc","path":"/","value":{"selected":"a"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"mc","components":[{"id":"root","component":"LdMultipleChoice","label":"Pick","selected":{"path":"/selected"},"allowCustom":true,"options":[{"value":"a","label":"A"},{"value":"b","label":"B"}]}]}}
{"version":"v0.9","createSurface":{"surfaceId":"confirm"}}
{"version":"v0.9","updateComponents":{"surfaceId":"confirm","components":[{"id":"root","component":"LdConfirm","title":"Sure?","primary":{"label":"Yes","action":{"name":"yes"}},"secondary":{"label":"No","action":{"name":"no"}}}]}}
{"version":"v0.9","createSurface":{"surfaceId":"callout"}}
{"version":"v0.9","updateComponents":{"surfaceId":"callout","components":[{"id":"root","component":"LdCallout","type":"info","body":"Hello"}]}}
{"version":"v0.9","createSurface":{"surfaceId":"weather"}}
{"version":"v0.9","updateComponents":{"surfaceId":"weather","components":[{"id":"root","component":"LdWeatherCard","location":"Berlin","temperature":18,"condition":"sunny"}]}}
{"version":"v0.9","createSurface":{"surfaceId":"event"}}
{"version":"v0.9","updateComponents":{"surfaceId":"event","components":[{"id":"root","component":"LdCalendarEvent","title":"Standup","start":"2026-08-05T09:00:00"}]}}
{"version":"v0.9","createSurface":{"surfaceId":"timeline"}}
{"version":"v0.9","updateComponents":{"surfaceId":"timeline","components":[{"id":"root","component":"LdTimeline","items":[{"title":"Start","time":"09:00"}]}]}}
{"version":"v0.9","createSurface":{"surfaceId":"list"}}
{"version":"v0.9","updateComponents":{"surfaceId":"list","components":[{"id":"root","component":"LdDetailList","items":[{"id":"1","title":"Item","markdown":"Details"}]}]}}
```
''';

    manager.processMessageText(block);

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LdAutoSpace(
                children: [
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'mc',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'confirm',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'callout',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'weather',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'event',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'timeline',
                  ),
                  LdGenuiSurfaceWidget(
                    surfaceManager: manager,
                    surfaceId: 'list',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pick'), findsOneWidget);
    expect(find.text('Sure?'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Berlin'), findsOneWidget);
    expect(find.text('Standup'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Item'), findsOneWidget);
  });
}
