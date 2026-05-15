import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/appbar/appbar_state.dart';

void main() {
  group('LdAppBarMetrics', () {
    const base = LdAppBarMetrics(
      position: LdAppBarPosition.top,
      barHeight: 56.0,
      edgeMargin: 8.0,
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
        barHeight: 56.0,
        edgeMargin: 8.0,
        hideOffset: 0.0,
        isScrolledUnder: false,
        level: 0,
      );
      expect(base, equals(other));
      expect(base.hashCode, equals(other.hashCode));
    });

    test('not equal when any field differs', () {
      expect(
        base == base.copyWith(barHeight: 48.0),
        isFalse,
      );
      expect(
        base == base.copyWith(position: LdAppBarPosition.bottom),
        isFalse,
      );
      expect(
        base == base.copyWith(isScrolledUnder: true),
        isFalse,
      );
      expect(
        base == base.copyWith(level: 1),
        isFalse,
      );
    });

    // -------------------------------------------------------------------------
    // consumedInsets – top bar
    // -------------------------------------------------------------------------

    test('consumedInsets for top bar with no hideOffset', () {
      // barHeight=56, edgeMargin=8, hideOffset=0  =>  top = 48
      final insets = base.consumedInsets;
      expect(insets, equals(const EdgeInsets.only(top: 48.0)));
    });

    test('consumedInsets for top bar with partial hideOffset', () {
      final metrics = base.copyWith(hideOffset: 20.0);
      // barHeight=56, edgeMargin=8, hideOffset=20  =>  top = 28
      expect(metrics.consumedInsets, equals(const EdgeInsets.only(top: 28.0)));
    });

    test('consumedInsets for top bar fully hidden (hideOffset == barHeight)', () {
      final metrics = base.copyWith(hideOffset: 56.0);
      expect(metrics.consumedInsets, equals(EdgeInsets.zero));
    });

    test('consumedInsets for top bar fully hidden beyond bar height', () {
      final metrics = base.copyWith(hideOffset: 64.0);
      expect(metrics.consumedInsets, equals(EdgeInsets.zero));
    });

    // -------------------------------------------------------------------------
    // consumedInsets – bottom bar
    // -------------------------------------------------------------------------

    test('consumedInsets for bottom bar with no hideOffset', () {
      const bottom = LdAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: 56.0,
        edgeMargin: 8.0,
        hideOffset: 0.0,
        isScrolledUnder: false,
        level: 0,
      );
      expect(bottom.consumedInsets, equals(const EdgeInsets.only(bottom: 48.0)));
    });

    test('consumedInsets for bottom bar fully hidden', () {
      const bottom = LdAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: 56.0,
        edgeMargin: 8.0,
        hideOffset: 56.0,
        isScrolledUnder: false,
        level: 0,
      );
      expect(bottom.consumedInsets, equals(EdgeInsets.zero));
    });

    test('consumedInsets for bottom bar: only bottom is non-zero', () {
      const bottom = LdAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: 56.0,
        edgeMargin: 0.0,
        hideOffset: 0.0,
        isScrolledUnder: false,
        level: 0,
      );
      final insets = bottom.consumedInsets;
      expect(insets.top, isZero);
      expect(insets.left, isZero);
      expect(insets.right, isZero);
      expect(insets.bottom, 56.0);
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
