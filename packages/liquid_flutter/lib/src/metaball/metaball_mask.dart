import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

import 'metaball_blob.dart';
import 'metaball_shader_scope.dart';

/// Maximum number of blobs the shader supports.
/// Capped at 12 to stay within Metal's 30 fragment-buffer-slot limit on iOS.
const int kLdMetaballMaxBlobs = 12;

// ---------------------------------------------------------------------------
// LdMetaballMask
// ---------------------------------------------------------------------------

/// A pure rendering primitive that applies a smooth-union metaball alpha mask
/// to its [child].
///
/// The mask consists of two stacked [ShaderMask] layers:
///   1. **Border layer** — each blob's bounding rect is inflated by
///      [borderWidth], filled with [borderColor].
///   2. **Fill layer** — normal-sized blobs, filled with [surfaceColor] then
///      composited with [child].
///
/// [LdMetaballMask] is intentionally stateless — it does not own a shader
/// instance. A [FragmentShader] pair must be provided via [shader] and
/// [borderShader]. The easiest way to supply these is to wrap the widget tree
/// with [LdMetaballShaderScope], which loads the program once and provides two
/// fresh shader instances on request.
///
/// For a fully self-contained widget (shader loading + pointer interaction
/// included), use [LdMetaball] instead.
///
/// ## Example
///
/// ```dart
/// LdMetaballShaderScope(
///   child: Builder(builder: (context) {
///     final shaders = LdMetaballShaderScope.of(context);
///     return LdMetaballMask(
///       shader: shaders.fill,
///       borderShader: shaders.border,
///       blobs: [
///         LdMetaballBlob(position: Offset(80, 80), width: 120, height: 120),
///         LdMetaballBlob(position: Offset(200, 80), width: 100, height: 100,
///             shape: LdMetaballShape.ellipse),
///       ],
///       surfaceColor: Colors.white,
///       borderColor: Colors.black12,
///       child: MyContent(),
///     );
///   }),
/// );
/// ```
class LdMetaballMask extends StatelessWidget {
  /// Fill-mask shader — shapes at their natural size.
  final ui.FragmentShader shader;

  /// Border-mask shader — shapes inflated by [borderWidth].
  final ui.FragmentShader borderShader;

  /// The blobs to render. Up to [kLdMetaballMaxBlobs] blobs are supported;
  /// any extras are silently ignored.
  final List<LdMetaballBlob> blobs;

  /// Controls how aggressively neighbouring blobs are blended together.
  /// 0 = hard-edged union; higher values = thicker liquid neck between blobs.
  /// Sensible range: 10–80.
  final double blend;

  /// Colour used to fill the interior of all blobs.
  final Color surfaceColor;

  /// Colour used for the 1-layer border ring around all blobs.
  final Color borderColor;

  /// Pixel thickness of the border ring. Defaults to 1.
  final double borderWidth;

  /// When non-null (and [pointerRadius] > 0), the shader applies a radial
  /// deformation bell at this position — the liquid "squishes" toward or away
  /// from the pointer.
  ///
  /// Coordinates are in the local space of this widget.
  final Offset? pointerPos;

  /// Radius of the pointer influence bell. Driven by a spring for the
  /// natural push-and-return feel. When 0 the influence is inactive even if
  /// [pointerPos] is set.
  final double pointerRadius;

  /// Widget rendered inside the fill layer. Clipped to the metaball shape.
  ///
  /// Useful for placing arbitrary content inside the liquid blobs (icons,
  /// menus, etc.). The child is composited on top of [surfaceColor].
  final Widget? child;

  const LdMetaballMask({
    super.key,
    required this.shader,
    required this.borderShader,
    required this.blobs,
    required this.surfaceColor,
    required this.borderColor,
    this.blend = 40,
    this.borderWidth = 1,
    this.pointerPos,
    this.pointerRadius = 0,
    this.child,
  });

  /// Writes all shader uniforms into [s].
  ///
  /// When [expand] > 0, each blob's width/height is inflated by that many
  /// logical pixels — this produces the border mask layer.
  ///
  /// Uniform layout (packed into vec4 slots, Metal-safe):
  ///   flat 0–3  : u0 (sizeW, sizeH, blend, numShapes)
  ///   flat 4–7  : u1 (pointerActive, pointerCx, pointerCy, pointerR)
  ///   per blob i, 8 floats at 8 + i*8:
  ///     +0 type (1=rrect, 2=ellipse), +1 cx, +2 cy, +3 w
  ///     +4 h, +5 cornerRadius, +6 pad, +7 pad
  static void setUniforms(
    ui.FragmentShader s,
    Size size,
    List<LdMetaballBlob> blobs,
    double blend, {
    Offset? pointerPos,
    double pointerRadius = 0,
    double expand = 0,
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

    for (int i = 0; i < kLdMetaballMaxBlobs; i++) {
      final base = 8 + i * 8;
      if (i < n) {
        final b = blobs[i];
        final type = b.shape == LdMetaballShape.ellipse ? 2.0 : 1.0;
        s.setFloat(base + 0, type);
        s.setFloat(base + 1, b.position.dx);
        s.setFloat(base + 2, b.position.dy);
        s.setFloat(base + 3, b.width + expand * 2);
        s.setFloat(base + 4, b.height + expand * 2);
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

  Widget _maskedLayer({
    required ui.FragmentShader s,
    required double expand,
    required Widget child,
  }) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        setUniforms(
          s,
          bounds.size,
          blobs,
          blend,
          pointerPos: pointerPos,
          pointerRadius: pointerRadius,
          expand: expand,
        );
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
        // Border layer — inflated shapes
        _maskedLayer(
          s: borderShader,
          expand: borderWidth,
          child: ColoredBox(color: borderColor, child: const SizedBox.expand()),
        ),
        // Fill layer — normal shapes + content
        _maskedLayer(
          s: shader,
          expand: 0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: surfaceColor, child: const SizedBox.expand()),
              if (child != null) child!,
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Convenience factory — resolves shaders from the nearest LdMetaballShaderScope
// ---------------------------------------------------------------------------

/// Like [LdMetaballMask] but resolves [shader] and [borderShader] automatically
/// from the nearest [LdMetaballShaderScope] in the widget tree.
///
/// Throws if no [LdMetaballShaderScope] is found above this widget.
class LdMetaballMaskScoped extends StatelessWidget {
  final List<LdMetaballBlob> blobs;
  final double blend;
  final Color surfaceColor;
  final Color borderColor;
  final double borderWidth;
  final Offset? pointerPos;
  final double pointerRadius;
  final Widget? child;

  const LdMetaballMaskScoped({
    super.key,
    required this.blobs,
    required this.surfaceColor,
    required this.borderColor,
    this.blend = 40,
    this.borderWidth = 1,
    this.pointerPos,
    this.pointerRadius = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shaders = LdMetaballShaderScope.of(context);
    if (shaders == null) {
      // Shader not loaded yet — render nothing (transparent).
      return const SizedBox.expand();
    }
    return LdMetaballMask(
      shader: shaders.fill,
      borderShader: shaders.border,
      blobs: blobs,
      blend: blend,
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      pointerPos: pointerPos,
      pointerRadius: pointerRadius,
      child: child,
    );
  }
}
