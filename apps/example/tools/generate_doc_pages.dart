#!/usr/bin/env dart
// ignore_for_file: avoid_print
//
// Generates component documentation pages for the example app from per-package
// api.json snapshots produced by `melos run generate_api`.
//
// Usage (from repo root):
//   melos run generate_docs        ← recommended (runs generate_api first)
//   dart run apps/example/tools/generate_doc_pages.dart
//
// Each package's snapshot lives under apps/example/.api_guard/:
//   liquid_flutter.json
//   liquid_flutter_md.json
//   liquid_flutter_reactive_forms.json
//
// For every _ComponentConfig below whose description contains
// <!-- demo:TAG --> markers the script emits a
// lib/components/generated/<name>.doc.g.dart file with a fully-formed
// ComponentPage widget.
//
// The TAG must match a key in lib/components/demo_registry.dart.
// The script validates all tags and exits non-zero if any are missing.

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const _apiGuardDir = 'apps/example/.api_guard';
const _demoRegistryPath = 'apps/example/lib/components/demo_registry.dart';
const _outputDir = 'apps/example/lib/components/generated';

/// Filenames of per-package api snapshots inside [_apiGuardDir].
const _packageFiles = <String>[
  'liquid_flutter.json',
  'liquid_flutter_md.json',
  'liquid_flutter_reactive_forms.json',
];

/// Components to generate pages for.
/// Key   = public component name (used as page title and for apiComponents).
/// Value = configuration for the generator.
const _components = <String, _ComponentConfig>{
  // ── liquid_flutter ─────────────────────────────────────────────────────
  'LdHint': _ComponentConfig(
    title: 'LdHint',
    category: 'Feedback',
    // Private backing class that carries the rich description.
    descriptionSource: '_LdHintWidget',
    // All names from api.json that belong to this component's API accordion.
    apiComponents: ['LdHint', 'LdHintType'],
    outputFile: 'hint_doc_page.doc.g.dart',
    className: 'LdHintDocPage',
    path: 'lib/src/hint.dart',
  ),
  'LdButton': _ComponentConfig(
    title: 'LdButton',
    category: 'Interaction',
    descriptionSource: '_LdButtonWidget',
    apiComponents: [
      'LdButton',
      'LdButtonGhost',
      'LdButtonMode',
      'LdButtonConfig',
      'LdButtonConfigProvider',
    ],
    outputFile: 'button_doc_page.doc.g.dart',
    className: 'LdButtonDocPage',
    path: 'lib/src/button.dart',
  ),

  // ── liquid_flutter_md ──────────────────────────────────────────────────
  'LdMarkdown': _ComponentConfig(
    title: 'LdMarkdown',
    category: 'Data Display',
    // Description comes from the class's own dartdoc in liquid_flutter_md.
    descriptionSource: 'LdMarkdown',
    apiComponents: ['LdMarkdown', 'LdMarkdownEditor', 'LdMarkdownEditingController'],
    outputFile: 'markdown_doc_page.doc.g.dart',
    className: 'LdMarkdownDocPage',
    path: 'lib/markdown_widget.dart',
  ),

  // ── liquid_flutter_reactive_forms ──────────────────────────────────────
  // Add entries here when demo widgets exist for reactive-forms components.
  // Example (uncomment and add demos to demo_registry.dart when ready):
  //
  // 'LdFormInput': _ComponentConfig(
  //   title: 'LdFormInput',
  //   category: 'Form',
  //   descriptionSource: 'LdFormInput',
  //   apiComponents: ['LdFormInput'],
  //   outputFile: 'form_input_doc_page.doc.g.dart',
  //   className: 'LdFormInputDocPage',
  //   path: 'lib/src/form_widgets/ld_form_input.dart',
  // ),
};

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ComponentConfig {
  final String title;
  final String category;

  /// Name of the class in the api snapshot to use as the description source.
  /// Must match the `name` field in one of the per-package JSON files.
  final String? descriptionSource;

  final List<String> apiComponents;
  final String outputFile;
  final String className;

  /// Source file path passed to [ComponentPage.path], relative to the
  /// owning package's root (e.g. `lib/src/hint.dart`).
  final String path;

  const _ComponentConfig({
    required this.title,
    required this.category,
    this.descriptionSource,
    required this.apiComponents,
    required this.outputFile,
    required this.className,
    required this.path,
  });
}

// ---------------------------------------------------------------------------
// Segment model — a description split on <!-- demo:TAG --> markers
// ---------------------------------------------------------------------------

sealed class _Segment {}

class _MarkdownSegment extends _Segment {
  final String text;
  _MarkdownSegment(this.text);
}

class _DemoSegment extends _Segment {
  final String tag;
  _DemoSegment(this.tag);
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

/// Splits [description] on `<!-- demo:TAG -->` markers.
List<_Segment> _parseSegments(String description) {
  final segments = <_Segment>[];
  final regex = RegExp(r'<!--\s*demo:(\w+)\s*-->');
  int cursor = 0;

  for (final match in regex.allMatches(description)) {
    final prose = description.substring(cursor, match.start).trim();
    if (prose.isNotEmpty) segments.add(_MarkdownSegment(prose));
    segments.add(_DemoSegment(match.group(1)!));
    cursor = match.end;
  }

  final trailing = description.substring(cursor).trim();
  if (trailing.isNotEmpty) segments.add(_MarkdownSegment(trailing));

  return segments;
}

/// Cleans a raw description string extracted from an api.json file.
///
/// api.json descriptions come from `element.documentationComment` which strips
/// the `///` prefix but leaves a leading space on every line. This function:
///   1. Removes the leading space added by the `///` stripper.
///   2. Converts dartdoc cross-references `[ClassName]` → `` `ClassName` ``.
///   3. Reflows prose paragraphs: collapses single newlines into spaces so that
///      dart comment line-wrapping at ~80 chars doesn't produce hard line breaks
///      in the rendered markdown. Double newlines (paragraph/heading/block
///      boundaries) and lines inside fenced code blocks are left untouched.
String _cleanDescription(String raw) {
  // Step 1: strip the leading space from every line.
  final lines = raw.split('\n').map((line) {
    if (line.startsWith(' ')) return line.substring(1);
    return line;
  }).toList();

  // Step 2: reflow — collapse single \n within prose paragraphs into spaces.
  final reflowed = _reflowParagraphs(lines);

  // Step 3: dartdoc cross-refs → backtick code.
  return reflowed.replaceAllMapped(
    RegExp(r'\[([A-Za-z_][A-Za-z0-9_.]*)\](?!\()'),
    (m) => '`${m.group(1)}`',
  );
}

/// Collapses single newlines within prose paragraphs into spaces.
///
/// Lines that are "structural" (blank, heading, fence delimiter, list item,
/// blockquote, HTML comment, indented code) force a real newline boundary
/// and are never joined with adjacent lines.
String _reflowParagraphs(List<String> lines) {
  final buf = StringBuffer();
  bool inFence = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Track fenced code blocks (``` or ~~~).
    if (RegExp(r'^(`{3,}|~{3,})').hasMatch(line)) {
      inFence = !inFence;
      buf.writeln(line);
      continue;
    }

    // Inside a fence: never reflow.
    if (inFence) {
      buf.writeln(line);
      continue;
    }

    // Structural lines that must stay as-is and break paragraph flow.
    final isStructural = line.isEmpty ||
        line.startsWith('#') ||         // heading
        line.startsWith('>') ||         // blockquote
        line.startsWith('- ') ||        // unordered list
        line.startsWith('* ') ||        // unordered list
        RegExp(r'^\d+\. ').hasMatch(line) || // ordered list
        line.startsWith('    ') ||      // indented code
        line.startsWith('<!--') ||      // HTML comment (demo markers etc.)
        line.startsWith('|');           // table row

    if (isStructural) {
      buf.writeln(line);
      continue;
    }

    // Prose line: look ahead to decide whether to join with next line.
    final isLastLine = i == lines.length - 1;
    if (!isLastLine) {
      final next = lines[i + 1];
      final nextIsStructural = next.isEmpty ||
          next.startsWith('#') ||
          next.startsWith('>') ||
          next.startsWith('- ') ||
          next.startsWith('* ') ||
          RegExp(r'^\d+\. ').hasMatch(next) ||
          next.startsWith('    ') ||
          next.startsWith('<!--') ||
          next.startsWith('|') ||
          RegExp(r'^(`{3,}|~{3,})').hasMatch(next);

      if (!nextIsStructural) {
        // Join this line with the next: emit without a trailing newline,
        // adding a space separator (unless this line already ends with one).
        final trimmed = line.trimRight();
        buf.write(trimmed.isEmpty ? '' : '$trimmed ');
        continue;
      }
    }

    buf.writeln(line);
  }

  return buf.toString().trim();
}

/// Finds the description for [sourceName] across all loaded component lists.
/// Returns the first non-empty match.
String _findDescription(
  List<List<dynamic>> allComponents,
  String sourceName,
) {
  for (final components in allComponents) {
    for (final c in components) {
      if (c['name'] == sourceName) {
        final desc = (c['description'] as String? ?? '').trim();
        if (desc.isNotEmpty) return _cleanDescription(desc);
      }
    }
  }
  return '';
}

// ---------------------------------------------------------------------------
// Code generation
// ---------------------------------------------------------------------------

String _escapeRawString(String s) {
  if (!s.contains("'''")) {
    return "r'''\n$s\n'''";
  }
  // Fallback: escape backslashes and single quotes.
  final escaped = s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  return "'''\n$escaped\n'''";
}

String _generateFile(_ComponentConfig config, List<_Segment> segments) {
  final buf = StringBuffer();

  buf.writeln('// GENERATED FILE — do not edit manually.');
  buf.writeln('// Regenerate with: melos run generate_docs');
  buf.writeln('//');
  buf.writeln('// Source: ${config.descriptionSource ?? 'inline'} dartdoc comments.');
  buf.writeln();
  buf.writeln("import 'package:flutter/material.dart';");
  buf.writeln("import 'package:liquid/components/component_page.dart';");
  buf.writeln("import 'package:liquid/components/demo_registry.dart';");
  buf.writeln("import 'package:liquid_flutter_md/liquid_flutter_md.dart';");
  buf.writeln();
  buf.writeln('class ${config.className} extends StatelessWidget {');
  buf.writeln('  const ${config.className}({super.key});');
  buf.writeln();

  if (config.apiComponents.isNotEmpty) {
    final list = config.apiComponents.map((e) => "'$e'").join(', ');
    buf.writeln('  static const List<String> _apiComponents = [$list];');
    buf.writeln();
  }

  buf.writeln('  @override');
  buf.writeln('  Widget build(BuildContext context) {');
  buf.writeln('    return ComponentPage(');
  buf.writeln("      path: '${config.path}',");
  buf.writeln("      title: '${config.title}',");
  buf.writeln("      category: '${config.category}',");
  if (config.apiComponents.isNotEmpty) {
    buf.writeln('      apiComponents: _apiComponents,');
  }

  if (segments.isEmpty) {
    buf.writeln('      demo: const SizedBox.shrink(),');
  } else {
    buf.writeln('      demo: Column(');
    buf.writeln('        crossAxisAlignment: CrossAxisAlignment.start,');
    buf.writeln('        children: [');

    for (final seg in segments) {
      switch (seg) {
        case _MarkdownSegment(:final text):
          buf.writeln('          LdMarkdown(');
          buf.writeln('            data: ${_escapeRawString(text)},');
          buf.writeln('          ),');
        case _DemoSegment(:final tag):
          buf.writeln("          demoRegistry['$tag']!(),");
      }
    }

    buf.writeln('        ],');
    buf.writeln('      ),');
  }

  buf.writeln('    );');
  buf.writeln('  }');
  buf.writeln('}');

  return buf.toString();
}

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

/// Extracts registered TAG keys from demo_registry.dart by scanning for
/// quoted string keys in the map literal. Simple text scan — no AST needed.
Set<String> _loadRegistryTags(String registryPath) {
  final src = File(registryPath).readAsStringSync();
  final regex = RegExp(r"'(\w+)':\s*\w");
  return regex.allMatches(src).map((m) => m.group(1)!).toSet();
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  // Resolve paths relative to repo root (script is always run from repo root
  // via melos).
  final repoRoot = Directory.current.path;
  final apiGuardDir = '$repoRoot/$_apiGuardDir';

  // Load all per-package api snapshots.
  final allComponents = <List<dynamic>>[];
  for (final filename in _packageFiles) {
    final file = File('$apiGuardDir/$filename');
    if (!file.existsSync()) {
      stderr.writeln('ERROR: $file not found. Run: melos run generate_api');
      exit(1);
    }
    final raw = jsonDecode(file.readAsStringSync());
    final components = (raw is Map ? raw['components'] : raw) as List<dynamic>;
    String packageName = filename;
    if (raw is Map) {
      final meta = raw['metadata'];
      if (meta is Map && meta['packageName'] is String) {
        packageName = meta['packageName'] as String;
      }
    }
    print('Loaded $packageName: ${components.length} components');
    allComponents.add(components);
  }

  final registryFile = File('$repoRoot/$_demoRegistryPath');
  if (!registryFile.existsSync()) {
    stderr.writeln('ERROR: $registryFile not found.');
    exit(1);
  }

  final registryTags = _loadRegistryTags(registryFile.path);
  print('Registry tags found: ${registryTags.toList()..sort()}');

  final outputDirectory = Directory('$repoRoot/$_outputDir');
  outputDirectory.createSync(recursive: true);

  final errors = <String>[];
  int generated = 0;

  for (final entry in _components.entries) {
    final config = entry.value;

    // Resolve description from the api snapshots.
    final description = _findDescription(allComponents, config.descriptionSource!);
    if (description.isEmpty) {
      stderr.writeln(
        'WARNING: No description found for ${config.descriptionSource} in any api snapshot. '
        'Skipping ${config.title}.',
      );
      continue;
    }

    final segments = _parseSegments(description);

    // Validate tags.
    for (final seg in segments) {
      if (seg is _DemoSegment && !registryTags.contains(seg.tag)) {
        errors.add(
          '${config.title}: demo tag "${seg.tag}" not found in demo_registry.dart',
        );
      }
    }

    final code = _generateFile(config, segments);
    final outFile = File('${outputDirectory.path}/${config.outputFile}');
    outFile.writeAsStringSync(code);
    print('Generated: ${outFile.path}');
    generated++;
  }

  if (errors.isNotEmpty) {
    stderr.writeln('\nERRORS:');
    for (final e in errors) {
      stderr.writeln('  - $e');
    }
    exit(1);
  }

  print('\nDone. $generated file(s) generated.');
}
