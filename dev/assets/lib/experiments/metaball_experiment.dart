import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Re-export the old internal shape/blob types under the old names so the
// lower-level demos below can still reference them.
// ---------------------------------------------------------------------------

// (MetaballShape / MetaballBlob are now LdMetaballShape / LdMetaballBlob in
//  the library.  The aliases below keep the experiment readable.)
typedef MetaballShape = LdMetaballShape;
typedef MetaballBlob = LdMetaballBlob;
const MetaballShape roundedRect = LdMetaballShape.roundedRect;
const MetaballShape ellipse = LdMetaballShape.ellipse;

/// Maximum number of metaball shapes the shader supports.
const int _kMetaballMaxShapes = kLdMetaballMaxBlobs;

// ---------------------------------------------------------------------------
// Main experiment page
// ---------------------------------------------------------------------------

class MetaballExperiment extends StatelessWidget {
  const MetaballExperiment({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the whole page in a single shader scope so the interactive
    // playground and the morph demo share one FragmentProgram load.
    return LdMetaballShaderScope(
      child: LdScaffold(
        body: LdAppBar(
          title: const Text('Metaball Experiment'),
          child: LdScaffoldBody(
            addContainer: false,
            children: [
              // --- Demo 1: High-level LdMetaball (auto-layout, no blob math) ---
              const _SimpleMetaballDemo(),
              const LdDivider(),

              // --- Demo 2: Interactive playground (low-level LdMetaballMask) ---
              const _InteractivePlayground(),
              const LdDivider(),

              // --- Demo 3: Button → menu morph (LdMetaballMask + springs) ---
              const _MorphDemo(),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Demo 1 — Simple high-level LdMetaball
//
// Shows LdMetaball with LdMetaballChild children.  No blob math, no shader
// management — the widgets discover their own positions.
// ===========================================================================

class _SimpleMetaballDemo extends StatefulWidget {
  const _SimpleMetaballDemo();

  @override
  State<_SimpleMetaballDemo> createState() => _SimpleMetaballDemoState();
}

class _SimpleMetaballDemoState extends State<_SimpleMetaballDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Padding(
      padding: theme.pad(size: LdSize.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdText.hs('High-level LdMetaball'),
          ldSpacerS,
          LdText.p(
            'Children declare their own shape. LdMetaball measures each '
            'widget and feeds the blobs to the shader automatically.',
            color: theme.textMuted,
          ),
          ldSpacerM,
          // The LdMetaball widget — children are normal Flutter widgets.
          LdMetaball(
            surfaceColor: theme.surface,
            borderColor: theme.border,
            blend: 30,
            children: [
              // A pill button blob
              LdMetaballChild(
                shape: LdMetaballShape.roundedRect,
                cornerRadius: 24,
                child: GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    width: _expanded ? 200 : 140,
                    height: 48,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _expanded ? LucideIcons.x : LucideIcons.layoutGrid,
                          color: theme.text,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _expanded ? 'Close' : 'Actions',
                          style: TextStyle(
                            color: theme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // A small circle blob that appears when expanded
              if (_expanded)
                LdMetaballChild(
                  shape: LdMetaballShape.ellipse,
                  child: Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(LucideIcons.star, color: theme.text, size: 18),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Demo 2 — Interactive playground (low-level LdMetaballMask)
//
// Preserves the original draggable-blob playground, now using the public
// API types (LdMetaballBlob, LdMetaballShape, LdMetaballMask).
// ===========================================================================

// ---------------------------------------------------------------------------
// Icon + label overlay for a single blob
// ---------------------------------------------------------------------------

class _BlobLabel extends StatelessWidget {
  final LdMetaballBlob blob;
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

  static const _labels = [
    'Design',
    'Explore',
    'Energy',
    'Rhythm',
    'Bright',
    'Cloud',
    'Spark',
    'Gem',
  ];

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
// Draggable blob handle
// ---------------------------------------------------------------------------

class _BlobHandle extends StatelessWidget {
  final LdMetaballBlob blob;
  final bool selected;
  final VoidCallback onTap;
  final void Function(DragUpdateDetails) onDrag;

  const _BlobHandle({
    required this.blob,
    required this.selected,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: blob.position.dx - blob.width / 2 - 4,
      top: blob.position.dy - blob.height / 2 - 4,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: onDrag,
        child: Container(
          width: blob.width + 8,
          height: blob.height + 8,
          decoration: const BoxDecoration(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal Euler-integration spring
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
// Interactive playground
// ---------------------------------------------------------------------------

class _InteractivePlayground extends StatefulWidget {
  const _InteractivePlayground();

  @override
  State<_InteractivePlayground> createState() => _InteractivePlaygroundState();
}

class _InteractivePlaygroundState extends State<_InteractivePlayground>
    with SingleTickerProviderStateMixin {
  static const double _borderWidth = 1.0;

  double _blend = 40.0;
  int _selectedIndex = 0;

  Offset? _pointerPos;
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

  late List<LdMetaballBlob> _blobs;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _blobs = [
      const LdMetaballBlob(
        position: Offset(160, 250),
        width: 120,
        height: 120,
        cornerRadius: 32,
        shape: LdMetaballShape.roundedRect,
      ),
      const LdMetaballBlob(
        position: Offset(310, 250),
        width: 100,
        height: 100,
        cornerRadius: 50,
        shape: LdMetaballShape.ellipse,
      ),
      const LdMetaballBlob(
        position: Offset(230, 380),
        width: 90,
        height: 90,
        cornerRadius: 24,
        shape: LdMetaballShape.roundedRect,
      ),
    ];
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);
    if (_radiusSpring.isActive) {
      _radiusSpring.step(elapsedMs);
      setState(() {
        if (!_radiusSpring.isActive && _radiusSpring.target == _radiusOff) {
          _pointerPos = null;
        }
      });
    }
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
  }

  void _addBlob(Offset center) {
    if (_blobs.length >= _kMetaballMaxShapes) return;
    setState(() {
      _blobs.add(LdMetaballBlob(
        position: center,
        width: 90,
        height: 90,
        cornerRadius: 28,
        shape: LdMetaballShape.roundedRect,
      ));
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

  LdMetaballBlob get _selected => _blobs[_selectedIndex];

  void _updateSelected(LdMetaballBlob updated) {
    setState(() => _blobs[_selectedIndex] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    // Resolve shaders from the nearest scope
    final shaders = LdMetaballShaderScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCanvas(theme, shaders),
        Padding(
          padding: theme.pad(size: LdSize.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LdText.hs('Interactive playground'),
              ldSpacerS,
              LdText.p(
                'Low-level LdMetaballMask — manage blobs manually for full '
                'control. Double-tap the canvas to add a blob.',
                color: theme.textMuted,
              ),
              ldSpacerM,
              _buildControls(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas(LdTheme theme, LdMetaballShaders? shaders) {
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
              onDoubleTapDown: (d) => _addBlob(d.localPosition),
              child: Container(
                width: size.width,
                height: size.height,
                color: theme.background,
                child: Stack(
                  children: [
                    if (shaders == null)
                      const Center(child: LdLoader())
                    else
                      Positioned.fill(
                        child: LdMetaballMask(
                          shader: shaders.fill,
                          borderShader: shaders.border,
                          blobs: _blobs,
                          blend: _blend,
                          pointerPos: _pointerPos,
                          pointerRadius: _radiusSpring.position,
                          surfaceColor: theme.surface,
                          borderColor: theme.border,
                          borderWidth: _borderWidth,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              for (int i = 0; i < _blobs.length; i++)
                                _BlobLabel(blob: _blobs[i], index: i),
                            ],
                          ),
                        ),
                      ),

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
                                (b.position.dx + d.delta.dx)
                                    .clamp(0, size.width),
                                (b.position.dy + d.delta.dy)
                                    .clamp(0, size.height),
                              ),
                            );
                          });
                        },
                      ),

                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: LdText.pxs(
                            'Drag blobs  •  double-tap to add',
                            color: theme.textMuted,
                          ),
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
        Row(children: [
          LdText.l('Blend radius'),
          const Spacer(),
          LdText.ls('${_blend.round()} px'),
        ]),
        Slider(
          value: _blend,
          min: 0,
          max: 120,
          onChanged: (v) => setState(() => _blend = v),
        ),
        const LdDivider(),
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
        Row(
          children: [
            LdText.l('Color'),
            const SizedBox(width: 12),
            for (final c in _palette)
              GestureDetector(
                onTap: () => setState(() {}), // color not stored in blob anymore
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        LdSelect<LdMetaballShape>(
          label: 'Shape',
          value: blob.shape,
          onChanged: (v) => _updateSelected(blob.copyWith(shape: v)),
          items: const [
            LdSelectItem(
              value: LdMetaballShape.roundedRect,
              child: Text('Rounded rect'),
            ),
            LdSelectItem(
              value: LdMetaballShape.ellipse,
              child: Text('Ellipse'),
            ),
          ],
        ),
        Row(children: [
          LdText.l('Width'),
          const Spacer(),
          LdText.ls('${blob.width.round()} px'),
        ]),
        Slider(
          value: blob.width,
          min: 40,
          max: 220,
          onChanged: (v) => _updateSelected(blob.copyWith(width: v)),
        ),
        Row(children: [
          LdText.l('Height'),
          const Spacer(),
          LdText.ls('${blob.height.round()} px'),
        ]),
        Slider(
          value: blob.height,
          min: 40,
          max: 220,
          onChanged: (v) => _updateSelected(blob.copyWith(height: v)),
        ),
        if (blob.shape == LdMetaballShape.roundedRect) ...[
          Row(children: [
            LdText.l('Corner radius'),
            const Spacer(),
            LdText.ls('${blob.cornerRadius.round()} px'),
          ]),
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

// ===========================================================================
// Demo 3 — Morph transition (LdMetaballMask + springs)
//
// A button blob smooth-unions into a menu blob as it opens.
// Uses LdMetaballMask directly for full control over blob geometry.
// ===========================================================================

class _MorphDemo extends StatefulWidget {
  const _MorphDemo();

  @override
  State<_MorphDemo> createState() => _MorphDemoState();
}

class _MorphDemoState extends State<_MorphDemo>
    with SingleTickerProviderStateMixin {
  bool _open = false;

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

  static const double _btnW = 140;
  static const double _btnH = 48;
  static const double _menuW = 240;
  static const double _menuH = 130;
  static const double _blendOpen = 10;
  static const double _blendClosed = 10;
  static const double _canvasH = 300.0;
  static const double _btnCy = _canvasH - 48;
  static const double _menuCyFinal = _canvasH - _btnH - _menuH / 2 - 32;

  late final _SpringSim _btnSpring = _SpringSim(
    springConstant: 80,
    dampingCoefficient: 18,
    mass: 1,
    initial: 1,
    target: 1,
  );
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
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bounceTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final elapsedMs = (elapsed - last).inMilliseconds.clamp(1, 64);
    if (_btnSpring.isActive ||
        _menuSpring.isActive ||
        _radiusSpring.isActive) {
      _btnSpring.step(elapsedMs);
      _menuSpring.step(elapsedMs);
      _radiusSpring.step(elapsedMs);
      if (!_radiusSpring.isActive && _radiusSpring.target == _radiusOff) {
        _pointerPos = null;
      }
      setState(() {});
    }
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
    final shaders = LdMetaballShaderScope.of(context);

    final menuScale = _menuSpring.position;
    const btnW = _btnW;
    const btnH = _btnH;
    final menuW = (btnW + (_menuW - btnW) * menuScale) * menuScale;
    final menuH = (btnH + (_menuH - btnH) * menuScale) * menuScale;
    final menuCy = _btnCy + (_menuCyFinal - _btnCy) * menuScale;
    const menuFinalRadius = 20;
    final btnRadius = btnH / 2;
    final menuRadius = btnRadius + (menuFinalRadius - btnRadius) * menuScale;

    const canvasW = 320.0;
    const cx = canvasW / 2;

    final blobs = [
      LdMetaballBlob(
        position: const Offset(cx, _btnCy),
        width: btnW,
        height: btnH,
        cornerRadius: _btnH / 2,
        shape: LdMetaballShape.roundedRect,
      ),
      LdMetaballBlob(
        position: Offset(cx, menuCy),
        width: menuW,
        height: menuH,
        cornerRadius: menuRadius,
        shape: LdMetaballShape.roundedRect,
      ),
    ];

    return Padding(
      padding: LdTheme.of(context).pad(size: LdSize.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdText.hs('Morph transition'),
          ldSpacerS,
          LdText.p(
            'A button morphs into a menu using metaball smooth-union. '
            'Uses LdMetaballMask directly for full geometry control.',
            color: theme.textMuted,
          ),
          ldSpacerM,
          Listener(
            onPointerDown: (e) => _onPointerDown(e.localPosition),
            onPointerMove: (e) => _onPointerMove(e.localPosition),
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) => _onPointerUp(),
            child: SizedBox(
              width: canvasW,
              height: _canvasH,
              child: shaders == null
                  ? const Center(child: LdLoader())
                  : LdMetaballMask(
                      shader: shaders.fill,
                      borderShader: shaders.border,
                      blobs: blobs,
                      blend: _blendClosed +
                          (_blendOpen - _blendClosed) *
                              (1 - _menuSpring.position),
                      surfaceColor: theme.surface,
                      borderColor: theme.border,
                      borderWidth: 1.0,
                      pointerPos: _pointerPos,
                      pointerRadius: _radiusSpring.position,
                      child: _MorphContent(
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
// Content rendered inside the morph blobs
// ---------------------------------------------------------------------------

class _MorphContent extends StatelessWidget {
  final List<LdMetaballBlob> blobs;
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
    final btnBlob = blobs[0];
    final menuBlob = blobs[1];
    return Stack(
      fit: StackFit.expand,
      children: [
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
                      LdListItem(
                        leading: Icon(icon, size: 18),
                        title: Text(label),
                        onPressed: onToggle,
                      ),
                  ],
                ),
              ),
            ),
          ),
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
