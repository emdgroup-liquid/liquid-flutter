const _identifiableImport = "import 'package:liquid_flutter/liquid_flutter.dart';";
const _generatedMessage = 'extends \$pb.GeneratedMessage ';
const _generatedMessageWithBrace = 'extends \$pb.GeneratedMessage {';

String transformIdentifiableProto(
  String content,
  Map<String, String> fieldOverrides,
) {
  final lines = content.split('\n');
  final replacements = <int, String>{};
  final forwardingGetters = <int, String>{};
  var needsImport = false;

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    final isClassLine = trimmed.startsWith('class ') &&
        trimmed.contains(_generatedMessage) &&
        trimmed.contains(' {');
    final hasIdentifiable = trimmed.contains('Identifiable<');

    if (isClassLine && !hasIdentifiable) {
      final className = _extractClassName(trimmed);
      final idField = _findIdField(
        lines,
        i + 1,
        className,
        fieldOverrides,
      );

      if (idField != null) {
        needsImport = true;
        final fieldName = idField.$1;
        final type = idField.$2;
        final newLine = line.replaceFirst(
          _generatedMessageWithBrace,
          'extends \$pb.GeneratedMessage with Identifiable<\$core.$type> {',
        );
        if (newLine != line) {
          replacements[i] = newLine;
        }

        if (fieldName != 'id') {
          final insertionLine = _findDefaultInstanceLine(lines, i + 1);
          if (insertionLine != null) {
            forwardingGetters[insertionLine] =
                '  \$core.$type get id => $fieldName;';
          }
        }
      }
    }
    i++;
  }

  if (replacements.isEmpty && forwardingGetters.isEmpty) {
    return content;
  }

  final outLines = List<String>.from(lines);
  for (final e in replacements.entries) {
    outLines[e.key] = e.value;
  }

  final insertions = forwardingGetters.entries.toList()
    ..sort((a, b) => b.key.compareTo(a.key));
  for (final e in insertions) {
    outLines.insert(e.key + 1, e.value);
  }

  final hasLiquidImport =
      content.contains('package:liquid_flutter/liquid_flutter.dart');
  if (needsImport && !hasLiquidImport) {
    var lastImportIdx = -1;
    for (var k = 0; k < outLines.length; k++) {
      if (outLines[k].trimLeft().startsWith("import '")) {
        lastImportIdx = k;
      }
    }
    if (lastImportIdx >= 0) {
      outLines.insert(lastImportIdx + 1, _identifiableImport);
    }
  }

  return outLines.join('\n');
}

String? _extractClassName(String trimmed) {
  final match = RegExp(r'^class\s+(\w+)\s+extends').firstMatch(trimmed);
  return match?.group(1);
}

(String, String)? _findIdField(
  List<String> lines,
  int startIndex,
  String? className,
  Map<String, String> fieldOverrides,
) {
  final fieldName = (className != null && fieldOverrides.containsKey(className))
      ? fieldOverrides[className]!
      : 'id';

  var j = startIndex;
  while (j < lines.length) {
    final nextLine = lines[j];
    if (nextLine.trimLeft().startsWith('class ') &&
        nextLine.contains('extends')) {
      break;
    }

    if (nextLine.contains('get $fieldName =>')) {
      final type = nextLine.contains(r'$core.int') ? 'int' : 'String';
      return (fieldName, type);
    }
    j++;
  }
  return null;
}

int? _findDefaultInstanceLine(List<String> lines, int startIndex) {
  var j = startIndex;
  while (j < lines.length) {
    final nextLine = lines[j];
    if (nextLine.trimLeft().startsWith('class ') &&
        nextLine.contains('extends')) {
      break;
    }
    if (nextLine.trimLeft().startsWith('static') &&
        nextLine.contains('? _defaultInstance;')) {
      return j;
    }
    j++;
  }
  return null;
}