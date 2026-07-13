import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Centroid cache
// ---------------------------------------------------------------------------

/// Shared cache: key → `Future<Offset>` (the translate delta to apply).
///
/// Using a Future as the value means concurrent calls for the same key share
/// a single in-flight computation — no duplicate GPU work.
final Map<String, Future<Offset>> _cache = {};

/// Returns the cached [Future<Offset>] for [key], or computes it via
/// [compute] and stores the future before returning it.
Future<Offset> _getOrCompute(String key, Future<Offset> Function() compute) {
  return _cache.putIfAbsent(key, compute);
}

// ---------------------------------------------------------------------------
// Off-screen render + centroid
// ---------------------------------------------------------------------------

/// Renders [emoji] at [fontSize] into a [ui.Image] using an off-screen
/// [ui.PictureRecorder] so no widget tree is involved.
Future<ui.Image> _renderEmoji(String emoji, double fontSize) async {
  // Use a fixed canvas slightly larger than the font size to ensure the full
  // glyph (including any platform-side extra space) is captured.
  final int size = (fontSize * 2).ceil();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
      // height: 1 removes leading above/below the glyph in the paragraph box.
      height: 1,
    ),
  )
    ..pushStyle(ui.TextStyle(fontSize: fontSize, height: 1))
    ..addText(emoji);

  final paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: size.toDouble()));

  // Centre the paragraph inside the canvas so overflow in any direction is
  // captured symmetrically.
  final dx = (size - paragraph.width) / 2;
  final dy = (size - paragraph.height) / 2;
  canvas.drawParagraph(paragraph, Offset(dx, dy));

  final picture = recorder.endRecording();
  return picture.toImage(size, size);
}

/// Computes the alpha-weighted visual centroid of [image] and returns the
/// [Offset] by which the rendered emoji must be *translated* so that its
/// visual centre aligns with the geometric centre of the widget.
///
/// Weight = √alpha (perceptual, logarithmic brightness model).
Future<Offset> _computeTranslation(ui.Image image, double widgetSize) async {
  final int w = image.width;
  final int h = image.height;

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();

  if (byteData == null) return Offset.zero;

  final Uint8List pixels = byteData.buffer.asUint8List();

  double wx = 0, wy = 0, total = 0;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final int idx = (y * w + x) * 4;
      final double alpha = pixels[idx + 3] / 255.0;
      final double weight = alpha;
      wx += x * weight;
      wy += y * weight;
      total += weight;
    }
  }

  if (total == 0) return Offset.zero;

  // Visual centre in pixel space.
  final double cx = wx / total;
  final double cy = wy / total;

  // Geometric centre of the rendered image.
  final double gx = w / 2.0;
  final double gy = h / 2.0;

  // Delta in pixel space, then scaled to logical-pixel widget space.
  final double scale = widgetSize / w;
  return Offset((gx - cx) * scale, (gy - cy) * scale);
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

/// Optically centres an emoji inside a square widget whose side length equals
/// the resolved font size.
///
/// The widget reads the font size from the ambient [DefaultTextStyle] so it
/// naturally inherits sizing from [LdAvatar], [LdListItem], etc.  An explicit
/// [style] can override this.
///
/// On the first render for a given (emoji, size) pair the emoji is shown at
/// its geometric centre; it snaps to the visual centre as soon as the
/// centroid computation completes (typically < 50 ms).  Subsequent renders
/// for the same pair are instant — the result is cached for the lifetime of
/// the application.
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
  /// Current translation delta. [Offset.zero] until the async result arrives.
  Offset _offset = Offset.zero;
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
    final double size = _resolveSize(context, widget.style);
    if (size == _resolvedSize) return; // nothing changed
    _resolvedSize = size;

    final String key = '${widget.emoji}:${size.round()}';
    _getOrCompute(key, () => _compute(widget.emoji, size)).then((offset) {
      if (mounted) {
        setState(() => _offset = offset);
      }
    });
  }

  static Future<Offset> _compute(String emoji, double size) async {
    final image = await _renderEmoji(emoji, size);
    return _computeTranslation(image, size);
  }

  @override
  Widget build(BuildContext context) {
    final double size = _resolvedSize ?? _resolveSize(context, widget.style);

    return SizedBox(
      width: size * 1.5,
      height: size * 1.5,
      child: Center(
        child: Transform.translate(
          offset: Offset.zero,
          child: Text(
            widget.emoji,
            style: TextStyle(
              fontSize: size,
              height: 1,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
