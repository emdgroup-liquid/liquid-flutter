import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

LdButtonMode compositeBtnMode(LdGenuiButtonMode mode) => switch (mode) {
  LdGenuiButtonMode.outline => LdButtonMode.outline,
  LdGenuiButtonMode.ghost => LdButtonMode.ghost,
  LdGenuiButtonMode.vague => LdButtonMode.vague,
  LdGenuiButtonMode.filled => LdButtonMode.filled,
};

/// Parses [ctx.data] into [T] and builds the widget. [FormatException]s
/// from [parse] become [FallbackWidget]s.
CatalogItem ldCatalogItem<T>({
  required String name,
  required Schema schema,
  required T Function(Object? json) parse,
  required Widget Function(CatalogItemContext ctx, T data) builder,
}) {
  return CatalogItem(
    name: name,
    dataSchema: schema,
    widgetBuilder: (ctx) {
      try {
        return builder(ctx, parse(ctx.data));
      } on FormatException catch (error, stack) {
        ctx.reportError(error, stack);
        return FallbackWidget(error: error);
      }
    },
  );
}

/// Data-model path for a two-way string binding.
String writableStringPath(LdStringRef? ref, String fallbackPath) =>
    switch (ref) {
      LdStringBinding(:final path) => path,
      _ => fallbackPath,
    };

/// Seeds a literal into the data model so two-way updates have a path, then
/// binds [BoundString] to that path.
Widget bindWritableString(
  CatalogItemContext ctx, {
  required LdStringRef? ref,
  required String fallbackPath,
  required Widget Function(BuildContext context, String? value) builder,
}) {
  final path = writableStringPath(ref, fallbackPath);
  if (ref is LdStringLiteral) {
    ctx.dataContext.update(DataPath(path), ref.value);
  }
  return BoundString(
    dataContext: ctx.dataContext,
    value: {'path': path},
    builder: builder,
  );
}

Future<void> dispatchLdAction(
  CatalogItemContext ctx,
  LdGenuiAction? action, {
  Map<String, Object?>? extraContext,
}) async {
  if (action == null) return;
  final resolved = await resolveContext(ctx.dataContext, action.context);
  final merged = <String, Object?>{...resolved, ...?extraContext};
  ctx.dispatchEvent(
    UserActionEvent(
      name: action.name,
      sourceComponentId: ctx.id,
      timestamp: DateTime.now(),
      context: merged,
    ),
  );
}
