import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  group('ldTimelineSegmentHeight', () {
    test('uses minimum height for zero duration', () {
      const entry = LdTimelineEntry(
        title: Text('a'),
        icon: Icon(Icons.circle),
        duration: Duration.zero,
      );
      expect(
        ldTimelineSegmentHeight(
          entry,
          minSegmentHeight: 80,
          durationScale: 2,
        ),
        80,
      );
    });

    test('adds height proportional to duration', () {
      const short = LdTimelineEntry(
        title: Text('a'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 10),
      );
      const long = LdTimelineEntry(
        title: Text('b'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 100),
      );
      final shortHeight = ldTimelineSegmentHeight(
        short,
        minSegmentHeight: 80,
        durationScale: 2,
      );
      final longHeight = ldTimelineSegmentHeight(
        long,
        minSegmentHeight: 80,
        durationScale: 2,
      );
      expect(longHeight, greaterThan(shortHeight));
      expect(shortHeight, 80 + 10 * 2);
      expect(longHeight, 80 + 100 * 2);
    });
  });

  group('ldTimelineNowOffset', () {
    const entries = [
      LdTimelineEntry(
        title: Text('a'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 10),
      ),
      LdTimelineEntry(
        title: Text('b'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 20),
      ),
    ];
    const minH = 48.0;
    const scale = 2.0;
    final items = entries;
    final heights = [
      ldTimelineItemHeight(
        items[0],
        minSegmentHeight: minH,
        durationScale: scale,
        gapHeight: 40,
      ),
      ldTimelineItemHeight(
        items[1],
        minSegmentHeight: minH,
        durationScale: scale,
        gapHeight: 40,
      ),
    ];

    test('is zero at timeline start', () {
      expect(
        ldTimelineNowOffset(items, Duration.zero, segmentHeights: heights),
        0,
      );
    });

    test('is proportional within a segment', () {
      expect(
        ldTimelineNowOffset(
          items,
          const Duration(seconds: 5),
          segmentHeights: heights,
        ),
        heights[0] * 0.5,
      );
    });

    test('accounts for completed segments', () {
      expect(
        ldTimelineNowOffset(
          items,
          const Duration(seconds: 20),
          segmentHeights: heights,
        ),
        heights[0] + heights[1] * 0.5,
      );
    });

    test('clamps to end when past total duration', () {
      expect(
        ldTimelineNowOffset(
          items,
          const Duration(seconds: 100),
          segmentHeights: heights,
        ),
        heights[0] + heights[1],
      );
    });

    test('accounts for fixed-height gaps', () {
      const itemsWithGap = <LdTimelineItem>[
        LdTimelineEntry(
          title: Text('a'),
          icon: Icon(Icons.circle),
          duration: Duration(seconds: 10),
        ),
        LdTimelineGap(duration: Duration(hours: 1)),
        LdTimelineEntry(
          title: Text('b'),
          icon: Icon(Icons.circle),
          duration: Duration(seconds: 10),
        ),
      ];
      const gapH = 40.0;
      final gapHeights = [
        ldTimelineItemHeight(
          itemsWithGap[0],
          minSegmentHeight: minH,
          durationScale: scale,
          gapHeight: gapH,
        ),
        ldTimelineItemHeight(
          itemsWithGap[1],
          minSegmentHeight: minH,
          durationScale: scale,
          gapHeight: gapH,
        ),
        ldTimelineItemHeight(
          itemsWithGap[2],
          minSegmentHeight: minH,
          durationScale: scale,
          gapHeight: gapH,
        ),
      ];
      expect(
        ldTimelineNowOffset(
          itemsWithGap,
          const Duration(minutes: 30),
          segmentHeights: gapHeights,
        ),
        gapHeights[0] + gapHeights[1] * 0.5,
      );
    });
  });

  group('ldTimelineItemHeight', () {
    test('gap uses fixed height regardless of duration', () {
      const shortGap = LdTimelineGap(duration: Duration(minutes: 5));
      const longGap = LdTimelineGap(duration: Duration(hours: 5));
      expect(
        ldTimelineItemHeight(
          shortGap,
          minSegmentHeight: 48,
          durationScale: 2,
          gapHeight: 56,
          gapSpacing: 12,
        ),
        56 + 24,
      );
      expect(
        ldTimelineItemHeight(
          longGap,
          minSegmentHeight: 48,
          durationScale: 2,
          gapHeight: 56,
          gapSpacing: 12,
        ),
        56 + 24,
      );
    });
  });

  group('ldFormatTimelineDuration', () {
    test('formats common durations', () {
      expect(ldFormatTimelineDuration(const Duration(hours: 2)), '2 h');
      expect(ldFormatTimelineDuration(const Duration(minutes: 45)), '45 min');
    });
  });

  group('ldTimelineSegmentProgress', () {
    const entries = [
      LdTimelineEntry(
        title: Text('done'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 10),
        state: LdTimelineEntryState.completed,
      ),
      LdTimelineEntry(
        title: Text('active'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 20),
        state: LdTimelineEntryState.active,
      ),
      LdTimelineEntry(
        title: Text('idle'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 30),
        state: LdTimelineEntryState.idle,
      ),
    ];

    test('returns null for non-active entries', () {
      expect(
        ldTimelineSegmentProgress(
          items: entries,
          itemIndex: 0,
          now: const Duration(seconds: 15),
        ),
        isNull,
      );
    });

    test('returns null for gaps', () {
      const itemsWithGap = <LdTimelineItem>[
        LdTimelineEntry(
          title: Text('active'),
          icon: Icon(Icons.circle),
          duration: Duration(seconds: 20),
          state: LdTimelineEntryState.active,
        ),
        LdTimelineGap(duration: Duration(hours: 1)),
      ];
      expect(
        ldTimelineSegmentProgress(
          items: itemsWithGap,
          itemIndex: 1,
          now: const Duration(minutes: 30),
        ),
        isNull,
      );
    });

    test('derives progress from now within active segment', () {
      expect(
        ldTimelineSegmentProgress(
          items: entries,
          itemIndex: 1,
          now: const Duration(seconds: 20),
        ),
        0.5,
      );
    });

    test('uses explicit progress on entry', () {
      const entry = LdTimelineEntry(
        title: Text('active'),
        icon: Icon(Icons.circle),
        duration: Duration(seconds: 20),
        state: LdTimelineEntryState.active,
        progress: 0.75,
      );
      expect(
        ldTimelineSegmentProgress(
          items: [entry],
          itemIndex: 0,
        ),
        0.75,
      );
    });
  });

  testWidgets('renders gap duration label', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: LdTimeline(
              gapHeight: 56,
              entries: [
                LdTimelineEntry(
                  title: Text('Before'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 10),
                ),
                LdTimelineGap(duration: Duration(hours: 2)),
                LdTimelineEntry(
                  title: Text('After'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 h'), findsOneWidget);
    expect(find.byKey(const ValueKey('ld_timeline_gap_1')), findsOneWidget);
  });

  testWidgets('renders now indicator when now is set', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: LdTimeline(
              minSegmentHeight: 48,
              durationScale: 2,
              now: const Duration(seconds: 5),
              nowLabel: const Text('Now'),
              entries: const [
                LdTimelineEntry(
                  title: Text('First'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 10),
                ),
                LdTimelineEntry(
                  title: Text('Second'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Stack), findsOneWidget);
    expect(find.byType(Positioned), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
  });

  testWidgets('renders titles and subtitles for each entry', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: LdTimeline(
              minSegmentHeight: 48,
              durationScale: 1,
              entries: [
                LdTimelineEntry.fromStrings(
                  title: 'First',
                  subtitle: 'Sub one',
                  icon: Icon(Icons.flag),
                  duration: Duration(seconds: 10),
                  state: LdTimelineEntryState.completed,
                ),
                LdTimelineEntry.fromStrings(
                  title: 'Second',
                  subtitle: 'Sub two',
                  icon: Icon(Icons.edit),
                  duration: Duration(seconds: 30),
                  state: LdTimelineEntryState.active,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Sub one'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Sub two'), findsOneWidget);
    expect(find.byType(LdTimeline), findsOneWidget);
  });

  testWidgets('longer duration yields taller segment', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: LdTimeline(
              minSegmentHeight: 48,
              durationScale: 2,
              entries: [
                LdTimelineEntry(
                  title: Text('Short'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 5),
                ),
                LdTimelineEntry(
                  title: Text('Long'),
                  icon: Icon(Icons.circle),
                  duration: Duration(seconds: 60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shortBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('ld_timeline_segment_0')),
    );
    final longBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('ld_timeline_segment_1')),
    );
    expect(longBox.height!, greaterThan(shortBox.height!));
  });

  testWidgets('empty entries renders shrink', (tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        theme: LdTheme(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: LdTimeline(entries: []),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LdTimeline), findsOneWidget);
    expect(find.byKey(const ValueKey('ld_timeline_segment_0')), findsNothing);
  });
}
