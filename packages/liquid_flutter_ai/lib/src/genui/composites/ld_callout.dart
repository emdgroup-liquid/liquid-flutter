import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldCallout = ldCatalogItem(
  name: 'LdCallout',
  schema: ldCalloutSchema,
  parse: LdCalloutData.fromJson,
  builder: (_, data) => LdCallout(data: data),
);

class LdCallout extends StatelessWidget {
  const LdCallout({super.key, required this.data});

  final LdCalloutData data;

  @override
  Widget build(BuildContext context) {
    final type = switch (data.type) {
      LdGenuiTone.warning => LdHintType.warning,
      LdGenuiTone.success => LdHintType.success,
      LdGenuiTone.error => LdHintType.error,
      LdGenuiTone.info => LdHintType.info,
    };
    final title = data.title;

    return LdHint(
      type: type,
      withBackground: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      child: LdAutoSpace(
        children: [
          if (title != null && title.isNotEmpty) LdText.h(title),
          LdText.p(data.body),
        ],
      ),
    );
  }
}
