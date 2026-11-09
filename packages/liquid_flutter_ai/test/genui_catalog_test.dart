import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

typedef _Harness = ({
  MessageProcessor<ComponentImplementation> processor,
  List<A2uiRendererAction> actions,
  List<A2uiRendererError> errors,
});

Widget _wrap(Widget child) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: const [LiquidLocalizations.delegate],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Renders [root] as the root component of a surface of the Liquid catalog,
/// with every check of the processor on.
Future<_Harness> _pumpRoot(
  WidgetTester tester,
  Map<String, Object?> root, {
  Map<String, Object?>? dataModel,
}) async {
  final processor = MessageProcessor<ComponentImplementation>(
    catalogs: [buildLdCatalog()],
    validationConfig: ValidationConfig.strict,
  );
  addTearDown(processor.dispose);
  final actions = <A2uiRendererAction>[];
  final errors = <A2uiRendererError>[];
  processor.model.onAction.subscribe(actions.add);
  processor.model.onError.subscribe(errors.add);
  processor.processMessages([
    {
      'version': 'v0.9',
      'createSurface': {'surfaceId': 's', 'catalogId': kLdGenuiCatalogId},
    },
    if (dataModel != null)
      {
        'version': 'v0.9',
        'updateDataModel': {'surfaceId': 's', 'path': '/', 'value': dataModel},
      },
    {
      'version': 'v0.9',
      'updateComponents': {
        'surfaceId': 's',
        'components': [
          {'id': 'root', ...root},
        ],
      },
    },
  ]);
  await tester.pumpWidget(
    _wrap(A2uiSurface(surface: processor.model.getSurface('s')!)),
  );
  await tester.pump();
  return (processor: processor, actions: actions, errors: errors);
}

void main() {
  setUp(() {
    ldDisableAnimations = true;
  });

  tearDown(() {
    ldDisableAnimations = false;
  });

  testWidgets('every composite renders without errors', (tester) async {
    final roots = <String, Map<String, Object?>>{
      'What should we cook?': {
        'component': 'LdMultipleChoice',
        'label': 'What should we cook?',
        'description': 'Pick one, or type your own.',
        'selected': {'path': '/selected'},
        'layout': 'list',
        'allowCustom': true,
        'customLabel': 'Something else',
        'customHint': 'Enter your own…',
        'submitLabel': 'Cook this',
        'options': [
          {'value': 'pasta', 'label': 'Pasta', 'description': 'Quick.'},
          {'value': 'soup', 'label': 'Soup'},
        ],
      },
      'Delete draft?': {
        'component': 'LdConfirm',
        'title': 'Delete draft?',
        'message': 'This cannot be undone.',
        'tone': 'danger',
        'primary': {
          'label': 'Delete',
          'action': {'name': 'deleteDraft'},
        },
        'secondary': {
          'label': 'Keep',
          'action': {'name': 'keepDraft'},
        },
      },
      'Quota nearly full': {
        'component': 'LdCallout',
        'type': 'warning',
        'title': 'Quota nearly full',
        'body': 'You have used 92% of your monthly token budget.',
      },
      "Tonight's recipes": {
        'component': 'LdCardGallery',
        'title': "Tonight's recipes",
        'selected': {'path': '/selected'},
        'cards': [
          {
            'id': 'r1',
            'title': 'Tomato pasta',
            'subtitle': '25 min',
            'tags': ['quick'],
            'markdown': '**Ingredients**: pasta, tomatoes, basil.',
            'action': {
              'name': 'pickRecipe',
              'context': {'id': 'r1'},
            },
          },
        ],
      },
      'Berlin': {
        'component': 'LdWeatherCard',
        'location': 'Berlin',
        'temperature': 18,
        'unit': 'c',
        'condition': 'partlyCloudy',
        'summary': 'Pleasant afternoon, light breeze.',
        'high': 21,
        'low': 12,
        'humidity': 55,
        'wind': '14 km/h W',
      },
      'Design critique': {
        'component': 'LdCalendarEvent',
        'title': 'Design critique',
        'start': '2026-08-05T14:00:00',
        'end': '2026-08-05T15:00:00',
        'location': 'Studio B',
        'description': 'Bring the latest mocks.',
        'allDay': false,
        'action': {'name': 'openEvent'},
      },
      'Release checklist': {
        'component': 'LdTimeline',
        'title': 'Release checklist',
        'items': [
          {'time': '09:00', 'title': 'Freeze main', 'body': 'Tag rc.1'},
          {'time': '16:00', 'title': 'Publish', 'tone': 'success'},
        ],
      },
      'Open PRs': {
        'component': 'LdDetailList',
        'title': 'Open PRs',
        'items': [
          {
            'id': 'pr1',
            'title': 'feat: composites',
            'subtitle': 'Ready for review',
            'markdown': 'Adds catalog composites.',
            'actions': [
              {
                'label': 'Approve',
                'mode': 'filled',
                'action': {
                  'name': 'approvePr',
                  'context': {'id': 'pr1'},
                },
              },
            ],
          },
        ],
      },
    };

    for (final MapEntry(key: text, value: root) in roots.entries) {
      final harness = await _pumpRoot(
        tester,
        root,
        dataModel: {'selected': 'pasta'},
      );
      expect(harness.errors, isEmpty, reason: root['component'] as String);
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('LdMultipleChoice writes the bound selection and submits it', (
    tester,
  ) async {
    final harness = await _pumpRoot(
      tester,
      {
        'component': 'LdMultipleChoice',
        'selected': {'path': '/choice'},
        'layout': 'chips',
        'options': [
          {'value': 'a', 'label': 'A'},
          {'value': 'b', 'label': 'B'},
        ],
      },
      dataModel: {'choice': 'a'},
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(
      harness.processor.model.getSurface('s')!.dataModel.get('/choice'),
      'b',
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(harness.actions.single.name, 'multipleChoiceSubmit');
    expect(harness.actions.single.sourceComponentId, 'root');
    expect(harness.actions.single.context, {'selected': 'b'});
    expect(harness.errors, isEmpty);
  });

  testWidgets('LdMultipleChoice keeps a literal selection in local state', (
    tester,
  ) async {
    final harness = await _pumpRoot(tester, {
      'component': 'LdMultipleChoice',
      'selected': 'a',
      'layout': 'chips',
      'options': [
        {'value': 'a', 'label': 'A'},
        {'value': 'b', 'label': 'B'},
      ],
    });

    await tester.tap(find.text('B'));
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(harness.actions.single.context, {'selected': 'b'});
    expect(harness.processor.model.getSurface('s')!.dataModel.get('/'), {});
  });

  testWidgets('LdCardGallery writes the selection and resolves the action', (
    tester,
  ) async {
    final harness = await _pumpRoot(
      tester,
      {
        'component': 'LdCardGallery',
        'selected': {'path': '/selected'},
        'cards': [
          {'id': 'r1', 'title': 'Pasta'},
          {
            'id': 'r2',
            'title': 'Soup',
            'action': {
              'name': 'pickRecipe',
              'context': {
                'user': {'path': '/user'},
                'picked': {'path': '/selected'},
              },
            },
          },
        ],
      },
      dataModel: {'selected': 'r1', 'user': 'ada'},
    );

    await tester.tap(find.text('Soup'));
    await tester.pump();

    expect(
      harness.processor.model.getSurface('s')!.dataModel.get('/selected'),
      'r2',
    );
    expect(harness.actions.single.name, 'pickRecipe');
    expect(harness.actions.single.context, {
      'user': 'ada',
      'picked': 'r2',
      'id': 'r2',
    });
    expect(harness.errors, isEmpty);
  });

  testWidgets('LdConfirm dispatches the action of the tapped button', (
    tester,
  ) async {
    final harness = await _pumpRoot(tester, {
      'component': 'LdConfirm',
      'title': 'Sure?',
      'primary': {
        'label': 'Yes',
        'action': {
          'name': 'yes',
          'context': {'reason': 'ok'},
        },
      },
      'secondary': {
        'label': 'No',
        'action': {'name': 'no'},
      },
    });

    await tester.tap(find.text('Yes'));
    await tester.pump();

    final action = harness.actions.single;
    expect(action.name, 'yes');
    expect(action.surfaceId, 's');
    expect(action.sourceComponentId, 'root');
    expect(action.context, {'reason': 'ok'});
    expect(
      ActionMessage(version: 'v0.9', action: action).toJson()['version'],
      'v0.9',
    );
  });

  testWidgets('LdWeatherCard follows a bound temperature', (tester) async {
    final harness = await _pumpRoot(
      tester,
      {
        'component': 'LdWeatherCard',
        'location': 'Berlin',
        'temperature': {'path': '/temp'},
        'condition': 'sunny',
      },
      dataModel: {'temp': 18},
    );
    expect(find.text('18°C'), findsOneWidget);

    harness.processor.processMessages({
      'version': 'v0.9',
      'updateDataModel': {'surfaceId': 's', 'path': '/temp', 'value': 21.4},
    });
    await tester.pump();

    expect(find.text('21°C'), findsOneWidget);
    expect(harness.errors, isEmpty);
  });

  testWidgets('composites accept properties their schema does not list', (
    tester,
  ) async {
    final harness = await _pumpRoot(tester, {
      'component': 'LdCallout',
      'type': 'info',
      'body': 'Hello',
      'variant': 'compact',
    });

    expect(find.text('Hello'), findsOneWidget);
    expect(harness.errors, isEmpty);
  });

  testWidgets('invalid component data is reported and shown as an error', (
    tester,
  ) async {
    final harness = await _pumpRoot(tester, {
      'component': 'LdCardGallery',
      'cards': <Object?>[],
    });

    expect(
      find.textContaining('LdCardGallery requires at least one card'),
      findsOneWidget,
    );
    expect(harness.errors.single.code, 'RUNTIME_ERROR');
    expect(harness.errors.single.surfaceId, 's');
  });

  group('LdGenuiSurfaceManager', () {
    test('reports unreadable lines on onError unless replaying', () async {
      final manager = LdGenuiSurfaceManager();
      addTearDown(manager.dispose);
      final errors = <A2uiRendererError>[];
      manager.processor.model.onError.subscribe(errors.add);

      const text =
          '```genui\n'
          'not json\n'
          '{"version":"v0.9","deleteSurface":{}}\n'
          '```';
      manager.processAndReplay(text);
      await Future<void>.delayed(Duration.zero);
      expect(errors, isEmpty);

      manager.processMessageText(text);
      await Future<void>.delayed(Duration.zero);
      expect(errors.map((e) => e.code), [
        'PARSE_ERROR',
        'SCHEMA_VALIDATION_FAILED',
      ]);
    });

    test('activeSurfaceIds moves an updated surface to the end', () {
      final manager = LdGenuiSurfaceManager();
      addTearDown(manager.dispose);

      manager.processMessageText(
        '```genui\n'
        '{"version":"v0.9","createSurface":{"surfaceId":"a"}}\n'
        '{"version":"v0.9","createSurface":{"surfaceId":"b"}}\n'
        '{"version":"v0.9","updateComponents":{"surfaceId":"a","components":'
        '[{"id":"root","component":"LdCallout","type":"info","body":"A"}]}}\n'
        '```',
      );

      expect(manager.activeSurfaceIds, ['b', 'a']);
    });

    testWidgets('LdGenuiSurfaceWidget shows a surface created after it', (
      tester,
    ) async {
      final manager = LdGenuiSurfaceManager();
      addTearDown(manager.dispose);
      await tester.pumpWidget(
        _wrap(LdGenuiSurfaceWidget(surfaceManager: manager, surfaceId: 'late')),
      );
      expect(find.text('Hello'), findsNothing);

      manager.processMessageText(
        '```genui\n'
        '{"version":"v0.9","createSurface":{"surfaceId":"late"}}\n'
        '{"version":"v0.9","updateComponents":{"surfaceId":"late","components":'
        '[{"id":"root","component":"LdCallout","type":"info","body":"Hello"}]}}\n'
        '```',
      );
      await tester.pump();
      expect(find.text('Hello'), findsOneWidget);

      manager.deleteSurface('late');
      await tester.pump();
      expect(find.text('Hello'), findsNothing);
    });
  });
}
