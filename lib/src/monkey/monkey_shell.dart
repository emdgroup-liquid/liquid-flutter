import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';

import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

const monkeyShortcuts = {
  SingleActivator(LogicalKeyboardKey.keyF, meta: true): SearchIntent(),
  SingleActivator(LogicalKeyboardKey.keyR, meta: true): RefreshIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
};

/// The shell route that is wrapped around the master and detail pages.
class LdMonkeyShell<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyShell({
    super.key,
    required this.basePath,
    required this.child,
    required this.layoutMode,
    required this.masterPage,
    required this.parseSelected,
    this.actions = const [],
    this.buildDetailPath,
    this.detailPanelFlex = 2,
    this.reflowBreakpoint = 600,
    this.repositoryBuilder,
    this.routeSelection,
  });

  /// The base path for the monkey pattern.
  final String basePath;

  /// Child route provided by go_router
  final Widget child;

  /// The selection part of the route path, is usually a comma separated
  /// list of ids.
  final String? routeSelection;

  /// Builder function that creates a repository instance asynchronously.
  /// If not provided, the repository will be looked up in the context.
  /// If the repository is not found in the context, an exception is thrown.
  final Future<LdRepository<T, IdType>> Function(BuildContext context)? repositoryBuilder;

  /// Function to parse selected items in URL to [IdType].
  ///
  /// Used when converting URL parameters back to typed IDs for selection
  /// and navigation purposes. The default is to parse the selected items
  /// as a comma separated list of ids.
  /// If the id type is [int], the ids are parsed as integers.
  /// If the id type is [String], the ids are parsed as strings.
  /// If the id type is not supported, an exception is thrown.
  final Set<IdType> Function(String selected) parseSelected;

  /// Controls the layout behavior of the master-detail interface.
  final LdMonkeyLayoutMode layoutMode;

  /// The actions that are available in the master and detail pages.
  ///
  final List<LdMonkeyAction<T, IdType>> actions;

  /// Breakpoint width in pixels for responsive layout switching.
  ///
  /// When the screen width is above this value and [layoutMode] is [LdMonkeyLayoutMode.auto],
  /// the component will display in side-by-side mode. Defaults to 600 pixels.
  final double reflowBreakpoint;

  /// Flex ratio for the detail panel in side-by-side layout.
  ///
  /// Higher values give more space to the detail view. Defaults to 2.
  final int? detailPanelFlex;

  /// Function to generate the detail path for a set of selected item IDs.
  ///
  /// This determines how selected items are represented in the URL path.
  /// For single selection, typically returns `/path/{id}`, for multiple
  /// selection, typically returns `/path/{id1,id2,id3}`.
  final String Function(Set<IdType> ids)? buildDetailPath;

  /// The master page to display in the master panel. This parameter is not used
  /// if the the effective layout is not side by side.
  final Widget masterPage;

  @override
  State<LdMonkeyShell<T, IdType>> createState() => LdMonkeyShellState<T, IdType>();
}

class LdMonkeyShellState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyShell<T, IdType>>
    with ChangeNotifier {
  LdRepository<T, IdType>? _repository;

  late final StreamSubscription _filterSubscription;
  late final StreamSubscription _sortSubscription;
  late final StreamSubscription _repositoryUpdatedItemsSubscription;

  /// Internal state for selected items.
  Set<IdType> _selectedItems = {};
  Set<IdType> get selectedItems => _selectedItems;

  /// The actions that are available in the master and detail pages.
  List<LdMonkeyAction<T, IdType>> get actions => widget.actions;

  /// Internal state for showing selection controls.
  bool _showSelectionControls = false;
  bool get showSelectionControls => _showSelectionControls;

  /// Stream controller for broadcasting selection state changes.
  final _selectionStreamController = StreamController<Set<IdType>>.broadcast();
  Stream<Set<IdType>> get selectedItemsStream => _selectionStreamController.stream;

  /// Stream controller for broadcasting selection controls visibility changes.
  final _showSelectionControlsStreamController = StreamController<bool>.broadcast();
  Stream<bool> get showSelectionControlsStream => _showSelectionControlsStreamController.stream;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initRepository() async {
    if (widget.repositoryBuilder != null) {
      _repository = await widget.repositoryBuilder!(context);
    } else {
      final contextRepo = LdRepository.maybeOf<T, IdType>(context);
      if (contextRepo != null) {
        _repository = contextRepo;
      } else {
        throw Exception(
            'No repository found in context. Please provide a repository builder or set a repository of type $T and id type $IdType in the context.');
      }
    }
    _parseInitialState();
    _setupSubscriptions();

    if (_selectedItems.isNotEmpty) {
      await _repository!.initWithSelection(_selectedItems);
    } else {
      await _repository!.fetchItemsAtOffset(0);
    }
  }

  static LdMonkeyShellState<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool watch = false,
  }) {
    return watch ? context.watch<LdMonkeyShellState<T, IdType>>() : context.read<LdMonkeyShellState<T, IdType>>();
  }

  static LdMonkeyShellState<T, IdType>? maybeOf<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen ? context.watch<LdMonkeyShellState<T, IdType>>() : context.read<LdMonkeyShellState<T, IdType>>();
  }

  /// Parses initial state from URL query parameters.
  void _parseInitialState() {
    final queryParameters = _getQueryParameters();
    _showSelectionControls = queryParameters['showSelectionControls'] == 'true';

    if (widget.routeSelection != null) {
      _selectedItems = _parseSelected(widget.routeSelection ?? "");
    }
    if (queryParameters.isNotEmpty) {
      for (final filter in _repository!.filters.values) {
        final value = queryParameters[filter.name];

        if (value != null) {
          _repository!.updateFilter(
            filter.name,
            (filter) => (filter as LdFilterOption<T, IdType>).marshalSerialized(value),
          );
        }
      }
    }
    setState(() {});
    notifyListeners();
  }

  Set<IdType> _parseSelected(String selected) {
    if (selected.isEmpty) {
      return {};
    }
    return widget.parseSelected(selected);
  }

  // Listen to updates from the repository and route state
  void _setupSubscriptions() {
    _filterSubscription = _repository!.filterStream.listen((_) => _updateQueryParameters());
    _sortSubscription = _repository!.sortStream.listen((_) => _updateQueryParameters());
    _repositoryUpdatedItemsSubscription = _repository!.updatedItems.listen((item) {
      if (item.state == LdPaginatorItemState.deleted) {
        print("Deleted item ${item.value?.id}");
        setSelectedItems(_selectedItems.difference({item.value?.id}));
      }
    });
  }

  /// Sets the selected items and updates the URL.
  void setSelectedItems(Set<IdType> selectedItems) {
    print("setSelectedItems ${selectedItems.join(",")}");
    if (_selectedItems.join(",") == selectedItems.join(",")) {
      return;
    }
    _selectedItems = selectedItems;
    _selectionStreamController.add(_selectedItems);
    notifyListeners();
    setState(() {});
    _applyStateToUrl();
  }

  /// Sets the visibility of selection controls and updates the URL.
  void setShowSelectionControls(bool showSelectionControls) {
    if (_showSelectionControls == showSelectionControls) {
      return;
    }
    _showSelectionControls = showSelectionControls;
    _showSelectionControlsStreamController.add(_showSelectionControls);
    _updateQueryParameters();

    // Clear selection when hiding controls
    if (!showSelectionControls) {
      setSelectedItems({});
    }
    notifyListeners();
  }

  @override
  void didUpdateWidget(LdMonkeyShell<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.routeSelection != widget.routeSelection) {
      _updateSelectionFromRoute();
    }

    // Parse showSelectionControls from query params if they changed
    final queryParameters = _getQueryParameters();
    final newShowSelectionControls = queryParameters['showSelectionControls'] == 'true';
    if (newShowSelectionControls != _showSelectionControls) {
      _showSelectionControls = newShowSelectionControls;
      _showSelectionControlsStreamController.add(_showSelectionControls);
    }
  }

  // The route selection changed, we parse the ids and set the selected items.
  // This basically binds the router to the shell state.
  void _updateSelectionFromRoute() {
    if (!mounted) return;

    var newSelectedIds = _parseSelected(widget.routeSelection ?? "");

    //newSelectedIds = newSelectedIds.difference(widget.route.state.deletedItems);

    setSelectedItems(newSelectedIds);
  }

  @override
  void dispose() {
    super.dispose();
    _filterSubscription.cancel();
    _sortSubscription.cancel();
    _selectionStreamController.close();
    _showSelectionControlsStreamController.close();
    _repositoryUpdatedItemsSubscription.cancel();

    // When disposing we reset the selection, to avoid re-selecting when the
    // user returns
    _selectedItems = {};
  }

  // Whether we are currently showing the detail page.
  bool get _showingDetail {
    final router = GoRouter.of(context);
    final currentUri = router.state.pathParameters.containsKey("selected");
    return currentUri;
  }

  // Apply the query parameters to the route. Filters and sort options provide
  // the query parameters.
  void _updateQueryParameters() {
    final queryParameters = <String, String>{};

    final repoParams = _repository!.queryParameters;
    queryParameters.addAll(repoParams.map((key, value) => MapEntry(key, value.toString())));
  }

  // Get the query parameters from the router.
  Map<String, String> _getQueryParameters() {
    final router = GoRouter.of(context);
    final queryParameters = router.routerDelegate.currentConfiguration.uri.queryParameters;
    return queryParameters;
  }

  LdMonkeyEffectiveLayoutMode _geteEffectiveLayoutMode(BoxConstraints constraints) {
    final wouldBeSideBySide = constraints.maxWidth > widget.reflowBreakpoint;
    final showingDetatil = _showingDetail;

    return switch (widget.layoutMode) {
      LdMonkeyLayoutMode.sideBySide => LdMonkeyEffectiveLayoutMode.sideBySide,
      LdMonkeyLayoutMode.auto => switch (wouldBeSideBySide) {
          true => LdMonkeyEffectiveLayoutMode.sideBySide,
          false => switch (showingDetatil) {
              true => LdMonkeyEffectiveLayoutMode.detail,
              false => LdMonkeyEffectiveLayoutMode.master,
            },
        },
      LdMonkeyLayoutMode.neverSideBySide => switch (showingDetatil) {
          true => LdMonkeyEffectiveLayoutMode.detail,
          false => LdMonkeyEffectiveLayoutMode.master,
        },
    };
  }

  String _serialiseDetailPath(Set<IdType> ids) {
    if (widget.buildDetailPath != null) {
      return widget.buildDetailPath!(_selectedItems);
    }
    return widget.basePath + "/" + ids.join(",");
  }

  // Update the selection in the URL.
  void _applyStateToUrl() {
    if (!mounted) return;

    final router = GoRouter.of(context);
    final detailPath = _serialiseDetailPath(_selectedItems);
    final queryParameters = <String, String>{};

    // Add repository query parameters
    final repoParams = _repository!.queryParameters;
    queryParameters.addAll(repoParams.map((key, value) => MapEntry(key, value.toString())));

    // Add showSelectionControls query parameter
    if (_showSelectionControls) {
      queryParameters['showSelectionControls'] = 'true';
    }

    final uri = Uri.parse(detailPath);
    final newUri = uri.replace(queryParameters: queryParameters);

    final currentSelected = _parseSelected(widget.routeSelection ?? "");
    if (currentSelected == _selectedItems) {
      return;
    }

    if (_selectedItems.isNotEmpty) {
      if (_showingDetail) {
        router.replace(newUri.toString());
      } else {
        if (_showSelectionControls) {
          return;
        }

        router.push(newUri.toString());
      }
    } else {
      if (_showingDetail) {
        router.pop();
      } else {
        final baseUri = Uri.parse(widget.basePath);
        final baseUriWithParams = baseUri.replace(queryParameters: queryParameters);
        router.replace(baseUriWithParams.toString());
      }
    }
    setState(() {});
  }

  LdMonkeyEffectiveLayoutMode? _lastEffectiveLayout;

  Widget _buildInitialized(
    BuildContext context,
  ) {
    return Provider.value(
      value: LdMonkeySelection<IdType>(items: _selectedItems),
      child: ListenableProvider.value(
        value: _repository!,
        child: LayoutBuilder(builder: (context, constraints) {
          final effectiveLayout = _geteEffectiveLayoutMode(constraints);

          if (effectiveLayout != _lastEffectiveLayout) {
            _lastEffectiveLayout = effectiveLayout;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifyListeners();
            });
          }

          if (effectiveLayout != LdMonkeyEffectiveLayoutMode.sideBySide) {
            return Provider.value(
              value: effectiveLayout,
              child: LdListItemConfigProvider(
                const LdListItemConfig(
                  trailing: LdListDefaultTrailingForward(),
                ),
                widget.child,
              ),
            );
          }

          final theme = LdTheme.of(context);

          return Provider.value(
            value: effectiveLayout,
            child: LdScaffold(
              body: ColoredBox(
                color: theme.background,
                child: MultiSplitViewTheme(
                  data: MultiSplitViewThemeData(
                    dividerThickness: 2,
                  ),
                  child: MultiSplitView(
                    dividerBuilder: (context, index, resizable, dragging, highlighted, themeData) => VerticalDivider(
                      color: theme.border,
                      thickness: 1,
                      width: 1,
                    ),
                    initialAreas: [
                      Area(
                        flex: 1,
                        builder: (context, area) => widget.masterPage,
                      ),
                      Area(
                        flex: widget.detailPanelFlex?.toDouble() ?? 2.0,
                        builder: (context, area) {
                          // We need to wrap the child in a stream builder to ensure
                          // that the child is rebuilt when the state changes as the
                          // Area will not rebuild.

                          return StreamBuilder<Set<IdType>>(
                              stream: _selectionStreamController.stream,
                              initialData: _selectedItems,
                              builder: (context, snapshot) {
                                final selectedItems = snapshot.data!;

                                if (selectedItems.isNotEmpty && _showingDetail) {
                                  return widget.child;
                                }
                                return Center(
                                  child: LdMute(
                                    child: LdText.l(
                                      "Select something",
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_repository == null) {
      return LdSubmit<void, void>(
        config: LdSubmitConfig(
          autoTrigger: true,
          timeout: null,
          action: (_) async {
            await _initRepository();
          },
        ),
        builder: const LdSubmitCenteredBuilder<void, void>(),
      );
    }

    return ChangeNotifierProvider.value(
      value: this,
      child: Shortcuts(
        shortcuts: monkeyShortcuts,
        child: FocusScope(autofocus: true, child: _buildInitialized(context)),
      ),
    );
  }
}
