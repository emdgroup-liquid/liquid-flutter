import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:provider/single_child_widget.dart';

class _FakeWindowHandle implements LdWindowHandle {
  final Completer<void> _closed = Completer<void>();
  bool _isClosed = false;

  Rect? lastAnchor;

  @override
  bool get isClosed => _isClosed;

  @override
  Future<void> get closed => _closed.future;

  @override
  void updateAnchor(Rect anchorRect) {
    lastAnchor = anchorRect;
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }
    _isClosed = true;
    _closed.complete();
  }
}

class _FakeWindowingAdapter implements LdWindowingAdapter {
  bool available = true;
  int popupCalls = 0;
  int tooltipCalls = 0;
  int dialogCalls = 0;
  _FakeWindowHandle? lastHandle;

  @override
  bool isAvailable(BuildContext context) => available;

  @override
  LdWindowHandle? showPopup({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  }) {
    popupCalls++;
    return lastHandle = _FakeWindowHandle();
  }

  @override
  LdWindowHandle? showTooltip({
    required BuildContext context,
    required Rect anchorRect,
    required WidgetBuilder builder,
    LdWindowPosition position = const LdWindowPosition(),
    BoxConstraints constraints = const BoxConstraints(),
    List<SingleChildWidget> providers = const [],
  }) {
    tooltipCalls++;
    return lastHandle = _FakeWindowHandle();
  }

  @override
  Route<T>? createDialogRoute<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Size size,
    String? title,
    RouteSettings? settings,
    List<SingleChildWidget> providers = const [],
  }) {
    dialogCalls++;
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    );
  }
}

Widget _frame({
  required Widget child,
  required LdWindowingAdapter adapter,
}) {
  return ldFrame(
    child: LdWindowingScope(
      adapter: adapter,
      child: child,
    ),
  );
}

void main() {
  testWidgets('LdTooltip falls back to Material Tooltip without windowing', (tester) async {
    await tester.pumpWidget(
      ldFrame(
        child: const LdTooltip(
          message: 'Help',
          child: Text('Hover me'),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('LdTooltip uses a native tooltip window when available', (tester) async {
    final adapter = _FakeWindowingAdapter();
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: const Center(
          child: LdTooltip(
            message: 'Help',
            waitDuration: Duration.zero,
            child: SizedBox(width: 80, height: 32, child: Text('Hover me')),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final center = tester.getCenter(find.text('Hover me'));
    await gesture.addPointer(location: center);
    await tester.pump();
    await gesture.moveTo(center + const Offset(1, 0));
    await tester.pump(const Duration(milliseconds: 1));

    expect(adapter.tooltipCalls, 1);
    expect(adapter.lastHandle?.isClosed, isFalse);

    await gesture.removePointer();
    await tester.pump();
    expect(adapter.lastHandle?.isClosed, isTrue);
  });

  testWidgets('LdTooltip can opt out of native windows', (tester) async {
    final adapter = _FakeWindowingAdapter();
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: const LdTooltip(
          windowMode: LdWindowMode.disabled,
          message: 'Help',
          child: Text('Hover me'),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('LdContextMenu opens a native popup when available', (tester) async {
    final adapter = _FakeWindowingAdapter();
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: Center(
          child: LdContextMenu(
            builder: (context, isShuttle, open, isOpen, child) {
              return GestureDetector(
                onTap: open,
                child: const Text('Open menu'),
              );
            },
            menuBuilder: (context) => const Text('Menu item'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    expect(adapter.popupCalls, 1);
    expect(adapter.lastHandle?.isClosed, isFalse);

    adapter.lastHandle!.close();
    await tester.pumpAndSettle();
    expect(adapter.lastHandle?.isClosed, isTrue);
  });

  testWidgets('LdContextMenu opts out of native windows', (tester) async {
    final adapter = _FakeWindowingAdapter();
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: Center(
          child: LdContextMenu(
            windowMode: LdWindowMode.disabled,
            builder: (context, isShuttle, open, isOpen, child) {
              return GestureDetector(
                onTap: open,
                child: const Text('Open menu'),
              );
            },
            menuBuilder: (context) => const Text('Menu item'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();

    expect(adapter.popupCalls, 0);
    expect(find.text('Menu item'), findsOneWidget);
  });

  testWidgets('LdModalRoute creates a native dialog route when available', (tester) async {
    final adapter = _FakeWindowingAdapter();
    late BuildContext hostContext;
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final route = LdModalRoute<void>(
      context: hostContext,
      modalTypeMode: LdModalTypeMode.dialog,
      pageBuilder: (context) => const Text('Dialog'),
    );

    final nativeRoute = route.createNativeWindowRoute<void>(hostContext);

    expect(nativeRoute, isNotNull);
    expect(adapter.dialogCalls, 1);
  });

  testWidgets('LdModalRoute keeps the overlay route when windowing is disabled', (tester) async {
    final adapter = _FakeWindowingAdapter();
    late BuildContext hostContext;
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final route = LdModalRoute<void>(
      context: hostContext,
      modalTypeMode: LdModalTypeMode.dialog,
      windowMode: LdWindowMode.disabled,
      pageBuilder: (context) => const Text('Dialog'),
    );

    expect(route.createNativeWindowRoute<void>(hostContext), isNull);
    expect(adapter.dialogCalls, 0);
  });

  testWidgets('LdModalRoute keeps the sheet overlay on narrow windows', (tester) async {
    final adapter = _FakeWindowingAdapter();
    late BuildContext hostContext;
    await tester.pumpWidget(
      _frame(
        adapter: adapter,
        child: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final route = LdModalRoute<void>(
      context: hostContext,
      modalTypeMode: LdModalTypeMode.auto,
      sheetBreakpoint: tester.view.physicalSize.width + 1,
      pageBuilder: (context) => const Text('Dialog'),
    );

    expect(route.createNativeWindowRoute<void>(hostContext), isNull);
    expect(adapter.dialogCalls, 0);
  });
}
