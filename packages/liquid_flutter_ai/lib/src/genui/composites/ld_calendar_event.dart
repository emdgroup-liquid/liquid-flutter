import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

final ldCalendarEvent = CatalogItem(
  name: 'LdCalendarEvent',
  dataSchema: ldCalendarEventSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String? ?? '';
    final startRaw = d['start'] as String?;
    final endRaw = d['end'] as String?;
    final location = d['location'] as String?;
    final description = d['description'] as String?;
    final allDay = d['allDay'] as bool? ?? false;
    final action = d['action'] as JsonMap?;

    if (title.isEmpty || startRaw == null || startRaw.isEmpty) {
      final error = FormatException(
        'LdCalendarEvent "${ctx.id}" requires title and start',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    final start = DateTime.tryParse(startRaw);
    final end = endRaw == null ? null : DateTime.tryParse(endRaw);
    final when = _formatEventWhen(start: start, end: end, allDay: allDay);

    return LdAutoSpace(
      children: [
        Row(
          children: [
            Icon(LucideIcons.calendar, size: 14),
            ldHSpacerS,
            Expanded(child: LdText.h(title)),
          ],
        ),
        if (when.isNotEmpty) LdMute(child: LdText.p(when)),
        if (location != null && location.isNotEmpty)
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 13),
              ldHSpacerXS,
              Expanded(child: LdText.p(location)),
            ],
          ),
        if (description != null && description.isNotEmpty)
          LdMarkdown(data: description, shrinkWrap: true),
        if (action != null)
          Align(
            alignment: Alignment.centerRight,
            child: LdButton(
              mode: LdButtonMode.outline,
              onPressed: () => dispatchAction(ctx, action),
              child: const Text('Open'),
            ),
          ),
      ],
    );
  },
);
