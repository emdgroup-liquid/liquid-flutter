import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum MetaballShape { roundedRect, ellipse }

/// A draggable blob. [color] is used for the widget content painted inside it.
class MetaballBlob {
  Offset position;
  double width;
  double height;
  double cornerRadius;
  MetaballShape shape;
  Color color;

  MetaballBlob({
    required this.position,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.shape,
    required this.color,
  });

  MetaballBlob copyWith({
    Offset? position,
    double? width,
    double? height,
    double? cornerRadius,
    MetaballShape? shape,
    Color? color,
  }) {
    return MetaballBlob(
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      shape: shape ?? this.shape,
      color: color ?? this.color,
    );
  }
}

// ---------------------------------------------------------------------------
// Icon + label overlay for a single blob — Positioned at the blob center.
// ---------------------------------------------------------------------------

class _BlobLabel extends StatelessWidget {
  final MetaballBlob blob;
  final int index;

  static const _icons = [
    LucideIcons.star,
    LucideIcons.heart,
    LucideIcons.zap,
    LucideIcons.music,
    LucideIcons.sun,
    LucideIcons.cloud,
    LucideIcons.flame,
    LucideIcons.diamond,
  ];

  static const _labels = ['Design', 'Explore', 'Energy', 'Rhythm', 'Bright', 'Cloud', 'Spark', 'Gem'];

  const _BlobLabel({required this.blob, required this.index});

  @override
  Widget build(BuildContext context) {
    final icon = _icons[index % _icons.length];
    final label = _labels[index % _labels.length];
    return Positioned(
      left: blob.position.dx - blob.width / 2,
      top: blob.position.dy - blob.height / 2,
      width: blob.width,
      height: blob.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: (blob.width * 0.28).clamp(16, 48)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: (blob.width * 0.12).clamp(10, 16),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable blob handle (transparent overlay for hit-testing + selection ring)
// ---------------------------------------------------------------------------

class _BlobHandle extends StatelessWidget {
  final MetaballBlob blob;
  final bool selected;
  final VoidCallback onTap;
  final void Function(DragUpdateDetails) onDrag;

  const _BlobHandle({required this.blob, required this.selected, required this.onTap, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: blob.position.dx - blob.width / 2 - 4,
      top: blob.position.dy - blob.height / 2 - 4,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: onDrag,
        child: Container(width: blob.width + 8, height: blob.height + 8, decoration: BoxDecoration()),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main experiment page
// ---------------------------------------------------------------------------

class MetaballExperiment extends StatefulWidget {
  const MetaballExperiment({super.key});

  @override
  State<MetaballExperiment> createState() => _MetaballExperimentState();
}

// ---------------------------------------------------------------------------
// Minimal Euler-integration spring — same algorithm as LdSpring's _Spring,
// but usable imperatively without a widget wrapper.
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

  bool get isActive => (position - target).abs() > 0.05 || _velocity.abs() > 0.05;

  double get _springForce => -springConstant * (position - target);
  double get _dampingForce => -dampingCoefficient * _velocity;

  void step(int elapsedMs) {
    const timeStep = 0.01;
    final frames = elapsedMs / 16.0;
    for (var i = 0; i < frames; i++) {
      final acceleration = (_springForce + _dampingForce) / mass;
      _velocity += acceleration * timeStep;
      position += _velocity * timeStep;
    }
    if (!isActive) {
      position = target;
      _velocity = 0.0;
    }
  }
}

// ---------------------------------------------------------------------------

class _MetaballExperimentState extends State<MetaballExperiment> with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader; // fill mask (normal sizes)
  ui.FragmentShader? _borderShader; // border mask (shapes inflated by borderWidth)
  String? _loadError;

  static const double _borderWidth = 1.0;

  double _blend = 40.0;
  int _selectedIndex = 0;

  Offset? _pointerPos; // last known pointer position, kept alive until spring fully settles
  bool _pointerDown = false;

  late final _SpringSim _radiusSpring = _SpringSim(
    springConstant: 50,
    dampingCoefficient: 10,
    mass: 2,
    initial: 0,
    target: 0,
  );
  late final Ticker _ticker;
  Duration? _lastTick;
  Timer? _bounceTimer;

  static const double _radiusPeak = 40.0;
  static const double _radiusRest = 20.80;
  static const double _radiusOff = 0.0;

  final List<Color> _palette = [
    const Color(0xFF4F7EFF),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFFFF8C42),
  ];

  late List<MetaballBlob> _blobs;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _blobs = [
      MetaballBlob(
        position: const Offset(160, 250),
        width: 120,
        height: 120,
        cornerRadius: 32,
        shape: MetaballShape.roundedRect,
        color: const Color(0xFF4F7EFF),
      ),
      MetaballBlob(
        position: const Offset(310, 250),
        width: 100,
        height: 100,
        cornerRadius: 50,
        shape: MetaballShape.ellipse,
        color: const Color(0xFFFF6B6B),
      ),
      MetaballBlob(
        position: const Offset(230, 380),
        width: 90,
        height: 90,
        cornerRadius: 24,
        shape: MetaballShape.roundedRect,
        color: const Color(0xFF4ECDC4),
      ),
    ];
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/metaball.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
          _borderShader = program.fragmentShader();
        });
      }
    } catch (e, st) {
      debugPrint('MetaballExperiment: shader load failed\n$e\n$st');
      if (mounted) {
        setState(() => _loadError = '$e');
      }
    }
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);
    if (_radiusSpring.isActive) {
      _radiusSpring.step(elapsedMs);
      setState(() {
        // Once fully settled at zero (not just down-crossing), clear pointer.
        if (!_radiusSpring.isActive && _radiusSpring.target == _radiusOff) {
          _pointerPos = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    _shader?.dispose();
    _borderShader?.dispose();
    super.dispose();
  }

  void _onPointerDown(Offset pos) {
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
    if (!_pointerDown) return;
    setState(() => _pointerPos = pos);
  }

  void _onPointerUp() {
    _bounceTimer?.cancel();
    _pointerDown = false;
    _radiusSpring.target = _radiusOff;
    // Keep _pointerPos alive — _onTick will clear it once the spring settles.
  }

  void _addBlob(Offset center) {
    setState(() {
      _blobs.add(
        MetaballBlob(
          position: center,
          width: 90,
          height: 90,
          cornerRadius: 28,
          shape: MetaballShape.roundedRect,
          color: _palette[_blobs.length % _palette.length],
        ),
      );
      _selectedIndex = _blobs.length - 1;
    });
  }

  void _removeSelected() {
    if (_blobs.length <= 1) return;
    setState(() {
      _blobs.removeAt(_selectedIndex);
      _selectedIndex = (_selectedIndex - 1).clamp(0, _blobs.length - 1);
    });
  }

  MetaballBlob get _selected => _blobs[_selectedIndex];

  void _updateSelected(MetaballBlob updated) {
    setState(() => _blobs[_selectedIndex] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return LdScaffold(
      body: LdAppBar(
        title: const Text('Metaball Experiment'),
        child: LdScaffoldBody(
          addContainer: false,
          children: [
            _buildCanvas(theme),
            Padding(
              padding: theme.pad(size: LdSize.m),
              child: _buildControls(theme),
            ),
            const LdDivider(),
            const _MorphDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(LdTheme theme) {
    return AspectRatio(
      aspectRatio: 2.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Listener(
            onPointerDown: (e) => _onPointerDown(e.localPosition),
            onPointerMove: (e) => _onPointerMove(e.localPosition),
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) => _onPointerUp(),
            child: GestureDetector(
              onDoubleTapDown: (details) => _addBlob(details.localPosition),
              child: Container(
                width: size.width,
                height: size.height,
                color: theme.background,
                child: Stack(
                  children: [
                    // ---- Metaball layer (widget content masked by shader) ----
                    if (_loadError != null)
                      Center(
                        child: Padding(
                          padding: theme.pad(size: LdSize.m),
                          child: LdHint(
                            type: LdHintType.error,
                            withBackground: true,
                            child: LdText('Shader failed to load:\n$_loadError'),
                          ),
                        ),
                      )
                    else if (_shader == null)
                      const Center(child: LdLoader())
                    else
                      Positioned.fill(
                        child: _MetaballMasked(
                          shader: _shader!,
                          borderShader: _borderShader!,
                          blobs: _blobs,
                          blend: _blend,
                          pointerPos: _pointerPos,
                          pointerRadius: _radiusSpring.position * 1,
                          surfaceColor: theme.surface,
                          borderColor: theme.border,
                          borderWidth: _borderWidth,
                        ),
                      ),

                    // ---- Drag handles ----
                    for (int i = 0; i < _blobs.length; i++)
                      _BlobHandle(
                        blob: _blobs[i],
                        selected: i == _selectedIndex,
                        onTap: () => setState(() => _selectedIndex = i),
                        onDrag: (d) {
                          setState(() {
                            final b = _blobs[i];
                            _blobs[i] = b.copyWith(
                              position: Offset(
                                (b.position.dx + d.delta.dx).clamp(0, size.width),
                                (b.position.dy + d.delta.dy).clamp(0, size.height),
                              ),
                            );
                          });
                        },
                      ),

                    // ---- Help hint ----
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: LdText.pxs('Drag blobs  •  double-tap to add', color: theme.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(LdTheme theme) {
    final blob = _selected;

    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Blend radius ----
        Row(children: [LdText.l('Blend radius'), const Spacer(), LdText.ls('${_blend.round()} px')]),
        Slider(value: _blend, min: 0, max: 120, onChanged: (v) => setState(() => _blend = v)),

        const LdDivider(),

        // ---- Selected blob header ----
        Row(
          children: [
            LdText.hs('Blob ${_selectedIndex + 1} / ${_blobs.length}'),
            const Spacer(),
            LdButton(
              size: LdSize.s,
              mode: LdButtonMode.ghost,
              disabled: _blobs.length <= 1,
              onPressed: () async => _removeSelected(),
              leading: const Icon(LucideIcons.trash2),
              child: const Text('Remove'),
            ),
          ],
        ),

        // ---- Color picker ----
        Row(
          children: [
            LdText.l('Color'),
            const SizedBox(width: 12),
            for (final c in _palette)
              GestureDetector(
                onTap: () => _updateSelected(blob.copyWith(color: c)),
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: blob.color == c
                        ? Border.all(
                            color: theme.text.withValues(alpha: 0.7),
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),

        // ---- Shape type ----
        LdSelect<MetaballShape>(
          label: 'Shape',
          value: blob.shape,
          onChanged: (v) => _updateSelected(blob.copyWith(shape: v)),
          items: const [
            LdSelectItem(value: MetaballShape.roundedRect, child: Text('Rounded rect')),
            LdSelectItem(value: MetaballShape.ellipse, child: Text('Ellipse')),
          ],
        ),

        // ---- Width ----
        Row(children: [LdText.l('Width'), const Spacer(), LdText.ls('${blob.width.round()} px')]),
        Slider(
          value: blob.width,
          min: 40,
          max: 220,
          onChanged: (v) => _updateSelected(blob.copyWith(width: v)),
        ),

        // ---- Height ----
        Row(children: [LdText.l('Height'), const Spacer(), LdText.ls('${blob.height.round()} px')]),
        Slider(
          value: blob.height,
          min: 40,
          max: 220,
          onChanged: (v) => _updateSelected(blob.copyWith(height: v)),
        ),

        // ---- Corner radius (rounded rect only) ----
        if (blob.shape == MetaballShape.roundedRect) ...[
          Row(children: [LdText.l('Corner radius'), const Spacer(), LdText.ls('${blob.cornerRadius.round()} px')]),
          Slider(
            value: blob.cornerRadius,
            min: 0,
            max: 80,
            onChanged: (v) => _updateSelected(blob.copyWith(cornerRadius: v)),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _MetaballMasked — two stacked ShaderMask layers:
//   1. Border layer  — shapes inflated by borderWidth, filled with borderColor
//   2. Fill layer    — normal shapes, filled with surfaceColor + icon labels
//
// Both use ShaderMask(blendMode: BlendMode.dstIn) which correctly composites
// the child into an offscreen buffer before masking.
// ---------------------------------------------------------------------------

class _MetaballMasked extends StatelessWidget {
  final ui.FragmentShader shader;
  final ui.FragmentShader borderShader;
  final List<MetaballBlob> blobs;
  final double blend;
  final Offset? pointerPos;
  final double pointerRadius;
  final Color surfaceColor;
  final Color borderColor;
  final double borderWidth;

  /// Optional override for the fill-layer content. When provided, receives the
  /// current [blobs] list and replaces the default [_BlobLabel] overlays.
  final Widget Function(BuildContext context, List<MetaballBlob> blobs)? contentBuilder;

  const _MetaballMasked({
    required this.shader,
    required this.borderShader,
    required this.blobs,
    required this.blend,
    required this.surfaceColor,
    required this.borderColor,
    required this.borderWidth,
    this.pointerPos,
    this.pointerRadius = 0,
    this.contentBuilder,
  });

  /// Write uniforms into [s]. When [expand] > 0 each blob's width/height is
  /// inflated by that many logical pixels, producing the border mask.
  void _setUniforms(ui.FragmentShader s, Size size, {double expand = 0}) {
    final int n = blobs.length.clamp(0, 15);

    s.setFloat(0, size.width);
    s.setFloat(1, size.height);
    s.setFloat(2, blend);
    s.setFloat(3, n.toDouble());

    final active = pointerPos != null;
    s.setFloat(4, active ? 1.0 : 0.0);
    s.setFloat(5, active ? pointerPos!.dx : 0.0);
    s.setFloat(6, active ? pointerPos!.dy : 0.0);
    s.setFloat(7, active ? pointerRadius : 0.0);

    for (int i = 0; i < 15; i++) {
      final base = 8 + i * 6;
      if (i < n) {
        final blob = blobs[i];
        final type = blob.shape == MetaballShape.ellipse ? 2.0 : 1.0;
        s.setFloat(base + 0, type);
        s.setFloat(base + 1, blob.position.dx);
        s.setFloat(base + 2, blob.position.dy);
        s.setFloat(base + 3, blob.width + expand * 2);
        s.setFloat(base + 4, blob.height + expand * 2);
        s.setFloat(base + 5, blob.cornerRadius);
      } else {
        s.setFloat(base + 0, 1.0);
        s.setFloat(base + 1, -99999.0);
        s.setFloat(base + 2, -99999.0);
        s.setFloat(base + 3, 0.0);
        s.setFloat(base + 4, 0.0);
        s.setFloat(base + 5, 0.0);
      }
    }
  }

  Widget _maskedLayer({required ui.FragmentShader s, required double expand, required Widget child}) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        _setUniforms(s, bounds.size, expand: expand);
        return s;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ---- Border layer (inflated shapes, border color) ----
        _maskedLayer(
          s: borderShader,
          expand: borderWidth,
          child: ColoredBox(color: borderColor, child: const SizedBox.expand()),
        ),

        // ---- Fill layer (normal shapes, surface color + labels) ----
        _maskedLayer(
          s: shader,
          expand: 0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: surfaceColor, child: const SizedBox.expand()),
              if (contentBuilder != null)
                Builder(builder: (ctx) => contentBuilder!(ctx, blobs))
              else
                for (int i = 0; i < blobs.length; i++) _BlobLabel(blob: blobs[i], index: i),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Morph transition demo
//
// A button blob smooth-unions into a menu blob as it opens.
// Two _SpringSim instances drive the sizes independently — button shrinks to
// zero while menu grows to full size, the blend zone making them appear to
// flow into each other.
// ---------------------------------------------------------------------------

class _MorphDemo extends StatefulWidget {
  const _MorphDemo();

  @override
  State<_MorphDemo> createState() => _MorphDemoState();
}

class _MorphDemoState extends State<_MorphDemo> with SingleTickerProviderStateMixin {
  // Shader instances — loaded from the same FragmentProgram as the main demo.
  ui.FragmentShader? _shader;
  ui.FragmentShader? _borderShader;

  bool _open = false;

  // Pointer influence — same mechanics as the main demo.
  Offset? _pointerPos;
  bool _pointerDown = false;
  late final _SpringSim _radiusSpring = _SpringSim(
    springConstant: 80,
    dampingCoefficient: 10,
    mass: 1,
    initial: 0,
    target: 0,
  );
  static const double _radiusPeak = 40.0;
  static const double _radiusRest = 20.8;
  static const double _radiusOff = 0.0;
  Timer? _bounceTimer;

  // Full sizes
  static const double _btnW = 140;
  static const double _btnH = 48;
  static const double _menuW = 240;
  static const double _menuH = 130;

  // Blend radius: starts large (liquid mass) and springs down as shapes separate.
  static const double _blendOpen = 10;
  static const double _blendClosed = 10;

  // Canvas / layout constants — kept here so springs can use them at init time.
  static const double _canvasH = 300.0;
  static const double _btnCy = _canvasH - 48;
  static const double _menuCyFinal = _canvasH - _btnH - _menuH / 2 - 32;

  // Button size spring: full → 0 when opening
  late final _SpringSim _btnSpring = _SpringSim(
    springConstant: 80,
    dampingCoefficient: 18,
    mass: 1,
    initial: 1,
    target: 1,
  );

  // Menu size spring: 0 → full when opening
  late final _SpringSim _menuSpring = _SpringSim(
    springConstant: 80,
    dampingCoefficient: 18,
    mass: 1,
    initial: 0,
    target: 0,
  );

  late final Ticker _ticker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _loadShaders();
  }

  Future<void> _loadShaders() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/metaball.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
          _borderShader = program.fragmentShader();
        });
      }
    } catch (e) {
      debugPrint('_MorphDemo: shader load failed: $e');
    }
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);
    if (_btnSpring.isActive || _menuSpring.isActive || _radiusSpring.isActive) {
      _btnSpring.step(elapsedMs);
      _menuSpring.step(elapsedMs);

      _radiusSpring.step(elapsedMs);
      if (!_radiusSpring.isActive && _radiusSpring.target == _radiusOff) {
        _pointerPos = null;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    _shader?.dispose();
    _borderShader?.dispose();
    super.dispose();
  }

  bool get _transitioning => _btnSpring.isActive || _menuSpring.isActive;

  void _onPointerDown(Offset pos) {
    setState(() => _pointerPos = pos);
    _pointerDown = true;
    _radiusSpring.target = _radiusPeak;
    _bounceTimer?.cancel();
    _bounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (_pointerDown) _radiusSpring.target = _radiusRest;
    });
  }

  void _onPointerMove(Offset pos) {
    if (!_pointerDown) return;
    setState(() => _pointerPos = pos);
  }

  void _onPointerUp() {
    _pointerDown = false;
    _radiusSpring.target = _radiusOff;
  }

  void _toggle() {
    setState(() => _open = !_open);
    _btnSpring.target = _open ? 0.0 : 1.0;
    _menuSpring.target = _open ? 1.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    // Compute actual sizes from spring positions (0..1 scale factor).

    final menuScale = _menuSpring.position;

    final btnW = _btnW;
    final btnH = _btnH;
    final menuW = (btnW + (_menuW - btnW) * menuScale) * menuScale;
    final menuH = (btnH + (_menuH - btnH) * menuScale) * menuScale;
    final menuCy = _btnCy + (_menuCyFinal - _btnCy) * menuScale;
    final menuFinalRadius = 20;
    final btnRadius = btnH / 2;
    final menuRadius = btnRadius + (menuFinalRadius - btnRadius) * menuScale;

    // Canvas is tall enough to hold both shapes with some padding.
    const canvasW = 320.0;

    // Button sits near the bottom-center; menu Y is spring-driven.
    const cx = canvasW / 2;

    final blobs = [
      // Button blob (index 1)
      MetaballBlob(
        position: const Offset(cx, _btnCy),
        width: btnW,
        height: btnH,
        cornerRadius: _btnH / 2,
        shape: MetaballShape.roundedRect,
        color: theme.surface,
      ),

      // Menu blob (index 0)
      MetaballBlob(
        position: Offset(cx, menuCy),
        width: menuW,
        height: menuH,
        cornerRadius: menuRadius,
        shape: MetaballShape.roundedRect,
        color: theme.surface,
      ),
    ].toList();

    return Padding(
      padding: LdTheme.of(context).pad(size: LdSize.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdText.hs('Morph transition'),
          ldSpacerS,
          LdText.p('A button morphs into a menu using metaball smooth-union.', color: theme.textMuted),
          ldSpacerM,
          Listener(
            onPointerDown: (e) => _onPointerDown(e.localPosition),
            onPointerMove: (e) => _onPointerMove(e.localPosition),
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) => _onPointerUp(),
            child: SizedBox(
              width: canvasW,
              height: _canvasH,
              child: _shader == null
                  ? const Center(child: LdLoader())
                  : _MetaballMasked(
                      shader: _shader!,
                      borderShader: _borderShader!,
                      blobs: blobs,
                      blend: _blendClosed + (_blendOpen - _blendClosed) * (1 - _menuSpring.position),
                      surfaceColor: theme.surface,
                      borderColor: theme.border,
                      borderWidth: 1.0,
                      pointerPos: _pointerPos,
                      pointerRadius: _radiusSpring.position,
                      // Content layer — button and menu widgets
                      contentBuilder: (context, blobs) => _MorphContent(
                        blobs: blobs,
                        open: _open,

                        menuScale: menuScale,
                        onToggle: _toggle,
                        btnW: _btnW,
                        btnH: _btnH,
                        menuW: _menuW,
                        menuH: _menuH,
                        transitioning: _transitioning,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content rendered inside the morph blobs.
// ---------------------------------------------------------------------------

class _MorphContent extends StatelessWidget {
  final List<MetaballBlob> blobs;
  final bool open;

  final double menuScale;
  final VoidCallback onToggle;
  final double btnW;
  final double btnH;
  final double menuW;
  final double menuH;
  final bool transitioning;

  const _MorphContent({
    required this.blobs,
    required this.open,

    required this.menuScale,
    required this.onToggle,
    required this.btnW,
    required this.btnH,
    required this.menuW,
    required this.menuH,
    required this.transitioning,
  });

  static const _menuItems = [
    (LucideIcons.pencil, 'Edit'),
    (LucideIcons.copy, 'Duplicate'),
    (LucideIcons.share, 'Share'),
    (LucideIcons.trash2, 'Delete'),
  ];

  @override
  Widget build(BuildContext context) {
    // Menu blob is index 0, button blob is index 1 (when both present).
    // Find them by size.
    MetaballBlob? btnBlob = blobs[0];
    MetaballBlob? menuBlob = blobs[1];
    return Stack(
      fit: StackFit.expand,
      children: [
        // ---- Menu content — centered on blob, shader masks to blob boundary ----
        if (menuScale > 0.01)
          Positioned(
            left: menuBlob.position.dx - menuW / 2,
            top: menuBlob.position.dy - menuH / 2,
            width: menuW,
            height: menuH,
            child: IgnorePointer(
              ignoring: transitioning,
              child: Opacity(
                opacity: menuScale.clamp(0.0, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final (icon, label) in _menuItems)
                      LdListItem(leading: Icon(icon, size: 18), title: Text(label), onPressed: onToggle),
                  ],
                ),
              ),
            ),
          ),

        // ---- Button content — centered on blob, shader masks to blob boundary ----
        Positioned(
          left: btnBlob.position.dx - btnW / 2,
          top: btnBlob.position.dy - btnH / 2,
          width: btnW,
          height: btnH,
          child: IgnorePointer(
            ignoring: transitioning,
            child: Center(
              child: LdButton.ghost(
                onPressed: () async => onToggle(),
                leading: const Icon(LucideIcons.layoutGrid),
                child: const Text('Actions'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
