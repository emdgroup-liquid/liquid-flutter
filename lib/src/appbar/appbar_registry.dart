import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';

class LdAppBarRegistryKey {
  final int order;
  final String? debugName;
  const LdAppBarRegistryKey({
    required this.order,
    this.debugName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LdAppBarRegistryKey && runtimeType == other.runtimeType && order == other.order;

  @override
  int get hashCode => order.hashCode;

  @override
  String toString() => 'LdAppBarRegistryKey(order: $order, debugName: $debugName)';
}

class AppBarInfo {
  final LdAppBarPosition position;
  final double innerHeight;
  final double verticalMargin;
  final double offset;
  final bool scrollUnder;
  final bool willHide;

  const AppBarInfo({
    required this.position,
    required this.innerHeight,
    required this.verticalMargin,
    required this.offset,
    required this.scrollUnder,
    required this.willHide,
  });

  factory AppBarInfo.initial(LdAppBarPosition position) {
    return AppBarInfo(
      position: position,
      innerHeight: 0.0,
      verticalMargin: 0.0,
      offset: 0.0,
      scrollUnder: false,
      willHide: false,
    );
  }

  AppBarInfo copyWith({
    LdAppBarPosition? position,
    double? innerHeight,
    bool? willHide,
    double? verticalMargin,
    double? offset,
    bool? scrollUnder,
  }) {
    return AppBarInfo(
      position: position ?? this.position,
      innerHeight: innerHeight ?? this.innerHeight,
      verticalMargin: verticalMargin ?? this.verticalMargin,
      offset: offset ?? this.offset,
      scrollUnder: scrollUnder ?? this.scrollUnder,
      willHide: willHide ?? this.willHide,
    );
  }

  @override
  String toString() => 'AppBarInfo(p: $position, iH: $innerHeight, vm: $verticalMargin, o: $offset, sU: $scrollUnder)';

  double get effectiveHeight => innerHeight + verticalMargin - offset;
}

class _AppBarRegistryEntryData extends InheritedWidget {
  final LdAppBarRegistryKey registryKey;

  const _AppBarRegistryEntryData({
    required super.child,
    required this.registryKey,
  });

  @override
  bool updateShouldNotify(_AppBarRegistryEntryData oldWidget) {
    return registryKey != oldWidget.registryKey;
  }
}

extension AppBarRegistryEntryExtension on BuildContext {
  LdAppBarRegistryKey? maybeAppBarRegistryKey() {
    final data = dependOnInheritedWidgetOfExactType<_AppBarRegistryEntryData>();
    return data?.registryKey;
  }

  LdAppBarRegistryKey appBarRegistryKey() {
    final key = maybeAppBarRegistryKey();
    assert(key != null, 'No LdAppBarRegistryEntry found in context');
    return key!;
  }
}

class LdAppBarRegistryEntry extends StatefulWidget {
  final Widget child;
  final String? debugName;
  final int order;

  const LdAppBarRegistryEntry({
    super.key,
    required this.child,
    this.debugName,
    this.order = 0,
  });

  @override
  State<LdAppBarRegistryEntry> createState() => _LdAppBarRegistryEntryState();
}

class _LdAppBarRegistryEntryState extends State<LdAppBarRegistryEntry> {
  LdAppBarRegistryKey? _key;
  late final _registry = AppBarRegistry.maybeStateOf(context)!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _key ??= _registry.registerAppBar(widget.order, debugName: widget.debugName);
  }

  @override
  void dispose() {
    if (_key != null) {
      _registry.unregisterAppBar(_key!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_key == null) {
      // Registry not found, return child without providing key
      return widget.child;
    }
    return _AppBarRegistryEntryData(
      registryKey: _key!,
      child: widget.child,
    );
  }
}

class AppBarRegistry extends StatefulWidget {
  final Widget Function(BuildContext context, List<Widget> appBars) builder;
  final List<Widget> appBars;

  const AppBarRegistry({
    super.key,
    required this.builder,
    this.appBars = const [],
  });

  static AppBarRegistryState? maybeStateOf(BuildContext context) {
    final state = context.findAncestorStateOfType<AppBarRegistryState>();
    return state;
  }

  @override
  State<AppBarRegistry> createState() => AppBarRegistryState();
}

class AppBarRegistryState extends ChangeNotifyingState<AppBarRegistry> {
  final _appBarRegistry = <LdAppBarRegistryKey, AppBarInfo>{};
  final _usedOrders = <int>{};

  AppBarRegistryState? _parentRegistry;
  VoidCallback? _parentRegistryListener;

  final ValueNotifier<EdgeInsets> _bodyPadding = ValueNotifier(EdgeInsets.zero);

  ValueNotifier<EdgeInsets> get bodyPadding => _bodyPadding;

  /// Registers an appbar with the desired order.
  /// If the order is already taken, automatically assigns the next available order.
  LdAppBarRegistryKey registerAppBar(int desiredOrder, {String? debugName}) {
    int actualOrder = desiredOrder;
    while (_usedOrders.contains(actualOrder)) {
      actualOrder++;
    }
    _usedOrders.add(actualOrder);
    final key = LdAppBarRegistryKey(order: actualOrder, debugName: debugName);
    _appBarRegistry[key] = AppBarInfo.initial(LdAppBarPosition.top);

    return key;
  }

  /// Unregisters an appbar from the registry.
  void unregisterAppBar(LdAppBarRegistryKey key) {
    _usedOrders.remove(key.order);
    _appBarRegistry.remove(key);
    notifyListeners();
    _updateBodyPadding();
  }

  void _updateBodyPadding() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    final modalRoute = ModalRoute.of(context);
    BuildContext? limitToChildrenOf;
    if (modalRoute is LdModalRoute) {
      limitToChildrenOf = modalRoute.subtreeContext;
    }

    final top = getTotalHeightAtPosition(
      LdAppBarPosition.top,
      limitToChildrenOf: limitToChildrenOf,
    );
    final bottom = getTotalHeightAtPosition(
      LdAppBarPosition.bottom,
      limitToChildrenOf: limitToChildrenOf,
    );
    final newPadding = EdgeInsets.only(top: top, bottom: bottom);
    if (_bodyPadding.value != newPadding) {
      await Future.delayed(Duration.zero);
      if (!mounted) return;
      _bodyPadding.value = newPadding;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Find parent registry by walking up the widget tree
    final newParentRegistry = AppBarRegistry.maybeStateOf(context);

    // Remove old listener if parent changed
    if (_parentRegistry != newParentRegistry) {
      if (_parentRegistry != null && _parentRegistryListener != null) {
        _parentRegistry!.removeListener(_parentRegistryListener!);
      }
      _parentRegistryListener = null;

      _parentRegistry = newParentRegistry;

      // Listen to parent registry changes
      if (_parentRegistry != null) {
        _parentRegistryListener = () {
          _updateBodyPadding();
        };
        _parentRegistry!.addListener(_parentRegistryListener!);
      }

      // Recalculate body padding when parent changes
      _updateBodyPadding();
    }
  }

  @override
  void dispose() {
    if (_parentRegistry != null && _parentRegistryListener != null) {
      _parentRegistry!.removeListener(_parentRegistryListener!);
    }
    _parentRegistryListener = null;
    _bodyPadding.dispose();
    super.dispose();
  }

  /// Called by the AppBarFrame to update the app bar info.
  void updateAppBarInfo(LdAppBarRegistryKey key, AppBarInfo info) {
    if (_appBarRegistry[key] == info) {
      return;
    }

    _appBarRegistry[key] = info;
    notifyListeners();
    _updateBodyPadding();
  }

  /// Called by the AppBarFrame to get the cumulative height of the app bars at the given position.
  List<AppBarInfo> getHigherAppBars(LdAppBarRegistryKey key, {BuildContext? limitToChildrenOf}) {
    final appBarInfo = _appBarRegistry[key];
    if (appBarInfo == null || !context.mounted) {
      return [];
    }
    if (limitToChildrenOf != null && !_isDescendantOf(context, limitToChildrenOf)) {
      return [];
    }
    final position = appBarInfo.position;

    // Get all appbars at the same position, sorted by order
    final sortedKeys = _appBarRegistry.keys.toList()..sort((a, b) => a.order.compareTo(b.order));

    // Find appbars with lower order (higher in the stack) at the same position
    final appbars = sortedKeys
        .where((k) => k.order < key.order && _appBarRegistry[k]?.position == position)
        .map((k) => _appBarRegistry[k]!)
        .toList();

    // Check if we should limit recursion to children of a specific context
    final parentAppBars = _parentRegistry?.getAppBarsAtPosition(position, limitToChildrenOf: limitToChildrenOf) ?? [];

    return parentAppBars + appbars;
  }

  /// Checks if [descendant] is a descendant of [ancestor] in the widget tree.
  bool _isDescendantOf(BuildContext descendant, BuildContext ancestor) {
    if (descendant == ancestor) {
      return false;
    }
    if (!descendant.mounted) {
      return false;
    }
    if (!ancestor.mounted) {
      return false;
    }

    bool found = false;

    try {
      descendant.visitAncestorElements((element) {
        // Check if descendant is still mounted before accessing ancestors
        if (!descendant.mounted) {
          return false;
        }
        if (!element.mounted) {
          return false;
        }
        if (element == ancestor) {
          found = true;
          return false; // Stop visiting
        }

        return true; // Continue visiting
      });
    } catch (e) {
      // Widget tree is being torn down, return false safely
      return false;
    }

    return found;
  }

  List<AppBarInfo> getAppBarsAtPosition(LdAppBarPosition position, {BuildContext? limitToChildrenOf}) {
    if (!mounted) {
      return [];
    }
    if (limitToChildrenOf != null && !_isDescendantOf(context, limitToChildrenOf)) {
      return [];
    }
    // Get appbars sorted by order
    final sortedKeys = _appBarRegistry.keys.toList()..sort((a, b) => a.order.compareTo(b.order));

    final appbars =
        sortedKeys.where((k) => _appBarRegistry[k]?.position == position).map((k) => _appBarRegistry[k]!).toList();

    // Check if we should limit recursion to children of a specific context
    List<AppBarInfo> parentAppBars =
        _parentRegistry?.getAppBarsAtPosition(position, limitToChildrenOf: limitToChildrenOf) ?? [];

    return parentAppBars + appbars;
  }

  /// Returns the level of an appbar at the given position.
  /// The level considers:
  /// - Parent registries that have appbars at the same position
  /// - Appbars in the current registry at the same position that come before this appbar
  int getLevel(LdAppBarRegistryKey appBarKey, LdAppBarPosition position, {BuildContext? limitToChildrenOf}) {
    return getHigherAppBars(appBarKey, limitToChildrenOf: limitToChildrenOf).length;
  }

  List<AppBarInfo> getAllAppBarsAtPosition(LdAppBarPosition position, {BuildContext? limitToChildrenOf}) {
    if (!mounted) {
      return [];
    }
    if (limitToChildrenOf != null && !_isDescendantOf(context, limitToChildrenOf)) {
      return [];
    }
    // Get appbars sorted by order

    final sortedKeys = _appBarRegistry.keys.toList()..sort((a, b) => a.order.compareTo(b.order));

    final appbars =
        sortedKeys.where((k) => _appBarRegistry[k]?.position == position).map((k) => _appBarRegistry[k]!).toList();

    return (_parentRegistry?.getAllAppBarsAtPosition(position, limitToChildrenOf: limitToChildrenOf) ?? []) + appbars;
  }

  double getTotalHeightAtPosition(LdAppBarPosition position, {BuildContext? limitToChildrenOf}) {
    final appBars = getAllAppBarsAtPosition(position, limitToChildrenOf: limitToChildrenOf);

    return appBars.fold(0.0, (sum, appBar) => sum + appBar.innerHeight) + (appBars.firstOrNull?.verticalMargin ?? 0);
  }

  double getEffectiveHeightOfOthers(LdAppBarRegistryKey key, {BuildContext? limitToChildrenOf}) {
    double total = 0.0;
    final appBars = getHigherAppBars(key, limitToChildrenOf: limitToChildrenOf);

    for (final appBar in appBars) {
      total += max(0, appBar.innerHeight - (appBar.willHide ? appBar.offset : 0.0));
    }
    if (appBars.isNotEmpty) {
      total += appBars.first.verticalMargin;
    }
    return total;
  }

  double getCumulativeHeightForPosition(LdAppBarPosition position, LdAppBarRegistryKey excludeKey) {
    double cumulativeHeight = 0.0;
    // Get sorted keys by order
    final sortedKeys = _appBarRegistry.keys.toList()..sort((a, b) => a.order.compareTo(b.order));

    for (final key in sortedKeys) {
      if (key == excludeKey) {
        break;
      }
      final info = _appBarRegistry[key];
      // Only include app bars that are registered and at the same position
      if (info != null && info.position == position) {
        // Use innerHeight + verticalMargin for positioning (actual height, not effective)
        cumulativeHeight += info.innerHeight + info.verticalMargin;
      }
    }
    return cumulativeHeight;
  }

  /// Get the current AppBarInfo for a given key
  AppBarInfo? getAppBarInfo(LdAppBarRegistryKey key) {
    return _appBarRegistry[key];
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.appBars);
  }
}

abstract class ChangeNotifyingState<T extends StatefulWidget> extends State<T> implements Listenable {
  final List<VoidCallback> _listeners = [];
  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void dispose() {
    super.dispose();
    _listeners.clear();
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}
