import 'package:flutter/widgets.dart';

/// Exposes detail-form state to custom layouts (e.g. save in an app bar).
class LdMonkeyDetailFormScope<TDetail> extends InheritedWidget {
  final bool isDirty;
  final bool isSaving;
  final TDetail? detail;
  final Future<void> Function() save;
  final void Function() reset;

  const LdMonkeyDetailFormScope({
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
    return isDirty != oldWidget.isDirty ||
        isSaving != oldWidget.isSaving ||
        detail != oldWidget.detail;
  }
}
