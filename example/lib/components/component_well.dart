import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ShowSourceCodeOptions {
  /// The tag to look for in the source code.
  /// The source code must contain a comment like this:
  /// ```dart
  /// /*begin demo:tag*/
  /// // your code here
  /// /*end demo:tag*/
  /// ```
  /// where `tag` is the value of this property.
  /// The code between the `begin` and `end` comments will be displayed.
  final String tag;

  /// The path to the source code file, e.g. "lib/components/reactive_form.dart".
  /// If no path is provided, it will be tried to be inferred from the current
  /// route.
  final String? path;

  ShowSourceCodeOptions({required this.tag, this.path});
}

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
  bool isShowingSourceCode = false;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.color ??
              (widget.onSurface ? theme.surface : theme.background),
          borderRadius: theme.radius(LdSize.m),
          border: Border.all(color: theme.border, width: theme.borderWidth),
        ),
        padding: widget.padding ??
            EdgeInsets.symmetric(
              vertical: widget.showSourceCodeOptions != null ? 16 : 32,
              horizontal: 16,
            ),
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: widget.onSurface),
          child: widget.showSourceCodeOptions != null
              ? _buildChildWithSourceCode(context)
              : widget.child,
        ));
  }

  static final sourceCodeCache = <String, String>{};

  /// Builds the child with a button to toggle between the demo and the source code.
  Widget _buildChildWithSourceCode(BuildContext context) {
    final _sourcePath = widget.showSourceCodeOptions?.path ??
        "lib${GoRouter.of(context).state?.pageKey.value}.dart";
    return FutureBuilder<String>(
      future: sourceCodeCache.containsKey(_sourcePath)
          ? Future.value(sourceCodeCache[_sourcePath])
          : rootBundle.loadString(_sourcePath),
      builder: (context, snapshot) {
        String? demoSource = "";
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            sourceCodeCache[_sourcePath] = snapshot.data!;
            RegExp exp = RegExp(
                r'/\*\s*begin demo:\s*' +
                    widget.showSourceCodeOptions!.tag +
                    r'\s*\*/(.*)\/\*\s*end demo:\s*' +
                    widget.showSourceCodeOptions!.tag +
                    r'\s*\*/',
                dotAll: true);
            demoSource = exp.firstMatch(snapshot.data!)?.group(1);
          }
        }

        return Column(
          children: [
            if (demoSource != null)
              Align(
                alignment: Alignment.centerRight,
                child: LdButtonGhost(
                  leading: Icon(isShowingSourceCode
                      ? Icons.grid_view_outlined
                      : Icons.code),
                  child: Text(
                      isShowingSourceCode ? "Show Demo" : "Show Source Code"),
                  onPressed: () => setState(
                    () => isShowingSourceCode = !isShowingSourceCode,
                  ),
                ),
              ),
            Visibility(child: widget.child, visible: !isShowingSourceCode),
            if (demoSource?.isNotEmpty == true)
              Visibility(
                child: CodeBlock(
                  code: demoSource!,
                  expanded: true,
                ),
                visible: isShowingSourceCode,
              ),
          ],
        );
      },
    );
  }
}
