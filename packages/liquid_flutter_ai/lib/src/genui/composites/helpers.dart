import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

LdButtonMode compositeBtnMode(LdGenuiButtonMode mode) => switch (mode) {
  LdGenuiButtonMode.outline => LdButtonMode.outline,
  LdGenuiButtonMode.ghost => LdButtonMode.ghost,
  LdGenuiButtonMode.vague => LdButtonMode.vague,
  LdGenuiButtonMode.filled => LdButtonMode.filled,
};

/// Parses the component's properties, as the agent sent them, into [T] and
/// builds the widget. The `props` passed to [builder] hold the current values
/// of the properties that may be bound to the data model. [FormatException]s
/// from [parse] are reported on the surface and become [LdGenuiFallback]s.
ComponentImplementation ldCatalogItem<T>({
  required String name,
  required Schema schema,
  required T Function(Object? json) parse,
  required Widget Function(
    ComponentNode<ComponentImplementation> node,
    ComponentProps props,
    T data,
  )
  builder,
}) {
  return ComponentImplementation(
    name: name,
    // Accept properties the schema does not list, so a component an agent
    // adds an unknown property to still renders.
    schema: Schema.fromMap({'additionalProperties': true, ...schema.value}),
    builder: (context, node, props, buildChild) {
      try {
        return builder(
          node,
          props,
          parse(node.context?.componentModel.properties),
        );
      } on FormatException catch (error) {
        final surface = A2uiSurface.of(context);
        unawaited(
          surface.dispatchError(
            A2uiRendererError(
              code: 'RUNTIME_ERROR',
              surfaceId: surface.id,
              message: error.toString(),
            ),
          ),
        );
        return LdGenuiFallback(error: error);
      }
    },
  );
}

/// Shown in place of a component, or part of one, whose data is invalid.
class LdGenuiFallback extends StatelessWidget {
  const LdGenuiFallback({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return LdHint(type: LdHintType.error, child: LdText.p(error.toString()));
  }
}

/// Builds with the current value of the string property [key] and a
/// callback that changes it. A property bound to a data path is written to
/// the data model; a literal or missing value is changed in local state only.
Widget bindWritableString(
  ComponentProps props,
  String key, {
  required Widget Function(
    BuildContext context,
    String? value,
    ValueChanged<String> onChanged,
  )
  builder,
}) {
  return _WritableString(
    value: props.string(key),
    binding: props.writable(key),
    builder: builder,
  );
}

class _WritableString extends StatefulWidget {
  const _WritableString({
    required this.value,
    required this.binding,
    required this.builder,
  });

  final String? value;
  final WritableBinding<Object?>? binding;
  final Widget Function(
    BuildContext context,
    String? value,
    ValueChanged<String> onChanged,
  )
  builder;

  @override
  State<_WritableString> createState() => _WritableStringState();
}

class _WritableStringState extends State<_WritableString> {
  late String? _value = widget.value;

  @override
  void didUpdateWidget(covariant _WritableString oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  void _onChanged(String value) {
    widget.binding?.set(value);
    setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, _onChanged);
}

/// Resolves the data bindings in [action]'s context and dispatches it from
/// [node], with [extraContext] added to the context.
Future<void> dispatchLdAction(
  ComponentNode<ComponentImplementation> node,
  LdGenuiAction? action, {
  Map<String, Object?>? extraContext,
}) async {
  final context = node.context;
  if (action == null || context == null) return;
  final resolved = await context.dataContext.resolveActionAsync({
    'name': action.name,
    'context': action.context,
  });
  final resolvedContext = resolved?['context'];
  await context.dispatchAction({
    'name': action.name,
    'context': <String, Object?>{
      if (resolvedContext is Map<String, Object?>) ...resolvedContext,
      ...?extraContext,
    },
  });
}
