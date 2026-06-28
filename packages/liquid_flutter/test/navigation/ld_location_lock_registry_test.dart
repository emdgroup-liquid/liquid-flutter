import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  group('normalizeLocationPath', () {
    test('normalizes empty and relative paths', () {
      expect(normalizeLocationPath(''), '/');
      expect(normalizeLocationPath('task-demo'), '/task-demo');
      expect(normalizeLocationPath('/task-demo/'), '/task-demo');
    });
  });

  group('isWithinLocationPathPrefix', () {
    test('matches exact path and sub-paths', () {
      expect(isWithinLocationPathPrefix('/task-demo/1', '/task-demo/1'), isTrue);
      expect(isWithinLocationPathPrefix('/task-demo/1', '/task-demo/1/edit'), isTrue);
    });

    test('rejects sibling paths', () {
      expect(isWithinLocationPathPrefix('/task-demo/1', '/task-demo/2'), isFalse);
      expect(isWithinLocationPathPrefix('/task-demo/1', '/movie-demo'), isFalse);
    });
  });

  group('locationPathsConflict', () {
    test('same path does not conflict', () {
      expect(locationPathsConflict('/a', '/a'), isFalse);
    });

    test('nested prefixes do not conflict', () {
      expect(locationPathsConflict('/task-demo', '/task-demo/1'), isFalse);
      expect(locationPathsConflict('/task-demo/1', '/task-demo'), isFalse);
    });

    test('unrelated prefixes conflict', () {
      expect(locationPathsConflict('/task-demo', '/movie-demo'), isTrue);
      expect(locationPathsConflict('/task-demo/1', '/task-demo/2'), isTrue);
    });
  });

  group('LdLocationLockRegistry', () {
    test('register replaces lock with same id', () {
      final registry = LdLocationLockRegistry();
      registry.register(
        LdLocationLock(
          id: 'a',
          pathPrefix: '/one',
          onLeave: (_) async => true,
        ),
      );
      registry.register(
        LdLocationLock(
          id: 'a',
          pathPrefix: '/two',
          onLeave: (_) async => true,
        ),
      );

      expect(registry.locks.single.pathPrefix, '/two');
    });

    test('throws on conflicting sibling locks', () {
      final registry = LdLocationLockRegistry();
      registry.register(
        LdLocationLock(
          id: 'a',
          pathPrefix: '/task-demo/1',
          onLeave: (_) async => true,
        ),
      );

      expect(
        () => registry.register(
          LdLocationLock(
            id: 'b',
            pathPrefix: '/task-demo/2',
            onLeave: (_) async => true,
          ),
        ),
        throwsStateError,
      );
    });

    test('allows nested locks', () {
      final registry = LdLocationLockRegistry();
      registry.register(
        LdLocationLock(
          id: 'parent',
          pathPrefix: '/task-demo',
          onLeave: (_) async => true,
        ),
      );

      expect(
        () => registry.register(
          LdLocationLock(
            id: 'child',
            pathPrefix: '/task-demo/1',
            onLeave: (_) async => true,
          ),
        ),
        returnsNormally,
      );
    });

    test('allows multiple locks on the same path (multi-view editors)', () {
      final registry = LdLocationLockRegistry();
      registry.register(
        LdLocationLock(
          id: 'editor-12',
          pathPrefix: '/task-demo/12,13',
          onLeave: (_) async => true,
        ),
      );

      expect(
        () => registry.register(
          LdLocationLock(
            id: 'editor-13',
            pathPrefix: '/task-demo/12,13',
            onLeave: (_) async => true,
          ),
        ),
        returnsNormally,
      );
      expect(registry.locks.length, 2);
    });
  });
}
