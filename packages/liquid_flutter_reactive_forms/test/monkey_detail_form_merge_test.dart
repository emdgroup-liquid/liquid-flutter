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
      );

      expect(form.control('title').getError(kLdMonkeyServerConflictKey), isNotNull);
      expect(form.control('note').getError(kLdMonkeyServerConflictKey), isNotNull);
      expect(form.control('title').value, 'my title');
      expect(lastServer['note'], 'server note');
    });

    test('re-triggers conflict when server resends same value after user resolved keepLocal', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'my title'),
      });
      form.control('title').markAsDirty();
      final lastServer = {'title': 'original'};

      // First conflict: server sends 'server v1'
      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server v1'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      );
      expect(form.control('title').getError(kLdMonkeyServerConflictKey), isNotNull);
      expect(lastServer['title'], 'server v1');

      // User resolves by keeping local — removes the error
      ldMonkeyResolveFieldConflict(
        form: form,
        conflict: LdMonkeyFieldConflict(
          fieldKey: 'title',
          localValue: 'my title',
          serverValue: 'server v1',
        ),
        resolution: LdMonkeyFieldConflictResolution.keepLocal,
        lastServerValues: lastServer,
      );
      expect(form.control('title').getError(kLdMonkeyServerConflictKey), isNull);
      expect(form.control('title').dirty, isTrue);

      // Server re-sends the same value 'server v1' — should re-trigger conflict
      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server v1'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      );

      expect(
        form.control('title').getError(kLdMonkeyServerConflictKey),
        isNotNull,
        reason: 'Conflict should re-appear when server resends the same value after keepLocal resolution',
      );
    });

    test('does not re-trigger conflict when same value is already showing as unresolved', () async {
      final form = FormGroup({
        'title': FormControl<String>(value: 'my title'),
      });
      form.control('title').markAsDirty();
      final lastServer = {'title': 'original'};

      // First conflict
      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server v1'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      );
      final errorBefore = form.control('title').getError(kLdMonkeyServerConflictKey);
      expect(errorBefore, isNotNull);

      // Server re-sends the same value while conflict is still unresolved — should not duplicate/reset
      await ldMonkeyMergeFormFromServer(
        form: form,
        serverValues: {'title': 'server v1'},
        lastServerValues: lastServer,
        conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,
      );

      // Error should still be present and identical (not re-set)
      final errorAfter = form.control('title').getError(kLdMonkeyServerConflictKey);
      expect(errorAfter, same(errorBefore),
          reason: 'Existing unresolved conflict should not be replaced when server resends same value');
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
