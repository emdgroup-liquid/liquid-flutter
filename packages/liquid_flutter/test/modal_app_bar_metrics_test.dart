import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:provider/provider.dart';

/// Simulates patched [MediaQuery.padding] from a shell with tab + header bars.
const _shellPatchedMediaQuery = MediaQueryData(
  size: Size(400, 800),
  padding: EdgeInsets.only(top: 118, bottom: 34),
);

/// Simulates [LdAppBarMetrics] left by a parent master-page app bar.
const _shellAppBarMetrics = LdAppBarMetrics(
  position: LdAppBarPosition.top,
  barHeight: EdgeInsets.only(top: 118),
  edgeMargin: EdgeInsets.only(top: 118),
  hideOffset: EdgeInsets.zero,
  isScrolledUnder: false,
  level: 0,
);

class _ModalOpener extends StatelessWidget {
  const _ModalOpener();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LdButton(
        onPressed: () {
          Navigator.of(context).push(
            LdModalRoute<void>(
              context: context,
              modalTypeMode: LdModalTypeMode.sheet,
              pageBuilder: (context) => LdScaffold(
                body: LdAppBar.top(
                  title: const Text('Modal title'),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        child: const Text('Open modal'),
      ),
    );
  }
}

Widget _parentPage({required bool withParentAppBar}) {
  Widget page = LdScaffold(
    body: withParentAppBar
        ? LdAppBar.top(
            title: const Text('Parent bar'),
            bottom: const SizedBox(height: 56),
            child: const _ModalOpener(),
          )
        : const _ModalOpener(),
  );

  if (withParentAppBar) {
    page = Provider<LdAppBarMetrics>.value(
      value: _shellAppBarMetrics,
      child: page,
    );
  }

  return page;
}

Widget _harness({required bool withParentAppBar}) {
  return ldFrame(
    size: LdThemeSize.m,
    brightnessMode: LdThemeBrightnessMode.light,
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: MediaQuery(
        data: _shellPatchedMediaQuery,
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => _parentPage(withParentAppBar: withParentAppBar),
          ),
        ),
      ),
    ),
  );
}

Future<double> _measureModalAppBarFrameHeight(WidgetTester tester) async {
  await tester.tap(find.text('Open modal'));
  await tester.pumpAndSettle();

  final frameFinder = find.ancestor(
    of: find.text('Modal title'),
    matching: find.byType(AppBarFrame),
  );
  expect(frameFinder, findsOneWidget);
  final height = tester.getSize(frameFinder).height;

  Navigator.of(tester.element(find.text('Modal title'))).pop();
  await tester.pumpAndSettle();

  return height;
}

void main() {
  testWidgets(
    'modal sheet app bar height is unchanged when parent page has an app bar',
    (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(_harness(withParentAppBar: false));
      await tester.pumpAndSettle();
      final withoutParentBar = await _measureModalAppBarFrameHeight(tester);

      await tester.pumpWidget(_harness(withParentAppBar: true));
      await tester.pumpAndSettle();
      final withParentBar = await _measureModalAppBarFrameHeight(tester);

      expect(
        withParentBar,
        closeTo(withoutParentBar, 1.0),
        reason: 'modal app bar must not grow from ancestor metrics or padding',
      );
    },
  );
}
