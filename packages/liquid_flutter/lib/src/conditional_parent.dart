import 'package:flutter/widgets.dart';

class LdWrapConditional extends StatefulWidget {
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
  State<LdWrapConditional> createState() => _LdWrapConditionalState();
}

class _LdWrapConditionalState extends State<LdWrapConditional> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _key, child: widget.child);
    return widget.condition ? widget.builder(context, child) : child;
  }
}
