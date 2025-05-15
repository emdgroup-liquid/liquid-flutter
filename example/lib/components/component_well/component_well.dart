import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/components/component_well/show_source_code_options.dart';
import 'package:liquid/components/component_well/source_code_extractor.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ComponentWell extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool onSurface;
  final Widget? title;
  final Widget? description;
  final Color? color;
  ShowSourceCodeOptions? showSourceCodeOptions;
  ComponentWell({
    super.key,
    this.padding,
    required this.child,
    this.color,
    this.onSurface = false,
    this.showSourceCodeOptions,
    this.title,
    this.description,
  }) {
    if (showSourceCodeOptions == null) {
      final stackTrace = StackTrace.current.toString();
      final fullPathRegex = RegExp(r"package(:|s/)liquid/(.*?)\.dart");
      // skip the first match, as it belongs to this file (component_well.dart), while the second match is the calling file
      final match = fullPathRegex.allMatches(stackTrace).skip(1).firstOrNull;
      final path = match?.group(2);

      if (path == null) {
        throw Exception("Could not infer the path to the source code");
      }

      showSourceCodeOptions = ShowSourceCodeOptions(path: "lib/$path.dart");
    }
  }

  @override
  State<ComponentWell> createState() => _ComponentWellState();
}

final Map<ValueKey<String>, int> instanceCounters = {};

class _ComponentWellState extends State<ComponentWell> {
  late int instanceIndex; // Instance index for this widget

  late ValueKey<String>? pageKey; // Page key for this widget

  /// The path to the source code file. If no path was provided via the
  /// [ShowSourceCodeOptions], it will be inferred from the current route.
  get sourcePath =>
      widget.showSourceCodeOptions?.path ?? "lib${pageKey!.value}.dart";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final showSourceCode = widget.showSourceCodeOptions?.showButton ?? true;

    return LdAutoSpace(
      children: [
        if (widget.title != null)
          Row(
            children: [
              Expanded(child: widget.title!),
              if (showSourceCode) buildSourceCodeModal(context)
            ],
          ),
        if (widget.description != null) widget.description!,
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
        if (showSourceCode && widget.title == null)
          Align(
            alignment: Alignment.centerRight,
            child: buildSourceCodeModal(context),
          ),
      ],
    );
  }

  @override
  void initState() {
    pageKey = GoRouter.of(context).state.pageKey;

    if (pageKey != null) {
      instanceIndex = instanceCounters.putIfAbsent(pageKey!, () => 0);
      instanceCounters[pageKey!] = instanceIndex + 1;
    }

    super.initState();
  }

  @override
  dispose() {
    instanceCounters.remove(pageKey!);
    super.dispose();
  }

  /// Builds the child with a button to toggle between the demo and the source code.
  Widget buildSourceCodeModal(BuildContext context) {
    return LdModalBuilder(
      modal: LdModal(
        title: const Text("Source Code"),
        size: LdSize.l,
        contentPadding: EdgeInsets.zero,
        modalContent: (context) => LdSubmit<String>(
          config: LdSubmitConfig(
              autoTrigger: true,
              action: () async {
                // Load the source code
                return await rootBundle.loadString(sourcePath);
              }),
          builder: LdSubmitCenteredBuilder<String>(
            resultBuilder: (context, result, controller) => SourceCodeExtractor(
              options: widget.showSourceCodeOptions,
              sourceCode: result,
              index: instanceIndex,
            ),
          ),
        ),
      ),
      builder: (context, showModal) {
        return LdButtonGhost(
          autoLoading: false,
          onPressed: showModal,
          child: const Icon(LucideIcons.code),
        );
      },
    );
  }
}
