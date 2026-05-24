import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/appbar/appbar_state.dart';

void main() {
  group('LdAppBarMetrics', () {
    // Level-0 top bar: edgeMargin=44 (device safe-area), inner content=48.
    // barHeight = edgeMargin + inner = 92.
    const base = LdAppBarMetrics(
      position: LdAppBarPosition.top,
      barHeight: 92.0,
      edgeMargin: 44.0,
      hideOffset: 0.0,
      isScrolledUnder: false,
      level: 0,
    );

    // -------------------------------------------------------------------------
    // Value equality
    // -------------------------------------------------------------------------

    test('equal when all fields match', () {
      const other = LdAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: 92.0,
        edgeMargin: 44.0,
        hideOffset: 0.0,
        isScrolledUnder: false,
        level: 0,
      );
      expect(base, equals(other));
      expect(base.hashCode, equals(other.hashCode));
    });

    test('not equal when any field differs', () {
      expect(base == base.copyWith(barHeight: 80.0), isFalse);
      expect(base == base.copyWith(edgeMargin: 0.0), isFalse);
      expect(base == base.copyWith(position: LdAppBarPosition.bottom), isFalse);
      expect(base == base.copyWith(isScrolledUnder: true), isFalse);
      expect(base == base.copyWith(level: 1), isFalse);
    });

    // -------------------------------------------------------------------------
    // stableConsumedInsets
    // -------------------------------------------------------------------------

    test('stableConsumedInsets for top bar = barHeight - edgeMargin', () {
      expect(base.stableConsumedInsets, equals(const EdgeInsets.only(top: 48.0)));
    });

    test('stableConsumedInsets ignores hideOffset', () {
      final hiding = base.copyWith(hideOffset: 46.0);
      // Still barHeight - edgeMargin = 48, regardless of hideOffset.
      expect(hiding.stableConsumedInsets, equals(const EdgeInsets.only(top: 48.0)));
    });

    test('stableConsumedInsets clamped to 0 when barHeight <= edgeMargin', () {
      final flat = base.copyWith(barHeight: 44.0); // inner content = 0
      expect(flat.stableConsumedInsets, equals(EdgeInsets.zero));
    });

    test('stableConsumedInsets for bottom bar', () {
      const bottom = LdAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: 82.0,
        edgeMargin: 34.0,
        hideOffset: 0.0,
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
      final hiding = base.copyWith(hideOffset: 46.0);
      expect(hiding.consumedInsets, equals(const EdgeInsets.only(top: 2.0)));
    });

    test('consumedInsets is zero when fully hidden', () {
      final hidden = base.copyWith(hideOffset: 92.0);
      expect(hidden.consumedInsets, equals(EdgeInsets.zero));
    });

    test('consumedInsets clamped to 0 when hideOffset > barHeight', () {
      final overHidden = base.copyWith(hideOffset: 120.0);
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
  });
}
