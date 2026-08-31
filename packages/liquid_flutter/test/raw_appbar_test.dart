import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrapInScaffold(Widget body) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: ldFrame(
      size: LdThemeSize.m,
      brightnessMode: LdThemeBrightnessMode.light,
      child: body,
    ),
  );
}

void main() {
  group('LdRawAppBar', () {
    testWidgets('top renders content and wraps child', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.top(
              content: const Text('Bar content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bar content'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('appbar_frame_inside_top')),
            )
            .decoration,
        isNull,
      );
    });

    testWidgets('bottom renders content and wraps child', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              content: const Text('Bottom content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom content'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('appbar_frame_inside_bottom')),
            )
            .decoration,
        isNull,
      );
    });

    testWidgets('leading and trailing stay visible next to content', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              leading: const Text('Leading'),
              trailing: const Text('Trailing'),
              content: const Text('Content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Trailing'), findsOneWidget);

      final leading = tester.getRect(find.text('Leading'));
      final content = tester.getRect(find.text('Content'));
      final trailing = tester.getRect(find.text('Trailing'));

      expect(leading.right, lessThanOrEqualTo(content.left));
      expect(content.right, lessThanOrEqualTo(trailing.left));
    });

    testWidgets('nested LdAppBar.top + LdRawAppBar.bottom both present', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Title bar'),
              child: LdRawAppBar.bottom(
                content: const Text('Raw content'),
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Title bar'), findsOneWidget);
      expect(find.text('Raw content'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(LdAppBar), findsOneWidget);
      expect(find.byType(LdRawAppBar), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('appbar_frame_inside_bottom')),
            )
            .decoration,
        isNull,
      );
    });

    testWidgets('center layout hugs content and is centered', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              layout: LdRawAppBarLayout.center,
              leading: const Text('Leading'),
              trailing: const Text('Trailing'),
              content: const Text('Content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final leading = tester.getRect(find.text('Leading'));
      final trailing = tester.getRect(find.text('Trailing'));
      final bar = tester.getRect(
        find.byKey(const Key('appbar_frame_inside_bottom')),
      );

      expect(trailing.right - leading.left, lessThan(bar.width));
      expect(
        ((leading.left + trailing.right) / 2 - bar.center.dx).abs(),
        lessThan(1.5),
      );
    });

    testWidgets('LdHorizontalScroll as content is width-bounded', (tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              leading: const Icon(LucideIcons.plus),
              trailing: const Icon(LucideIcons.arrowUp),
              content: LdHorizontalScroll(
                layout: LdHorizontalScrollLayout.scroll,
                children: List.generate(
                  12,
                  (index) => SizedBox(
                    width: 120,
                    height: 32,
                    child: Center(child: Text('Chip $index')),
                  ),
                ),
              ),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Chip 0'), findsOneWidget);
      expect(find.byKey(LdHorizontalScroll.scrollViewKey), findsOneWidget);

      final scrollSize = tester.getSize(
        find.byKey(LdHorizontalScroll.scrollViewKey),
      );
      expect(scrollSize.width.isFinite, isTrue);
      expect(scrollSize.width, greaterThan(0));
    });

    testWidgets('inside and outside decorations are applied to the frame', (tester) async {
      ldDisableAnimations = true;
      const inside = BoxDecoration(color: Color(0xFF112233));
      const outside = BoxDecoration(color: Color(0xFF445566));

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              insideDecoration: inside,
              outsideDecoration: outside,
              content: const Text('Decorated'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final insideApplied = tester
          .widget<AnimatedContainer>(
            find.byKey(const Key('appbar_frame_inside_bottom')),
          )
          .decoration as BoxDecoration;
      final outsideApplied = tester
          .widget<AnimatedContainer>(
            find.byKey(const Key('appbar_frame_outside_bottom')),
          )
          .decoration as BoxDecoration;

      expect(insideApplied.color, inside.color);
      expect(outsideApplied.color, outside.color);
    });

    testWidgets('decoration builders override static decorations', (tester) async {
      ldDisableAnimations = true;
      const inside = BoxDecoration(color: Color(0xFF112233));
      const builtInside = BoxDecoration(color: Color(0xFFAABBCC));

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdRawAppBar.bottom(
              insideDecoration: inside,
              insideDecorationBuilder: (_) => builtInside,
              content: const Text('Decorated'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final applied = tester
          .widget<AnimatedContainer>(
            find.byKey(const Key('appbar_frame_inside_bottom')),
          )
          .decoration as BoxDecoration;
      expect(applied.color, builtInside.color);
    });
  });
}
