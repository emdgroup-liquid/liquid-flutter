import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_state.dart';

import 'appbar_metrics_test_utils.dart';

void main() {
  group('LdAppBarMetrics', () {
    // Level-0 top bar: edgeMargin.top=44 (device safe-area), inner content=48.
    // barHeight.top = edgeMargin.top + inner = 92.
    final base = testAppBarMetrics(
      position: LdAppBarPosition.top,
      barHeight: const EdgeInsets.only(top: 92.0),
      edgeMargin: const EdgeInsets.only(top: 44.0),
    );

    test('equal when all fields match', () {
      final other = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 92.0),
        edgeMargin: const EdgeInsets.only(top: 44.0),
      );
      expect(base, equals(other));
      expect(base.hashCode, equals(other.hashCode));
    });

    test('not equal when any field differs', () {
      expect(
        base == base.copyWith(innerHeight: const EdgeInsets.only(top: 80.0)),
        isFalse,
      );
      expect(base == base.copyWith(ownMargin: EdgeInsets.zero), isFalse);
      expect(base == base.copyWith(position: LdAppBarPosition.bottom), isFalse);
      expect(base == base.copyWith(isScrolledUnder: true), isFalse);
      expect(base == base.copyWith(level: 1), isFalse);
    });

    test('maximumSize for top bar = innerHeight + configuredInsets', () {
      expect(base.maximumSize, equals(const EdgeInsets.only(top: 92.0)));
    });

    test('maximumSize ignores scrollOffset', () {
      final hiding = base.copyWith(scrollOffset: const EdgeInsets.only(top: 46.0));
      expect(hiding.maximumSize, equals(base.maximumSize));
    });

    test('effectiveSize shrinks as scrollOffset grows', () {
      final hiding = base.copyWith(scrollOffset: const EdgeInsets.only(top: 46.0));
      expect(hiding.effectiveSize, equals(const EdgeInsets.only(top: 46.0)));
    });

    test('effectiveSize is zero when fully hidden', () {
      final hidden = base.copyWith(scrollOffset: const EdgeInsets.only(top: 92.0));
      expect(hidden.effectiveSize, equals(EdgeInsets.zero));
    });

    test('effectiveSize clamped to 0 when scrollOffset exceeds maximumSize components', () {
      final overHidden = base.copyWith(scrollOffset: const EdgeInsets.only(top: 120.0));
      expect(
        overHidden.accumulatedEffectiveSizes,
        equals(EdgeInsets.zero),
      );
    });

    test('accumulatedEffectiveSizes for bottom bar', () {
      final bottom = testAppBarMetrics(
        position: LdAppBarPosition.bottom,
        barHeight: const EdgeInsets.only(bottom: 82.0),
        edgeMargin: const EdgeInsets.only(bottom: 34.0),
      );
      expect(bottom.accumulatedEffectiveSizes, equals(const EdgeInsets.only(bottom: 82.0)));
    });

    test('copyWith preserves unchanged fields', () {
      final modified = base.copyWith(level: 2, isScrolledUnder: true);
      expect(modified.position, base.position);
      expect(modified.innerHeight, base.innerHeight);
      expect(modified.configuredInsets, base.configuredInsets);
      expect(modified.scrollOffset, base.scrollOffset);
      expect(modified.isScrolledUnder, isTrue);
      expect(modified.level, 2);
    });

    test('copyWith with no arguments returns equal object', () {
      expect(base.copyWith(), equals(base));
    });

    test('metrics carry both-edge data when a top and bottom bar are nested', () {
      final topMetrics = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 92.0),
        edgeMargin: const EdgeInsets.only(top: 44.0),
        hideOffset: const EdgeInsets.only(top: 30.0),
        isScrolledUnder: true,
      );

      final combined = topMetrics.copyWith(
        position: LdAppBarPosition.bottom,
        innerHeight: topMetrics.innerHeight.copyWith(bottom: 46.0),
        ownMargin: topMetrics.configuredInsets.copyWith(bottom: 34.0),
        scrollOffset: topMetrics.scrollOffset.copyWith(bottom: 0.0),
        level: 0,
      );

      expect(combined.maximumSize.top, 92.0);
      expect(combined.configuredInsets.top, 44.0);
      expect(combined.scrollOffset.top, 30.0);

      expect(combined.maximumSize.bottom, 80.0);
      expect(combined.configuredInsets.bottom, 34.0);
      expect(combined.scrollOffset.bottom, 0.0);
    });
  });

  group('ldHasParentTopAppBar', () {
    test('returns false for outermost app bar', () {
      final metrics = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 48.0),
      );

      expect(ldHasParentTopAppBar(metrics), isFalse);
    });

    test('returns true when parent is a top app bar', () {
      final parent = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 48.0),
      );
      final child = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 40.0),
        level: 1,
        parentMetrics: parent,
      );

      expect(ldHasParentTopAppBar(child), isTrue);
    });

    test('ignores tab navigation ancestors', () {
      final parent = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 48.0),
        isTabNavigation: true,
      );
      final child = testAppBarMetrics(
        position: LdAppBarPosition.top,
        barHeight: const EdgeInsets.only(top: 40.0),
        level: 1,
        parentMetrics: parent,
      );

      expect(ldHasParentTopAppBar(child), isFalse);
    });
  });
}
