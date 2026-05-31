import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testGoldens('LdTimeline Golden', (tester) async {
    await multiGolden(tester, 'LdTimeline', {
      'States': (tester, place) async {
        await place(
          LdTimeline(
            entries: [
              LdTimelineEntry.fromStrings(
                title: 'Kickoff',
                subtitle: 'Jan 2 · 30 min',
                icon: const Icon(LucideIcons.flag),
                duration: const Duration(minutes: 30),
                state: LdTimelineEntryState.completed,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Design review',
                subtitle: 'In progress',
                icon: const Icon(LucideIcons.pencil),
                duration: const Duration(hours: 2),
                state: LdTimelineEntryState.active,
              ),
              LdTimelineEntry.fromStrings(
                title: 'QA pass',
                subtitle: 'Waiting',
                icon: const Icon(LucideIcons.clipboardCheck),
                duration: const Duration(hours: 1),
                state: LdTimelineEntryState.idle,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Archived sprint',
                subtitle: 'Last quarter',
                icon: const Icon(LucideIcons.archive),
                duration: const Duration(minutes: 15),
                state: LdTimelineEntryState.past,
              ),
            ],
          ),
        );
      },
      'ActiveProgress': (tester, place) async {
        await place(
          LdTimeline(
            minSegmentHeight: 72,
            durationScale: 1,
            now: const Duration(minutes: 15),
            entries: [
              LdTimelineEntry.fromStrings(
                title: 'Done',
                subtitle: '10 min',
                icon: const Icon(LucideIcons.check),
                duration: const Duration(minutes: 10),
                state: LdTimelineEntryState.completed,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Active',
                subtitle: 'From now',
                icon: const Icon(LucideIcons.play),
                duration: const Duration(minutes: 30),
                state: LdTimelineEntryState.active,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Explicit',
                subtitle: '65%',
                icon: const Icon(LucideIcons.loader),
                duration: const Duration(minutes: 20),
                state: LdTimelineEntryState.active,
                progress: 0.65,
              ),
            ],
          ),
        );
      },
      'Now': (tester, place) async {
        await place(
          LdTimeline(
            durationScale: 0.02,
            now: const Duration(minutes: 50),
            nowLabel: LdText.l('Now'),
            entries: [
              LdTimelineEntry.fromStrings(
                title: 'Kickoff',
                subtitle: '30 min',
                icon: const Icon(LucideIcons.flag),
                duration: const Duration(minutes: 30),
                state: LdTimelineEntryState.completed,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Design review',
                subtitle: '2 h',
                icon: const Icon(LucideIcons.pencil),
                duration: const Duration(hours: 2),
                state: LdTimelineEntryState.active,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Launch',
                subtitle: '1 h',
                icon: const Icon(LucideIcons.rocket),
                duration: const Duration(hours: 1),
                state: LdTimelineEntryState.idle,
              ),
            ],
          ),
        );
      },
      'Gaps': (tester, place) async {
        await place(
          LdTimeline(
            minSegmentHeight: 72,
            durationScale: 1,
            gapHeight: 56,
            entries: [
              LdTimelineEntry.fromStrings(
                title: 'Sprint A',
                subtitle: 'Done',
                icon: const Icon(LucideIcons.flag),
                duration: const Duration(minutes: 30),
                state: LdTimelineEntryState.completed,
              ),
              const LdTimelineGap(duration: Duration(hours: 2)),
              LdTimelineEntry.fromStrings(
                title: 'Sprint B',
                subtitle: 'Active',
                icon: const Icon(LucideIcons.play),
                duration: const Duration(hours: 1),
                state: LdTimelineEntryState.active,
              ),
            ],
          ),
        );
      },
      'Durations': (tester, place) async {
        await place(
          LdTimeline(
            entries: [
              LdTimelineEntry.fromStrings(
                title: 'Short',
                subtitle: '5 min',
                icon: const Icon(LucideIcons.timer),
                duration: const Duration(minutes: 5),
                state: LdTimelineEntryState.completed,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Medium',
                subtitle: '45 min',
                icon: const Icon(LucideIcons.timer),
                duration: const Duration(minutes: 45),
                state: LdTimelineEntryState.active,
              ),
              LdTimelineEntry.fromStrings(
                title: 'Long',
                subtitle: '3 h',
                icon: const Icon(LucideIcons.timer),
                duration: const Duration(hours: 3),
                state: LdTimelineEntryState.idle,
              ),
            ],
          ),
        );
      },
    });
  });
}
