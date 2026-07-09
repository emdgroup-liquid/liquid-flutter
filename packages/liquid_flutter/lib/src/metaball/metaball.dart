import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'metaball_blob.dart';
import 'metaball_mask.dart';

// ---------------------------------------------------------------------------
// _LdMetaballScopeData — InheritedWidget that exposes the scope to descendants
// ---------------------------------------------------------------------------

class _LdMetaballScopeData extends InheritedWidget {
  final _LdMetaballScopeState scope;

  const _LdMetaballScopeData({
    required this.scope,
    required super.child,
  });

  @override
  bool updateShouldNotify(_LdMetaballScopeData old) => scope != old.scope;

  static _LdMetaballScopeState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LdMetaballScopeData>()
        ?.scope;
  }
}

// ---------------------------------------------------------------------------
// _SpringSim — imperative Euler-integration spring
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
// LdMetaballScope — the liquid surface container
// ---------------------------------------------------------------------------

/// A self-contained liquid metaball surface.
///
/// Place [LdMetaball] widgets anywhere in [children] — each one registers its
/// own size and position with this scope every frame so the shader always
/// tracks the actual layout with no lag.
///
/// ```dart
/// LdMetaballScope(
///   surfaceColor: theme.surface,
///   borderColor: theme.border,
///   blend: 40,
///   children: [
///     LdMetaball(
///       shape: LdMetaballShape.roundedRect,
///       cornerRadius: 24,
///       child: MyButton(),
///     ),
///     LdMetaball(
///       shape: LdMetaballShape.ellipse,
///       child: MyAvatar(),
///     ),
///   ],
/// )
/// ```
class LdMetaballScope extends StatefulWidget {
  /// The child widgets. Wrap any child that should have a metaball blob
  /// around it in an [LdMetaball] widget.
  final List<Widget> children;

  /// Fill colour for the interior of all blobs.
  final Color surfaceColor;

  /// Colour of the border ring around all blobs. When null, no border is drawn.
  final Color? borderColor;

  /// Blend radius. 0 = hard union; ~40 = liquid feel.
  final double blend;

  /// Width of the border ring in logical pixels.
  final double borderWidth;

  /// Whether pointer/touch events should animate the metaball surface.
  final bool interactive;

  const LdMetaballScope({
    super.key,
    required this.children,
    required this.surfaceColor,
    this.borderColor,
    this.blend = 40,
    this.borderWidth = 1,
    this.interactive = true,
  });

  @override
  State<LdMetaballScope> createState() => _LdMetaballScopeState();
}

class _LdMetaballScopeState extends State<LdMetaballScope>
    with SingleTickerProviderStateMixin {
  // Shader — owned and disposed by this state.
  ui.FragmentShader? _fill;
  ui.FragmentShader? _border;

  // Registered blobs keyed by the LdMetaball State that owns them.
  // Using insertion-ordered map so blob order is deterministic.
  final Map<_LdMetaballState, LdMetaballBlob> _blobs = {};

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
    _loadShaders();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _loadShaders() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/liquid_flutter/shaders/metaball.frag',
      );
      if (mounted) {
        setState(() {
          _fill = program.fragmentShader();
          _border =
              widget.borderColor != null ? program.fragmentShader() : null;
        });
      }
    } catch (e, st) {
      debugPrint('LdMetaballScope: shader load failed\n$e\n$st');
    }
  }

  @override
  void didUpdateWidget(LdMetaballScope old) {
    super.didUpdateWidget(old);
    // If borderColor toggled between null and non-null, allocate or release
    // the border shader instance accordingly.
    final hadBorder = old.borderColor != null;
    final hasBorder = widget.borderColor != null;
    if (hadBorder != hasBorder) {
      if (hasBorder && _fill != null) {
        // Need a border shader — reuse the already-loaded program via a new
        // fragmentShader() call. We can't get the program back from _fill, so
        // reload from asset (cheap: Flutter caches fragment programs).
        _border?.dispose();
        _border = null;
        _loadBorderShader();
      } else {
        _border?.dispose();
        _border = null;
      }
    }
  }

  Future<void> _loadBorderShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/liquid_flutter/shaders/metaball.frag',
      );
      if (mounted && widget.borderColor != null) {
        setState(() => _border = program.fragmentShader());
      }
    } catch (e, st) {
      debugPrint('LdMetaballScope: border shader load failed\n$e\n$st');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    _fill?.dispose();
    _border?.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Registration API — called by LdMetaball children
  // -------------------------------------------------------------------------

  /// Returns this scope's [RenderBox], used by [LdMetaball] children to
  /// convert their global position to the scope's local coordinate space.
  RenderBox? get renderBox {
    final obj = context.findRenderObject();
    if (obj is RenderBox && obj.hasSize) return obj;
    return null;
  }

  void register(_LdMetaballState child, LdMetaballBlob blob) {
    final current = _blobs[child];
    if (current == blob) return; // nothing changed
    setState(() {
      _blobs[child] = blob;
    });
  }

  void unregister(_LdMetaballState child) {
    if (!_blobs.containsKey(child)) return;
    // Defer to post-frame: unregister may be called from dispose() while the
    // framework tree is locked, in which case setState() would throw.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _blobs.remove(child));
    });
  }

  // -------------------------------------------------------------------------
  // Ticker — drives the pointer spring only
  // -------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;

    if (!_radiusSpring.isActive) return;

    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);
    _radiusSpring.step(elapsedMs);
    if (!_radiusSpring.isActive && _radiusSpring.target == _radiusOff) {
      setState(() => _pointerPos = null);
    } else {
      setState(() {});
    }
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
    final blobs = _blobs.values.toList();

    return _LdMetaballScopeData(
      scope: this,
      child: Listener(
        onPointerDown: (e) => _onPointerDown(e.localPosition),
        onPointerMove: (e) => _onPointerMove(e.localPosition),
        onPointerUp: (_) => _onPointerUp(),
        onPointerCancel: (_) => _onPointerUp(),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (fill != null && blobs.isNotEmpty)
              Positioned.fill(
                child: LdMetaballMask(
                  shader: fill,
                  borderShader: border,
                  blobs: blobs,
                  blend: widget.blend,
                  surfaceColor: widget.surfaceColor,
                  borderColor: widget.borderColor,
                  borderWidth: widget.borderWidth,
                  pointerPos: _pointerPos,
                  pointerRadius: _radiusSpring.position,
                ),
              ),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LdMetaball — a single blob child that registers itself with LdMetaballScope
// ---------------------------------------------------------------------------

/// Wraps a child widget and registers it as a metaball blob with the nearest
/// [LdMetaballScope] ancestor.
///
/// [LdMetaball] measures its own size and position after each frame and
/// reports them to the scope — no lag, even for animated children.
///
/// Must be a descendant of [LdMetaballScope].
///
/// ```dart
/// LdMetaballScope(
///   surfaceColor: Colors.white,
///   borderColor: Colors.black12,
///   children: [
///     LdMetaball(
///       shape: LdMetaballShape.roundedRect,
///       cornerRadius: 24,
///       child: MyButton(),
///     ),
///   ],
/// )
/// ```
class LdMetaball extends StatefulWidget {
  final Widget child;
  final LdMetaballShape shape;
  final double cornerRadius;

  const LdMetaball({
    super.key,
    required this.child,
    this.shape = LdMetaballShape.roundedRect,
    this.cornerRadius = 16,
  });

  @override
  State<LdMetaball> createState() => _LdMetaballState();
}

class _LdMetaballState extends State<LdMetaball> {
  // Stable key for measuring this widget's render box. Created once, never
  // recreated — preserves animation state in child widgets across rebuilds.
  final GlobalKey _key = GlobalKey();

  // Cached scope reference — updated in didChangeDependencies so it is safe
  // to read in dispose() where context lookups are forbidden.
  _LdMetaballScopeState? _scope;

  @override
  void initState() {
    super.initState();
    // Schedule first measurement after the initial layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newScope = _LdMetaballScopeData.of(context);
    if (newScope != _scope) {
      // Unregister from the old scope (if any) and register with the new one.
      _scope?.unregister(this);
      _scope = newScope;
      // Registration with the new scope happens on the next _measure() call.
    }
  }

  @override
  void didUpdateWidget(LdMetaball old) {
    super.didUpdateWidget(old);
    // Shape/cornerRadius may have changed — re-measure immediately.
    if (old.shape != widget.shape ||
        old.cornerRadius != widget.cornerRadius) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  @override
  void dispose() {
    _scope?.unregister(this);
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;

    final scope = _scope;
    if (scope == null) return;

    final scopeBox = scope.renderBox;
    final myBox = _key.currentContext?.findRenderObject() as RenderBox?;

    if (scopeBox == null || myBox == null || !myBox.hasSize) {
      // Layout not ready yet — try again next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
      return;
    }

    final localTopLeft =
        scopeBox.globalToLocal(myBox.localToGlobal(Offset.zero));
    final size = myBox.size;
    final center = localTopLeft + Offset(size.width / 2, size.height / 2);

    scope.register(
      this,
      LdMetaballBlob(
        position: center,
        width: size.width,
        height: size.height,
        cornerRadius: widget.cornerRadius,
        shape: widget.shape,
      ),
    );

    // Keep measuring every frame so animated children stay in sync.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  Widget build(BuildContext context) {
    // KeyedSubtree gives the subtree a stable identity so Flutter never
    // remounts child widgets (e.g. AnimatedContainer) across rebuilds.
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
