import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

Widget _harness({
  required Widget child,
  LdFrameOptions ldFrameOptions = const LdFrameOptions(),
  double width = 200,
  double height = 48,
}) {
  return ldFrame(
    ldFrameOptions: ldFrameOptions,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: height),
        child: child,
      ),
    ),
  );
}

List<Widget> _wideChips(int count) {
  return List.generate(
    count,
    (index) => SizedBox(
      width: 120,
      height: 32,
      child: Center(child: Text('Chip $index')),
    ),
  );
}

AnimatedOpacity _fadeOpacity(WidgetTester tester, Key fadeKey) {
  return tester.widget<AnimatedOpacity>(
    find.descendant(
      of: find.byKey(fadeKey),
      matching: find.byType(AnimatedOpacity),
    ),
  );
}

ScrollController _scrollController(WidgetTester tester) {
  final scrollView = tester.widget<SingleChildScrollView>(find.byKey(LdHorizontalScroll.scrollViewKey));
  return scrollView.controller!;
}

void main() {
  group('LdHorizontalScroll', () {
    setUp(() => ldDisableAnimations = true);
    tearDown(() => ldDisableAnimations = false);

    testWidgets('does not show fades when content fits', (tester) async {
      await tester.pumpWidget(
        _harness(
          width: 800,
          child: LdHorizontalScroll(
            layout: LdHorizontalScrollLayout.scroll,
            children: _wideChips(2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LdScrollEdgeFade), findsOneWidget);
      expect(_fadeOpacity(tester, LdScrollEdgeFade.leftFadeKey).opacity, 0);
      expect(_fadeOpacity(tester, LdScrollEdgeFade.rightFadeKey).opacity, 0);
    });

    testWidgets('scrolls horizontally when content overflows', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: LdHorizontalScroll(
            layout: LdHorizontalScrollLayout.scroll,
            hint: LdHorizontalScrollHint.none,
            initialPeek: false,
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(LdHorizontalScroll.scrollViewKey), const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(_scrollController(tester).offset, greaterThan(0));
    });

    testWidgets('shows trailing fade when content overflows', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: LdHorizontalScroll(
            layout: LdHorizontalScrollLayout.scroll,
            initialPeek: false,
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_scrollController(tester).position.maxScrollExtent, greaterThan(0));
      expect(_fadeOpacity(tester, LdScrollEdgeFade.leftFadeKey).opacity, 0);
      expect(_fadeOpacity(tester, LdScrollEdgeFade.rightFadeKey).opacity, 1);
    });

    testWidgets('shows leading fade after scrolling', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: LdHorizontalScroll(
            layout: LdHorizontalScrollLayout.scroll,
            initialPeek: false,
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(LdHorizontalScroll.scrollViewKey),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(_fadeOpacity(tester, LdScrollEdgeFade.leftFadeKey).opacity, 1);
    });

    testWidgets('uses wrap on desktop in adaptive layout', (tester) async {
      await tester.pumpWidget(
        _harness(
          ldFrameOptions: const LdFrameOptions(platform: LdPlatform.macos),
          width: 200,
          child: LdHorizontalScroll(
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LdHorizontalScroll),
          matching: find.byKey(LdHorizontalScroll.scrollViewKey),
        ),
        findsNothing,
      );
      expect(find.byType(LdScrollEdgeFade), findsNothing);
    });

    testWidgets('skips peek when ldDisableAnimations is true', (tester) async {
      await tester.pumpWidget(
        _harness(
          width: 200,
          child: LdHorizontalScroll(
            layout: LdHorizontalScrollLayout.scroll,
            initialPeek: true,
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_scrollController(tester).offset, 0);
    });

    testWidgets('runs peek once when animations enabled', (tester) async {
      ldDisableAnimations = false;

      await tester.pumpWidget(
        _harness(
          child: LdHorizontalScroll(
            key: const ValueKey('scroll'),
            layout: LdHorizontalScrollLayout.scroll,
            initialPeek: true,
            peekDistance: 40,
            children: _wideChips(6),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(_scrollController(tester).offset, greaterThan(0));

      await tester.pumpAndSettle();

      expect(_scrollController(tester).offset, 0);

      await tester.pumpWidget(
        _harness(
          child: LdHorizontalScroll(
            key: const ValueKey('scroll'),
            layout: LdHorizontalScrollLayout.scroll,
            initialPeek: true,
            children: _wideChips(6),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_scrollController(tester).offset, 0);
    });

    testWidgets('edge bleed extends scroll area past parent padding', (tester) async {
      await tester.binding.setSurfaceSize(const Size(300, 80));

      await tester.pumpWidget(
        ldFrame(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 200,
              height: 48,
              child: LdHorizontalScroll(
                layout: LdHorizontalScrollLayout.scroll,
                hint: LdHorizontalScrollHint.none,
                initialPeek: false,
                edgeBleed: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  SizedBox(width: 80, height: 32, child: ColoredBox(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final overflowBox = tester.widget<OverflowBox>(
        find.descendant(
          of: find.byType(LdHorizontalScroll),
          matching: find.byType(OverflowBox),
        ),
      );
      expect(overflowBox.maxWidth, 248);
    });
  });

  group('LdScrollEdgeFade horizontal', () {
    setUp(() => ldDisableAnimations = true);
    tearDown(() => ldDisableAnimations = false);

    testWidgets('shows right fade at start and left fade after scroll', (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        ldFrame(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 200, height: 48),
            child: LdScrollEdgeFade(
              axis: Axis.horizontal,
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 120,
                      child: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_fadeOpacity(tester, LdScrollEdgeFade.rightFadeKey).opacity, 1);
      expect(_fadeOpacity(tester, LdScrollEdgeFade.leftFadeKey).opacity, 0);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(_fadeOpacity(tester, LdScrollEdgeFade.leftFadeKey).opacity, 1);
    });
  });
}
