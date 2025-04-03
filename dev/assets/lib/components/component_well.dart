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
  ///
  /// If no tag is provided, the source code will be extracted in an elaborated
  /// way counting the braces to ensure the entire child widget is captured.
  ///
  /// If multiple [ComponentWell] widgets are present in the same file, the
  /// [componentWellIndex] property can be used to specify which one to extract.
  ///
  /// This method is less reliable and may not work in all cases.
  final String? tag;

  /// The index of the [ComponentWell] widget in the source code file. It will
  /// only be used if the [tag] property is not provided.
  final int? componentWellIndex;

  /// The path to the source code file, e.g. "lib/components/reactive_form.dart".
  /// If no path is provided, it will be tried to be inferred from the current
  /// route.
  final String? path;

  /// Set to false to hide the source code button.
  final bool showButton;

  ShowSourceCodeOptions(
      {this.tag, this.path, this.showButton = true, this.componentWellIndex});
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
  /// Cache for the source code of the demo pages (to avoid having to reload
  /// it again for each widget instance on a page).
  static final _sourceCodeCache = <String, String>{};
  static final Map<ValueKey<String>, int> _instanceCounters = {};
  late int _instanceIndex; // Instance index for this widget
  late ValueKey<String>? _pageKey; // Page key for this widget
  bool isShowingSourceCode = false;

  /// The path to the source code file. If no path was provided via the
  /// [ShowSourceCodeOptions], it will be inferred from the current route.
  get _sourcePath =>
      widget.showSourceCodeOptions?.path ?? "lib${_pageKey!.value}.dart";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    // let's show the source code button by default
    final showSourceCode = widget.showSourceCodeOptions?.showButton ?? true;

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
              vertical: showSourceCode ? 16 : 32,
              horizontal: 16,
            ),
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: widget.onSurface),
          child: showSourceCode
              ? _buildChildWithSourceCode(context)
              : widget.child,
        ));
  }

  @override
  void initState() {
    // use the initState() lifecycle method to increment the instance counter,
    // for each instance of the ComponentWell widget on the page. This should be
    // safe as we assume that it gets called only once per instance on a page
    // and in the correct order for the widget tree.
    _pageKey = GoRouter.of(context).state.pageKey;
    if (_pageKey != null) {
      _instanceIndex = _instanceCounters.putIfAbsent(_pageKey!, () => 0);
      _instanceCounters[_pageKey!] = _instanceIndex + 1;
    }
    super.initState();
  }

  @override
  dispose() {
    // use the dispose() lifecycle method to reset the instance counter for the
    // page when any of the ComponentWell widgets are disposed.
    _sourceCodeCache.remove(_sourcePath);
    _instanceCounters.remove(_pageKey!);
    super.dispose();
  }

  /// Builds the child with a button to toggle between the demo and the source code.
  Widget _buildChildWithSourceCode(BuildContext context) {
    return FutureBuilder<String>(
      future: _sourceCodeCache.containsKey(_sourcePath)
          ? Future.value(_sourceCodeCache[_sourcePath])
          : rootBundle.loadString(_sourcePath),
      builder: (context, snapshot) {
        String? componentWellChildCode;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _sourceCodeCache[_sourcePath] = snapshot.data!;

            if (widget.showSourceCodeOptions?.tag != null) {
              // Extract the source code between the 'begin' and 'end' comments
              final RegExp exp = RegExp(
                  r'/\*\s*begin demo:\s*' +
                      widget.showSourceCodeOptions!.tag! +
                      r'\s*\*/(.*)\/\*\s*end demo:\s*' +
                      widget.showSourceCodeOptions!.tag! +
                      r'\s*\*/',
                  dotAll: true);
              componentWellChildCode = exp.firstMatch(snapshot.data!)?.group(1);
            }

            if (componentWellChildCode?.isEmpty ?? true) {
              // If no tag was provided or the tag was not found, we try to
              // extract the content of the 'child' property of the ComponentWell
              // widget in a more elaborated way.
              componentWellChildCode = extractComponentWellChildCode(
                snapshot.data!,
                index: widget.showSourceCodeOptions?.componentWellIndex ??
                    _instanceIndex,
              );
            }
          }
        }

        return Column(
          children: [
            if (componentWellChildCode?.isNotEmpty ?? false)
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
            if (componentWellChildCode?.isNotEmpty ?? false)
              Visibility(
                child: CodeBlock(
                  code: componentWellChildCode!,
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

/// Extracts the content of the 'child' property of a 'ComponentWell' widget
/// from a Dart code string. If multiple 'ComponentWell' widgets are present in
/// the same file, the [index] property can be used to specify which one to
/// extract.
String? extractComponentWellChildCode(String dartCode, {int index = 0}) {
  // Find the ComponentWell widgets in the code
  final regex = RegExp(r'ComponentWell\s*\(.*?child:\s*', dotAll: true);
  final matches = regex.allMatches(dartCode).toList();
  if (matches.isEmpty || index >= matches.length) {
    // No ComponentWell widget found or index out of bounds
    return null;
  }

  // The ComponentWell widget we are actually interested in
  final match = matches[index];

  // We count the brackets to ensure we capture the entire content of 'child'
  int openBrackets = 0;
  int closeBrackets = 0;
  int i = match.end;

  // Iterate through the string to count braces and balance them
  while (i < dartCode.length) {
    if (dartCode[i] == '(') openBrackets++;
    if (dartCode[i] == ')') closeBrackets++;

    if (openBrackets == closeBrackets && openBrackets > 0) {
      // As soon as the braces are balanced, we stop, as we have the full child widget
      break;
    }
    i++;
  }

  // Get the content of the 'child' property
  String extractedChild = dartCode.substring(match.end, i + 1);

  // Take the last line indentation to apply it to the extracted child
  final lastLineIndentation =
      extractedChild.split('\n').last.replaceAll(RegExp(r'\S.*'), '');
  return lastLineIndentation + extractedChild;
}
