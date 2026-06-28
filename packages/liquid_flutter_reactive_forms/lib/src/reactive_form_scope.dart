import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Exposes the active [FormGroup] to descendants of [LdReactiveForm].
class LdReactiveFormScope extends InheritedWidget {
  final FormGroup formGroup;

  const LdReactiveFormScope({
    required this.formGroup,
    required super.child,
    super.key,
  });

  static FormGroup of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LdReactiveFormScope>();
    assert(scope != null, 'LdReactiveFormScope not found in context');
    return scope!.formGroup;
  }

  static FormGroup? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LdReactiveFormScope>()?.formGroup;
  }

  @override
  bool updateShouldNotify(LdReactiveFormScope oldWidget) {
    return !identical(formGroup, oldWidget.formGroup);
  }
}
