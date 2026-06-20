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

String movieSearchText(MovieDemo movie) => '${movie.title} ${movie.genre}';

List<MovieDemo> applyMovieFilters(List<MovieDemo> data, Set<LdFilterOption<MovieDemo, int>> filters) {
  final filtered = data
      .where(
        (element) => filters.every((filter) {
          if (filter is LdFilterRange<MovieDemo, int>) {
            return filter.range.inRange(element.rating);
          }
          if (filter is LdFilterAnyOf<MovieDemo, int, String>) {
            if (!filter.isOn || filter.selectedValues.isEmpty) {
              return true;
            }
            return filter.selectedValues.contains(element.genre);
          }
          return true;
        }),
      )
      .toList();

  return ldFuzzySearchFromFilters<MovieDemo, int>(items: filtered, filters: filters, searchText: movieSearchText);
}

LdRepository<MovieDemo, int> movieRepository(BuildContext context) => LdRepository<MovieDemo, int>(
  pageSize: 5,
  getOffsetById: (parameters) async {
    await Future.delayed(const Duration(seconds: 1));

    final filtered = applyMovieFilters(movieData, parameters.filters);

    return filtered.indexWhere((element) => element.id == parameters.id);
  },
  getById: (id) async {
    return movieData.firstWhere((element) => element.id == id);
  },

  fetchListWithParameters: (FetchPageParameters<MovieDemo, int> parameters) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final filtered = applyMovieFilters(movieData, parameters.filters);
    return LdListPage<MovieDemo>(
      newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
      hasMore: parameters.offset + parameters.pageSize < filtered.length,
      total: filtered.length,
    );
  },
  deleteItem: (context, id) async {
    movieData.removeWhere((element) => element.id == id);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  deleteBatch: (context, ids) async {
    for (final id in ids) {
      movieData.removeWhere((element) => element.id == id);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  },
  updateItem: (context, id, newItem) async {
    final index = movieData.indexWhere((element) => element.id == id);
    newItem = newItem.copyWith(lastUpdate: DateTime.now());
    movieData[index] = newItem;
    await Future.delayed(const Duration(milliseconds: 500));
    return newItem;
  },
  createItem: (context, item) async {
    movieData.add(item!);
    return item;
  },
);

Future<List<LdFilterOption<MovieDemo, int>>> buildMovieFilters(BuildContext context) async {
  final genres = await loadMovieGenres(context);
  return [
    LdFilterSearch<MovieDemo, int, String>(
      name: 'search',
      label: (context) => 'Search',
      icon: (context) => const Icon(LucideIcons.search),
      hint: 'Search movies',
      getSuggestions: (searchText) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return ldFuzzySearchItems(
          items: movieData,
          query: searchText,
          searchText: movieSearchText,
        ).map((movie) => movie.title).toList();
      },
      buildSuggestion: (context, suggestion) {
        return LdListItem(
          title: Text(suggestion),
          onPressed: () {
            LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
          },
        );
      },
    ),
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
      icon: (context) => const Icon(LucideIcons.film),
      allValues: {for (final genre in genres) genre: (context) => Text(genre)},
    ),
  ];
}

Future<List<String>> loadMovieGenres(BuildContext context) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return movieData.map((movie) => movie.genre).toSet().toList()..sort();
}

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
                  await repo.update(context, widget.movie.value!.id, newMovie);
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
    id: 'duplicate',
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
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Duplicating"),
    onSubmit: (ctx) async {
      final item = await ctx.repository.getById(ctx.selectedIds.first);

      final newItem = item.copyWith(id: movieData.length + 1, title: "${item.title} (copy)");

      await ctx.repository.create(ctx.appContext, newItem);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (ctx.appContext.mounted) {
        ctx.updateViewing({newItem.id});
      }
    },
    child: Text("Duplicate"),
    icon: Icon(LucideIcons.copy),
  ),
  deleteAction<MovieDemo, int>(detailLocation: LdMonkeyActionLocation.detailSecondary),
  showSelectionControlsAction<MovieDemo, int>(),
];

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<MovieDemo, int>.scrollable(
      primaryAppBarConfig: LdAppBarConfig(title: Text("Movie"), debugName: "MovieDetailPage"),
      secondaryAppBarConfig: LdAppBarConfig(
        positionMode: LdAppBarPositionMode.top,
        borderMode: LdAppBarBorderMode.visible,
      ),
      buildDetail: (context, item) => _MovieDetail(movie: item),
    );
  }
}

class MovieMasterPage extends StatelessWidget {
  const MovieMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<MovieDemo, int>(
      filterBarConfig: [
        LdFilterChipConfig.range(filterName: 'rating'),
        LdFilterChipConfig.anyOf(
          filterName: 'genre',
          groupLabel: (context) => 'Genre',
          presentation: LdFilterChipChoicePresentation.inline,
          optionChild: (context, genre) => Text(genre as String),
        ),
      ],
      primaryAppBarConfig: LdAppBarConfig(title: LdText.h('Movies')),
      buildItem: (context, item) => LdListItem(
        title: Text(item.value!.title),
        subtitle: Text(item.value!.genre),
        trailing: LdTag(
          color: switch (item.value!.rating) {
            1 => LdTheme.of(context).error,
            2 || 3 => LdTheme.of(context).warning,
            _ => LdTheme.of(context).success,
          },
          child: Row(children: [Text("${item.value!.rating}"), Icon(LucideIcons.star)]).spaceXS(),
        ),
      ),
    );
  }
}
