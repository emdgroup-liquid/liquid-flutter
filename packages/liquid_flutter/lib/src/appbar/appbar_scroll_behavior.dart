import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';

class ScrolledUnderBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isScrolledUnder) builder;

  const ScrolledUnderBuilder({super.key, required this.builder});

  @override
  State<ScrolledUnderBuilder> createState() => _ScrolledUnderBuilderState();
}

class _ScrolledUnderBuilderState extends State<ScrolledUnderBuilder> {
  bool _isScrolledUnder = false;

  AppBarRegistryState? _registry;
  late final appBarKey = context.maybeAppBarRegistryKey()!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRegistry = AppBarRegistry.maybeStateOf(context);
    if (_registry != newRegistry) {
      _registry?.removeListener(_onRegistryChange);
      _registry = newRegistry;
      _registry?.addListener(_onRegistryChange);
      _onRegistryChange();
    }
  }

  @override
  void dispose() {
    _registry?.removeListener(_onRegistryChange);
    super.dispose();
  }

  void _onRegistryChange() {
    if (!mounted) return;
    if (_registry == null) return;
    final currentInfo = _registry!.getAppBarInfo(appBarKey);
    if (currentInfo == null) return;
    final isScrolledUnder = currentInfo.scrollUnder;
    if (isScrolledUnder != _isScrolledUnder) {
      setState(() {
        _isScrolledUnder = isScrolledUnder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isScrolledUnder);
  }
}
