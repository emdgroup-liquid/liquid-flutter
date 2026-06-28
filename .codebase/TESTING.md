# Testing Conventions

This document describes the testing patterns and infrastructure used in liquid-flutter.

## Test Framework

- **Test Runner**: `flutter_test` (bundled with Flutter SDK)
- **Golden Testing**: `golden_toolkit ^0.15.0`
- **Test Utilities**: `liquid_flutter_test_utils`
- **Mocking**: Built-in Flutter test mocks + custom `MockBuildContext`

## Test File Organization

### Location

Test files live in `test/` directories within each package:

```
packages/liquid_flutter/
  test/
    button_test.dart              # Unit/interaction tests
    button_golden_test.dart        # Golden visual tests
    form_test.dart
    utils.dart                    # Shared test utilities
    monkey/
      monkey_integration_test.dart
      test_utils.dart
```

### Naming Conventions

| Pattern | Example | Purpose |
|---------|---------|---------|
| `<component>_test.dart` | `button_test.dart` | Unit/widget tests |
| `<component>_golden_test.dart` | `button_golden_test.dart` | Visual regression tests |
| `utils.dart` | `test/utils.dart` | Shared test helpers |
| `test_utils.dart` | `monkey/test_utils.dart` | Test-specific utilities |

## Common Test Structure

### Widget Test Pattern

```dart
void main() {
  testWidgets('LdButton interactivity', (WidgetTester test) async {
    var theme = LdTheme();

    await test.pumpWidget(LdThemeProvider(
      theme: theme,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LdButton(
          onPressed: () {},
          child: const Text("Test button"),
        ),
      ),
    ));

    await test.pumpAndSettle();

    expect(find.text("Test button"), findsOneWidget);

    await test.tap(find.byType(LdButton));
    await test.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
```

### Grouped Tests

Use `group()` to organize related tests:

```dart
void main() {
  group('LdExceptionView Tests', () {
    testWidgets('displays message correctly', ...);
    testWidgets('handles retry callback correctly', ...);
  });

  group('LdExceptionLocalizerMapper Tests', () {
    testWidgets('parent fallback works correctly', ...);
  });
}
```

## Test Utilities

### Theme Wrapper

```dart
// test/utils.dart
Widget withLiquidTheme(Widget child, {LdTheme? theme}) {
  ldDisableAnimations = true;  // Disable for consistent testing
  return LdThemeProvider(
    theme: theme ?? LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate
      ],
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: child,
          ),
        ),
      ),
    ),
  );
}
```

### Custom Gesture Helper

```dart
Future<void> performPanGesture(
  WidgetTester tester, {
  required Offset startPosition,
  Offset? endPosition,
  Offset? offset,
  int steps = 10,
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  // Start pan gesture
  final gesture = await tester.startGesture(startPosition, kind: kind);
  await tester.pump();

  // Move in incremental steps
  final stepsDouble = steps.toDouble();
  for (var i = 1; i <= steps; i++) {
    await gesture.moveBy(targetOffset / stepsDouble);
    await tester.pump();
  }

  await gesture.up();
  await tester.pumpAndSettle();
}
```

### Mock BuildContext

```dart
class MockBuildContext extends BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    throw UnimplementedError();
  }

  // ... other required implementations
}
```

## Golden Tests

### Setup

Golden tests require `flutter_test_config.dart`:

```dart
// test/flutter_test_config.dart
import 'dart:async';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setupGoldenTest();
  await testMain();
}
```

### Golden Test Pattern

```dart
// button_golden_test.dart
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("Button Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdButton", {
      "LdButton": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          onPressed: () {},
        ));
      },
      "LdButtonOutline": (tester, place) async {
        await place(LdButton.outline(
          child: const Text("Hello"),
          onPressed: () {},
        ));
      },
      // ... more variants
    });
  });
}
```

### Multi-Golden Helper

The `multiGolden` function from `liquid_flutter_test_utils` handles:
- Pump/settle cycles
- Multiple device sizes
- Animation disabled state

## Mocking Patterns

### Test Repository

```dart
LdListController<TestItem, int> createTestListController({
  List<TestItem>? initialItems,
  Set<LdFilterOption<TestItem, int>>? filters,
}) {
  final items = initialItems ?? [
    TestItem(1, 'Item 1', 10),
    TestItem(2, 'Item 2', 20),
  ];

  return LdListController<TestItem, int>(
    fetchListWithParameters: ({required offset, required pageSize, ...}) async {
      return LdListPage(
        newItems: items.skip(offset).take(pageSize).toList(),
        hasMore: offset + pageSize < items.length,
        total: items.length,
      );
    },
    getById: (id) async => items.firstWhere((item) => item.id == id),
    filters: filters,
  );
}
```

### Test Item Factory

```dart
TestItem createTestItem(int id, {String? name, int? value, bool? active}) {
  return TestItem(
    id,
    name ?? 'Item $id',
    value ?? id * 10,
    active ?? true,
  );
}
```

### Mock Objects

Use `MockXXX` classes from `package:flutter_test`:

```dart
import 'package:flutter_test/flutter_test.dart';

testWidgets('test name', (WidgetTester tester) async {
  var pressed = false;
  
  await tester.pumpWidget(LdButton(
    onPressed: () {
      pressed = true;
    },
    child: const Text('Press'),
  ));

  await tester.tap(find.byType(LdButton));
  expect(pressed, isTrue);
});
```

## Async Testing Patterns

### Completer Pattern

```dart
testWidgets('LdButton loading', (WidgetTester test) async {
  var completer = Completer();

  onPressed() async {
    return completer.future;
  }

  await test.pumpWidget(LdButton(
    onPressed: onPressed,
    child: const Text("Test button"),
  ));

  await test.tap(find.byType(LdButton));
  await test.pump();
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  completer.complete();
  await test.pumpAndSettle();
  
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

### Pump and Settle

- `test.pump()` - Advance 1 frame
- `test.pumpAndSettle()` - Wait for all animations to complete
- `test.pump(Duration)` - Advance specific duration

## Test Data Fixtures

### Inline Fixtures

For simple tests, define fixtures inline:

```dart
final sampleErrorException = LdLocalizedException(
  message: 'Error occurred',
  type: LdHintType.error,
  moreInfo: 'Detailed error information',
);
```

### Factory Functions

For complex or reusable fixtures:

```dart
Widget buildBasicExceptionView({
  required LdLocalizedException exception,
  LdRetryController? retryController,
  VoidCallback? retry,
  Axis direction = Axis.vertical,
}) {
  return SizedBox(
    width: 300,
    height: 300,
    child: Center(
      child: LdExceptionView(
        exception: exception,
        retryController: retryController,
        retry: retry,
        direction: direction,
      ),
    ),
  );
}
```

## Coverage Requirements

### Running Coverage

```bash
# Via melos
melos test

# Direct flutter test (from package directory)
flutter test --coverage
```

### Viewing Coverage

Coverage data is generated in `coverage/` directory. Use tools like:
- `genhtml` to generate HTML reports
- VS Code coverage extensions
- Codecov (CI integration)

### Golden Test Tags

Golden tests are tagged in `dart_test.yaml`:

```yaml
tags: 
  golden: 
```

Run only golden tests:
```bash
flutter test --tags=golden
```

## Types of Tests

### Unit Tests

Test individual functions, classes, or business logic:

```dart
test('LdException copyWith works correctly', () {
  final exception = LdException(canRetry: true, type: LdHintType.error);
  final copy = exception.copyWith(canRetry: false);
  
  expect(copy.canRetry, false);
  expect(copy.type, LdHintType.error);
});
```

### Widget/Component Tests

Test UI components in isolation:

```dart
testWidgets('LdForm submits correctly', (WidgetTester tester) async {
  await tester.pumpWidget(withLiquidTheme(LdForm(
    onSubmit: () async { submitted = true; },
    fields: [LdFormItem("name", LdInput(hint: "Name"))],
  )));
  
  await tester.tap(find.byType(LdButton));
  await tester.pumpAndSettle();
  
  expect(submitted, true);
});
```

### Golden Tests

Visual regression tests comparing rendered output against expected images:

```dart
testGoldens("LdButton variants", (WidgetTester tester) async {
  await multiGolden(tester, "LdButton", {
    "filled": (tester, place) async {
      await place(LdButton(child: Text("Test"), onPressed: () {}));
    },
    // ...
  });
});
```

### Integration Tests

Test multiple components working together (e.g., monkey tests):

```dart
testWidgets('renders master and detail side-by-side', (WidgetTester tester) async {
  final repository = createTestListController(initialItems: [...]);
  final routes = buildMonkeyRoutes<TestItem, int>(...);

  final router = GoRouter(routes: routes);
  
  await tester.pumpWidget(LdThemeProvider(
    child: MaterialApp.router(routerConfig: router),
  ));

  router.go('/test/1');
  await tester.pumpAndSettle();

  expect(find.text('Item 1'), findsWidgets);
  expect(find.byType(LdMonkeyShell<TestItem, int>>), findsOneWidget);
});
```

## Running Tests

### All Tests

```bash
flutter test
# or via melos
melos test
```

### Specific Package

```bash
cd packages/liquid_flutter
flutter test
```

### Golden Tests Only

```bash
flutter test --tags=golden
```

### Watch Mode

```bash
flutter test --watch
```
