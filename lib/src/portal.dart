import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderOrValue<T extends Listenable> extends StatelessWidget {
  final T? value;

  final Create<T>? create;

  /// Dispose function for the provider, only used if [value] is null
  final Dispose<T>? dispose;

  final Widget Function(BuildContext, Widget?) builder;

  final Widget? child;

  const ProviderOrValue({
    super.key,
    this.value,
    this.create,
    this.child,
    this.dispose,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return ListenableProvider<T>.value(
        value: value!,
        child: child!,
        builder: builder,
      );
    } else {
      return ListenableProvider<T>(
        create: create!,
        child: child!,
        dispose: dispose,
        builder: builder,
      );
    }
  }
}
