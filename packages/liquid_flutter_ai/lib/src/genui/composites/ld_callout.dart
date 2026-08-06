import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldCallout = CatalogItem(
  name: 'LdCallout',
  dataSchema: ldCalloutSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final type = switch (d['type'] as String?) {
      'warning' => LdHintType.warning,
      'success' => LdHintType.success,
      'error' => LdHintType.error,
      _ => LdHintType.info,
    };
    final title = d['title'] as String?;
    final body = d['body'] as String? ?? '';

    return LdHint(
      type: type,
      withBackground: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      child: LdAutoSpace(
        children: [
          if (title != null && title.isNotEmpty) LdText.h(title),
          LdText.p(body),
        ],
      ),
    );
  },
);
