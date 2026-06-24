import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _LockOnMount extends StatefulWidget {
  final LdLocationLock lock;
  final Widget child;

  const _LockOnMount({
    required this.lock,
    required this.child,
  });

  @override
  State<_LockOnMount> createState() => _LockOnMountState();
}

class _LockOnMountState extends State<_LockOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      LdLocationLockRegistry.of(context).register(widget.lock);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  group('ldLocationLockRedirect', () {
    testWidgets('blocks navigation away from locked prefix', (tester) async {
      var leavePrompted = false;
      late GoRouter router;

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            routerConfig: router = GoRouter(
              initialLocation: '/detail',
              redirect: ldLocationLockRedirect,
              routes: [
                GoRoute(
                  path: '/detail',
                  builder: (context, state) => _LockOnMount(
                    lock: LdLocationLock(
                      id: 'test',
                      pathPrefix: '/detail',
                      onLeave: (_) async {
                        leavePrompted = true;
                        return false;
                      },
                    ),
                    child: const Text('detail'),
                  ),
                ),
                GoRoute(
                  path: '/other',
                  builder: (context, state) => const Text('other'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/other');
      await tester.pumpAndSettle();

      expect(leavePrompted, isTrue);
      expect(router.state.uri.path, '/detail');
      expect(find.text('detail'), findsOneWidget);
    });

    testWidgets('allows navigation to sub-path of lock prefix', (tester) async {
      var leavePrompted = false;
      late GoRouter router;

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            routerConfig: router = GoRouter(
              initialLocation: '/detail',
              redirect: ldLocationLockRedirect,
              routes: [
                GoRoute(
                  path: '/detail',
                  builder: (context, state) => _LockOnMount(
                    lock: LdLocationLock(
                      id: 'test',
                      pathPrefix: '/detail',
                      onLeave: (_) async {
                        leavePrompted = true;
                        return false;
                      },
                    ),
                    child: const Text('detail'),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => const Text('edit'),
                    ),
                  ],
                ),
                GoRoute(
                  path: '/other',
                  builder: (context, state) => const Text('other'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/detail/edit');
      await tester.pumpAndSettle();

      expect(leavePrompted, isFalse);
      expect(router.state.uri.path, '/detail/edit');
      expect(find.text('edit'), findsOneWidget);
    });

    testWidgets('allows leave after onLeave returns true', (tester) async {
      late GoRouter router;

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            routerConfig: router = GoRouter(
              initialLocation: '/detail',
              redirect: ldLocationLockRedirect,
              routes: [
                GoRoute(
                  path: '/detail',
                  builder: (context, state) => _LockOnMount(
                    lock: LdLocationLock(
                      id: 'test',
                      pathPrefix: '/detail',
                      onLeave: (_) async => true,
                    ),
                    child: const Text('detail'),
                  ),
                ),
                GoRoute(
                  path: '/other',
                  builder: (context, state) => const Text('other'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/other');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/other');
      expect(find.text('other'), findsOneWidget);
    });
  });
}
