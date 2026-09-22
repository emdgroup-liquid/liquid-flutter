import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:test/test.dart';

void main() {
  group('LdStringRef', () {
    test('parses literals and path bindings', () {
      expect(LdStringRef.tryParse('hello'), isA<LdStringLiteral>());
      expect((LdStringRef.tryParse('hello') as LdStringLiteral).value, 'hello');

      final binding = LdStringRef.tryParse({'path': '/selected'});
      expect(binding, isA<LdStringBinding>());
      expect((binding as LdStringBinding).path, '/selected');
    });

    test('boundValue matches BoundString input', () {
      expect(const LdStringLiteral('a').boundValue, 'a');
      expect(const LdStringBinding('/x').boundValue, {'path': '/x'});
    });
  });

  group('LdNumberRef', () {
    test('parses literals and path bindings', () {
      expect(LdNumberRef.tryParse(18), isA<LdNumberLiteral>());
      expect((LdNumberRef.tryParse(18.5) as LdNumberLiteral).value, 18.5);

      final binding = LdNumberRef.tryParse({'path': '/temp'});
      expect((binding as LdNumberBinding).path, '/temp');
    });
  });

  group('LdCalloutData', () {
    test('parses type, title, body', () {
      final data = LdCalloutData.fromJson({
        'type': 'warning',
        'title': 'Heads up',
        'body': 'Quota nearly full',
      });
      expect(data.type, LdGenuiTone.warning);
      expect(data.title, 'Heads up');
      expect(data.body, 'Quota nearly full');
    });
  });

  group('LdConfirmData', () {
    test('parses primary and secondary actions', () {
      final data = LdConfirmData.fromJson({
        'title': 'Delete?',
        'message': 'Cannot undo',
        'tone': 'danger',
        'primary': {
          'label': 'Delete',
          'action': {
            'name': 'delete',
            'context': {'id': '1'},
          },
        },
        'secondary': {
          'label': 'Keep',
          'action': {'name': 'keep'},
        },
      });
      expect(data.tone, LdConfirmTone.danger);
      expect(data.primary.label, 'Delete');
      expect(data.primary.action.name, 'delete');
      expect(data.primary.action.context['id'], '1');
      expect(data.secondary?.label, 'Keep');
    });

    test('throws when title or primary is missing', () {
      expect(
        () => LdConfirmData.fromJson({
          'primary': {
            'label': 'Yes',
            'action': {'name': 'y'},
          },
        }),
        throwsFormatException,
      );
      expect(
        () => LdConfirmData.fromJson({'title': 'Sure?'}),
        throwsFormatException,
      );
    });
  });

  group('LdMultipleChoiceData', () {
    test('parses options, layout, and selected binding', () {
      final data = LdMultipleChoiceData.fromJson({
        'label': 'Pick',
        'selected': {'path': '/selected'},
        'layout': 'list',
        'allowCustom': true,
        'options': [
          {'value': 'a', 'label': 'A', 'description': 'First'},
          {'value': 'b', 'label': 'B'},
          {'label': 'broken'},
        ],
      });
      expect(data.label, 'Pick');
      expect(data.layout, LdMultipleChoiceLayout.list);
      expect(data.allowCustom, isTrue);
      expect(data.selected, isA<LdStringBinding>());
      expect(data.options, hasLength(2));
      expect(data.options.first.description, 'First');
      expect(data.customHint, 'Enter your own…');
    });
  });

  group('LdCardGalleryData', () {
    test('parses cards and skips invalid entries', () {
      final data = LdCardGalleryData.fromJson({
        'title': 'Recipes',
        'selected': 'r1',
        'cards': [
          {
            'id': 'r1',
            'title': 'Pasta',
            'tags': ['quick', 1, ''],
            'action': {'name': 'pick'},
          },
          {'title': 'missing id'},
        ],
      });
      expect(data.cards, hasLength(1));
      expect(data.cards.first.tags, ['quick']);
      expect(data.selected, isA<LdStringLiteral>());
    });

    test('throws when no valid cards', () {
      expect(
        () => LdCardGalleryData.fromJson({'cards': []}),
        throwsFormatException,
      );
    });
  });

  group('LdWeatherCardData', () {
    test('parses literal temperature and unit', () {
      final data = LdWeatherCardData.fromJson({
        'location': 'Berlin',
        'temperature': 18,
        'unit': 'f',
        'condition': 'sunny',
        'high': 21,
      });
      expect(data.unit, LdTemperatureUnit.f);
      expect(data.unit.label, 'F');
      expect((data.temperature as LdNumberLiteral).value, 18);
    });
  });

  group('LdCalendarEventData', () {
    test('parses ISO datetimes', () {
      final data = LdCalendarEventData.fromJson({
        'title': 'Standup',
        'start': '2026-08-05T09:00:00',
        'end': '2026-08-05T09:30:00',
      });
      expect(data.startDate?.hour, 9);
      expect(data.endDate?.minute, 30);
    });
  });

  group('LdTimelineData', () {
    test('parses body and tone', () {
      final data = LdTimelineData.fromJson({
        'items': [
          {
            'time': '09:00',
            'title': 'Start',
            'body': 'Tag rc.1',
            'tone': 'success',
          },
        ],
      });
      expect(data.items.single.body, 'Tag rc.1');
      expect(data.items.single.tone, LdGenuiTone.success);
    });
  });

  group('LdDetailListData', () {
    test('parses nested actions', () {
      final data = LdDetailListData.fromJson({
        'items': [
          {
            'id': '1',
            'title': 'PR',
            'markdown': 'Details',
            'actions': [
              {
                'label': 'Approve',
                'mode': 'outline',
                'action': {'name': 'approve'},
              },
            ],
          },
        ],
      });
      expect(data.items.single.actions.single.mode, LdGenuiButtonMode.outline);
      expect(data.items.single.actions.single.action.name, 'approve');
    });
  });
}
