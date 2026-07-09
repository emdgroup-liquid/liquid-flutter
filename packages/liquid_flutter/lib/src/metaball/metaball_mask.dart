import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

import 'metaball_blob.dart';

/// Maximum number of blobs the shader supports.
/// Capped at 12 to stay within Metal's 30 fragment-buffer-slot limit on iOS.
const int kLdMetaballMaxBlobs = 12;

// ---------------------------------------------------------------------------
// LdMetaballMask
// ---------------------------------------------------------------------------

/// A pure rendering primitive that applies a smooth-union metaball mask
/// to its [child].
///
/// Rendering uses two layers from the same shader program:
///   1. **Border layer** (optional) — a `CustomPaint` that outputs the border
///      ring color directly (mode 1). The ring is computed as the band between
///      the fill boundary and `d = borderWidth`, so it exactly hugs the
///      smooth-union shape with no blurriness regardless of border width.
///   2. **Fill layer** — a `ShaderMask` (mode 0) that clips [surfaceColor] and
///      [child] to the metaball shape via `BlendMode.dstIn`.
///
/// [LdMetaballMask] is intentionally stateless — it does not own shader
/// instances. Provide [shader] (fill/mode-0) and optionally [borderShader]
/// (border/mode-1) from the same `FragmentProgram`. Load with
/// `ui.FragmentProgram.fromAsset(...)` and call `.fragmentShader()` for each.
///
/// For a fully self-contained widget (shader loading + blob tracking included),
/// use [LdMetaballScope] with [LdMetaball] children instead.
class LdMetaballMask extends StatelessWidget {
  /// Fill-mask shader (mode 0) — used with ShaderMask+dstIn to clip content.
  final ui.FragmentShader shader;

  /// Border ring shader (mode 1) — outputs borderColor * ringAlpha directly.
  /// When null (or [borderColor] is null), no border is drawn.
  final ui.FragmentShader? borderShader;

  /// The blobs to render. Up to [kLdMetaballMaxBlobs] blobs are supported;
  /// any extras are silently ignored.
  final List<LdMetaballBlob> blobs;

  /// Controls how aggressively neighbouring blobs are blended together.
  /// 0 = hard-edged union; higher values = thicker liquid neck between blobs.
  /// Sensible range: 10–80.
  final double blend;

  /// Colour used to fill the interior of all blobs.
  final Color surfaceColor;

  /// Colour of the border ring. When null, no border is drawn.
  final Color? borderColor;

  /// Pixel width of the border ring. Defaults to 1.
  final double borderWidth;

  /// When non-null (and [pointerRadius] > 0), the shader applies a radial
  /// deformation bell at this position — the liquid "squishes" toward or away
  /// from the pointer.
  ///
  /// Coordinates are in the local space of this widget.
  final Offset? pointerPos;

  /// Radius of the pointer influence bell. When 0 the influence is inactive.
  final double pointerRadius;

  /// Widget rendered inside the fill layer, clipped to the metaball shape.
  final Widget? child;

  const LdMetaballMask({
    super.key,
    required this.shader,
    this.borderShader,
    required this.blobs,
    required this.surfaceColor,
    this.borderColor,
    this.blend = 40,
    this.borderWidth = 1,
    this.pointerPos,
    this.pointerRadius = 0,
    this.child,
  });

  // -------------------------------------------------------------------------
  // Uniform writers
  // -------------------------------------------------------------------------

  /// Writes uniforms for the **fill** shader (mode 0).
  ///
  /// Uniform layout:
  ///   0-3   : u0  (sizeW, sizeH, blend, numShapes)
  ///   4-7   : u1  (pointerActive, pointerCx, pointerCy, pointerR)
  ///   8-11  : u2  (mode=0, borderWidth=0, pad, pad)
  ///   12-15 : u3  (borderColor — unused in mode 0, zeroed)
  ///   16+   : shapes (12 × 8 floats)
  static void setFillUniforms(
    ui.FragmentShader s,
    Size size,
    List<LdMetaballBlob> blobs,
    double blend, {
    Offset? pointerPos,
    double pointerRadius = 0,
  }) {
    _writeCommon(s, size, blobs, blend,
        pointerPos: pointerPos,
        pointerRadius: pointerRadius,
        mode: 0,
        borderWidth: 0,
        borderColor: const Color(0x00000000));
  }

  /// Writes uniforms for the **border** shader (mode 1).
  ///
  /// Same layout as fill; mode=1, borderWidth and borderColor are active.
  static void setBorderUniforms(
    ui.FragmentShader s,
    Size size,
    List<LdMetaballBlob> blobs,
    double blend, {
    Offset? pointerPos,
    double pointerRadius = 0,
    required double borderWidth,
    required Color borderColor,
  }) {
    _writeCommon(s, size, blobs, blend,
        pointerPos: pointerPos,
        pointerRadius: pointerRadius,
        mode: 1,
        borderWidth: borderWidth,
        borderColor: borderColor);
  }

  /// Legacy entry point — sets fill uniforms (mode 0). Kept for compatibility
  /// with any code that calls [setUniforms] directly.
  static void setUniforms(
    ui.FragmentShader s,
    Size size,
    List<LdMetaballBlob> blobs,
    double blend, {
    Offset? pointerPos,
    double pointerRadius = 0,
  }) =>
      setFillUniforms(s, size, blobs, blend,
          pointerPos: pointerPos, pointerRadius: pointerRadius);

  static void _writeCommon(
    ui.FragmentShader s,
    Size size,
    List<LdMetaballBlob> blobs,
    double blend, {
    required Offset? pointerPos,
    required double pointerRadius,
    required int mode,
    required double borderWidth,
    required Color borderColor,
  }) {
    final int n = blobs.length.clamp(0, kLdMetaballMaxBlobs);

    // u0
    s.setFloat(0, size.width);
    s.setFloat(1, size.height);
    s.setFloat(2, blend);
    s.setFloat(3, n.toDouble());

    // u1
    final active = pointerPos != null;
    s.setFloat(4, active ? 1.0 : 0.0);
    s.setFloat(5, active ? pointerPos.dx : 0.0);
    s.setFloat(6, active ? pointerPos.dy : 0.0);
    s.setFloat(7, pointerRadius);

    // u2
    s.setFloat(8, mode.toDouble());
    s.setFloat(9, borderWidth);
    s.setFloat(10, 0.0);
    s.setFloat(11, 0.0);

    // u3 — borderColor (premultiplied). Color.r/g/b/a are already 0.0–1.0.
    final double a = borderColor.a;
    s.setFloat(12, borderColor.r * a);
    s.setFloat(13, borderColor.g * a);
    s.setFloat(14, borderColor.b * a);
    s.setFloat(15, a);

    // shapes
    for (int i = 0; i < kLdMetaballMaxBlobs; i++) {
      final base = 16 + i * 8;
      if (i < n) {
        final b = blobs[i];
        final type = b.shape == LdMetaballShape.ellipse ? 2.0 : 1.0;
        s.setFloat(base + 0, type);
        s.setFloat(base + 1, b.position.dx);
        s.setFloat(base + 2, b.position.dy);
        s.setFloat(base + 3, b.width);
        s.setFloat(base + 4, b.height);
        s.setFloat(base + 5, b.cornerRadius);
        s.setFloat(base + 6, 0.0);
        s.setFloat(base + 7, 0.0);
      } else {
        // Off-screen placeholder — contributes nothing to the union.
        s.setFloat(base + 0, 1.0);
        s.setFloat(base + 1, -99999.0);
        s.setFloat(base + 2, -99999.0);
        s.setFloat(base + 3, 0.0);
        s.setFloat(base + 4, 0.0);
        s.setFloat(base + 5, 0.0);
        s.setFloat(base + 6, 0.0);
        s.setFloat(base + 7, 0.0);
      }
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bs = borderShader;
    final bc = borderColor;
    final hasBorder = bs != null && bc != null;

    // Fill layer — ShaderMask clips surfaceColor + child to the metaball shape.
    Widget fillLayer = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        setFillUniforms(
          shader,
          bounds.size,
          blobs,
          blend,
          pointerPos: pointerPos,
          pointerRadius: pointerRadius,
        );
        return shader;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: surfaceColor, child: const SizedBox.expand()),
          if (child != null) child!,
        ],
      ),
    );

    if (!hasBorder) return fillLayer;

    // Border layer — CustomPaint outputs the ring color directly underneath
    // the fill. The ring is computed in the shader as the band between d=0
    // (fill inner edge) and d=borderWidth (outer edge), both with ±0.5px AA,
    // so it is always crisp regardless of borderWidth.
    // Border sits on top of the fill. ShaderMask+dstIn only clips its own
    // child subtree — it does not erase sibling layers — so the ring pixels
    // outside d=0 are visible even though the fill layer's mask would zero
    // them out inside its own subtree.
    //
    // CustomPaint needs an explicit size; SizedBox.expand() provides that.
    return Stack(
      fit: StackFit.expand,
      children: [
        fillLayer,
        SizedBox.expand(
          child: CustomPaint(
            painter: _MetaballBorderPainter(
              shader: bs,
              blobs: blobs,
              blend: blend,
              borderWidth: borderWidth,
              borderColor: bc,
              pointerPos: pointerPos,
              pointerRadius: pointerRadius,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _MetaballBorderPainter
// ---------------------------------------------------------------------------

class _MetaballBorderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final List<LdMetaballBlob> blobs;
  final double blend;
  final double borderWidth;
  final Color borderColor;
  final Offset? pointerPos;
  final double pointerRadius;

  const _MetaballBorderPainter({
    required this.shader,
    required this.blobs,
    required this.blend,
    required this.borderWidth,
    required this.borderColor,
    required this.pointerPos,
    required this.pointerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    LdMetaballMask.setBorderUniforms(
      shader,
      size,
      blobs,
      blend,
      pointerPos: pointerPos,
      pointerRadius: pointerRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_MetaballBorderPainter old) =>
      old.shader != shader ||
      old.blobs != blobs ||
      old.blend != blend ||
      old.borderWidth != borderWidth ||
      old.borderColor != borderColor ||
      old.pointerPos != pointerPos ||
      old.pointerRadius != pointerRadius;
}
