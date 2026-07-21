const _identifiableImport = "import 'package:liquid_flutter/liquid_flutter.dart';";
const _jsonSerializableAnnotation = '@JsonSerializable(';

/// Transforms swagger-generated `.swagger.dart` files to add the
/// [Identifiable] mixin to model classes that have an `id` field (or an
/// override field mapped to `id`).
///
/// The swagger code-generator produces plain Dart classes annotated with
/// `@JsonSerializable(explicitToJson: true)`.  Each class that has a `final
/// int id` or `final String id` field (as indicated by a preceding
/// `@JsonKey(name: 'id')` annotation) can satisfy the [Identifiable] mixin
/// contract because Dart final fields implicitly provide a getter.
///
/// For classes whose identity field has a different name (e.g. `uuid`), a
/// forwarding getter `int get id => uuid;` is inserted right after the
/// opening brace of the class body.
String transformIdentifiableSwagger(
  String content,
  Map<String, String> fieldOverrides,
) {
  final lines = content.split('\n');

  // Map from line-index → replacement line.
  final replacements = <int, String>{};
  // Map from line-index → line to insert AFTER that index.
  final insertions = <int, String>{};
  var needsImport = false;

  // Whether the next class declaration should be treated as a swagger model.
  var nextClassIsSwaggerModel = false;

  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();

    // Track the @JsonSerializable annotation so we know the next class
    // declaration is a swagger model.
    if (trimmed.startsWith(_jsonSerializableAnnotation)) {
      nextClassIsSwaggerModel = true;
      continue;
    }

    // Detect a class declaration line.
    final isClassDecl = trimmed.startsWith('class ') && trimmed.endsWith('{');
    if (!isClassDecl) {
      // Any non-empty line that is not the annotation resets the flag.
      if (trimmed.isNotEmpty) {
        nextClassIsSwaggerModel = false;
      }
      continue;
    }

    // From here: isClassDecl == true.
    final wasSwaggerModel = nextClassIsSwaggerModel;
    nextClassIsSwaggerModel = false;

    if (!wasSwaggerModel) continue;

    // Skip classes already patched.
    if (trimmed.contains('Identifiable<')) continue;

    final className = _extractClassName(trimmed);
    if (className == null) continue;

    final idField = _findIdField(lines, i + 1, className, fieldOverrides);
    if (idField == null) continue;

    final fieldName = idField.$1;
    final dartType = idField.$2; // 'int' or 'String'

    needsImport = true;

    // Rewrite: `class Foo {` → `class Foo with Identifiable<TYPE> {`
    final newLine = lines[i].replaceFirst(
      RegExp(r'\s*\{$'),
      ' with Identifiable<$dartType> {',
    );
    replacements[i] = newLine;

    // For field overrides, insert a forwarding getter after the `{`.
    if (fieldName != 'id') {
      insertions[i] = '  $dartType get id => $fieldName;';
    }
  }

  if (replacements.isEmpty && insertions.isEmpty) {
    return content;
  }

  final outLines = List<String>.from(lines);

  // Apply class-declaration replacements.
  for (final e in replacements.entries) {
    outLines[e.key] = e.value;
  }

  // Insert forwarding getters (process in descending order to keep indices
  // stable).
  final sortedInsertions = insertions.entries.toList()
    ..sort((a, b) => b.key.compareTo(a.key));
  for (final e in sortedInsertions) {
    outLines.insert(e.key + 1, e.value);
  }

  // Inject the liquid_flutter import once, after the last existing import.
  final hasLiquidImport =
      content.contains('package:liquid_flutter/liquid_flutter.dart');
  if (needsImport && !hasLiquidImport) {
    var lastImportIdx = -1;
    for (var k = 0; k < outLines.length; k++) {
      if (outLines[k].trimLeft().startsWith("import '") ||
          outLines[k].trimLeft().startsWith('import "')) {
        lastImportIdx = k;
      }
    }
    if (lastImportIdx >= 0) {
      outLines.insert(lastImportIdx + 1, _identifiableImport);
    }
  }

  return outLines.join('\n');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String? _extractClassName(String trimmed) {
  final match = RegExp(r'^class\s+(\w+)').firstMatch(trimmed);
  return match?.group(1);
}

/// Scans forward from [startIndex] inside the class body to find the identity
/// field.  The identity field is identified by:
///   1. A `@JsonKey(name: '<fieldName>')` annotation on one line, immediately
///      followed by `final TYPE <fieldName>;` on the next line.
///   2. [fieldOverrides] can map a class name to a non-`id` field name.
///
/// Returns `(fieldName, dartType)` or `null` if not found.
(String, String)? _findIdField(
  List<String> lines,
  int startIndex,
  String? className,
  Map<String, String> fieldOverrides,
) {
  final targetField =
      (className != null && fieldOverrides.containsKey(className))
          ? fieldOverrides[className]!
          : 'id';

  var j = startIndex;
  while (j < lines.length) {
    final line = lines[j].trim();

    // Stop at the next top-level class declaration.
    if (line.startsWith('class ') && line.endsWith('{')) break;

    // Look for `@JsonKey(name: '<targetField>')` …
    if (line == "@JsonKey(name: '$targetField')") {
      // … followed by `final TYPE <targetField>;`
      if (j + 1 < lines.length) {
        final next = lines[j + 1].trim();
        final fieldMatch =
            RegExp(r'^final\s+(\w+)\s+' + RegExp.escape(targetField) + r';$')
                .firstMatch(next);
        if (fieldMatch != null) {
          final rawType = fieldMatch.group(1)!;
          // Normalise to int / String (the two types Identifiable supports).
          final dartType = rawType == 'int' ? 'int' : 'String';
          return (targetField, dartType);
        }
      }
    }
    j++;
  }
  return null;
}
