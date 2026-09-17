import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:provider/provider.dart';

Widget _overflowHarness({
  required double width,
  required List<Widget> children,
}) {
  return MaterialApp(
    home: ldFrame(
      size: LdThemeSize.m,
      child: Center(
        child: SizedBox(
          width: width,
          child: LdOverflowView(
            builder: (context, overflowedChildIndices) => SizedBox(
              width: 32,
              height: 32,
              child: Center(child: Text('+${overflowedChildIndices.length}')),
            ),
            spacing: 8,
            children: children,
          ),
        ),
      ),
    ),
  );
}

Widget _appBarHarness({
  required double width,
  required List<Widget> actions,
}) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: ldFrame(
      size: LdThemeSize.m,
      child: SizedBox(
        width: width,
        child: LdScaffold(
          body: LdAppBar.top(
            title: const Text('T'),
            actions: actions,
            child: const Center(child: Text('Body')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ldAppBarActionGroupMenuChildren', () {
    test('does not insert dividers for a single ungrouped item', () {
      const solo = Text('A');
      expect(ldAppBarActionGroupMenuChildren([solo]), [solo]);
    });

    test('flattens a lone group without a divider', () {
      const child = Text('A');
      final group = LdAppBarActionGroup(
        children: const [child],
      );
      expect(ldAppBarActionGroupMenuChildren([group]), [child]);
    });

    test('inserts a divider between a group and a neighbor and flattens the group', () {
      const alpha = Text('A');
      const beta = Text('B');
      final group = LdAppBarActionGroup(
        children: const [alpha, beta],
      );
      final children = ldAppBarActionGroupMenuChildren([
        const Text('Solo'),
        group,
        const Text('After'),
      ]);

      expect(children, hasLength(6));
      expect(children[0], isA<Text>());
      expect(children[1], isA<LdDivider>());
      expect(children[2], same(alpha));
      expect(children[3], same(beta));
      expect(children[4], isA<LdDivider>());
      expect(children[5], isA<Text>());
    });

    test('does not insert a divider between two ungrouped actions', () {
      final children = ldAppBarActionGroupMenuChildren(const [
        Text('One'),
        Text('Two'),
      ]);

      expect(children, hasLength(2));
      expect(children.any((child) => child is LdDivider), isFalse);
    });
  });

  group('LdAppBarActionGroup', () {
    testWidgets('overflows as a single candidate', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _overflowHarness(
          width: 150,
          children: const [
            SizedBox(
              width: 60,
              height: 32,
              child: Center(child: Text('Solo')),
            ),
            LdAppBarActionGroup(
              children: [
                SizedBox(
                  width: 80,
                  height: 32,
                  child: Center(child: Text('Alpha')),
                ),
                SizedBox(
                  width: 80,
                  height: 32,
                  child: Center(child: Text('Beta')),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Beta'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('draws a leading divider when not first and none when last', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _appBarHarness(
          width: 800,
          actions: [
            LdAppBarAction(
              onPressed: () {},
              child: const Text('Solo'),
            ),
            LdAppBarActionGroup(
              leadingDivider: true,
              children: [
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text('Alpha'),
                ),
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text('Beta'),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('does not draw a leading divider when the group is first', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _appBarHarness(
          width: 800,
          actions: [
            LdAppBarActionGroup(
              children: [
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text('Alpha'),
                ),
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text('Beta'),
                ),
              ],
            ),
            LdAppBarAction(
              onPressed: () {},
              child: const Text('Solo'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('overflow menu shows grouped actions together with a divider', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            child: LdScaffold(
              body: Provider.value(
                value: LdAppBarActionDisplayMode.contextMenu,
                child: Column(
                  children: ldAppBarActionGroupMenuChildren([
                    LdAppBarAction(
                      onPressed: () {},
                      child: const Text('SoloAction'),
                    ),
                    LdAppBarActionGroup(
                      children: [
                        LdAppBarAction(
                          onPressed: () {},
                          child: const Text('AlphaAction'),
                        ),
                        LdAppBarAction(
                          onPressed: () {},
                          child: const Text('BetaAction'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SoloAction'), findsOneWidget);
      expect(find.text('AlphaAction'), findsOneWidget);
      expect(find.text('BetaAction'), findsOneWidget);
      expect(find.byType(LdDivider), findsOneWidget);
    });
  });
}
