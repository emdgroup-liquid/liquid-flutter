import 'package:flutter/material.dart';
import 'package:liquid/components/component_well/show_source_code_options.dart';
import 'package:liquid/source_code.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SourceCodeExtractor extends StatelessWidget {
  final String sourceCode;
  final int? index;
  final ShowSourceCodeOptions? options;

  const SourceCodeExtractor({
    super.key,
    required this.sourceCode,
    this.options,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    String extractedCode = "";
    if (options?.tag != null) {
      extractedCode = extractFromTag(sourceCode, options!.tag!) ?? "";
    }

    if (extractedCode.isEmpty) {
      extractedCode = extractFromChild(sourceCode, index: index ?? 0) ?? "";
    }

    return SourceCode(
      padding: LdTheme.of(context).pad(),
      code: extractedCode,
    );
  }
}

String? extractFromTag(String dartCode, String tag) {
  final regex =
      RegExp(r'/\*\s*begin demo:\s*' + tag + r'\s*\*/(.*)\/\*\s*end demo:\s*' + tag + r'\s*\*/', dotAll: true);
  final match = regex.firstMatch(dartCode);
  return match?.group(1);
}

/// Extracts the content of the 'child' property of a 'ComponentWell' widget
/// from a Dart code string. If multiple 'ComponentWell' widgets are present in
/// the same file, the [index] property can be used to specify which one to
/// extract.
String? extractFromChild(String dartCode, {int index = 0}) {
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
  final lastLineIndentation = extractedChild.split('\n').last.replaceAll(RegExp(r'\S.*'), '');
  return lastLineIndentation + extractedChild;
}
