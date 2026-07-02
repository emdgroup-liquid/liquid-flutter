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
      );

      expect(form.control('title').value, 'external edit');
      expect(form.control('title').pristine, isTrue);
      expect(lastServer['title'], 'external edit');
    });

    test('does not inline-conflict when dirty control already equals server value', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'same'),
      });
      form.control('title').markAsDirty();
      final lastServer = {'title': 'original'};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'same'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      );

      expect(form.control('title').pristine, isTrue);
      expect(lastServer['title'], 'same');
    });

    test('prompt policy sets inline conflict errors when unresolved', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'my title'),
        'note': FormControl<String>(value: 'my note'),
      });
      form.control('title').markAsDirty();
      form.control('note').markAsDirty();
      final lastServer = {'title': 'old title', 'note': 'old note'};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server title', 'note': 'server note'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
        fieldLabels: {'title': 'Title', 'note': 'Note'},
      );

      expect(form.control('title').getError(kLdMonkeyServerConflictKey), isNotNull);
      expect(form.control('note').getError(kLdMonkeyServerConflictKey), isNotNull);
      expect(form.control('title').value, 'my title');
      expect(lastServer['note'], 'server note');
    });

    test('onFieldConflict resolves per field under prompt policy', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'my title'),
        'note': FormControl<String>(value: 'my note'),
      });
      form.control('title').markAsDirty();
      form.control('note').markAsDirty();
      final lastServer = {'title': 'old title', 'note': 'old note'};

      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server title', 'note': 'server note'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
        onFieldConflict: (conflict) async {
          return switch (conflict.fieldKey) {
            'title' => LdMonkeyFieldConflictResolution.preferServer,
            _ => LdMonkeyFieldConflictResolution.keepLocal,
          };
        },
      );

      expect(form.control('title').value, 'server title');
      expect(form.control('title').pristine, isTrue);
      expect(form.control('note').value, 'my note');
      expect(form.control('note').getError(kLdMonkeyServerConflictKey), isNull);
    });
  });
}
