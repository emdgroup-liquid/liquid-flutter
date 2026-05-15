import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/appbar/appbar_state.dart';
import 'package:provider/provider.dart';

/// Builds its subtree with the current `isScrolledUnder` value sourced from
/// the nearest [LdAppBarMetrics] provided by [AppBarFrame].
///
/// Returns `false` when no metrics are available (e.g. legacy scaffold mode).
class ScrolledUnderBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isScrolledUnder) builder;

  const ScrolledUnderBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isScrolledUnder = context.watch<LdAppBarMetrics?>()?.isScrolledUnder ?? false;
    return builder(context, isScrolledUnder);
  }
}
