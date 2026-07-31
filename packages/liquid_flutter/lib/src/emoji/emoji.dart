import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/emoji/analyzer.dart';
import 'package:liquid_flutter/src/emoji/optical_center.dart';

// ---------------------------------------------------------------------------
// Raster cache
// ---------------------------------------------------------------------------

/// Algorithm fingerprint mixed into cache keys (invalidates on model changes).
const _algorithmVersion = 'raster3';

/// Cropped ink raster ready to paint, sized for [analysisFontSize] at [pixelRatio].
class _EmojiRaster {
  const _EmojiRaster({
    required this.image,
    required this.pixelRatio,
    required this.analysisFontSize,
    this.opticalDx = 0,
    this.opticalDy = 0,
  });

  final ui.Image image;
  final double pixelRatio;
  final double analysisFontSize;

  /// V2 optical translate in **image pixels** (positive = shift right / down).
  final double opticalDx;
  final double opticalDy;
}

/// Shared cache: key → in-flight / completed raster.
final Map<String, Future<_EmojiRaster>> _cache = {};

Future<_EmojiRaster> _getOrCompute(
  String key,
  Future<_EmojiRaster> Function() compute,
) {
  return _cache.putIfAbsent(key, compute);
}

// ---------------------------------------------------------------------------
// Off-screen render + ink crop + optical refine
// ---------------------------------------------------------------------------

const _maxAnalysisFontSize = 64.0;

/// Extra logical padding around the layout box so glyphs that paint outside
/// their advance/ascent (e.g. ⚽) are not clipped during rasterization.
const _overflowPadFactor = 0.35;

double _analysisFontSize(double fontSize) =>
    math.min(fontSize, _maxAnalysisFontSize);

/// Renders [emoji], crops to opaque ink, measures V2 optical centre within
/// that crop, and returns a paint-ready raster.
///
/// Pipeline:
/// 1. AABB crop — strips advance-width padding (Apple emoji metrics).
/// 2. Optical V2 on the crop — shifts asymmetric ink (👋, 🚗) so visual mass,
///    not the bounding box, sits on centre.
Future<_EmojiRaster> _rasterizeEmoji(String emoji, double analysisFontSize) async {
  final views = ui.PlatformDispatcher.instance.views;
  final dpr = views.isEmpty ? 2.0 : views.first.devicePixelRatio;
  final pixelRatio = math.max(2.0, dpr);

  final painter = TextPainter(
    text: TextSpan(
      text: emoji,
      style: TextStyle(
        fontSize: analysisFontSize,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  )..layout();

  final layoutW = math.max(painter.width, 1.0);
  final layoutH = math.max(painter.height, 1.0);
  final pad = analysisFontSize * _overflowPadFactor;
  final canvasW = layoutW + 2 * pad;
  final canvasH = layoutH + 2 * pad;
  final imageW = math.max(1, (canvasW * pixelRatio).ceil());
  final imageH = math.max(1, (canvasH * pixelRatio).ceil());

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, imageW.toDouble(), imageH.toDouble()),
  );
  canvas.scale(pixelRatio);
  painter.paint(canvas, Offset(pad, pad));
  final picture = recorder.endRecording();
  final full = await picture.toImage(imageW, imageH);

  final byteData = await full.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    return _EmojiRaster(
      image: full,
      pixelRatio: pixelRatio,
      analysisFontSize: analysisFontSize,
    );
  }

  final pixels = byteData.buffer.asUint8List();
  final bounds = findInkBounds(
    pixels,
    width: imageW,
    height: imageH,
    alphaThreshold: 1,
  );
  if (bounds == null) {
    return _EmojiRaster(
      image: full,
      pixelRatio: pixelRatio,
      analysisFontSize: analysisFontSize,
    );
  }

  // Keep a 1px fringe so anti-aliased edges aren't shaved off.
  final left = math.max(0, bounds.left - 1);
  final top = math.max(0, bounds.top - 1);
  final right = math.min(imageW, bounds.left + bounds.width + 1);
  final bottom = math.min(imageH, bounds.top + bounds.height + 1);
  final cropW = right - left;
  final cropH = bottom - top;

  final cropped = await _cropImage(
    full,
    left: left,
    top: top,
    width: cropW,
    height: cropH,
  );
  full.dispose();

  // Optical centre within the crop (AABB centre ≠ visual mass for 👋 / 🚗).
  final cropBytes = await cropped.toByteData(format: ui.ImageByteFormat.rawRgba);
  var opticalDx = 0.0;
  var opticalDy = 0.0;
  if (cropBytes != null) {
    final optical = getOpticalCenter(
      Uint8List.fromList(cropBytes.buffer.asUint8List()),
      width: cropW,
      height: cropH,
    );
    opticalDx = optical.dx;
    opticalDy = optical.dy;
  }

  return _EmojiRaster(
    image: cropped,
    pixelRatio: pixelRatio,
    analysisFontSize: analysisFontSize,
    opticalDx: opticalDx,
    opticalDy: opticalDy,
  );
}

Future<ui.Image> _cropImage(
  ui.Image src, {
  required int left,
  required int top,
  required int width,
  required int height,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  );
  canvas.drawImageRect(
    src,
    Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      width.toDouble(),
      height.toDouble(),
    ),
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..filterQuality = FilterQuality.medium,
  );
  return recorder.endRecording().toImage(width, height);
}

/// Resolves the font size to use for rendering from [style] and [context].
///
/// Priority order:
///   1. `style.fontSize` if explicitly set
///   2. `IconTheme.of(context).size` — set by [LdAvatar] and similar wrappers
///   3. `DefaultTextStyle.of(context).style.fontSize`
///   4. Fallback: 24.0
double _resolveSize(BuildContext context, TextStyle? style) {
  if (style?.fontSize != null) return style!.fontSize!;
  final iconSize = IconTheme.of(context).size;
  if (iconSize != null) return iconSize;
  final inherited = DefaultTextStyle.of(context).style.fontSize;
  return inherited ?? 24.0;
}

// ---------------------------------------------------------------------------
// LdEmoji widget
// ---------------------------------------------------------------------------

/// Centres an emoji by painted ink and perceptual optical centre.
///
/// 1. Rasterize and crop to the opaque ink AABB (strips advance-width padding).
/// 2. Run optical-center V2 on that crop so asymmetric glyphs (👋, 🚗) sit on
///    visual mass, not the bounding-box midpoint.
/// 3. Paint the cropped bitmap centred (then optically translated) in a square
///    of the resolved font size.
///
/// The widget reads the font size from the ambient [DefaultTextStyle] so it
/// naturally inherits sizing from [LdAvatar], [LdListItem], etc.  An explicit
/// [style] can override this.
///
/// Example:
/// ```dart
/// LdAvatar(child: LdEmoji('🚗'))
/// LdAvatar(child: LdEmoji('🚗', style: TextStyle(fontSize: 32)))
/// ```
class LdEmoji extends StatefulWidget {
  const LdEmoji(this.emoji, {super.key, this.style});

  /// The emoji character(s) to display.
  final String emoji;

  /// Optional text style.  Only [TextStyle.fontSize] is used; the emoji is
  /// always rendered with the platform colour emoji font.
  final TextStyle? style;

  @override
  State<LdEmoji> createState() => _LdEmojiState();
}

class _LdEmojiState extends State<LdEmoji> {
  _EmojiRaster? _raster;
  double? _resolvedSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleComputation();
  }

  @override
  void didUpdateWidget(LdEmoji old) {
    super.didUpdateWidget(old);
    if (old.emoji != widget.emoji ||
        old.style?.fontSize != widget.style?.fontSize) {
      _scheduleComputation();
    }
  }

  void _scheduleComputation() {
    final size = _resolveSize(context, widget.style);
    if (size == _resolvedSize && _raster != null) return;
    _resolvedSize = size;

    final analysisFontSize = _analysisFontSize(size);
    final key =
        '${widget.emoji}:${analysisFontSize.round()}:$_algorithmVersion';

    _getOrCompute(
      key,
      () => _rasterizeEmoji(widget.emoji, analysisFontSize),
    ).then((raster) {
      if (mounted) {
        setState(() => _raster = raster);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = _resolvedSize ?? _resolveSize(context, widget.style);
    final raster = _raster;

    Widget child;
    if (raster == null) {
      // Placeholder keeps layout stable while the raster is prepared.
      child = Text(
        widget.emoji,
        style: widget.style?.copyWith(fontSize: size, height: 1) ??
            TextStyle(fontSize: size, height: 1),
        maxLines: 1,
      );
    } else {
      final scale = size / raster.analysisFontSize;
      final logicalW = raster.image.width / raster.pixelRatio * scale;
      final logicalH = raster.image.height / raster.pixelRatio * scale;
      // Tall/wide ink (⚽ etc.) can exceed [size]; fit uniformly inside the box.
      final fit = size / math.max(logicalW, logicalH);
      final displayW = logicalW * fit;
      final displayH = logicalH * fit;
      final px = displayW / raster.image.width;

      child = Transform.translate(
        offset: Offset(raster.opticalDx * px, raster.opticalDy * px),
        child: RawImage(
          image: raster.image,
          width: displayW,
          height: displayH,
          filterQuality: FilterQuality.medium,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: child),
    );
  }
}
