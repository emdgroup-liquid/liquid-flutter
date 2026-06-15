import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _CacheItem with Identifiable<int> {
  @override
  final int id;
  final String label;

  _CacheItem(this.id, this.label);
}

void main() {
  group('LdRepositoryCache', () {
    test('writePage stores defensive copy', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      final source = [_CacheItem(1, 'a')];

      cache.writePage('items', offset: 0, items: source, total: 1);
      source.add(_CacheItem(2, 'b'));

      expect(cache.readPage('items', 0)?.length, equals(1));
      expect(cache.readPage('items', 0)?.first.id, equals(1));
    });

    test('readPage returns unmodifiable list', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage('items', offset: 0, items: [_CacheItem(1, 'a')], total: 1);

      final read = cache.readPage('items', 0);
      expect(read, isNotNull);
      expect(
        () => read!.add(_CacheItem(2, 'b')),
        throwsUnsupportedError,
      );
    });

    test('remove deletes entry', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage('items', offset: 0, items: [_CacheItem(1, 'a')], total: 1);

      cache.remove('items');

      expect(cache.containsPage('items', 0), isFalse);
      expect(cache.readPage('items', 0), isNull);
    });

    test('readPage returns null when ttl expired', () async {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage(
        'items',
        offset: 0,
        items: [_CacheItem(1, 'a')],
        total: 1,
        ttl: const Duration(milliseconds: 10),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cache.readPage('items', 0), isNull);
      expect(cache.containsPage('items', 0), isFalse);
    });

    test('all merges contiguous pages when complete', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage(
        'items',
        offset: 0,
        items: [_CacheItem(1, 'a'), _CacheItem(2, 'b')],
        total: 4,
      );
      cache.writePage(
        'items',
        offset: 2,
        items: [_CacheItem(3, 'c'), _CacheItem(4, 'd')],
        total: 4,
      );

      final entry = cache.readEntry('items');
      expect(entry?.isComplete, isTrue);
      expect(entry?.all?.map((item) => item.id).toList(), equals([1, 2, 3, 4]));
    });

    test('all returns null when pages are partial', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage(
        'items',
        offset: 0,
        items: [_CacheItem(1, 'a')],
        total: 3,
      );

      expect(cache.readEntry('items')?.all, isNull);
      expect(cache.readEntry('items')?.isComplete, isFalse);
    });

    test('all returns null when offsets are not contiguous from 0', () {
      final cache = LdRepositoryCache<_CacheItem, int>();
      cache.writePage(
        'items',
        offset: 2,
        items: [_CacheItem(3, 'c')],
        total: 3,
      );

      expect(cache.readEntry('items')?.all, isNull);
    });
  });
}
