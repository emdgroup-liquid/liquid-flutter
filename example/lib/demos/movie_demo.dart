import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Movie with Identifiable<int> {
  @override
  final int id;
  final String title;
  final String genre;
  final int rating; // 1-5
  final DateTime lastUpdate;
  _Movie(this.id, this.title, this.genre, this.rating, this.lastUpdate);

  _Movie copyWith({
    int? id,
    String? title,
    String? genre,
    int? rating,
    DateTime? lastUpdate,
  }) =>
      _Movie(
        id ?? this.id,
        title ?? this.title,
        genre ?? this.genre,
        rating ?? this.rating,
        lastUpdate ?? this.lastUpdate,
      );
}

var movieData = [
  _Movie(1, "Inception", "Sci-Fi", 5, DateTime.now()),
  _Movie(2, "The Godfather", "Crime", 5, DateTime.now()),
  _Movie(3, "Pulp Fiction", "Crime", 5, DateTime.now()),
  _Movie(4, "The Dark Knight", "Action", 5, DateTime.now()),
  _Movie(5, "Forrest Gump", "Drama", 4, DateTime.now()),
  _Movie(6, "Interstellar", "Sci-Fi", 4, DateTime.now()),
  _Movie(7, "The Matrix", "Sci-Fi", 5, DateTime.now()),
  _Movie(8, "Fight Club", "Drama", 4, DateTime.now()),
  _Movie(9, "The Shawshank Redemption", "Drama", 5, DateTime.now()),
  _Movie(10, "Gladiator", "Action", 4, DateTime.now()),
  _Movie(11, "Transformers: Revenge of the Fallen", "Action", 2, DateTime.now()),
  _Movie(12, "Cats", "Drama", 2, DateTime.now()),
  _Movie(13, "The Room", "Drama", 1, DateTime.now()),
  _Movie(14, "Batman & Robin", "Action", 2, DateTime.now()),
  _Movie(15, "Battlefield Earth", "Sci-Fi", 1, DateTime.now()),
];

final movieRepository = LdRepository<_Movie, int>(
  singularItemTitle: "Movie",
  pluralItemTitle: "Movies",
  pageSize: 5,
  getOffsetById: (id, {filters, sortOptions}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Apply the same filtering and sorting logic as fetchListWithParameters
    final filtered =
        movieData.where((element) => filters?.every((filter) => filter.optimisticFilter(element)) ?? true).toList();

    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }

    return filtered.indexWhere((element) => element.id == id);
  },
  getById: (id) async {
    return movieData.firstWhere((element) => element.id == id);
  },
  filters: {
    LdFilterRange<_Movie, int>(
      name: "rating",
      label: (context) => "Rating",
      icon: (context) => const Icon(LucideIcons.star),
      min: 0,
      max: 5,
      optimisticFilter: (item, range) => range.inRange(item.rating),
    ),
    LdFilterAnyOf<_Movie, int, String>(
      name: "genre",
      label: (context) => "Genre",
      icon: (context) => const Icon(LucideIcons.star),
      allValues: {
        "Sci-Fi": (context) => const Text("Sci-Fi"),
        "Action": (context) => const Text("Action"),
        "Drama": (context) => const Text("Drama"),
        "Crime": (context) => const Text("Crime"),
      },
      optimisticFilter: (item, value) => value.contains(item.genre),
    ),
  },
  fetchListWithParameters: ({
    required int offset,
    required int pageSize,
    String? pageToken,
    Set<LdFilterOption<_Movie, int>>? filters,
    List<LdSortOption<_Movie, int>>? sortOptions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final filtered =
        movieData.where((element) => filters?.every((filter) => filter.optimisticFilter(element)) ?? true).toList();
    return LdListPage<_Movie>(
      newItems: filtered.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (int id) async {
    movieData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  deleteBatch: (ids) async {
    for (final id in ids) {
      movieData.removeWhere((element) => element.id == id);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  },
  updateItem: (id, newItem) async {
    final index = movieData.indexWhere((element) => element.id == id);
    newItem = newItem.copyWith(lastUpdate: DateTime.now());
    movieData[index] = newItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return newItem;
  },
  createItem: (item) async {
    movieData.add(item!);
    return item;
  },
);

class _MovieDetail extends StatefulWidget {
  final LdPaginatorItem<_Movie> movie;
  const _MovieDetail({required this.movie});
  @override
  State<_MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<_MovieDetail> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.movie.value?.title ?? "";
    _genreController.text = widget.movie.value?.genre ?? "";
    _ratingController.text = widget.movie.value?.rating.toString() ?? "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movie.value == null) {
      return LdCard(child: Center(child: LdLoader()));
    }
    return LdAutoSpace(
      children: [
        LdInput(
          label: "Title",
          hint: "Movie title",
          controller: _titleController,
        ),
        LdInput(
          label: "Genre",
          hint: "Movie genre",
          controller: _genreController,
        ),
        LdInput(
          label: "Rating",
          hint: "1-5",
          controller: _ratingController,
          keyboardType: TextInputType.number,
        ),
        LdText(
          "Last updated: ${Jiffy.parseFromDateTime(widget.movie.value!.lastUpdate).fromNow()}",
        ),
        Row(
          children: [
            LdSubmit<void, void>(
              config: LdSubmitConfig<void, void>(
                submitText: "Save",
                debugLabel: "Save Movie",
                action: (_) async {
                  final newMovie = _Movie(
                    widget.movie.value!.id,
                    _titleController.text,
                    _genreController.text,
                    int.tryParse(_ratingController.text) ?? 1,
                    widget.movie.value!.lastUpdate,
                  );
                  final repo = LdRepository.of<_Movie, int>(context);
                  await repo.update(
                    widget.movie.value!.id,
                    newMovie,
                  );
                },
              ),
            ),
          ],
        ).spaceM(),
      ],
    );
  }
}

class MovieShell extends StatelessWidget {
  final Widget child;
  final GoRouterState routeState;
  final String pathParameterName;
  final Widget masterPage;
  final String basePath;
  const MovieShell({
    super.key,
    required this.child,
    required this.routeState,
    required this.pathParameterName,
    required this.masterPage,
    required this.basePath,
  });
  @override
  Widget build(BuildContext context) {
    return LdMonkeyShell<_Movie, int>(
      pathParameterName: pathParameterName,
      routeState: routeState,
      basePath: basePath,
      layoutMode: LdMonkeyLayoutMode.neverSideBySide,
      masterPage: masterPage,
      parseSelected: (selected) => selected.split(",").map(int.parse).toSet(),
      repositoryBuilder: (context) async => movieRepository,
      actions: [
        toggleFilters<_Movie, int>(),
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.detailSecondary,
              minSelectionCount: 1,
              maxSelectionCount: 1,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: 1,
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.keyD, meta: true),
          },
          config: (context) => LdSubmitConfig(
            action: (_) async {
              final selectionItems = LdMonkeySelection.adaptive<_Movie, int>(context);
              final shellState = LdMonkeyShellState.of<_Movie, int>(context);
              final item = await movieRepository.getById(selectionItems.first);

              final newItem = item.copyWith(
                id: movieData.length + 1,
                title: "${item.title} (copy)",
              );

              await movieRepository.create(newItem);

              await Future.delayed(const Duration(milliseconds: 1500));

              shellState.setSelectedItems({newItem.id});
            },
          ),
          child: Text("Duplicate"),
          icon: Icon(LucideIcons.copy),
        ),
        LdMonkeySubmitAction(
          visibility: {
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.detailSecondary,
              minSelectionCount: 1,
              maxSelectionCount: null,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.context,
              minSelectionCount: 1,
              maxSelectionCount: null,
            ),
            LdMonkeyActionVisibility(
              location: LdMonkeyActionLocation.masterSecondary,
              minSelectionCount: 1,
              maxSelectionCount: null,
              layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
            ),
          },
          shortcutActivators: {
            SingleActivator(LogicalKeyboardKey.delete),
            SingleActivator(LogicalKeyboardKey.backspace),
          },
          config: (context) => LdSubmitConfig(
            action: (_) async {
              final selection = LdMonkeySelection.adaptive<_Movie, int>(context);
              await movieRepository.deleteBatch(selection);
            },
          ),
          child: Text("Delete"),
          icon: Icon(LucideIcons.trash2),
        ),
        toggleSelectionControls<_Movie, int>(),
      ],
      child: child,
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<_Movie, int>.scrollable(
      primaryAppBar: LdMonkeyAppBar<_Movie, int>(
        location: LdMonkeyActionLocation.detailAppBar,
        title: Text("Movie"),
        debugName: "MovieDetailPage",
      ),
      buildDetail: (context, item) => _MovieDetail(movie: item),
    );
  }
}

class MovieMasterPage extends StatelessWidget {
  const MovieMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<_Movie, int>(
      appBar: LdMonkeyAppBar<_Movie, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Movies"),
      ),
      buildItem: (context, item) => LdListItem(
        title: Text(item.value!.title),
        subtitle: Text(item.value!.genre),
        trailing: Row(children: [
          for (var i = 0; i < item.value!.rating; i++) Icon(LucideIcons.star),
        ]),
      ),
    );
  }
}
