import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';
/*
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
    repository: null,
  );

  /// Stream controller for broadcasting state changes to subscribers.
  final _stateStream = StreamController<LdMonkeyDetailState<T, IdType>>.broadcast();

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
  /// When the screen width is above this value and [layoutMode] is [LdMonkeyLayoutMode.auto],
  /// the component will display in side-by-side mode. Defaults to 600 pixels.
  final double reflowBreakpoint;

  /// Flex ratio for the detail panel in side-by-side layout.
  ///
  /// Higher values give more space to the detail view. Defaults to 2.
  final int? detailFlex;

  /// Controls the layout behavior of the master-detail interface.
  ///
  /// - [LdMonkeyLayoutMode.auto]: Automatically switch based on screen size
  /// - [LdMonkeyLayoutMode.sideBySide]: Always use side-by-side layout
  /// - [LdMonkeyLayoutMode.neverSideBySide]: Always use stacked layout
  final LdMonkeyLayoutMode layoutMode;

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

  /// Builds the selectable list widget for the master view.
  ///
  /// This function receives the build context, current route, state, and selection change
  /// callback, allowing for custom list implementations while maintaining
  /// integration with the monkey's selection and state management.
  final LdSelectableList<T, IdType> Function(
    BuildContext context,
    LdMonkey<T, IdType> route,
    LdMonkeyDetailState<T, IdType> state,
    void Function(Set<IdType> selectedItems) onSelectionChanged,
  ) listBuilder;

  /// Creates a new [LdMonkey] instance.
  ///
  /// The [path], [detailPath], [buildDetail], [parseId], and
  /// [listBuilder] parameters are required for basic functionality.
  ///
  /// ## Parameters
  ///
  /// - [path]: The base route path for the master view
  /// - [detailPath]: Function to generate detail paths from selected IDs
  /// - [buildDetail]: Builder for detail content widgets
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
    required this.parseId,
    required this.listBuilder,
    this.reflowBreakpoint = 600,
    this.detailFlex = 2,
    this.allowMultipleSelection = true,
    this.showMultiSelectItems = false,
    this.wrapShell,
    this.layoutMode = LdMonkeyLayoutMode.auto,
    Set<IdType> Function(String selected)? parseSelected,
  }) : _parseSelected = parseSelected;

  /// The current repository instance for data operations.
  ///
  /// Throws an exception if the repository has not been initialized yet.
  /// The repository should be set by the shell using [setRepository].
  LdRepository<T, IdType> get repository => _state.repository!;

  /// Sets the repository instance.
  ///
  /// This method should be called by the shell when initializing the repository.
  void setRepository(LdRepository<T, IdType> repository) {
    _updateState(_state.copyWith(repository: repository));
  }

  /// The current state of the monkey component.
  ///
  /// Contains information about the repository instance and deleted items.
  LdMonkeyDetailState<T, IdType> get state => _state;

  /// Stream of state changes for reactive UI updates.
  ///
  /// Subscribe to this stream to receive notifications when the monkey's
  /// state changes (selection, repository updates, etc.).
  Stream<LdMonkeyDetailState<T, IdType>> get stateStream => _stateStream.stream;

  /// Updates the state when items are deleted.
  ///
  /// This method should be called by the shell when items are deleted.
  void markItemDeleted(IdType id) {
    _updateState(
      _state.copyWith(
        deletedItems: {
          ..._state.deletedItems,
          id,
        },
      ),
    );
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
  /// - [layoutMode] being [LdMonkeyLayoutMode.auto] or [LdMonkeyLayoutMode.sideBySide]
  /// - [layoutMode] not being [LdMonkeyLayoutMode.neverSideBySide]
  bool isSideBySide(Size size) {
    switch (layoutMode) {
      case LdMonkeyLayoutMode.auto:
        return size.width > reflowBreakpoint;
      case LdMonkeyLayoutMode.sideBySide:
        return true;
      case LdMonkeyLayoutMode.neverSideBySide:
        return false;
    }
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
}*/

/// Builds the routing configuration for a monkey component.
///
/// Creates a set of [GoRoute] instances that handle:
/// - Master list view at the base [basePath]
/// - Detail view at [basePath]/:selected
/// - Filter modal at [basePath]/filters
///
/// The routes are wrapped in a [ShellRoute] that provides the master-detail
/// layout and handles responsive behavior.
///
/// ## Parameters
///
/// - [basePath]: The base route path for the master view
/// - [route]: The [LdMonkey] instance containing configuration
/// - [repositoryBuilder]: Builder function that creates a repository instance asynchronously
/// - [layoutMode]: Controls the layout behavior of the master-detail interface
/// - [shellBuilder]: Optional wrapper widget that can be used to wrap the entire monkey shell
/// - [masterPageBuilder]: Optional builder for the master page (defaults to [LdMonkeyMasterPage])
/// - [detailPageBuilder]: Optional builder for the detail page (defaults to [LdMonkeyDetailPage])
/// - [filterModalBuilder]: Optional builder for the filter modal (defaults to [ldFilterModal])
///
/// Returns a list of routes that can be added to a [GoRouter] configuration.
List<RouteBase> buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>({
  required String basePath,
  required Widget detailPage,
  required Widget masterPage,
  required Future<LdRepository<T, IdType>> Function(BuildContext context) repositoryBuilder,
  required LdMonkeyLayoutMode layoutMode,
  required Set<IdType> Function(String selected) parseSelected,
  Widget Function(
    BuildContext context,
    GoRouterState state,
    Widget child,
  )? shellBuilder,
  LdModalRoute Function(BuildContext context)? filterModalBuilder,
  bool detailInDialog = false,
}) {
  return [
    GoRoute(
      name: "$basePath-filters",
      path: "$basePath/filters",
      pageBuilder: (context, state) => LdModalPage(
        builder: (context) => filterModalBuilder?.call(context) ?? ldFilterModal(context),
      ),
    ),
    ShellRoute(
      routes: [
        GoRoute(
          name: "$basePath-master",
          path: basePath,
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: masterPage,
          ),
          routes: [
            GoRoute(
              name: "$basePath-detail",
              path: "/:selected",
              pageBuilder: (context, goState) {
                final effectiveLayout = context.read<LdMonkeyEffectiveLayoutMode>();

                final page = detailPage;

                if (effectiveLayout == LdMonkeyEffectiveLayoutMode.detail) {
                  if (detailInDialog) {
                    return LdModalPage(
                      builder: (context) => LdModalRoute(context: context, pageBuilder: (context) => page),
                    );
                  }

                  return MaterialPage(
                    child: page,
                    key: goState.pageKey,
                  );
                }
                return NoTransitionPage<void>(
                  key: goState.pageKey,
                  child: page,
                );
              },
            ),
          ],
        ),
      ],
      builder: (context, state, child) => shellBuilder != null
          ? shellBuilder(context, state, child)
          : LdMonkeyShell(
              child: child,
              basePath: basePath,
              parseSelected: parseSelected,
              masterPage: masterPage,
              repositoryBuilder: repositoryBuilder,
              layoutMode: layoutMode,
              routeSelection: state.pathParameters['selected'],
              queryParameters: state.uri.queryParameters,
            ),
    )
  ];
}

/// Defines the layout behavior of the master-detail interface.
enum LdMonkeyLayoutMode {
  /// Automatically switch between side-by-side and stacked layouts based on screen size.
  auto,

  /// Always display in side-by-side layout regardless of screen size.
  sideBySide,

  /// Always display in stacked layout regardless of screen size.
  neverSideBySide,
}

enum LdMonkeyEffectiveLayoutMode {
  master,
  detail,
  sideBySide,
}
