import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

LdButtonMode compositeBtnMode(String? m) => switch (m) {
  'outline' => LdButtonMode.outline,
  'ghost' => LdButtonMode.ghost,
  'vague' => LdButtonMode.vague,
  _ => LdButtonMode.filled,
};

String? bindingPath(Object? ref, String fallback) {
  if (ref is JsonMap && ref.containsKey('path')) {
    return ref['path'] as String?;
  }
  return fallback;
}

Future<void> dispatchAction(
  CatalogItemContext ctx,
  JsonMap? action, {
  Map<String, Object?>? extraContext,
}) async {
  if (action == null) return;
  final resolved = await resolveContext(
    ctx.dataContext,
    action['context'] as JsonMap?,
  );
  final merged = <String, Object?>{...resolved, ...?extraContext};
  ctx.dispatchEvent(
    UserActionEvent(
      name: action['name'] as String? ?? 'action',
      sourceComponentId: ctx.id,
      timestamp: DateTime.now(),
      context: merged,
    ),
  );
}

List<JsonMap> objectList(Object? raw) {
  if (raw is! List) return const [];
  final out = <JsonMap>[];
  for (final item in raw) {
    if (item is Map) {
      out.add(Map<String, Object?>.from(item));
    }
  }
  return out;
}
