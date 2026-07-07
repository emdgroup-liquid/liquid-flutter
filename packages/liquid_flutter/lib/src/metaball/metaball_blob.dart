import 'package:flutter/painting.dart';

// ---------------------------------------------------------------------------
// Shape type
// ---------------------------------------------------------------------------

/// The SDF shape used for a single metaball blob.
enum LdMetaballShape {
  /// Rounded rectangle. The corner radius is controlled by
  /// [LdMetaballBlob.cornerRadius].
  roundedRect,

  /// Ellipse (pill / circle when width == height).
  ellipse,
}

// ---------------------------------------------------------------------------
// Blob descriptor
// ---------------------------------------------------------------------------

/// Describes a single metaball shape: its position, dimensions, and shape
/// type.
///
/// Positions are in the local coordinate space of the enclosing
/// [LdMetaballMask] (or [LdMetaball]) widget. The origin is the top-left
/// corner of that widget.
///
/// Blobs are immutable value objects. Use [copyWith] to produce modified
/// copies.
class LdMetaballBlob {
  /// Center of the blob in local widget coordinates.
  final Offset position;

  /// Total width of the blob's bounding rectangle (before any blending).
  final double width;

  /// Total height of the blob's bounding rectangle (before any blending).
  final double height;

  /// Corner radius for [LdMetaballShape.roundedRect] blobs.
  /// Clamped to `min(width, height) / 2` by the shader. Has no effect for
  /// [LdMetaballShape.ellipse] blobs.
  final double cornerRadius;

  /// The SDF primitive used to render this blob.
  final LdMetaballShape shape;

  const LdMetaballBlob({
    required this.position,
    required this.width,
    required this.height,
    this.cornerRadius = 0,
    this.shape = LdMetaballShape.roundedRect,
  });

  /// Returns a copy with the provided fields replaced.
  LdMetaballBlob copyWith({
    Offset? position,
    double? width,
    double? height,
    double? cornerRadius,
    LdMetaballShape? shape,
  }) {
    return LdMetaballBlob(
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      shape: shape ?? this.shape,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LdMetaballBlob &&
          other.position == position &&
          other.width == width &&
          other.height == height &&
          other.cornerRadius == cornerRadius &&
          other.shape == shape;

  @override
  int get hashCode => Object.hash(position, width, height, cornerRadius, shape);
}
