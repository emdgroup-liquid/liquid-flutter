import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A master-detail navigation component that provides a responsive layout for managing
/// lists of items with detailed views.
///
/// The [LdMonkey] widget implements a master-detail pattern that automatically adapts
/// to different screen sizes and provides a seamless navigation experience between
/// a list view (master) and detail view. It supports:
///
/// - **Responsive Layout**: Automatically switches between side-by-side and stacked
///   layouts based on screen size and configuration
/// - **Selection Management**: Supports single and multiple item selection with
///   visual feedback and state management
/// - **Pagination**: Integrates with [LdRepository] for efficient data loading
/// - **Actions**: Configurable actions that can be placed in different locations
///   (app bar, context menu, etc.) with visibility rules
/// - **Filtering & Sorting**: Built-in support for data filtering and sorting
/// - **Modal Support**: Can display details in modals or full pages
///
/// ## Type Parameters
///
/// - `T`: The type of items being displayed, must extend [Identifiable<IdType>]
/// - `IdType`: The type of the unique identifier for items
class LdMonkey<T extends Identifiable<IdType>, IdType> {
  /// Internal state management for the monkey component.
  var _state = LdMonkeyDetailState<T, IdType>(
    showSelectionControls: false,
    selectedItems: {},
    repository: null,
  );

  /// Stream controller for broadcasting state changes to subscribers.
  final _stateStream = StreamController<LdMonkeyDetailState<T, IdType>>.broadcast();

  /// Factory function that creates a repository instance for the given context.
  ///
  /// The repository handles data fetching, pagination, filtering, and CRUD operations
  /// for the items displayed in the monkey component.
  final LdRepository<T, IdType> Function(BuildContext context) buildRepository;

  /// Optional wrapper widget that can be used to wrap the entire monkey shell.
  ///
  /// This is useful for adding custom layouts, navigation drawers, or other
  /// UI elements that should surround the master-detail interface.
  final Widget Function(BuildContext context, Widget child)? wrapShell;

  /// The base path for the master view route.
  ///
  /// This path will be used to generate the master list route and as a prefix
  /// for detail routes.
  final String path;

  /// Function to parse a string ID into the expected [IdType].
  ///
  /// Used when converting URL parameters back to typed IDs for selection
  /// and navigation purposes.
  final IdType Function(String id) parseId;

  /// Function to generate the detail path for a set of selected item IDs.
  ///
  /// This determines how selected items are represented in the URL path.
  /// For single selection, typically returns `/path/{id}`, for multiple
  /// selection, typically returns `/path/{id1,id2,id3}`.
  final String Function(Set<IdType> ids) detailPath;

  /// Optional custom parser for converting URL parameters to selected item sets.
  ///
  /// If not provided, uses the default comma-separated parsing with [parseId].
  final Set<IdType> Function(String selected)? _parseSelected;

  /// Breakpoint width in pixels for responsive layout switching.
  ///
  /// When the screen width is above this value and [layoutMode] is [MonkeyLayoutMode.auto],
  /// the component will display in side-by-side mode. Defaults to 600 pixels.
  final double reflowBreakpoint;

  /// Flex ratio for the detail panel in side-by-side layout.
  ///
  /// Higher values give more space to the detail view. Defaults to 2.
  final int? detailFlex;

  /// Determines how detail content is presented.
  ///
  /// - [MonkeyDetailVariant.page]: Full page navigation
  /// - [MonkeyDetailVariant.dialog]: Modal dialog presentation
  final MonkeyDetailVariant presentationMode;

  /// Controls the layout behavior of the master-detail interface.
  ///
  /// - [MonkeyLayoutMode.auto]: Automatically switch based on screen size
  /// - [MonkeyLayoutMode.sideBySide]: Always use side-by-side layout
  /// - [MonkeyLayoutMode.neverSideBySide]: Always use stacked layout
  final MonkeyLayoutMode layoutMode;

  /// Whether multiple items can be selected simultaneously.
  ///
  /// When true, users can select multiple items using checkboxes or
  /// keyboard shortcuts. When false, only single selection is allowed.
  final bool allowMultipleSelection;

  /// Whether to show multi-select UI elements (checkboxes, selection controls).
  ///
  /// This controls the visual selection interface, independent of
  /// [allowMultipleSelection] which controls the actual selection behavior.
  final bool showMultiSelectItems;

  /// Builds the detail content widget for a selected item.
  ///
  /// This function is called whenever an item is selected and the detail
  /// view needs to be rendered. The [LdPaginatorItem] contains the item
  /// data and loading state information.
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;

  /// The actions that are available in the master and detail pages.
  ///
  /// Actions can be placed in different locations (app bar, context menu, etc.)
  /// and have configurable visibility rules based on selection state, filters,
  /// and layout mode.
  final List<LdMonkeyAction<T, IdType>> actions;

  /// Builds the selectable list widget for the master view.
  ///
  /// This function receives the current route, state, and selection change
  /// callback, allowing for custom list implementations while maintaining
  /// integration with the monkey's selection and state management.
  final LdSelectableList<T, IdType> Function(
    LdMonkey<T, IdType> route,
    LdMonkeyDetailState<T, IdType> state,
    void Function(Set<IdType> selectedItems) onSelectionChanged,
  ) listBuilder;

  /// Creates a new [LdMonkey] instance.
  ///
  /// The [path], [detailPath], [buildDetail], [buildRepository], [parseId], and
  /// [listBuilder] parameters are required for basic functionality.
  ///
  /// ## Parameters
  ///
  /// - [path]: The base route path for the master view
  /// - [detailPath]: Function to generate detail paths from selected IDs
  /// - [buildDetail]: Builder for detail content widgets
  /// - [buildRepository]: Factory for creating data repositories
  /// - [parseId]: Function to convert string IDs to typed IDs
  /// - [listBuilder]: Builder for the selectable list widget
  /// - [reflowBreakpoint]: Screen width breakpoint for responsive layout (default: 600)
  /// - [detailFlex]: Flex ratio for detail panel in side-by-side mode (default: 2)
  /// - [actions]: List of available actions (default: empty)
  /// - [allowMultipleSelection]: Whether multiple selection is allowed (default: true)
  /// - [showMultiSelectItems]: Whether to show multi-select UI (default: false)
  /// - [wrapShell]: Optional wrapper for the entire component
  /// - [presentationMode]: How details are presented (default: page)
  /// - [layoutMode]: Layout behavior (default: auto)
  /// - [parseSelected]: Custom parser for URL parameters (optional)
  LdMonkey({
    required this.path,
    required this.detailPath,
    required this.buildDetail,
    required this.buildRepository,
    required this.parseId,
    required this.listBuilder,
    this.reflowBreakpoint = 600,
    this.detailFlex = 2,
    this.actions = const [],
    this.allowMultipleSelection = true,
    this.showMultiSelectItems = false,
    this.wrapShell,
    this.presentationMode = MonkeyDetailVariant.page,
    this.layoutMode = MonkeyLayoutMode.auto,
    Set<IdType> Function(String selected)? parseSelected,
  }) : _parseSelected = parseSelected;

  /// The current repository instance for data operations.
  ///
  /// Throws an exception if the repository has not been initialized yet.
  /// Use [initRepository] to initialize the repository before accessing this getter.
  LdRepository<T, IdType> get repository => _state.repository!;

  /// The current state of the monkey component.
  ///
  /// Contains information about selected items, selection controls visibility,
  /// and the repository instance.
  LdMonkeyDetailState<T, IdType> get state => _state;

  /// Stream of state changes for reactive UI updates.
  ///
  /// Subscribe to this stream to receive notifications when the monkey's
  /// state changes (selection, repository updates, etc.).
  Stream<LdMonkeyDetailState<T, IdType>> get stateStream => _stateStream.stream;

  /// Builds the routing configuration for the monkey component.
  ///
  /// Creates a set of [GoRoute] instances that handle:
  /// - Master list view at the base [path]
  /// - Detail view at [path]/:selected
  /// - Filter modal at [path]/filters
  ///
  /// The routes are wrapped in a [ShellRoute] that provides the master-detail
  /// layout and handles responsive behavior.
  ///
  /// Returns a list of routes that can be added to a [GoRouter] configuration.
  List<RouteBase> buildRoute() {
    return [
      GoRoute(
        name: "$path-filters",
        path: "$path/filters",
        pageBuilder: (context, state) => LdModalPage(
          key: state.pageKey,
          modal: ldFilterModal(context, this),
        ),
      ),
      ShellRoute(
        routes: [
          GoRoute(
              name: "$path-master",
              path: path,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                    key: state.pageKey,
                    child: LdMonkeyMasterPage(
                      route: this,
                    ),
                  ),
              routes: [
                GoRoute(
                    name: "$path-detail",
                    path: "/:selected",
                    pageBuilder: (context, state) {
                      final effectivePresentationMode = LdMonkeyContext.of<T, IdType>(context);

                      final page = Provider.value(
                        value: effectivePresentationMode,
                        child: Provider.value(
                          value: this,
                          child: LdMonkeyDetailPage<T, IdType>(),
                        ),
                      );

                      if (!effectivePresentationMode.isSideBySide) {
                        if (effectivePresentationMode.detailInDialog) {
                          return LdModalPage(
                            key: state.pageKey,
                            modal: ldMonkeyDetailModal(this),
                          );
                        }

                        return MaterialPage(
                          child: page,
                          key: state.pageKey,
                        );
                      }
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: page,
                      );
                    }),
              ]),
        ],
        builder: (context, state, child) => LdWrapConditional(
          condition: wrapShell != null,
          builder: (context, child) => wrapShell!.call(context, child),
          child: LdMonkeyShell(
            child: child,
            route: this,
            routeSelection: state.pathParameters['selected'],
          ),
        ),
      )
    ];
  }

  /// Initializes the repository and sets up initial data loading.
  ///
  /// This method gets called by the monkey shell.
  ///
  /// ## Parameters
  ///
  /// - [context]: The build context for creating the repository
  /// - [initialSelection]: Set of item IDs to pre-select
  /// - [queryParameters]: URL query parameters to apply as filters
  ///
  /// ## Behavior
  ///
  /// 1. Creates a repository instance using [buildRepository]
  /// 2. If [initialSelection] is provided, initializes with those items
  /// 3. Otherwise, fetches items starting from offset 0
  /// 4. Applies any filter values from [queryParameters]
  /// 5. Sets up listeners for item updates and deletions
  Future<void> initRepository(
    BuildContext context,
    Set<IdType> initialSelection,
    Map<String, String> queryParameters,
  ) async {
    _updateState(
      _state.copyWith(repository: buildRepository(context)),
    );

    if (initialSelection.isNotEmpty) {
      await repository.initWithSelection(initialSelection);
    } else {
      await repository.fetchItemsAtOffset(0);
    }

    if (queryParameters.isNotEmpty) {
      for (final filter in repository.filters.values) {
        final value = queryParameters[filter.name];

        if (value != null) {
          repository.updateFilter<LdFilterOption<T, IdType>>(filter.name, (filter) => filter.marshalSerialized(value));
        }
      }
    }

    repository.updatedItems.listen((item) async {
      if (item.state == LdPaginatorItemState.deleted && item.value != null) {
        _updateState(
          _state.copyWith(
            deletedItems: {
              ..._state.deletedItems,
              item.value!.id,
            },
            selectedItems: _state.selectedItems.where((id) => id != item.value!.id).toSet(),
          ),
        );
      }
    });
  }

  /// Determines if the component should display in side-by-side layout.
  ///
  /// ## Parameters
  ///
  /// - [size]: The current screen size
  ///
  /// ## Returns
  ///
  /// `true` if the component should display in side-by-side mode, `false` otherwise.
  ///
  /// The decision is based on:
  /// - Screen width being greater than [reflowBreakpoint]
  /// - [layoutMode] being [MonkeyLayoutMode.auto] or [MonkeyLayoutMode.sideBySide]
  /// - [layoutMode] not being [MonkeyLayoutMode.neverSideBySide]
  bool isSideBySide(Size size) {
    return (size.width > reflowBreakpoint && layoutMode == MonkeyLayoutMode.auto) &&
        layoutMode != MonkeyLayoutMode.neverSideBySide;
  }

  /// Parses a string representation of selected items into a set of IDs.
  ///
  /// ## Parameters
  ///
  /// - [selected]: String representation of selected item IDs
  ///
  /// ## Returns
  ///
  /// A set of parsed [IdType] values representing the selected items.
  ///
  /// ## Behavior
  ///
  /// - If a custom [parseSelected] function was provided, uses that
  /// - If [selected] is empty, returns an empty set
  /// - Otherwise, splits by comma and parses each ID using [parseId]
  Set<IdType> parseSelected(String selected) {
    if (_parseSelected != null) {
      return _parseSelected!(selected);
    }
    if (selected.isEmpty) {
      return {};
    }
    return selected.split(",").map(parseId).toSet();
  }

  /// Updates the set of currently selected items.
  ///
  /// ## Parameters
  ///
  /// - [selectedItems]: The new set of selected item IDs
  ///
  /// ## Behavior
  ///
  /// - Compares the new selection with the current selection to avoid unnecessary updates
  /// - Updates the internal state and notifies listeners via [stateStream]
  /// - Triggers UI updates for selection-dependent components
  void setSelectedItems(Set<IdType> selectedItems) {
    if (selectedItems.join(",") == _state.selectedItems.join(",")) {
      return;
    }

    _updateState(
      _state.copyWith(selectedItems: selectedItems),
    );
  }

  /// Controls the visibility of selection controls (checkboxes, etc.).
  ///
  /// ## Parameters
  ///
  /// - [showSelectionControls]: Whether to show selection UI elements
  ///
  /// ## Behavior
  ///
  /// - When `true`, shows selection controls and maintains current selection
  /// - When `false`, hides selection controls and clears all selections
  /// - Updates the internal state and notifies listeners
  void setShowSelectionControls(bool showSelectionControls) {
    _updateState(
      _state.copyWith(
        showSelectionControls: showSelectionControls,
        selectedItems: showSelectionControls ? _state.selectedItems : {},
      ),
    );
  }

  /// Internal method to update the component state and notify listeners.
  ///
  /// ## Parameters
  ///
  /// - [state]: The new state to set
  ///
  /// ## Behavior
  ///
  /// - Updates the internal state variable
  /// - Broadcasts the new state to all [stateStream] subscribers
  void _updateState(LdMonkeyDetailState<T, IdType> state) {
    _state = state;
    _stateStream.add(state);
  }

  /// Retrieves the [LdMonkey] instance from the widget tree.
  ///
  /// ## Parameters
  ///
  /// - [context]: The build context to search for the monkey instance
  /// - [watch]: Whether to watch for changes (default: false)
  ///
  /// ## Returns
  ///
  /// The [LdMonkey] instance from the nearest provider in the widget tree.
  ///
  /// ## Behavior
  ///
  /// - If [watch] is `true`, returns a watched instance that rebuilds on changes
  /// - If [watch] is `false`, returns a read-only instance
  /// - Throws an exception if no monkey instance is found in the tree
  static LdMonkey<T, IdType> of<T extends Identifiable<IdType>, IdType>(BuildContext context, {bool watch = false}) {
    return watch ? context.watch<LdMonkey<T, IdType>>() : context.read<LdMonkey<T, IdType>>();
  }
}

/// Defines how detail content is presented to the user.
enum MonkeyDetailVariant {
  /// Detail content is shown as a full page with navigation.
  page,

  /// Detail content is shown in a modal dialog.
  dialog,
}

/// Defines the layout behavior of the master-detail interface.
enum MonkeyLayoutMode {
  /// Automatically switch between side-by-side and stacked layouts based on screen size.
  auto,

  /// Always display in side-by-side layout regardless of screen size.
  sideBySide,

  /// Always display in stacked layout regardless of screen size.
  neverSideBySide,
}
