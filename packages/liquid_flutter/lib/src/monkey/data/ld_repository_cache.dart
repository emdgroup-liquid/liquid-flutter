import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdRepositoryCacheEntry<T> {
  int total;
  final Map<int, List<T>> _pagesByOffset;
  final DateTime? expiresAt;

  LdRepositoryCacheEntry({
    required this.total,
    Map<int, List<T>>? pagesByOffset,
    this.expiresAt,
  }) : _pagesByOffset = pagesByOffset ?? {};

  bool get isExpired {
    final expiresAt = this.expiresAt;
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt);
  }

  Map<int, List<T>> get pagesByOffset => Map<int, List<T>>.unmodifiable(
        _pagesByOffset.map(
          (offset, items) => MapEntry(offset, List<T>.unmodifiable(items)),
        ),
      );

  /// Merges cached pages in offset order when contiguous from 0 through [total].
  List<T>? get all {
    if (_pagesByOffset.isEmpty) {
      return null;
    }

    final offsets = _pagesByOffset.keys.toList()..sort();
    if (offsets.first != 0) {
      return null;
    }

    final merged = <T>[];
    var expectedOffset = 0;

    for (final offset in offsets) {
      if (offset != expectedOffset) {
        return null;
      }
      final page = _pagesByOffset[offset]!;
      merged.addAll(page);
      expectedOffset = offset + page.length;
    }

    if (merged.length != total) {
      return null;
    }

    return List<T>.unmodifiable(merged);
  }

  bool get isComplete => all != null;

  void writePage({
    required int offset,
    required List<T> items,
    required int total,
  }) {
    this.total = total;
    _pagesByOffset[offset] = List<T>.unmodifiable(List<T>.from(items));
  }
}

/// Per-repository page-aware cache for use inside [fetchListWithParameters].
class LdRepositoryCache<T extends Identifiable<IdType>, IdType> {
  final Map<String, LdRepositoryCacheEntry<T>> _entries = {};

  Iterable<String> get keys => _entries.keys;

  LdRepositoryCacheEntry<T>? readEntry(String key) {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }
    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    return entry;
  }

  List<T>? readPage(String key, int offset) {
    return readEntry(key)?.pagesByOffset[offset];
  }

  void writePage(
    String key, {
    required int offset,
    required List<T> items,
    required int total,
    Duration? ttl,
  }) {
    final existing = _entries[key];
    final entry = existing ??
        LdRepositoryCacheEntry<T>(
          total: total,
          expiresAt: ttl == null ? null : DateTime.now().add(ttl),
        );

    entry.writePage(
      offset: offset,
      items: items,
      total: total,
    );

    _entries[key] = entry;
  }

  void remove(String key) {
    _entries.remove(key);
  }

  void clear() {
    _entries.clear();
  }

  bool containsPage(String key, int offset) {
    return readPage(key, offset) != null;
  }

  /// Invalidates cached pages after a repository mutation.
  ///
  /// [create] and [delete] always clear the full cache. [update] removes cache
  /// keys whose filter/sort parts report affected via [LdFilterOption.mutationAffectsCache]
  /// or [LdSortOption.mutationAffectsCache], read from [LdMonkeySortAndFilterState].
  void invalidateOnMutation({
    required BuildContext context,
    required LdRepositoryMutationKind kind,
    T? before,
    T? after,
  }) {
    if (kind == LdRepositoryMutationKind.create || kind == LdRepositoryMutationKind.delete) {
      clear();
      return;
    }

    final state = context.read<LdMonkeySortAndFilterState<T, IdType>?>();
    if (state == null) {
      clear();
      return;
    }

    final filtersByName = {for (final filter in state.filters) filter.name: filter};
    final sortsByName = {for (final sort in state.sortOptions) sort.name: sort};

    final hasAnyPredicate = state.filters.any((filter) => filter.mutationAffectsCache != null) ||
        state.sortOptions.any((sort) => sort.mutationAffectsCache != null);

    if (!hasAnyPredicate) {
      clear();
      return;
    }

    final keysToRemove = <String>[];
    for (final key in List<String>.from(_entries.keys)) {
      if (_isCacheKeyAffectedByUpdate(
        key: key,
        before: before,
        after: after,
        filtersByName: filtersByName,
        sortsByName: sortsByName,
      )) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      remove(key);
    }
  }

  bool _isCacheKeyAffectedByUpdate({
    required String key,
    required T? before,
    required T? after,
    required Map<String, LdFilterOption<T, IdType>> filtersByName,
    required Map<String, LdSortOption<T, IdType>> sortsByName,
  }) {
    for (final part in parseLdRepositoryCacheKey(key)) {
      switch (part.kind) {
        case 'filter':
          final filter = filtersByName[part.name];
          if (filter == null) {
            return true;
          }
          if (filter.mutationAffectsCache?.call(before, after) ?? true) {
            return true;
          }
        case 'sort':
          final sort = sortsByName[part.name];
          if (sort == null) {
            return true;
          }
          if (sort.mutationAffectsCache?.call(before, after) ?? true) {
            return true;
          }
        case 'token':
          break;
      }
    }

    return false;
  }
}
