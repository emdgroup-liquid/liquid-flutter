import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final ldCalendarEvent = ldCatalogItem(
  name: 'LdCalendarEvent',
  schema: ldCalendarEventSchema,
  parse: LdCalendarEventData.fromJson,
  builder: (ctx, data) => LdCalendarEvent(catalogContext: ctx, data: data),
);

class LdCalendarEvent extends StatelessWidget {
  const LdCalendarEvent({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdCalendarEventData data;

  @override
  Widget build(BuildContext context) {
    final when = _formatEventWhen(
      start: data.startDate,
      end: data.endDate,
      allDay: data.allDay,
    );
    final location = data.location;
    final description = data.description;
    final action = data.action;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdBadge(
          symmetric: true,
          size: LdSize.l,
          child: Icon(LucideIcons.calendar),
        ),
        Expanded(
          child: LdAutoSpace(
            children: [
              LdText.h(data.title),
              LdMute(
                child: LdHorizontalScroll(
                  children: [
                    if (when.isNotEmpty) LdText.l(when),
                    if (location != null && location.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin, size: 13),
                          LdText.l(location),
                        ],
                      ).spaceXS(),
                  ],
                ),
              ),

              if (description != null && description.isNotEmpty)
                LdMarkdown(data: description, shrinkWrap: true),
              if (action != null)
                LdButton(
                  mode: LdButtonMode.outline,
                  size: LdSize.l,
                  onPressed: () => dispatchLdAction(catalogContext, action),
                  child: const Text('Open'),
                ),
            ],
          ),
        ),
      ],
    ).spaceS();
  }
}

String _formatEventWhen({
  required DateTime? start,
  DateTime? end,
  required bool allDay,
}) {
  if (start == null) return '';
  final date =
      '${start.year}-${start.month.toString().padLeft(2, '0')}-'
      '${start.day.toString().padLeft(2, '0')}';
  if (allDay) {
    if (end == null ||
        (end.year == start.year &&
            end.month == start.month &&
            end.day == start.day)) {
      return '$date · All day';
    }
    final endDate =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-'
        '${end.day.toString().padLeft(2, '0')}';
    return '$date → $endDate · All day';
  }
  String hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
  if (end == null) return '$date · ${hm(start)}';
  if (end.year == start.year &&
      end.month == start.month &&
      end.day == start.day) {
    return '$date · ${hm(start)} – ${hm(end)}';
  }
  final endDate =
      '${end.year}-${end.month.toString().padLeft(2, '0')}-'
      '${end.day.toString().padLeft(2, '0')}';
  return '$date ${hm(start)} → $endDate ${hm(end)}';
}
