import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/appbar/appbar_state.dart';

void main() {
  group('LdAppBarMetrics', () {
    // Level-0 top bar: edgeMargin.top=44 (device safe-area), inner content=48.
    // barHeight.top = edgeMargin.top + inner = 92.
    const base = LdAppBarMetrics(
      position: LdAppBarPosition.top,
      barHeight: EdgeInsets.only(top: 92.0),
      edgeMargin: EdgeInsets.only(top: 44.0),
      hideOffset: EdgeInsets.only(top: 0.0),
      isScrolledUnder: false,
      level: 0,
    );

    // -------------------------------------------------------------------------
    // Value equality
    // -------------------------------------------------------------------------

    test('equal when all fields match', () {
      const other = LdAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: EdgeInsets.only(top: 92.0),
        edgeMargin: EdgeInsets.only(top: 44.0),
        hideOffset: EdgeInsets.only(top: 0.0),
        isScrolledUnder: false,
        level: 0,
      );
      expect(base, equals(other));
      expect(base.hashCode, equals(other.hashCode));
    });

    test('not equal when any field differs', () {
      expect(base == base.copyWith(barHeight: const EdgeInsets.only(top: 80.0)), isFalse);
      expect(base == base.copyWith(edgeMargin: EdgeInsets.zero), isFalse);
      expect(base == base.copyWith(position: LdAppBarPosition.bottom), isFalse);
      expect(base == base.copyWith(isScrolledUnder: true), isFalse);
      expect(base == base.copyWith(level: 1), isFalse);
    });

    // -------------------------------------------------------------------------
    // stableConsumedInsets
    // -------------------------------------------------------------------------

    test('stableConsumedInsets for top bar = barHeight.top - edgeMargin.top', () {
      expect(base.stableConsumedInsets, equals(const EdgeInsets.only(top: 48.0)));
    });

    test('stableConsumedInsets ignores hideOffset', () {
      final hiding = base.copyWith(hideOffset: const EdgeInsets.only(top: 46.0));
      // Still barHeight.top - edgeMargin.top = 48, regardless of hideOffset.
      expect(hiding.stableConsumedInsets, equals(const EdgeInsets.only(top: 48.0)));
    });

    test('stableConsumedInsets clamped to 0 when barHeight <= edgeMargin', () {
      final flat = base.copyWith(barHeight: const EdgeInsets.only(top: 44.0)); // inner content = 0
      expect(flat.stableConsumedInsets, equals(EdgeInsets.zero));
    });

    test('stableConsumedInsets for bottom bar', () {
      const bottom = LdAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: EdgeInsets.only(bottom: 82.0),
        edgeMargin: EdgeInsets.only(bottom: 34.0),
        hideOffset: EdgeInsets.only(bottom: 0.0),
        isScrolledUnder: false,
        level: 0,
      );
      expect(bottom.stableConsumedInsets, equals(const EdgeInsets.only(bottom: 48.0)));
    });

    // -------------------------------------------------------------------------
    // consumedInsets (animated)
    // -------------------------------------------------------------------------

    test('consumedInsets with no hideOffset equals stableConsumedInsets', () {
      expect(base.consumedInsets, equals(base.stableConsumedInsets));
    });

    test('consumedInsets shrinks as hideOffset grows', () {
      // visible = 92 - 46 = 46; incremental = 46 - 44 = 2
      final hiding = base.copyWith(hideOffset: const EdgeInsets.only(top: 46.0));
      expect(hiding.consumedInsets, equals(const EdgeInsets.only(top: 2.0)));
    });

    test('consumedInsets is zero when fully hidden', () {
      final hidden = base.copyWith(hideOffset: const EdgeInsets.only(top: 92.0));
      expect(hidden.consumedInsets, equals(EdgeInsets.zero));
    });

    test('consumedInsets clamped to 0 when hideOffset > barHeight', () {
      final overHidden = base.copyWith(hideOffset: const EdgeInsets.only(top: 120.0));
      expect(overHidden.consumedInsets, equals(EdgeInsets.zero));
    });

    // -------------------------------------------------------------------------
    // copyWith
    // -------------------------------------------------------------------------

    test('copyWith preserves unchanged fields', () {
      final modified = base.copyWith(level: 2, isScrolledUnder: true);
      expect(modified.position, base.position);
      expect(modified.barHeight, base.barHeight);
      expect(modified.edgeMargin, base.edgeMargin);
      expect(modified.hideOffset, base.hideOffset);
      expect(modified.isScrolledUnder, isTrue);
      expect(modified.level, 2);
    });

    test('copyWith with no arguments returns equal object', () {
      expect(base.copyWith(), equals(base));
    });

    // -------------------------------------------------------------------------
    // EdgeInsets merging across positions (the fix)
    // -------------------------------------------------------------------------

    test('metrics carry both-edge data when a top and bottom bar are nested', () {
      // Simulate what AppBarFrame._buildMetrics produces for a bottom bar that
      // wraps inside a top bar whose metrics are already in the tree.
      const topMetrics = LdAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: EdgeInsets.only(top: 92.0),
        edgeMargin: EdgeInsets.only(top: 44.0),
        hideOffset: EdgeInsets.only(top: 30.0),
        isScrolledUnder: true,
        level: 0,
      );

      // Bottom bar writes its edge into a copy of the parent's insets.
      final combined = topMetrics.copyWith(
        position: LdAppBarPosition.bottom,
        barHeight: topMetrics.barHeight.copyWith(bottom: 80.0),
        edgeMargin: topMetrics.edgeMargin.copyWith(bottom: 34.0),
        hideOffset: topMetrics.hideOffset.copyWith(bottom: 0.0),
        level: 0,
      );

      // Top-edge data is preserved.
      expect(combined.barHeight.top, 92.0);
      expect(combined.edgeMargin.top, 44.0);
      expect(combined.hideOffset.top, 30.0);

      // Bottom-edge data is written.
      expect(combined.barHeight.bottom, 80.0);
      expect(combined.edgeMargin.bottom, 34.0);
      expect(combined.hideOffset.bottom, 0.0);

      // stableConsumedInsets covers both edges.
      expect(
        combined.stableConsumedInsets,
        equals(const EdgeInsets.only(top: 48.0, bottom: 46.0)),
      );
    });
  });
}
