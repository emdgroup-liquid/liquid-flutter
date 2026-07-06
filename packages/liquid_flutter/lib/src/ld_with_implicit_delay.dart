import 'dart:async';

import 'package:flutter/material.dart';

class LdWithImplicitDelay extends StatefulWidget {
  final bool condition;
  final bool? initialCondition;
  final Widget Function(BuildContext context, bool condition) builder;

  final Duration delay;

  const LdWithImplicitDelay({
    super.key,
    required this.condition,
    this.initialCondition,
    required this.builder,
    required this.delay,
  });

  @override
  State<LdWithImplicitDelay> createState() => _LdWithImplicitDelayState();
}

class _LdWithImplicitDelayState extends State<LdWithImplicitDelay> {
  late bool _condition = widget.initialCondition ?? widget.condition;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _condition = widget.condition;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.condition != widget.condition) {
      _timer?.cancel();
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _condition = widget.condition;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _condition);
  }
}
