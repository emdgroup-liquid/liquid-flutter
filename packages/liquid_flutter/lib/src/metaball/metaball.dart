import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'metaball_blob.dart';
import 'metaball_mask.dart';
import 'metaball_shader_scope.dart';

// ---------------------------------------------------------------------------
// _MetaballChild — wraps a single caller-supplied child widget
// ---------------------------------------------------------------------------

/// Internal data record for a single child of [LdMetaball].
class _MetaballChild {
  final Widget child;
  final GlobalKey key;
  final LdMetaballShape shape;
  final double cornerRadius;

  _MetaballChild({
    required this.child,
    required this.key,
    required this.shape,
    required this.cornerRadius,
  });
}

// ---------------------------------------------------------------------------
// LdMetaballChild — public wrapper to declare a child with blob metadata
// ---------------------------------------------------------------------------

/// Wraps a [child] widget so that [LdMetaball] can auto-detect its position
/// and size and render it inside a metaball blob.
///
/// Place [LdMetaballChild] widgets directly inside [LdMetaball.children].
///
/// ```dart
/// LdMetaball(
///   children: [
///     LdMetaballChild(
///       shape: LdMetaballShape.roundedRect,
///       cornerRadius: 24,
///       child: MyButton(),
///     ),
///     LdMetaballChild(
///       shape: LdMetaballShape.ellipse,
///       child: MyAvatar(),
///     ),
///   ],
/// )
/// ```
class LdMetaballChild extends StatelessWidget {
  final Widget child;
  final LdMetaballShape shape;
  final double cornerRadius;

  const LdMetaballChild({
    super.key,
    required this.child,
    this.shape = LdMetaballShape.roundedRect,
    this.cornerRadius = 16,
  });

  @override
  Widget build(BuildContext context) => child;
}

// ---------------------------------------------------------------------------
// _SpringSim — imperative Euler-integration spring (no widget overhead)
// ---------------------------------------------------------------------------

class _SpringSim {
  final double springConstant;
  final double dampingCoefficient;
  final double mass;

  double position;
  double target;
  double _velocity = 0.0;

  _SpringSim({
    required this.springConstant,
    required this.dampingCoefficient,
    required this.mass,
    required double initial,
    required this.target,
  }) : position = initial;

  bool get isActive =>
      (position - target).abs() > 0.05 || _velocity.abs() > 0.05;

  void step(int elapsedMs) {
    const timeStep = 0.01;
    final frames = elapsedMs / 16.0;
    for (var i = 0; i < frames; i++) {
      final springForce = -springConstant * (position - target);
      final dampingForce = -dampingCoefficient * _velocity;
      _velocity += (springForce + dampingForce) / mass * timeStep;
      position += _velocity * timeStep;
    }
    if (!isActive) {
      position = target;
      _velocity = 0.0;
    }
  }
}

// ---------------------------------------------------------------------------
// LdMetaball — high-level, self-contained widget
// ---------------------------------------------------------------------------

/// A self-contained liquid metaball widget.
///
/// [LdMetaball] automatically measures the position and size of each
/// [LdMetaballChild] in its [children] list and feeds them to the underlying
/// [LdMetaballMask] on every frame.  The caller does not need to maintain any
/// [LdMetaballBlob] state manually — layout is tracked via [GlobalKey]s.
///
/// ## Pointer interaction
///
/// When [interactive] is `true` (the default), pointer events within the
/// widget are used to drive a spring-animated deformation of the metaball
/// surface — the liquid "squishes" toward the touch point and springs back.
/// Set [interactive] to `false` to disable this behaviour.
///
/// ## Blend
///
/// [blend] controls the width of the smooth-union neck between blobs.  0
/// produces a hard union; 40–80 gives a viscous liquid feel.
///
/// ## Shader loading
///
/// [LdMetaball] looks for a [LdMetaballShaderScope] ancestor first.  If one
/// is found, it uses the shared shaders from that scope (recommended for pages
/// that contain multiple [LdMetaball] widgets).  If no scope is found, it
/// loads its own [ui.FragmentProgram] independently.
///
/// ## Example
///
/// ```dart
/// LdMetaball(
///   blend: 40,
///   surfaceColor: theme.surface,
///   borderColor: theme.border,
///   children: [
///     LdMetaballChild(
///       shape: LdMetaballShape.roundedRect,
///       cornerRadius: 24,
///       child: SizedBox(
///         width: 120,
///         height: 48,
///         child: Center(child: Text('Hello')),
///       ),
///     ),
///     LdMetaballChild(
///       shape: LdMetaballShape.ellipse,
///       child: SizedBox.square(dimension: 80),
///     ),
///   ],
/// )
/// ```
class LdMetaball extends StatefulWidget {
  /// The child widgets to wrap with metaball blobs.
  ///
  /// Each element should be a [LdMetaballChild] (or any widget whose
  /// [LdMetaball] can measure the render box of).  The children are laid out
  /// in a [Stack] so they can be placed freely via [Positioned] or similar.
  final List<Widget> children;

  /// Blend radius. 0 = hard union; ~40 = liquid feel.
  final double blend;

  /// Fill colour for the interior of all blobs.
  final Color surfaceColor;

  /// Colour of the border ring around all blobs.
  final Color borderColor;

  /// Width of the border ring in logical pixels.
  final double borderWidth;

  /// Whether pointer/touch events should animate the metaball surface.
  final bool interactive;

  const LdMetaball({
    super.key,
    required this.children,
    required this.surfaceColor,
    required this.borderColor,
    this.blend = 40,
    this.borderWidth = 1,
    this.interactive = true,
  });

  @override
  State<LdMetaball> createState() => _LdMetaballState();
}

class _LdMetaballState extends State<LdMetaball>
    with SingleTickerProviderStateMixin {
  // Shader instances — either borrowed from scope or owned locally.
  ui.FragmentShader? _fill;
  ui.FragmentShader? _border;
  bool _ownedShaders = false; // true when we loaded them ourselves

  // Per-child tracking
  late List<_MetaballChild> _children;

  // Measured blobs (updated each frame when size changes)
  List<LdMetaballBlob> _blobs = [];

  // Pointer spring
  Offset? _pointerPos;
  bool _pointerDown = false;
  late final _SpringSim _radiusSpring = _SpringSim(
    springConstant: 60,
    dampingCoefficient: 10,
    mass: 1.5,
    initial: 0,
    target: 0,
  );
  static const double _radiusPeak = 40.0;
  static const double _radiusRest = 20.8;
  static const double _radiusOff = 0.0;
  Timer? _bounceTimer;

  late final Ticker _ticker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _rebuildChildren();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(LdMetaball old) {
    super.didUpdateWidget(old);
    if (old.children != widget.children) {
      _rebuildChildren();
    }
  }

  void _rebuildChildren() {
    _children = widget.children.map((child) {
      LdMetaballShape shape = LdMetaballShape.roundedRect;
      double cornerRadius = 16;
      if (child is LdMetaballChild) {
        shape = child.shape;
        cornerRadius = child.cornerRadius;
      }
      return _MetaballChild(
        child: child,
        key: GlobalKey(debugLabel: 'LdMetaballChild'),
        shape: shape,
        cornerRadius: cornerRadius,
      );
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryBorrowShaders();
  }

  /// Tries to get shaders from an ancestor [LdMetaballShaderScope].
  /// Falls back to loading its own shader if none is found.
  void _tryBorrowShaders() {
    try {
      final scoped = LdMetaballShaderScope.of(context);
      if (scoped != null && !_ownedShaders) {
        // Use scope shaders — don't dispose them.
        setState(() {
          _fill = scoped.fill;
          _border = scoped.border;
        });
      }
    } on FlutterError {
      // No scope — load our own.
      if (_fill == null && !_ownedShaders) {
        _ownedShaders = true;
        _loadOwnShaders();
      }
    }
  }

  Future<void> _loadOwnShaders() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/liquid_flutter/shaders/metaball.frag',
      );
      if (mounted) {
        setState(() {
          _fill = program.fragmentShader();
          _border = program.fragmentShader();
        });
      }
    } catch (e, st) {
      debugPrint('LdMetaball: shader load failed\n$e\n$st');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    if (_ownedShaders) {
      _fill?.dispose();
      _border?.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Ticker — spring simulation + blob measurement
  // -------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;

    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);

    final springWasActive = _radiusSpring.isActive;
    if (springWasActive) {
      _radiusSpring.step(elapsedMs);
      if (!_radiusSpring.isActive &&
          _radiusSpring.target == _radiusOff) {
        _pointerPos = null;
      }
    }

    // Measure all child render boxes and rebuild the blob list.
    final newBlobs = _measureBlobs();
    final blobsChanged = !_blobListEqual(newBlobs, _blobs);

    if (springWasActive || blobsChanged) {
      setState(() {
        _blobs = newBlobs;
      });
    }
  }

  /// Reads the [RenderBox] of each child via its [GlobalKey] and converts to
  /// [LdMetaballBlob] in the local coordinate space of this widget's own
  /// [RenderBox].
  List<LdMetaballBlob> _measureBlobs() {
    final myBox = context.findRenderObject() as RenderBox?;
    if (myBox == null || !myBox.hasSize) return _blobs;

    final List<LdMetaballBlob> result = [];
    for (final child in _children) {
      final childCtx = child.key.currentContext;
      if (childCtx == null) continue;
      final childBox = childCtx.findRenderObject() as RenderBox?;
      if (childBox == null || !childBox.hasSize) continue;

      // Convert child's top-left to local coordinates of this widget.
      final localTopLeft =
          myBox.globalToLocal(childBox.localToGlobal(Offset.zero));
      final size = childBox.size;
      final center = localTopLeft + Offset(size.width / 2, size.height / 2);

      result.add(LdMetaballBlob(
        position: center,
        width: size.width,
        height: size.height,
        cornerRadius: child.cornerRadius,
        shape: child.shape,
      ));
    }
    return result;
  }

  bool _blobListEqual(List<LdMetaballBlob> a, List<LdMetaballBlob> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // -------------------------------------------------------------------------
  // Pointer handling
  // -------------------------------------------------------------------------

  void _onPointerDown(Offset pos) {
    if (!widget.interactive) return;
    _bounceTimer?.cancel();
    setState(() {
      _pointerPos = pos;
      _pointerDown = true;
    });
    _radiusSpring.target = _radiusPeak;
    _bounceTimer = Timer(const Duration(milliseconds: 50), () {
      _radiusSpring.target = _radiusRest;
    });
  }

  void _onPointerMove(Offset pos) {
    if (!widget.interactive || !_pointerDown) return;
    setState(() => _pointerPos = pos);
  }

  void _onPointerUp() {
    if (!widget.interactive) return;
    _bounceTimer?.cancel();
    _pointerDown = false;
    _radiusSpring.target = _radiusOff;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final fill = _fill;
    final border = _border;

    return Listener(
      onPointerDown: (e) => _onPointerDown(e.localPosition),
      onPointerMove: (e) => _onPointerMove(e.localPosition),
      onPointerUp: (_) => _onPointerUp(),
      onPointerCancel: (_) => _onPointerUp(),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Metaball mask layer (below the children so pointer events pass through)
          if (fill != null && border != null && _blobs.isNotEmpty)
            Positioned.fill(
              child: LdMetaballMask(
                shader: fill,
                borderShader: border,
                blobs: _blobs,
                blend: widget.blend,
                surfaceColor: widget.surfaceColor,
                borderColor: widget.borderColor,
                borderWidth: widget.borderWidth,
                pointerPos: _pointerPos,
                pointerRadius: _radiusSpring.position,
              ),
            ),

          // Children — each wrapped with its GlobalKey for measurement
          for (final meta in _children)
            KeyedSubtree(key: meta.key, child: meta.child),
        ],
      ),
    );
  }
}
