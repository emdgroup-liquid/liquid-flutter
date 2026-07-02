import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Returns whether changing [before] to [after] might change list membership or
/// sort order for views that use this filter or sort option.
///
/// Used for cache invalidation and paginator layout decisions. Bias toward `true`
/// — false negatives cause visible glitches.
typedef LdAffectedByUpdate<T> = bool Function(T? before, T? after);

/// Evaluates [predicate], defaulting to `true` when unset (conservative).
bool evaluateAffectedByUpdate<T>(
  LdAffectedByUpdate<T>? predicate,
  T? before,
  T? after,
) {
  return predicate?.call(before, after) ?? true;
}

/// Whether an update may change list layout for the active filter/sort query.
bool isLayoutAffectedByUpdate<T extends Identifiable<IdType>, IdType>({
  required BuildContext context,
  required T? before,
  required T? after,
}) {
  final state = context.read<LdMonkeySortAndFilterState<T, IdType>?>();
  if (state == null) {
    return false;
  }

  final activeFilters = state.activeFilters;
  final activeSortOptions = state.activeSortOptions;

  final hasAnyPredicate = state.filters.any((filter) => filter.affectedByUpdate != null) ||
      state.sortOptions.any((sort) => sort.affectedByUpdate != null);

  if (!hasAnyPredicate) {
    return true;
  }

  for (final filter in activeFilters) {
    if (evaluateAffectedByUpdate(filter.affectedByUpdate, before, after)) {
      return true;
    }
  }

  for (final sort in activeSortOptions) {
    if (evaluateAffectedByUpdate(sort.affectedByUpdate, before, after)) {
      return true;
    }
  }

  return false;
}

/// Whether a cached page under [cacheKey] may be stale after an update.
bool isCacheKeyAffectedByUpdate<T extends Identifiable<IdType>, IdType>({
  required String cacheKey,
  required T? before,
  required T? after,
  required Map<String, LdFilterOption<T, IdType>> filtersByName,
  required Map<String, LdSortOption<T, IdType>> sortsByName,
}) {
  for (final part in parseLdListCacheKey(cacheKey)) {
    switch (part.kind) {
      case 'filter':
        final filter = filtersByName[part.name];
        if (filter == null) {
          return true;
        }
        if (evaluateAffectedByUpdate(filter.affectedByUpdate, before, after)) {
          return true;
        }
      case 'sort':
        final sort = sortsByName[part.name];
        if (sort == null) {
          return true;
        }
        if (evaluateAffectedByUpdate(sort.affectedByUpdate, before, after)) {
          return true;
        }
      case 'token':
        break;
    }
  }

  return false;
}
