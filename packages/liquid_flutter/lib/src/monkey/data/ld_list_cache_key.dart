import 'package:liquid_flutter/liquid_flutter.dart';

enum LdListMutationKind {
  create,
  update,
  delete,
}

class LdListCacheKeyPart {
  final String kind;
  final String name;
  final String value;

  const LdListCacheKeyPart({
    required this.kind,
    required this.name,
    required this.value,
  });
}

/// Builds a deterministic cache key from active filters and sort options.
///
/// Excludes pagination fields ([offset], [pageSize], [reason]). Optionally
/// includes [pageToken] for token-based APIs.
String ldListCacheKey<T extends Identifiable<IdType>, IdType>({
  required Iterable<LdFilterOption<T, IdType>> filters,
  required Iterable<LdSortOption<T, IdType>> sortOptions,
  String? pageToken,
}) {
  final parts = <String>[];

  final sortedFilters = filters.toList()..sort((a, b) => a.name.compareTo(b.name));
  for (final filter in sortedFilters) {
    parts.add('filter:${filter.name}=${filter.serialize()}');
  }

  final sortedSortOptions = sortOptions.toList()..sort((a, b) => a.name.compareTo(b.name));
  for (final sortOption in sortedSortOptions) {
    parts.add('sort:${sortOption.name}=${sortOption.serialize()}');
  }

  if (pageToken != null) {
    parts.add('token:$pageToken');
  }

  return parts.join('|');
}

/// Parses a cache key produced by [ldListCacheKey].
List<LdListCacheKeyPart> parseLdListCacheKey(String key) {
  if (key.isEmpty) {
    return const [];
  }

  final parsed = <LdListCacheKeyPart>[];
  for (final segment in key.split('|')) {
    if (segment.startsWith('filter:')) {
      final rest = segment.substring('filter:'.length);
      final separatorIndex = rest.indexOf('=');
      if (separatorIndex == -1) {
        continue;
      }
      parsed.add(
        LdListCacheKeyPart(
          kind: 'filter',
          name: rest.substring(0, separatorIndex),
          value: rest.substring(separatorIndex + 1),
        ),
      );
      continue;
    }

    if (segment.startsWith('sort:')) {
      final rest = segment.substring('sort:'.length);
      final separatorIndex = rest.indexOf('=');
      if (separatorIndex == -1) {
        continue;
      }
      parsed.add(
        LdListCacheKeyPart(
          kind: 'sort',
          name: rest.substring(0, separatorIndex),
          value: rest.substring(separatorIndex + 1),
        ),
      );
      continue;
    }

    if (segment.startsWith('token:')) {
      parsed.add(
        LdListCacheKeyPart(
          kind: 'token',
          name: '',
          value: segment.substring('token:'.length),
        ),
      );
    }
  }

  return parsed;
}
