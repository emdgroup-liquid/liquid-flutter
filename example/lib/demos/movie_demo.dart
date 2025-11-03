import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/table_row.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Movie with Identifiable<int> {
  @override
  final int id;
  final String title;
  final String genre;
  final int rating; // 1-10
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
  _Movie(1, "Inception", "Sci-Fi", 9, DateTime.now()),
  _Movie(2, "The Godfather", "Crime", 10, DateTime.now()),
  _Movie(3, "Pulp Fiction", "Crime", 9, DateTime.now()),
  _Movie(4, "The Dark Knight", "Action", 10, DateTime.now()),
  _Movie(5, "Forrest Gump", "Drama", 8, DateTime.now()),
  _Movie(6, "Interstellar", "Sci-Fi", 8, DateTime.now()),
  _Movie(7, "The Matrix", "Sci-Fi", 9, DateTime.now()),
  _Movie(8, "Fight Club", "Drama", 8, DateTime.now()),
  _Movie(9, "The Shawshank Redemption", "Drama", 10, DateTime.now()),
  _Movie(10, "Gladiator", "Action", 8, DateTime.now()),
  _Movie(11, "Transformers: Revenge of the Fallen", "Action", 4, DateTime.now()),
  _Movie(12, "Cats", "Drama", 3, DateTime.now()),
  _Movie(13, "The Room", "Drama", 2, DateTime.now()),
  _Movie(14, "Batman & Robin", "Action", 3, DateTime.now()),
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
      max: 10,
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

final movieDemo = LdMonkey<_Movie, int>(
  path: "/movie-demo",
  allowMultipleSelection: true,
  presentationMode: MonkeyDetailVariant.dialog,
  layoutMode: MonkeyLayoutMode.neverSideBySide,
  showMultiSelectItems: true,
  parseId: (id) => int.parse(id),
  detailPath: (items) => "/movie-demo/${items.join(",")}",
  buildRepository: (context) => movieRepository,
  buildDetail: (context, item) => _MovieDetail(movie: item),
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<_Movie, int>(
      showSelectionControls: route.state.showSelectionControls,
      listBuilder: (context, scrollController, itemBuilder) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: LdList(
              shrinkWrap: true,
              separatorBuilder: (context) => LdDivider(),
              header: LdAutoBackground(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: LdText.l("Movie"),
                    ),
                    Expanded(
                      flex: 2,
                      child: LdText.l("Genre"),
                    ),
                    Expanded(
                      flex: 2,
                      child: LdText.l("Rating"),
                    ),
                  ],
                ).spaceM().padL(),
              ),
              paginator: route.repository,
              itemBuilder: itemBuilder,
              scrollController: scrollController,
              assumedItemHeight: 50,
            ))
          ],
        );
      },
      paginator: route.repository,
      initialSelectedItems: route.state.selectedItems,
      multiSelect: true,
      onSelectionChange: (selected) => onSelectionChange(selected),
      itemBuilder: (context, item, index) {
        return LdMonkeySingleShortcuts(
          item: item.value!.id,
          actions: route.actions,
          child: LdMonkeyContextMenu<_Movie, int>(
            item: item,
            child: LdListItemAnimation(
              state: item.state,
              child: LdTableRow(
                isOdd: index.isOdd,
                title: Text(
                  item.value!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.value!.genre),
                subContent: Text("Rating: ${item.value!.rating}/10"),
              ),
            ),
          ),
        );
      },
    );
  },
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
          final selectionItems = LdMonkeySelection.of<_Movie, int>(context).items;
          final route = LdMonkey.of<_Movie, int>(context);
          final item = await movieRepository.getById(selectionItems.first);

          final newItem = item.copyWith(
            id: movieData.length + 1,
            title: "${item.title} (copy)",
          );

          await movieRepository.create(newItem);

          await Future.delayed(const Duration(milliseconds: 1500));

          route.setSelectedItems({newItem.id});
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
          visibleInSplitView: false,
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.delete),
        SingleActivator(LogicalKeyboardKey.backspace),
      },
      config: (context) => LdSubmitConfig(
        action: (_) async {
          final selection = LdMonkeySelection.of<_Movie, int>(context);
          await movieRepository.deleteBatch(selection.items);
        },
      ),
      child: Text("Delete"),
      icon: Icon(LucideIcons.trash2),
    ),
    toggleSelectionControls<_Movie, int>(),
  ],
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
    return LdCard(
      child: LdAutoSpace(
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
            hint: "1-10",
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
                    final repo = LdMonkey.of<_Movie, int>(context).repository;
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
      ),
    ).padL();
  }
}
