import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/components/component_well/show_source_code_options.dart';
import 'package:liquid/components/component_well/source_code_extractor.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ComponentWell extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool onSurface;
  final Color? color;
  final ShowSourceCodeOptions? showSourceCodeOptions;
  const ComponentWell({
    Key? key,
    this.padding,
    required this.child,
    this.color,
    this.onSurface = false,
    this.showSourceCodeOptions,
  }) : super(key: key);

  @override
  State<ComponentWell> createState() => _ComponentWellState();
}

class _ComponentWellState extends State<ComponentWell> {
  static final Map<ValueKey<String>, int> _instanceCounters = {};

  late int _instanceIndex; // Instance index for this widget

  late ValueKey<String>? _pageKey; // Page key for this widget

  /// The path to the source code file. If no path was provided via the
  /// [ShowSourceCodeOptions], it will be inferred from the current route.
  get _sourcePath =>
      widget.showSourceCodeOptions?.path ?? "lib${_pageKey!.value}.dart";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final showSourceCode = widget.showSourceCodeOptions?.showButton ?? true;

    return LdAutoSpace(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.color ??
                (widget.onSurface ? theme.surface : theme.background),
            borderRadius: theme.radius(LdSize.m),
            border: Border.all(
              color: theme.border,
              width: theme.borderWidth,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          padding: widget.padding ??
              EdgeInsets.symmetric(
                vertical: showSourceCode ? 16 : 32,
                horizontal: 16,
              ),
          child: Provider.value(
            value: LdSurfaceInfo(isSurface: widget.onSurface),
            child: widget.child,
          ),
        ),
        if (showSourceCode)
          Align(
            alignment: Alignment.centerRight,
            child: _buildSourceCodeModal(context),
          ),
      ],
    );
  }

  @override
  void initState() {
    _pageKey = GoRouter.of(context).state.pageKey;
    if (_pageKey != null) {
      _instanceIndex = _instanceCounters.putIfAbsent(_pageKey!, () => 0);
      _instanceCounters[_pageKey!] = _instanceIndex + 1;
    }
    super.initState();
  }

  @override
  dispose() {
    _instanceCounters.remove(_pageKey!);
    super.dispose();
  }

  /// Builds the child with a button to toggle between the demo and the source code.
  Widget _buildSourceCodeModal(BuildContext context) {
    return LdModalBuilder(
      modal: LdModal(
        title: const Text("Source Code"),
        size: LdSize.l,
        modalContent: (context) => LdSubmit<String>(
          config: LdSubmitConfig(
              autoTrigger: true,
              action: () async {
                // Load the source code
                return await rootBundle.loadString(_sourcePath);
              }),
          builder: LdSubmitCenteredBuilder<String>(
            resultBuilder: (context, result, controller) => SourceCodeExtractor(
              options: widget.showSourceCodeOptions,
              sourceCode: result,
              index: _instanceIndex,
            ),
          ),
        ),
      ),
      builder: (context, showModal) {
        return LdButtonGhost(
          leading: const Icon(Icons.code),
          child: const Text("Show Source Code"),
          autoLoading: false,
          onPressed: showModal,
        );
      },
    );
  }
}
