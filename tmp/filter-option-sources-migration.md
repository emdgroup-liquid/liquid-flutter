# Migrating from `filterOptionSources` to async `filtersBuilder`

## What changed

The `filterOptionSources` API has been removed. Dynamic oneOf/anyOf option catalogs are now loaded inside `filtersBuilder` instead.

**Removed:**
- `filterOptionSources` parameter on `buildMonkeyRoutes`, `MonkeyRouteNode`, `LdMonkeyRouteScope`, `LdMonkeyRouteDefinitionsResolver`
- `LdMonkeyFilterOptionSource`, `ldMonkeyFilterOptionSourceOneOf`, `ldMonkeyFilterOptionSourceAnyOf`

**Unchanged:**
- `filtersBuilder` is still async and runs via `LdMonkeyRouteDefinitionsResolver`
- URL query hydration still happens automatically in `resolveMonkeyRouteDefinitions`
- `LdMonkeySortAndFilterState.refreshFilterDefinitions(context)` still re-fetches filters

## Migration steps

### 1. Remove `filterOptionSources` from route setup

**Before:**

```dart
buildMonkeyRoutes<MovieDemo, int>(
  filtersBuilder: (_) async => movieFilters,
  filterOptionSources: [
    ldMonkeyFilterOptionSourceAnyOf<MovieDemo, int, String>(
      filterName: 'genre',
      loadValues: loadMovieGenres,
      valueChild: (context, genre) => Text(genre),
    ),
  ],
  ...
);
```

**After:**

```dart
buildMonkeyRoutes<MovieDemo, int>(
  filtersBuilder: buildMovieFilters,
  ...
);
```

### 2. Move option loading into `filtersBuilder`

Instead of defining a filter skeleton with empty `allValues` and hydrating it separately, load options and build the full filter in one place.

**Before** (split across two APIs):

```dart
final movieFilters = [
  LdFilterRange<MovieDemo, int>(...),
  LdFilterAnyOf<MovieDemo, int, String>(
    name: 'genre',
    label: (context) => 'Genre',
    icon: (context) => const Icon(LucideIcons.film),
    allValues: {}, // populated later by filterOptionSources
  ),
];
```

**After** (single async builder):

```dart
Future<List<LdFilterOption<MovieDemo, int>>> buildMovieFilters(BuildContext context) async {
  final genres = await loadMovieGenres(context);
  return [
    LdFilterRange<MovieDemo, int>(...),
    LdFilterAnyOf<MovieDemo, int, String>(
      name: 'genre',
      label: (context) => 'Genre',
      icon: (context) => const Icon(LucideIcons.film),
      allValues: {
        for (final genre in genres)
          genre: (context) => Text(genre),
      },
    ),
  ];
}
```

The `loadValues` + `valueChild` pair from option sources maps directly to:
- `loadValues(context)` → `await` inside `filtersBuilder`
- `valueChild(context, value)` → the widget builder in `allValues`

### 3. Use `allValues` for oneOf/anyOf options

There is no `options` / `buildOption` shorthand. Build the map explicitly:

```dart
allValues: {
  for (final option in options)
    option: (context) => Text(option),
},
```

### 4. Keep static filters inline when they don't need async loading

If only some filters need dynamic options, you can still mix static and async:

```dart
filtersBuilder: (context) async {
  final categories = await api.fetchCategories(context);
  return [
    LdFilterBool<Task, int>(...),           // static
    LdFilterRange<Task, int>(...),          // static
    LdFilterOneOf<Task, int, String>(       // dynamic
      name: 'category',
      label: (context) => 'Category',
      icon: (context) => const Icon(LucideIcons.tag),
      allValues: {
        for (final category in categories)
          category: (context) => Text(category),
      },
    ),
  ];
},
```

Or extract a helper like `buildMovieFilters` when the list gets long.

## What you don't need to change

- **URL sync** — still automatic; no manual `marshalSerialized` in your builder
- **Filter chips bar** — `LdFilterChipsBar` configs still reference filters by `filterName`
- **Repository filtering** — still reads active filters from `LdMonkeySortAndFilterState`
- **Refresh** — `refreshFilterDefinitions` re-runs your `filtersBuilder`, so dynamic catalogs stay up to date

## Quick checklist

| Old API | New API |
|---------|---------|
| `filterOptionSources: [...]` | Remove entirely |
| `filtersBuilder: (_) async => staticFilters` | `filtersBuilder: (context) async { ... }` with full `allValues` |
| `ldMonkeyFilterOptionSourceOneOf(...)` | `LdFilterOneOf` with populated `allValues` in builder |
| `ldMonkeyFilterOptionSourceAnyOf(...)` | `LdFilterAnyOf` with populated `allValues` in builder |
| `loadValues: fetchFn` | `await fetchFn(context)` inside `filtersBuilder` |
| `valueChild: (ctx, v) => Text(v)` | `v: (ctx) => Text(v)` in `allValues` map |

## Reference implementation

See `apps/example/lib/demos/movie_demo.dart` (`buildMovieFilters`) and `apps/example/lib/router.dart` (`filtersBuilder: buildMovieFilters`).
