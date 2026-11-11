// Experimental integration with Flutter's desktop windowing API.
//
// The windowing API is still marked `@internal` by Flutter and is only
// available from Flutter 3.47 (behind `flutter config --enable-windowing`).
// Importing it directly here keeps the rest of Liquid Flutter free of
// implementation imports. Every entry point is guarded at runtime so that
// mobile, web, older Flutter versions and apps without the feature flag keep
// using the existing overlay implementation.
//
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;
import 'package:flutter/src/widgets/_window.dart' as fw;
import 'package:flutter/src/widgets/_window_positioner.dart' as fw_positioner;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Whether Liquid Flutter should use native windows for popups, tooltips and
/// dialogs.
enum LdWindowMode {
  /// Use a native window whenever the platform supports it. Falls back to the
  /// overlay implementation everywhere else.
  auto,

  /// Always use the overlay implementation, even on a supported desktop
  /// platform.
  disabled,
}

/// Alignment of a child window relative to its anchor.
enum LdWindowAlign {
  /// Align the leading edge of the child with the leading edge of the anchor.
  start,

  /// Center the child on the anchor.
  center,

  /// Align the trailing edge of the child with the trailing edge of the anchor.
  end,
}

/// Describes where a child window should be placed relative to its anchor.
class LdWindowPosition {
  const LdWindowPosition({
    this.above = false,
    this.align = LdWindowAlign.start,
    this.offset = Offset.zero,
  });

  /// Whether the window should open above the anchor instead of below it.
  final bool above;

  /// Horizontal alignment relative to the anchor.
  final LdWindowAlign align;

  /// Additional logical-pixel offset applied after anchoring.
  final Offset offset;
}

/// A handle to a native child window (popup or tooltip).
abstract class LdWindowHandle {
  /// Whether the underlying window has been closed.
  bool get isClosed;

  /// Completes when the window is closed, either by the caller or by the
  /// platform.
  Future<void> get closed;

  /// Updates the anchor rectangle of the window.
  void updateAnchor(Rect anchorRect);

  /// Closes the window.
  void close();
}

/// Tracks the global rectangle of a widget and reports layout changes.
///
/// Native popup and tooltip windows are positioned in screen space, so their
/// anchor has to follow the widget they point at when the window resizes or
/// the page scrolls.
class LdWindowAnchorTracker {
  LdWindowAnchorTracker({required this.target, required this.onChanged}) {
    _lastRect = _rectOf(target);
    _schedule();
  }

  /// Key attached to the widget that should be tracked.
  final GlobalKey target;

  /// Called whenever the tracked rectangle changes.
  final ValueChanged<Rect> onChanged;

  Rect? _lastRect;
  bool _active = true;

  /// Stops tracking the widget.
  void dispose() {
    _active = false;
  }

  void _schedule() {
    if (!_active) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_active) {
        return;
      }
      _tick();
      _schedule();
    });
  }

  void _tick() {
    final rect = _rectOf(target);
    if (rect != null && rect != _lastRect) {
      _lastRect = rect;
      onChanged(rect);
    }
  }

  static Rect? _rectOf(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    return MatrixUtils.transformRect(
      renderObject.getTransformTo(null),
      Offset.zero & renderObject.size,
    );
  }
}

/// Provides a native windowing implementation to the components in
/// [Liquid Flutter].
///
/// The default scope uses Flutter's desktop windowing API. Installing a scope
/// with [enabled] set to `false`, or with a custom [adapter] (useful in tests),
/// overrides that behaviour.
class LdWindowingScope extends InheritedWidget {
  const LdWindowingScope({
    super.key,
    this.enabled = true,
    this.adapter,
    required super.child,
  });

  /// Whether native windows may be used below this scope.
  final bool enabled;

  /// Optional adapter override. When null, [LdNativeWindowingAdapter] is used.
  final LdWindowingAdapter? adapter;

  static LdWindowingAdapter? maybeAdapter(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LdWindowingScope>();
    if (scope != null && !scope.enabled) {
      return null;
    }
    final adapter = scope?.adapter ?? const LdNativeWindowingAdapter();
    return adapter.isAvailable(context) ? adapter : null;
  }

  @override
  bool updateShouldNotify(LdWindowingScope oldWidget) {
    return enabled != oldWidget.enabled || adapter != oldWidget.adapter;
  }
}

/// Platform and feature-flag helpers for the desktop windowing API.
abstract final class LdWindowing {
  /// Whether the app was compiled with `flutter config --enable-windowing`.
  static bool get isCompiledIn => isWindowingEnabled;

  /// Whether the current platform can host native windows.
  static bool get isSupportedPlatform {
    if (kIsWeb || kIsWasm) {
      return false;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
      _ => false,
    };
  }

  /// Whether native windows are available in [context].
  static bool isAvailable(BuildContext context) => LdWindowingScope.maybeAdapter(context) != null;
}

/// Creates native windows for Liquid Flutter components.
///
/// Components ask [LdWindowingScope] for an adapter and always fall back to
/// their overlay implementation when [isAvailable] returns `false` or when a
/// factory returns `null`.
abstract class LdWindowingAdapter {
  /// Whether this adapter can create native windows in [context].
  bool isAvailable(BuildContext context);

  /// Shows a popup window, typically used for context menus.
  ///
  /// Returns `null` when the window could not be created. Callers must then
  /// fall back to the overlay implementation.
  LdWindowHandle? showPopup({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  });

  /// Shows a tooltip window anchored to [anchorRect].
  ///
  /// Returns `null` when the window could not be created.
  LdWindowHandle? showTooltip({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  });

  /// Creates a [Route] that hosts its content in a native dialog window.
  ///
  /// The route is pushed into the existing navigator so that
  /// `Navigator.pop(result)` and the returned `Future` keep working.
  /// Returns `null` when a native dialog window cannot be created.
  Route<T>? createDialogRoute<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Size size,
    String? title,
    RouteSettings? settings,
    List<SingleChildWidget> providers = const [],
  });
}

/// The default adapter backed by Flutter's desktop windowing API.
class LdNativeWindowingAdapter implements LdWindowingAdapter {
  const LdNativeWindowingAdapter();

  @override
  bool isAvailable(BuildContext context) {
    return LdWindowing.isCompiledIn &&
        LdWindowing.isSupportedPlatform &&
        fw.WindowRegistry.maybeOf(context) != null &&
        fw.WindowScope.maybeOf(context) != null;
  }

  @override
  LdWindowHandle? showPopup({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  }) {
    return _showChildWindow(
      context: context,
      anchorRect: anchorRect,
      builder: builder,
      position: position,
      constraints: constraints,
      providers: providers,
      createController: (parent, positioner, delegate) => _createPopupWindowController(
        parent: parent,
        anchorRect: anchorRect,
        positioner: positioner,
        constraints: constraints,
        delegate: delegate as fw.PopupWindowControllerDelegate,
      ),
      createDelegate: _LdPopupWindowDelegate.new,
    );
  }

  @override
  LdWindowHandle? showTooltip({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  }) {
    return _showChildWindow(
      context: context,
      anchorRect: anchorRect,
      builder: builder,
      position: position,
      constraints: constraints,
      providers: providers,
      createController: (parent, positioner, delegate) => _createTooltipWindowController(
        parent: parent,
        anchorRect: anchorRect,
        positioner: positioner,
        constraints: constraints,
        delegate: delegate as fw.TooltipWindowControllerDelegate,
      ),
      createDelegate: _LdTooltipWindowDelegate.new,
    );
  }

  LdWindowHandle? _showChildWindow({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    required LdWindowPosition position,
    required BoxConstraints constraints,
    required List<SingleChildWidget> providers,
    required fw.BaseWindowController Function(
      fw.BaseWindowController parent,
      fw_positioner.WindowPositioner positioner,
      Object delegate,
    ) createController,
    required _LdChildWindowDelegate Function(VoidCallback onDestroyed) createDelegate,
  }) {
    if (!LdWindowing.isCompiledIn || !LdWindowing.isSupportedPlatform) {
      return null;
    }
    final parent = fw.WindowScope.maybeOf(context);
    final registry = fw.WindowRegistry.maybeOf(context);
    if (parent == null || registry == null) {
      return null;
    }

    try {
      late final _LdChildWindowHandle handle;
      final delegate = createDelegate(() => handle.handlePlatformDestroyed());
      final controller = createController(
        parent,
        _toPositioner(position),
        delegate,
      );
      final entry = fw.WindowEntry(
        controller: controller,
        builder: (windowContext) => _wrapWindowContent(
          windowContext,
          providers,
          builder,
          onPop: (_) => handle.close(),
        ),
      );
      handle = _LdChildWindowHandle(
        controller: controller,
        registry: registry,
        entry: entry,
      );
      registry.register(entry);
      return handle;
    } on UnsupportedError {
      return null;
    } on FlutterError {
      return null;
    }
  }

  @override
  Route<T>? createDialogRoute<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Size size,
    String? title,
    RouteSettings? settings,
    List<SingleChildWidget> providers = const [],
  }) {
    if (!LdWindowing.isCompiledIn || !LdWindowing.isSupportedPlatform) {
      return null;
    }
    final parent = fw.WindowScope.maybeOf(context);
    final registry = fw.WindowRegistry.maybeOf(context);
    if (parent == null || registry == null) {
      return null;
    }

    try {
      return _LdDialogWindowRoute<T>(
        parent: parent,
        registry: registry,
        size: size,
        title: title,
        settings: settings,
        builder: builder,
        providers: providers,
      );
    } on UnsupportedError {
      return null;
    } on FlutterError {
      return null;
    }
  }
}

// Flutter renamed the popup/tooltip constraint parameter from
// `preferredConstraints` (3.44) to `constraints` (3.47). Resolve the shape at
// runtime so the package works on both stable releases.
fw.BaseWindowController _createPopupWindowController({
  required fw.BaseWindowController parent,
  required Rect anchorRect,
  required fw_positioner.WindowPositioner positioner,
  required BoxConstraints constraints,
  required fw.PopupWindowControllerDelegate delegate,
}) {
  final baseArgs = <Symbol, dynamic>{
    #parent: parent,
    #anchorRect: anchorRect,
    #positioner: positioner,
    #delegate: delegate,
  };
  try {
    return Function.apply(fw.PopupWindowController.new, const [], {
      ...baseArgs,
      #constraints: constraints,
    }) as fw.BaseWindowController;
  } on NoSuchMethodError {
    return Function.apply(fw.PopupWindowController.new, const [], {
      ...baseArgs,
      #preferredConstraints: constraints,
    }) as fw.BaseWindowController;
  }
}

fw.BaseWindowController _createTooltipWindowController({
  required fw.BaseWindowController parent,
  required Rect anchorRect,
  required fw_positioner.WindowPositioner positioner,
  required BoxConstraints constraints,
  required fw.TooltipWindowControllerDelegate delegate,
}) {
  final baseArgs = <Symbol, dynamic>{
    #parent: parent,
    #anchorRect: anchorRect,
    #positioner: positioner,
    #delegate: delegate,
  };
  try {
    return Function.apply(fw.TooltipWindowController.new, const [], {
      ...baseArgs,
      #constraints: constraints,
    }) as fw.BaseWindowController;
  } on NoSuchMethodError {
    return Function.apply(fw.TooltipWindowController.new, const [], {
      ...baseArgs,
      #preferredConstraints: constraints,
    }) as fw.BaseWindowController;
  }
}

// Flutter renamed `preferredSize` (3.44) to `size` (3.47).
fw.DialogWindowController _createDialogWindowController({
  required fw.BaseWindowController parent,
  required Size size,
  required String? title,
  required fw.DialogWindowControllerDelegate delegate,
}) {
  final baseArgs = <Symbol, dynamic>{
    #parent: parent,
    #title: title,
    #delegate: delegate,
  };
  try {
    return Function.apply(fw.DialogWindowController.new, const [], {
      ...baseArgs,
      #size: size,
    }) as fw.DialogWindowController;
  } on NoSuchMethodError {
    return Function.apply(fw.DialogWindowController.new, const [], {
      ...baseArgs,
      #preferredSize: size,
    }) as fw.DialogWindowController;
  }
}

fw_positioner.WindowPositioner _toPositioner(LdWindowPosition position) {
  final parentAnchor = switch ((position.above, position.align)) {
    (false, LdWindowAlign.start) => fw_positioner.WindowPositionerAnchor.bottomLeft,
    (false, LdWindowAlign.center) => fw_positioner.WindowPositionerAnchor.bottom,
    (false, LdWindowAlign.end) => fw_positioner.WindowPositionerAnchor.bottomRight,
    (true, LdWindowAlign.start) => fw_positioner.WindowPositionerAnchor.topLeft,
    (true, LdWindowAlign.center) => fw_positioner.WindowPositionerAnchor.top,
    (true, LdWindowAlign.end) => fw_positioner.WindowPositionerAnchor.topRight,
  };
  final childAnchor = switch ((position.above, position.align)) {
    (false, LdWindowAlign.start) => fw_positioner.WindowPositionerAnchor.topLeft,
    (false, LdWindowAlign.center) => fw_positioner.WindowPositionerAnchor.top,
    (false, LdWindowAlign.end) => fw_positioner.WindowPositionerAnchor.topRight,
    (true, LdWindowAlign.start) => fw_positioner.WindowPositionerAnchor.bottomLeft,
    (true, LdWindowAlign.center) => fw_positioner.WindowPositionerAnchor.bottom,
    (true, LdWindowAlign.end) => fw_positioner.WindowPositionerAnchor.bottomRight,
  };
  return fw_positioner.WindowPositioner(
    parentAnchor: parentAnchor,
    childAnchor: childAnchor,
    offset: position.offset,
    constraintAdjustment: const fw_positioner.WindowPositionerConstraintAdjustment(
      flipX: true,
      flipY: true,
      slideX: true,
      slideY: true,
      resizeX: true,
      resizeY: true,
    ),
  );
}

Widget _wrapWindowContent(
  BuildContext context,
  List<SingleChildWidget> providers,
  WidgetBuilder builder, {
  required void Function(Object? result) onPop,
}) {
  final content = _LdWindowNavigatorShim(
    onPop: onPop,
    child: Builder(builder: builder),
  );
  if (providers.isEmpty) {
    return content;
  }
  return MultiProvider(providers: providers, builder: (context, _) => content);
}

/// A minimal navigator that lets window content call
/// `Navigator.of(context).pop()` even though the content is rendered outside
/// the main navigator (the window manager lives above it).
class _LdWindowNavigatorShim extends StatelessWidget {
  const _LdWindowNavigatorShim({required this.child, required this.onPop});

  final Widget child;
  final void Function(Object? result) onPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          onPop(result);
        }
      },
      child: HeroControllerScope.none(
        child: Navigator(
          pages: <Page<void>>[_LdWindowContentPage(child: child)],
          // ignore: deprecated_member_use
          onPopPage: (Route<dynamic> route, dynamic result) {
            onPop(result);
            // The native window owns the lifecycle; keep the shim route
            // mounted until the window closes.
            return false;
          },
        ),
      ),
    );
  }
}

class _LdWindowContentPage extends Page<void> {
  const _LdWindowContentPage({required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}

abstract class _LdChildWindowDelegate {
  _LdChildWindowDelegate(this.onDestroyed);

  final VoidCallback onDestroyed;

  void handleDestroyed() => onDestroyed();
}

class _LdPopupWindowDelegate extends _LdChildWindowDelegate with fw.PopupWindowControllerDelegate {
  _LdPopupWindowDelegate(super.onDestroyed);

  @override
  void onWindowDestroyed() {
    handleDestroyed();
    super.onWindowDestroyed();
  }
}

class _LdTooltipWindowDelegate extends _LdChildWindowDelegate with fw.TooltipWindowControllerDelegate {
  _LdTooltipWindowDelegate(super.onDestroyed);

  @override
  void onWindowDestroyed() {
    handleDestroyed();
    super.onWindowDestroyed();
  }
}

class _LdChildWindowHandle implements LdWindowHandle {
  _LdChildWindowHandle({
    required fw.BaseWindowController controller,
    required fw.WindowRegistry registry,
    required fw.WindowEntry entry,
  })  : _controller = controller,
        _registry = registry,
        _entry = entry;

  final fw.BaseWindowController _controller;
  final fw.WindowRegistry _registry;
  final fw.WindowEntry _entry;
  final Completer<void> _closed = Completer<void>();
  bool _isClosed = false;

  @override
  bool get isClosed => _isClosed;

  @override
  Future<void> get closed => _closed.future;

  void handlePlatformDestroyed() {
    _finish(alreadyDestroyed: true);
  }

  @override
  void updateAnchor(Rect anchorRect) {
    if (_isClosed) {
      return;
    }
    try {
      switch (_controller) {
        case final fw.TooltipWindowController tooltip:
          tooltip.updatePosition(anchorRect: anchorRect);
        case final fw.PopupWindowController popup:
          popup.updatePosition(anchorRect: anchorRect);
        default:
          break;
      }
    } on UnsupportedError {
      // The feature flag may have been turned off between build and update.
    }
  }

  @override
  void close() {
    _finish(alreadyDestroyed: false);
  }

  void _finish({required bool alreadyDestroyed}) {
    if (_isClosed) {
      return;
    }
    _isClosed = true;
    try {
      _registry.unregister(_entry);
    } on UnsupportedError {
      // Ignore: the feature is no longer enabled.
    }
    try {
      if (!alreadyDestroyed) {
        _controller.destroy();
      }
    } on UnsupportedError {
      // Ignore: the feature is no longer enabled.
    }
    _controller.dispose();
    if (!_closed.isCompleted) {
      _closed.complete();
    }
  }
}

class _LdDialogWindowDelegate with fw.DialogWindowControllerDelegate {
  _LdDialogWindowDelegate(this.route);

  final _LdDialogWindowRoute<dynamic> route;

  @override
  void onWindowCloseRequested(fw.DialogWindowController controller) {
    route.popFromWindow(null);
  }
}

class _LdDialogWindowRoute<T> extends Route<T> {
  _LdDialogWindowRoute({
    required fw.BaseWindowController parent,
    required fw.WindowRegistry registry,
    required Size size,
    required String? title,
    required WidgetBuilder builder,
    required List<SingleChildWidget> providers,
    super.settings,
  })  : _parent = parent,
        _registry = registry,
        _builder = builder,
        _providers = providers,
        _title = title,
        _size = size {
    _controller = _createDialogWindowController(
      parent: _parent,
      size: _size,
      title: _title,
      delegate: _LdDialogWindowDelegate(this),
    );
  }

  final fw.BaseWindowController _parent;
  final fw.WindowRegistry _registry;
  final WidgetBuilder _builder;
  final List<SingleChildWidget> _providers;
  final String? _title;
  final Size _size;

  late final fw.DialogWindowController _controller;
  late final List<OverlayEntry> _overlayEntries;
  fw.WindowEntry? _entry;
  bool _popping = false;
  bool _destroyed = false;

  @override
  List<OverlayEntry> get overlayEntries => _overlayEntries;

  @override
  void install() {
    super.install();

    // The navigator requires at least one overlay entry. The real content is
    // rendered through the window registry.
    _overlayEntries = <OverlayEntry>[
      OverlayEntry(builder: (BuildContext context) => const SizedBox.shrink()),
    ];

    final fw.WindowEntry entry = fw.WindowEntry(
      controller: _controller,
      builder: (windowContext) => _wrapWindowContent(
        windowContext,
        _providers,
        _builder,
        onPop: popFromWindow,
      ),
    );
    _entry = entry;
    _registry.register(entry);
  }

  void popFromWindow(Object? result) {
    if (_popping) {
      return;
    }
    _popping = true;
    final navigator = this.navigator;
    if (navigator == null) {
      return;
    }
    if (isCurrent) {
      navigator.pop(result);
    } else {
      navigator.removeRoute(this, result);
    }
  }

  void _unregisterAndDestroy() {
    if (_destroyed) {
      return;
    }
    _destroyed = true;
    final entry = _entry;
    if (entry != null) {
      _entry = null;
      try {
        _registry.unregister(entry);
      } on UnsupportedError {
        // Ignore: the feature is no longer enabled.
      }
    }
    try {
      _controller.destroy();
    } on UnsupportedError {
      // Ignore: the feature is no longer enabled.
    }
    _controller.dispose();
  }

  @override
  bool didPop(T? result) {
    _unregisterAndDestroy();
    return super.didPop(result);
  }

  @override
  void dispose() {
    _unregisterAndDestroy();
    super.dispose();
  }
}
