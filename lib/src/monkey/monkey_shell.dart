import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:liquid_flutter/src/monkey/monkey_shell_state.dart';

import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

const monkeyShortcuts = {
  SingleActivator(LogicalKeyboardKey.keyF, meta: true): SearchIntent(),
  SingleActivator(LogicalKeyboardKey.keyR, meta: true): RefreshIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
};

typedef LdMonkeyActions<T extends Identifiable<IdType>, IdType> = List<LdMonkeyAction<T, IdType>>;

/// The shell route that is wrapped around the master and detail pages.
class LdMonkeyShell<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyShell({
    super.key,
    required this.basePath,
    required this.child,
    required this.layoutMode,
    required this.masterPage,
    required this.parseSelected,
    required this.routeSelection,
    this.actions = const [],
    this.buildDetailPath,
    this.detailPanelFlex = 2,
    this.reflowBreakpoint = 600,
    this.repositoryBuilder,
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
  State<LdMonkeyShell<T, IdType>> createState() => _LdMonkeyShellState<T, IdType>();
}

class _LdMonkeyShellState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyShell<T, IdType>> {
  LdRepository<T, IdType>? _repository;

  late final StreamSubscription _filterSubscription;
  late final StreamSubscription _sortSubscription;
  late final StreamSubscription _repositoryUpdatedItemsSubscription;

  /// The actions that are available in the master and detail pages.
  List<LdMonkeyAction<T, IdType>> get actions => widget.actions;

  final LdMonkeyShellState<T, IdType> _state = LdMonkeyShellState<T, IdType>();

  LdMonkeyShellState<T, IdType> get state => _state;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initRepository() async {
    print('initRepository');
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

    if (state.selectedItems.isNotEmpty) {
      print('Got initital selection');
      await _repository!.initWithSelection(state.selectedItems);
    } else {
      await _repository!.fetchItemsAtOffset(0);
    }
  }

  /// Parses initial state from URL query parameters.
  void _parseInitialState() {
    final queryParameters = _getQueryParameters();
    state.setShowSelectionControls(queryParameters['showSelectionControls'] == 'true');

    if (widget.routeSelection != null) {
      print("Route selection: ${widget.routeSelection}");
      state.setSelectedItems(_parseSelected(widget.routeSelection ?? ""));
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
      if (item.state == LdPaginatorItemState.deleted && item.value?.id != null) {
        final id = item.value!.id! as IdType;
        state.setDeletedItems({
          id,
          ...state.deletedItems,
        });
        state.setSelectedItems(state.selectedItems.difference({item.value?.id!}));
      }
    });
    _state.addListener(() async {
      await Future.delayed(Duration.zero);
      _applyStateToUrl();
    });
  }

  /// Sets the selected items and updates the URL.
  void setSelectedItems(Set<IdType> selectedItems) {
    state.setSelectedItems(selectedItems);
    setState(() {});
    _applyStateToUrl();
  }

  /// Sets the visibility of selection controls and updates the URL.
  void setShowSelectionControls(bool showSelectionControls) {
    state.setShowSelectionControls(showSelectionControls);
    _updateQueryParameters();

    // Clear selection when hiding controls
    if (!showSelectionControls) {
      setSelectedItems({});
    }
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
    if (newShowSelectionControls != state.showSelectionControls) {
      state.setShowSelectionControls(newShowSelectionControls);
    }
  }

  // The route selection changed, we parse the ids and set the selected items.
  // This basically binds the router to the shell state.
  void _updateSelectionFromRoute() async {
    if (!mounted) return;

    await Future.delayed(Duration.zero);

    var newSelectedIds = _parseSelected(widget.routeSelection ?? "");
    setSelectedItems(newSelectedIds);
  }

  @override
  void dispose() {
    super.dispose();
    _filterSubscription.cancel();
    _sortSubscription.cancel();
    _repositoryUpdatedItemsSubscription.cancel();
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
      return widget.buildDetailPath!(state.selectedItems);
    }
    return widget.basePath + "/" + ids.join(",");
  }

  // Update the selection in the URL.
  void _applyStateToUrl() {
    if (!mounted) return;

    final router = GoRouter.of(context);
    final detailPath = _serialiseDetailPath(state.selectedItems);
    final queryParameters = <String, String>{};

    // Add repository query parameters
    final repoParams = _repository!.queryParameters;
    queryParameters.addAll(repoParams.map((key, value) => MapEntry(key, value.toString())));

    // Add showSelectionControls query parameter
    if (state.showSelectionControls) {
      queryParameters['showSelectionControls'] = 'true';
    }

    final uri = Uri.parse(detailPath);
    final newUri = uri.replace(queryParameters: queryParameters);

    final currentSelected = _parseSelected(widget.routeSelection ?? "");
    if (currentSelected == state.selectedItems) {
      return;
    }

    if (state.selectedItems.isNotEmpty) {
      if (_showingDetail) {
        router.replace(newUri.toString());
      } else {
        if (state.showSelectionControls) {
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
      value: LdMonkeySelection<IdType>(items: state.selectedItems),
      child: ListenableProvider.value(
        value: _repository!,
        child: LayoutBuilder(builder: (context, constraints) {
          final effectiveLayout = _geteEffectiveLayoutMode(constraints);

          if (effectiveLayout != _lastEffectiveLayout) {
            _lastEffectiveLayout = effectiveLayout;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              state.setEffectiveLayout(effectiveLayout);
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

                          return ListenableBuilder(
                              listenable: state,
                              builder: (context, _) {
                                final selectedItems = state.selectedItems;

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

    return Provider.value(
      value: actions,
      child: ChangeNotifierProvider.value(
        value: state,
        child: Shortcuts(
          shortcuts: monkeyShortcuts,
          child: FocusScope(autofocus: true, child: _buildInitialized(context)),
        ),
      ),
    );
  }
}
