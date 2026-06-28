import 'package:flutter/widgets.dart';
import 'package:liquid_flutter_reactive_forms/src/monkey_detail/ld_monkey_reactive_detail_form_mode.dart';

/// Exposes detail-form state to custom layouts (e.g. save in an app bar).
class LdMonkeyDetailFormScope<TDetail> extends InheritedWidget {
  final LdMonkeyReactiveDetailFormMode mode;
  final bool isDirty;
  final bool isSaving;
  final TDetail? detail;
  final Future<void> Function() save;
  final void Function() reset;

  const LdMonkeyDetailFormScope({
    required this.mode,
    required this.isDirty,
    required this.isSaving,
    required this.detail,
    required this.save,
    required this.reset,
    required super.child,
    super.key,
  });

  static LdMonkeyDetailFormScope<TDetail> of<TDetail>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LdMonkeyDetailFormScope<TDetail>>();
    assert(scope != null, 'LdMonkeyDetailFormScope not found in context');
    return scope!;
  }

  static LdMonkeyDetailFormScope<TDetail>? maybeOf<TDetail>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LdMonkeyDetailFormScope<TDetail>>();
  }

  @override
  bool updateShouldNotify(LdMonkeyDetailFormScope<TDetail> oldWidget) {
    return mode != oldWidget.mode ||
        isDirty != oldWidget.isDirty ||
        isSaving != oldWidget.isSaving ||
        detail != oldWidget.detail;
  }
}
