import 'package:flutter/widgets.dart';

class LdWrapConditional extends StatelessWidget {
  final bool condition;
  final Widget child;
  final Widget Function(BuildContext context, Widget child) builder;

  const LdWrapConditional({
    super.key,
    required this.condition,
    required this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? builder(context, child) : child;
  }
}
