import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  group('ldMonkeyMergeFormFromServer', () {
    test('patches pristine controls from server', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'old'),
        'done': FormControl<bool>(value: false),
      });
      final lastServer = {'title': 'old', 'done': false};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server', 'done': true},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.keepLocal,
        promptConflict: (_, __, ___) async => LdMonkeyFieldConflictResolution.keepLocal,
      );

      expect(form.control('title').value, 'server');
      expect(form.control('done').value, isTrue);
      expect(lastServer['title'], 'server');
    });

    test('keeps dirty control when server value unchanged', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'local edit'),
      });
      form.control('title').markAsDirty();
      final lastServer = {'title': 'original'};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'original'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.keepLocal,
        promptConflict: (_, __, ___) async => LdMonkeyFieldConflictResolution.keepLocal,
      );

      expect(form.control('title').value, 'local edit');
      expect(form.control('title').dirty, isTrue);
    });

    test('preferServer overwrites dirty conflicted control', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'local edit'),
      });
      form.control('title').markAsDirty();
      final lastServer = {'title': 'original'};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'external edit'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.preferServer,
        promptConflict: (_, __, ___) async => LdMonkeyFieldConflictResolution.keepLocal,
      );

      expect(form.control('title').value, 'external edit');
      expect(form.control('title').pristine, isTrue);
      expect(lastServer['title'], 'external edit');
    });
  });
}
