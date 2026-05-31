import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TimelineDemo extends StatelessWidget {
  const TimelineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/components/interaction/timeline.dart',
      title: 'LdTimeline',
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            title: LdText.l('With now indicator and active progress'),
            child: LdTimeline(
              durationScale: 0.02,
              now: const Duration(minutes: 75),
              nowLabel: LdText.l('Now'),
              entries: [
                LdTimelineEntry.fromStrings(
                  title: 'Kickoff',
                  subtitle: 'Jan 2 · 30 min · done',
                  icon: const Icon(LucideIcons.flag),
                  duration: const Duration(minutes: 30),
                  state: LdTimelineEntryState.completed,
                ),
                const LdTimelineGap(duration: Duration(hours: 1)),
                LdTimelineEntry.fromStrings(
                  title: 'Design review',
                  subtitle: '20 min into 2 h block',
                  icon: const Icon(LucideIcons.pencil),
                  duration: const Duration(hours: 2),
                  state: LdTimelineEntryState.active,
                ),
                LdTimelineEntry.fromStrings(
                  title: 'Launch',
                  subtitle: 'Scheduled · 1 h',
                  icon: const Icon(LucideIcons.rocket),
                  duration: const Duration(hours: 1),
                  state: LdTimelineEntryState.idle,
                ),
              ],
            ),
          ),
          ComponentWell(
            title: LdText.l('Explicit active progress'),
            child: LdTimeline(
              minSegmentHeight: 72,
              now: const Duration(minutes: 15),
              durationScale: 0.1,
              entries: [
                LdTimelineEntry.fromStrings(
                  title: 'Deploy',
                  subtitle: '65% complete',
                  icon: const Icon(LucideIcons.rocket),
                  duration: const Duration(minutes: 30),
                  state: LdTimelineEntryState.active,
                  progress: 0.5,
                ),
                LdTimelineEntry.fromStrings(
                  title: 'Verify',
                  subtitle: 'Up next',
                  icon: const Icon(LucideIcons.clipboardCheck),
                  duration: const Duration(minutes: 15),
                  state: LdTimelineEntryState.idle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
