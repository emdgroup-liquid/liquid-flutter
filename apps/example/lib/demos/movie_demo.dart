import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MovieDemo with Identifiable<int> {
  @override
  final int id;
  final String title;
  final String genre;
  final int rating; // 1-5
  final DateTime lastUpdate;
  MovieDemo(this.id, this.title, this.genre, this.rating, this.lastUpdate);

  MovieDemo copyWith({int? id, String? title, String? genre, int? rating, DateTime? lastUpdate}) => MovieDemo(
    id ?? this.id,
    title ?? this.title,
    genre ?? this.genre,
    rating ?? this.rating,
    lastUpdate ?? this.lastUpdate,
  );
}

var movieData = [
  MovieDemo(1, "Inception", "Sci-Fi", 5, DateTime.now()),
  MovieDemo(2, "The Godfather", "Crime", 5, DateTime.now()),
  MovieDemo(3, "Pulp Fiction", "Crime", 5, DateTime.now()),
  MovieDemo(4, "The Dark Knight", "Action", 5, DateTime.now()),
  MovieDemo(5, "Forrest Gump", "Drama", 4, DateTime.now()),
  MovieDemo(6, "Interstellar", "Sci-Fi", 4, DateTime.now()),
  MovieDemo(7, "The Matrix", "Sci-Fi", 5, DateTime.now()),
  MovieDemo(8, "Fight Club", "Drama", 4, DateTime.now()),
  MovieDemo(9, "The Shawshank Redemption", "Drama", 5, DateTime.now()),
  MovieDemo(10, "Gladiator", "Action", 4, DateTime.now()),
  MovieDemo(11, "Transformers: Revenge of the Fallen", "Action", 2, DateTime.now()),
  MovieDemo(12, "Cats", "Drama", 2, DateTime.now()),
  MovieDemo(13, "The Room", "Drama", 1, DateTime.now()),
  MovieDemo(14, "Batman & Robin", "Action", 2, DateTime.now()),
  MovieDemo(15, "Battlefield Earth", "Sci-Fi", 1, DateTime.now()),
];

LdRepository<MovieDemo, int> movieRepository(BuildContext context) => LdRepository<MovieDemo, int>(
  pageSize: 5,
  getOffsetById: (parameters, {filters, sortOptions}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Apply the same filtering and sorting logic as fetchListWithParameters
    final filtered = movieData
        .where(
          (element) => (filters ?? {}).all((filter) {
            if (filter is LdFilterRange<MovieDemo, int>) {
              return filter.range.inRange(element.rating);
            }
            if (filter is LdFilterAnyOf<MovieDemo, int, String>) {
              return filter.selectedValues.contains(element.genre);
            }
            return true;
          }),
        )
        .toList();

    for (final sortOption in sortOptions ?? []) {
      filtered.sort((a, b) => sortOption.optimisticSort(a, b));
    }

    return filtered.indexWhere((element) => element.id == parameters.id);
  },
  getById: (id) async {
    return movieData.firstWhere((element) => element.id == id);
  },

  fetchListWithParameters: (FetchPageParameters<MovieDemo, int> parameters) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final filtered = movieData
        .where(
          (element) => (parameters.filters).all((filter) {
            if (filter is LdFilterRange<MovieDemo, int>) {
              return filter.range.inRange(element.rating);
            }
            if (filter is LdFilterAnyOf<MovieDemo, int, String>) {
              return filter.selectedValues.contains(element.genre);
            }
            return true;
          }),
        )
        .toList();
    return LdListPage<MovieDemo>(
      newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
      hasMore: parameters.offset + parameters.pageSize < filtered.length,
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

final movieFilters = [
  LdFilterRange<MovieDemo, int>(
    name: "rating",
    label: (context) => "Rating",
    icon: (context) => const Icon(LucideIcons.star),
    min: 0,
    max: 5,
  ),
  LdFilterAnyOf<MovieDemo, int, String>(
    name: "genre",
    label: (context) => "Genre",
    icon: (context) => const Icon(LucideIcons.star),
    allValues: {
      "Sci-Fi": (context) => const Text("Sci-Fi"),
      "Action": (context) => const Text("Action"),
      "Drama": (context) => const Text("Drama"),
      "Crime": (context) => const Text("Crime"),
    },
  ),
];

class _MovieDetail extends StatefulWidget {
  final LdPaginatorItem<MovieDemo> movie;
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
        LdInput(label: "Title", hint: "Movie title", controller: _titleController),
        LdInput(label: "Genre", hint: "Movie genre", controller: _genreController),
        LdInput(label: "Rating", hint: "1-5", controller: _ratingController, keyboardType: TextInputType.number),
        LdText("Last updated: ${Jiffy.parseFromDateTime(widget.movie.value!.lastUpdate).fromNow()}"),
        Row(
          children: [
            LdSubmit<void, void>(
              config: LdSubmitConfig<void, void>(
                submitText: "Save",
                debugLabel: "Save Movie",
                action: (_) async {
                  final newMovie = MovieDemo(
                    widget.movie.value!.id,
                    _titleController.text,
                    _genreController.text,
                    int.tryParse(_ratingController.text) ?? 1,
                    widget.movie.value!.lastUpdate,
                  );
                  final repo = LdRepository.of<MovieDemo, int>(context);
                  await repo.update(widget.movie.value!.id, newMovie);
                },
              ),
            ),
          ],
        ).spaceM(),
      ],
    );
  }
}

List<LdMonkeyAction<MovieDemo, int>> movieActions = [
  showFilterContextMenu<MovieDemo, int>(),
  LdMonkeySubmitAction(
    tooltip: (context) => "Duplicate selection",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailSecondary,
        minSelectionCount: 1,
        maxSelectionCount: 1,
      ),
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, minSelectionCount: 1, maxSelectionCount: 1),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.keyD, meta: true)},
    config: (context) => LdSubmitConfig(
      action: (_) async {
        final selectionItems = LdMonkeySelection.adaptive<MovieDemo, int>(context);
        final repository = LdRepository.of<MovieDemo, int>(context);

        final item = await repository.getById(selectionItems.first);

        final newItem = item.copyWith(id: movieData.length + 1, title: "${item.title} (copy)");

        await repository.create(newItem);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          LdMonkeySelection.updateViewing<MovieDemo, int>(context, {newItem.id});
        }
      },
    ),
    child: Text("Duplicate"),
    icon: Icon(LucideIcons.copy),
  ),
  LdMonkeySubmitAction(
    tooltip: (context) => "Duplicate selection",
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailSecondary,
        minSelectionCount: 1,
        maxSelectionCount: null,
      ),
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, minSelectionCount: 1, maxSelectionCount: null),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterSecondary,
        minSelectionCount: 1,
        maxSelectionCount: null,
        layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
      ),
    },
    shortcutActivators: {SingleActivator(LogicalKeyboardKey.delete), SingleActivator(LogicalKeyboardKey.backspace)},
    config: (context) => LdSubmitConfig(
      action: (_) async {
        final selection = LdMonkeySelection.adaptive<MovieDemo, int>(context);
        final repository = LdRepository.of<MovieDemo, int>(context);
        await repository.deleteBatch(context: context, ids: selection);
      },
    ),
    child: Text("Delete"),
    icon: Icon(LucideIcons.trash2),
  ),
  toggleSelectionControls<MovieDemo, int>(),
];

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<MovieDemo, int>.scrollable(buildDetail: (context, item) => _MovieDetail(movie: item));
  }
}

class MovieMasterPage extends StatelessWidget {
  const MovieMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<MovieDemo, int>(
      appBar: LdMonkeyAppBar<MovieDemo, int>(location: LdMonkeyActionLocation.masterAppBar, title: Text("Movies")),
      buildItem: (context, item) => LdListItem(
        title: Text(item.value!.title),
        subtitle: Text(item.value!.genre),
        trailing: Row(children: [for (var i = 0; i < item.value!.rating; i++) Icon(LucideIcons.star)]),
      ),
    );
  }
}

extension All<T> on Set<T> {
  bool all(bool Function(T) test) {
    for (final element in this) {
      if (!test(element)) {
        return false;
      }
    }
    return true;
  }
}
