import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  testWidgets('registers lock while locked', (tester) async {
    LdLocationLockRegistry? lockRegistry;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp.router(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/detail',
            redirect: ldLocationLockRedirect,
            routes: [
              GoRoute(
                path: '/detail',
                builder: (context, state) {
                  lockRegistry = LdLocationLockRegistry.of(context);
                  return LdLocationLockGuard(
                    locked: true,
                    pathPrefix: '/detail',
                    onLeave: (_) async => true,
                    child: const Text('content'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(lockRegistry!.isEmpty, isFalse);
    expect(lockRegistry!.locks.single.pathPrefix, '/detail');
  });

  testWidgets('unregisters lock when unlocked', (tester) async {
    LdLocationLockRegistry? lockRegistry;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp.router(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/detail',
            redirect: ldLocationLockRedirect,
            routes: [
              GoRoute(
                path: '/detail',
                builder: (context, state) {
                  lockRegistry = LdLocationLockRegistry.of(context);
                  return const _UnlockableLockGuardPage();
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(lockRegistry!.isEmpty, isFalse);

    await tester.tap(find.text('unlock'));
    await tester.pumpAndSettle();

    expect(lockRegistry!.isEmpty, isTrue);
  });

  testWidgets('blocked pop invokes onBlockedPop', (tester) async {
    var blockedPopCount = 0;

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp.router(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/list',
            redirect: ldLocationLockRedirect,
            routes: [
              GoRoute(
                path: '/list',
                builder: (context, state) => LdButton(
                  child: const Text('open'),
                  onPressed: () => context.push('/detail'),
                ),
              ),
              GoRoute(
                path: '/detail',
                builder: (context, state) => LdLocationLockGuard(
                  locked: true,
                  pathPrefix: '/detail',
                  onLeave: (_) async => false,
                  onBlockedPop: (_) async {
                    blockedPopCount++;
                  },
                  child: LdButton(
                    child: const Text('back'),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    expect(blockedPopCount, 1);
    expect(find.text('back'), findsOneWidget);
  });
}

class _UnlockableLockGuardPage extends StatefulWidget {
  const _UnlockableLockGuardPage();

  @override
  State<_UnlockableLockGuardPage> createState() => _UnlockableLockGuardPageState();
}

class _UnlockableLockGuardPageState extends State<_UnlockableLockGuardPage> {
  var _locked = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LdButton(
          child: const Text('unlock'),
          onPressed: () => setState(() => _locked = false),
        ),
        LdLocationLockGuard(
          locked: _locked,
          pathPrefix: '/detail',
          onLeave: (_) async => true,
          child: const Text('content'),
        ),
      ],
    );
  }
}
