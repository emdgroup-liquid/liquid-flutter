import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

/// The merge logic that was previously exposed as free functions
/// (ldMonkeyMergeFormFromServer / ldMonkeyResolveFieldConflict) is now
/// encapsulated in LdForm's internal state.
///
/// This file tests the public data types and constants used by that logic.
void main() {
  group('LdMonkeyFieldConflict', () {
    test('holds field key and both values', () {
      const conflict = LdMonkeyFieldConflict(
        fieldKey: 'title',
        localValue: 'local',
        serverValue: 'server',
      );

      expect(conflict.fieldKey, 'title');
      expect(conflict.localValue, 'local');
      expect(conflict.serverValue, 'server');
    });
  });

  group('LdMonkeyFieldConflictPolicy', () {
    test('enum has expected values', () {
      expect(
        LdMonkeyFieldConflictPolicy.values,
        containsAll([
          LdMonkeyFieldConflictPolicy.keepLocal,
          LdMonkeyFieldConflictPolicy.preferServer,
          LdMonkeyFieldConflictPolicy.prompt,
        ]),
      );
    });
  });

  group('LdMonkeyFieldConflictResolution', () {
    test('enum has expected values', () {
      expect(
        LdMonkeyFieldConflictResolution.values,
        containsAll([
          LdMonkeyFieldConflictResolution.keepLocal,
          LdMonkeyFieldConflictResolution.preferServer,
        ]),
      );
    });
  });

  group('kLdMonkeyServerConflictKey', () {
    test('is the expected string', () {
      expect(kLdMonkeyServerConflictKey, 'serverConflict');
    });
  });

  group('LdMonkeyFieldConflictError', () {
    test('holds local and server values', () {
      const error = LdMonkeyFieldConflictError(
        localValue: 'mine',
        serverValue: 'theirs',
      );

      expect(error.localValue, 'mine');
      expect(error.serverValue, 'theirs');
    });
  });

  group('LdFormConflicts', () {
    test('hasConflicts reflects conflict list', () {
      var resolvedConflict = const LdMonkeyFieldConflict(
        fieldKey: 'x',
        localValue: 1,
        serverValue: 2,
      );

      final withConflicts = LdFormConflicts(
        conflicts: [resolvedConflict],
        resolveConflict: ({required conflict, required resolution}) {},
      );

      final withoutConflicts = LdFormConflicts(
        conflicts: [],
        resolveConflict: ({required conflict, required resolution}) {},
      );

      expect(withConflicts.conflicts, isNotEmpty);
      expect(withoutConflicts.conflicts, isEmpty);
    });
  });
}
