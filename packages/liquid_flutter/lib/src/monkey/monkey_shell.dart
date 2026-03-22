import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';

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
    this.layoutMode = LdMonkeyLayoutMode.auto,
    required this.routeState,
    required this.masterPage,
    required this.parseSelected,
    this.actions = const [],
    this.buildDetailPath,
    this.detailPanelFlex = 2,
    this.reflowBreakpoint = 600,
    this.repositoryBuilder,
    required this.pathParameterName,
    this.immediateViewSelection = false,
    this.allowMultipleSelection = true,
  });

  /// The item id for the route parameters, this will be used to disambiguate between multiple monkey patterns
  final String pathParameterName;

  /// The state of the route parameters, this will be used to get the selected items
  final GoRouterState routeState;

  /// The base path for the monkey pattern.
  final String basePath;

  /// Child route provided by navigator
  final Widget child;

  /// Whether multiple selection is allowed.
  final bool allowMultipleSelection;

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
  final double detailPanelFlex;

  /// Function to generate the detail path for a set of selected item IDs.
  ///
  /// This determines how selected items are represented in the URL path.
  /// For single selection, typically returns `/path/{id}`, for multiple
  /// selection, typically returns `/path/{id1,id2,id3}`.
  final String Function(Set<IdType> ids)? buildDetailPath;

  /// The master page to display in the master panel. This parameter is not used
  /// if the the effective layout is not side by side.
  final Widget masterPage;

  /// When true, selection immediately updates viewing and URL (old behavior).
  /// When false, selection and viewing are decoupled when selection controls
  /// are enabled or multiple items are selected.
  final bool immediateViewSelection;

  String? get routeSelection {
    return routeState.pathParameters["selected_$pathParameterName"];
  }

  /// Query parameters from the current route. Only includes parameters that start with the path parameter name.
  Map<String, String> get queryParameters => Map.fromEntries(
        routeState.uri.queryParameters.entries.where(
          (entry) => entry.key.startsWith(pathParameterName),
        ),
      );

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

  late final LdMonkeyShellState<T, IdType> _state = LdMonkeyShellState<T, IdType>(
    basePath: widget.basePath,
  );

  LdMonkeyShellState<T, IdType> get state => _state;

  /// Mutex to prevent race condition between state→URL and URL→state updates.
  /// When applying state to URL, we create a completer. URL changes that try
  /// to update state will check if this completer exists and skip the update
  /// if it does (meaning we're currently applying state to URL).
  Completer<void>? _urlUpdateMutex;

  @override
  void initState() {
    super.initState();

    _state.selectedItemsStream.listen((selectedItems) {
      _onStateChange();
    });

    _state.viewingItemsStream.listen((viewingItems) {
      _onStateChange();
    });

    // Apply initial URL state to shell state
    _onUrlChange();
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
          'No repository found in context. Please provide a repository '
          'builder or set a repository of type $T and id type $IdType in '
          'the context.',
        );
      }
    }

    // Apply query parameters to repository filters
    // Iterate over all filters to ensure disabled filters are properly cleared
    for (final filter in _repository!.filters.values) {
      final value = widget.queryParameters[filter.name];

      if (value != null) {
        _repository!.updateFilter(
          filter.name,
          (filter) => (filter as LdFilterOption<T, IdType>).marshalSerialized(value),
        );
      } else if (filter.isOn) {
        // Disable filter if it's not in query parameters but currently enabled
        _repository!.updateFilter(
          filter.name,
          (filter) => filter!.copyWith(isOn: false),
        );
      }
    }

    _setupSubscriptions();

    _onUrlChange();

    if (state.viewingItems.isNotEmpty) {
      await _repository!.initWithSelection(state.viewingItems);
    } else {
      await _repository!.fetchItemsAtOffset(0);
    }
  }

  Set<IdType> _parseSelected(String selected) {
    if (selected.isEmpty) {
      return {};
    }
    return widget.parseSelected(selected);
  }

  /// Callback when state changes - applies state to URL.
  void _onStateChange() async {
    if (!mounted || _repository == null) return;

    // If we're currently applying URL to state, skip this update to prevent loop
    if (_urlUpdateMutex != null) {
      return;
    }

    await _applyStateToUrl();
  }

  /// Callback when URL changes - applies URL to state.
  void _onUrlChange() {
    // If we're currently applying state to URL, skip this update to prevent loop
    if (_urlUpdateMutex != null) {
      return;
    }

    // Update showSelectionControls from query parameters
    final newShowSelectionControls = widget.queryParameters['${widget.pathParameterName}-select'] == 'true';
    if (newShowSelectionControls != state.showSelectionControls) {
      state.setShowSelectionControls(newShowSelectionControls);
    }
    final newSelectedIds = _parseSelected(
      widget.queryParameters['${widget.pathParameterName}-selection'] ?? "",
    );

    state.setSelectedItems(newSelectedIds);

    if (widget.routeSelection != "filters") {
      final newViewingIds = _parseSelected(widget.routeSelection ?? "");

      state.setViewingItems(newViewingIds);
    }
  }

  // Listen to updates from the repository only
  void _setupSubscriptions() {
    _filterSubscription = _repository!.filterStream.listen((_) {
      _onStateChange();
    });
    _sortSubscription = _repository!.sortStream.listen((_) {
      _onStateChange();
    });
    _repositoryUpdatedItemsSubscription = _repository!.updatedItems.listen(
      _onRepositoryUpdatedItems,
    );
  }

  void _onRepositoryUpdatedItems(LdPaginatorItem<T> item) {
    if (item.state == LdPaginatorItemState.deleted && item.value?.id != null) {
      state.setViewingItems(
        state.selectedItems.difference({item.value?.id!}),
      );
    }
  }

  /// Sets the visibility of selection controls and updates the URL.
  void setShowSelectionControls(bool showSelectionControls) {
    state.setShowSelectionControls(showSelectionControls);

    // Clear selection when hiding controls
    if (!showSelectionControls) {
      state.setSelectedItems({});
    }
  }

  /// Moves selection to viewing items, making the selected items visible in the detail view.
  Future<void> showSelection() async {
    if (state.selectedItems.isEmpty) return;
    state.setViewingItems(state.selectedItems);
  }

  @override
  void didUpdateWidget(LdMonkeyShell<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if URL changed (query parameters or route selection)
    final queryParamsChanged = !mapEquals(oldWidget.queryParameters, widget.queryParameters);
    final routeSelectionChanged = oldWidget.routeSelection != widget.routeSelection;

    if (queryParamsChanged || routeSelectionChanged) {
      _onUrlChange();
    }

    if (oldWidget.allowMultipleSelection != widget.allowMultipleSelection) {
      state.setAllowMultipleSelection(widget.allowMultipleSelection);
    }

    if (oldWidget.immediateViewSelection != widget.immediateViewSelection) {
      state.setImmediateViewSelection(widget.immediateViewSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _state.removeListener(_onStateChange);
    _filterSubscription.cancel();
    _sortSubscription.cancel();
    _repositoryUpdatedItemsSubscription.cancel();
  }

  // Whether we are currently showing the detail page.
  bool get _showingDetail {
    return widget.routeSelection != null;
  }

  /// Builds query parameters from repository and state.
  Map<String, String> _buildQueryParameters() {
    final queryParameters = <String, String>{};

    if (_repository != null) {
      final repoParams = _repository!.queryParameters;
      queryParameters.addAll(
        repoParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    // Add showSelectionControls query parameter
    if (state.showSelectionControls) {
      queryParameters['${widget.pathParameterName}-select'] = 'true';
    }

    // Add selection query parameter if decoupled

    final selectionParam = state.selectedItems.join('_');
    if (selectionParam.isNotEmpty) {
      queryParameters['${widget.pathParameterName}-selection'] = selectionParam;
    }

    return queryParameters;
  }

  LdMonkeyEffectiveLayoutMode _geteEffectiveLayoutMode(BoxConstraints constraints) {
    final wouldBeSideBySide = constraints.maxWidth > widget.reflowBreakpoint;
    final showingDetatil = _state.viewingItems.isNotEmpty;

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
      return widget.buildDetailPath!(ids);
    }
    return "${widget.basePath}/${ids.join("_")}";
  }

  // Update the selection in the URL.
  // Acquires a mutex to prevent URL→state updates during this operation.
  Future<void> _applyStateToUrl() async {
    if (!mounted || _repository == null) return;

    // Acquire mutex to prevent URL→state updates during URL change
    _urlUpdateMutex = Completer<void>();

    try {
      final router = GoRouter.of(context);
      final queryParameters = _buildQueryParameters();
      final detailPath = _serialiseDetailPath(state.viewingItems);
      final detailUri = Uri.parse(detailPath);
      final newUri = detailUri.replace(queryParameters: queryParameters);
      final currentUri = router.state.uri;

      if (currentUri.toString() == newUri.toString()) {
        return;
      }

      if (_state.viewingItems.isNotEmpty) {
        if (_showingDetail) {
          router.replace(newUri.toString());
        } else {
          router.push(newUri.toString());
        }
      } else {
        if (_showingDetail) {
          router.pop();
        } else {
          final baseUri = Uri.parse(widget.basePath);
          final baseUriWithParams = baseUri.replace(
            queryParameters: queryParameters,
          );
          router.replace(baseUriWithParams.toString());
        }
      }
    } finally {
      // Release mutex after URL update completes
      _urlUpdateMutex?.complete();
      _urlUpdateMutex = null;
    }
  }

  LdMonkeyEffectiveLayoutMode? _lastEffectiveLayout;

  Widget _buildInitialized(
    BuildContext context,
  ) {
    return Provider.value(
      value: LdMonkeySelection<T, IdType>(
        selection: state.selectedItems,
        viewing: state.viewingItems,
      ),
      updateShouldNotify: (previous, next) => previous != next,
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
                config: const LdListItemConfig(
                  trailing: LdListDefaultTrailingForward(),
                ),
                child: widget.child,
              ),
            );
          }

          return Provider.value(
              value: effectiveLayout,
              child: ListenableBuilder(
                  listenable: state,
                  builder: (context, _) {
                    final showDetail = _showingDetail;

                    return Provider.value(
                      value: LdDrawerState(isOpen: showDetail, isSideBySide: true),
                      child: LdMultiPanelLayout(
                        enableBorders: true,
                        visibleStartIndex: 0,
                        spacing: 0,
                        visibleEndIndex: showDetail ? 1 : 0,
                        widths: [PanelWidth.fill(), PanelWidth.fill(fillFlex: widget.detailPanelFlex)],
                        children: [
                          Provider.value(
                              value: showDetail ? LdDrawerSlot.drawer : LdDrawerSlot.body, child: widget.masterPage),
                          if (showDetail) Provider.value(value: LdDrawerSlot.body, child: widget.child) else Container()
                        ],
                      ),
                    );
                  }));
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdSubmit<bool, void>(
      config: LdSubmitConfig(
        autoTrigger: true,
        timeout: null,
        action: (_) async {
          await _initRepository();
          return true;
        },
      ),
      builder: LdSubmitCenteredBuilder<bool, void>(
        resultBuilder: (context, response, controller) => Provider.value(
          value: actions,
          child: ChangeNotifierProvider.value(
            value: state,
            child: Shortcuts(
              shortcuts: monkeyShortcuts,
              child: FocusScope(autofocus: true, child: _buildInitialized(context)),
            ),
          ),
        ),
      ),
    );
  }
}
