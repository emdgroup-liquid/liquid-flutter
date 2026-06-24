import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/golden_utils.dart';
import 'package:liquid_flutter_test_utils/widget_creation_location.dart';
import 'package:liquid_flutter_test_utils/widget_tree_package_index.dart';
import 'package:liquid_flutter_test_utils/widget_tree_test.dart';
import 'package:path/path.dart' as p;

class _AppPackageChild extends StatelessWidget {
  const _AppPackageChild();

  @override
  Widget build(BuildContext context) {
    return LdText.p('App child');
  }
}

Widget _themed(Widget child) {
  return LdThemeProvider(
    child: LdThemedAppBuilder(
      appBuilder: (context, theme) => MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: LiquidLocalizations.localizationsDelegates,
        supportedLocales: LiquidLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
  setUp(() {
    ldDisableAnimations = true;
    WidgetTreePackageIndex.clear();
    clearFocusPackageScopeCache();
  });

  setUpAll(() async {
    await setupGoldenTest();
    await loadAppFonts();
  });

  test('isWidgetCreationTracked is enabled in widget tests', () {
    expect(isWidgetCreationTracked(), isTrue);
  });

  test('FocusPackageScope resolves liquid_flutter from test path', () {
    final liquidFlutterTest = p.normalize(
      p.join(
        Directory.current.path,
        '..',
        'liquid_flutter',
        'test',
        'card_golden_test.dart',
      ),
    );

    final scope = FocusPackageScope.resolveSync(
      testFilePath: liquidFlutterTest,
    );

    expect(scope, isNotNull);
    expect(scope!.packageName, 'liquid_flutter');
    expect(
      FocusPackageScope.isFocusPackageLocation(
        p.join(scope.packageRoot, 'lib', 'src', 'card.dart'),
        scope,
      ),
      isTrue,
    );
    expect(
      FocusPackageScope.isFocusPackageLocation(
        '/path/packages/flutter/lib/src/widgets/container.dart',
        scope,
      ),
      isFalse,
    );
  });

  testWidgets('LdCard tree shows Container but hides DecoratedBox and ClipPath', (
    tester,
  ) async {
    const key = ValueKey('ld-card-provenance');
    await tester.pumpWidget(
      _themed(
        LdCard(
          key: key,
          header: LdText.p('Header'),
          footer: LdText.p('Footer'),
          child: LdText.p('Hello'),
        ),
      ),
    );
    await tester.pump();

    final focusScope = WidgetTreePackageIndex.resolveForTest(
      focusPackageOverride: 'liquid_flutter',
    );
    expect(focusScope, isNotNull);

    final tree = createWidgetTree(
      tester.element(find.byKey(key)),
      context: WidgetTreeContext(
        options: const WidgetTreeOptions(
          focusPackage: 'liquid_flutter',
          filterByCreationLocation: true,
        ),
        tester: tester,
        focusScope: focusScope,
      ),
    );

    final xml = tree?.toXmlString(
          boundsPrecision: 0,
          parentBounds: null,
          parentConstraints: null,
        ) ??
        '';

    expect(xml, contains('<LdCard'));
    expect(xml, contains('<Container'));
    expect(xml, contains('<Column'));
    expect(xml, isNot(contains('<DecoratedBox')));
    expect(xml, isNot(contains('<ClipPath')));
    expect(xml, contains('text="Header"'));
    expect(xml, contains('text="Hello"'));
    expect(xml, contains('text="Footer"'));
  });

  testWidgets('App focus package hides liquid_flutter implementation internals', (
    tester,
  ) async {
    const key = ValueKey('app-package-provenance');
    await tester.pumpWidget(
      _themed(
        LdCard(
          key: key,
          child: const _AppPackageChild(),
        ),
      ),
    );
    await tester.pump();

    final testPath = currentTestFilePath();
    expect(testPath, isNotNull);

    final focusScope = WidgetTreePackageIndex.resolveForTest(
      testFilePath: testPath,
      focusPackageOverride: 'liquid_flutter_test_utils',
    );
    expect(focusScope, isNotNull);

    final tree = createWidgetTree(
      tester.element(find.byKey(key)),
      context: WidgetTreeContext(
        options: const WidgetTreeOptions(
          focusPackage: 'liquid_flutter_test_utils',
          filterByCreationLocation: true,
        ),
        tester: tester,
        focusScope: focusScope,
      ),
    );

    final xml = tree?.toXmlString(
          boundsPrecision: 0,
          parentBounds: null,
          parentConstraints: null,
        ) ??
        '';

    expect(xml, contains('<LdCard'));
    expect(xml, contains('<_AppPackageChild'));
    expect(xml, contains('<LdText'));
    expect(xml, isNot(contains('<DecoratedBox')));
    expect(xml, isNot(contains('<ClipPath')));
    expect(xml, isNot(contains('<LdAutoBackground')));
  });

  testWidgets('filterByCreationLocation false preserves full foreign subtree', (
    tester,
  ) async {
    const key = ValueKey('full-tree');
    await tester.pumpWidget(
      _themed(
        LdCard(
          key: key,
          child: LdText.p('Hello'),
        ),
      ),
    );
    await tester.pump();

    final tree = createWidgetTree(
      tester.element(find.byKey(key)),
      context: WidgetTreeContext(
        options: const WidgetTreeOptions(
          filterByCreationLocation: false,
        ),
        tester: tester,
        focusScope: null,
      ),
    );

    final xml = tree?.toXmlString(
          boundsPrecision: 0,
          parentBounds: null,
          parentConstraints: null,
        ) ??
        '';

    expect(xml, contains('<DecoratedBox'));
    expect(xml, contains('<ClipPath'));
  });
}
