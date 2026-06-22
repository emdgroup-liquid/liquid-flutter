import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';

void main() {
  testWidgets('sheet dismisses on downward pull at scroll top', (tester) async {
    ldDisableAnimations = true;
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ldFrame(
        size: LdThemeSize.m,
        brightnessMode: LdThemeBrightnessMode.light,
        child: Builder(
          builder: (context) {
            return LdScaffold(
              body: Center(
                child: LdModalBuilder(
                  builder: (context, open) {
                    return LdButton(
                      onPressed: open,
                      child: const Text('Open sheet'),
                    );
                  },
                  modal: LdModalRoute(
                    context: context,
                    modalTypeMode: LdModalTypeMode.sheet,
                    pageBuilder: (context) => LdScaffold(
                      body: LdAppBarWidget(
                        title: const Text('Sheet'),
                        child: LdScaffoldBody(
                          children: List.generate(
                            30,
                            (index) => LdText.p('Row $index'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet'), findsOneWidget);

    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(find.text('Sheet'), findsNothing);
  });

  testWidgets('sheet dismisses past halfway on nested navigator', (tester) async {
    ldDisableAnimations = true;
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ldFrame(
        size: LdThemeSize.m,
        brightnessMode: LdThemeBrightnessMode.light,
        child: Builder(
          builder: (context) {
            return LdScaffold(
              body: Center(
                child: LdModalBuilder(
                  useRootNavigator: false,
                  builder: (context, open) {
                    return LdButton(
                      onPressed: open,
                      child: const Text('Open sheet'),
                    );
                  },
                  modal: LdModalRoute(
                    context: context,
                    modalTypeMode: LdModalTypeMode.sheet,
                    pageBuilder: (context) => LdScaffold(
                      body: LdAppBarWidget(
                        title: const Text('Sheet'),
                        child: LdScaffoldBody(
                          children: List.generate(
                            30,
                            (index) => LdText.p('Row $index'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(find.text('Sheet'), findsNothing);
  });

  testWidgets('sheet stays open after upward fling to scroll top', (tester) async {
    ldDisableAnimations = true;
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ldFrame(
        size: LdThemeSize.m,
        brightnessMode: LdThemeBrightnessMode.light,
        child: Builder(
          builder: (context) {
            return LdScaffold(
              body: Center(
                child: LdModalBuilder(
                  builder: (context, open) {
                    return LdButton(
                      onPressed: open,
                      child: const Text('Open sheet'),
                    );
                  },
                  modal: LdModalRoute(
                    context: context,
                    modalTypeMode: LdModalTypeMode.sheet,
                    pageBuilder: (context) => LdScaffold(
                      body: LdAppBarWidget(
                        title: const Text('Sheet'),
                        child: LdScaffoldBody(
                          children: List.generate(
                            30,
                            (index) => LdText.p('Row $index'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.fling(scrollable, const Offset(0, 600), 2500);
    await tester.pumpAndSettle();

    expect(find.text('Sheet'), findsOneWidget);
  });
}
