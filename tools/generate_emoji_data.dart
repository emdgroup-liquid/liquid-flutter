#!/usr/bin/env dart
// ignore_for_file: avoid_print
//
// Generates packages/liquid_flutter/lib/src/emoji_picker/emoji_data.dart
// from the latest Unicode emoji-test.txt, CLDR English annotations, and
// extra search keywords in tools/emoji_extra_keywords.json.
//
// Usage (from repo root):
//   dart tools/generate_emoji_data.dart
//
// Re-run whenever a new Unicode Emoji version is released.
// Extra keywords are curated search aliases (slang, ISO codes, use-cases)
// merged on top of CLDR; edit tools/emoji_extra_keywords.json to add more.

import 'dart:convert';
import 'dart:io';

const _sourceUrl = 'https://www.unicode.org/Public/emoji/latest/emoji-test.txt';

/// CLDR English annotations — provides search keywords for each emoji.
/// The file is keyed by emoji character; each entry has a "default" list of
/// keyword strings and a "tts" list with the spoken name.
const _cldrAnnotationsUrl =
    'https://raw.githubusercontent.com/unicode-org/cldr-json/main/'
    'cldr-json/cldr-annotations-full/annotations/en/annotations.json';

const _outputPath =
    'packages/liquid_flutter/lib/src/emoji_picker/emoji_data.dart';

/// Extra search keywords generated/curated on top of CLDR annotations.
/// Keyed by emoji character. Merged with CLDR at generation time.
///
/// Re-generate extras with sub-agents, then re-run this script.
const _extraKeywordsPath = 'tools/emoji_extra_keywords.json';

// Skin-tone modifier code points (U+1F3FB..U+1F3FF).
const _skinToneModifiers = {
  '1F3FB',
  '1F3FC',
  '1F3FD',
  '1F3FE',
  '1F3FF',
};

// We skip the Component group – it only contains raw modifier code points
// (skin tone & hair) that are not useful as standalone emoji in a picker.
const _skipGroups = {'Component'};

// Representative icon emoji for each standard group.
// Used as the tab icon in the picker.
const _groupIcons = {
  'Smileys & Emotion': '😀',
  'People & Body': '👋',
  'Animals & Nature': '🐶',
  'Food & Drink': '🍎',
  'Travel & Places': '🚗',
  'Activities': '⚽',
  'Objects': '💡',
  'Symbols': '❤️',
  'Flags': '🏳️',
};

// ---------------------------------------------------------------------------

Future<String> _download(String url) async {
  print('Downloading $url …');
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    // The file is ASCII-compatible UTF-8; decode properly.
    return utf8.decode(bytes);
  } finally {
    client.close();
  }
}

// ---------------------------------------------------------------------------

class _EmojiEntry {
  final String emoji;
  final String name;
  final String subgroup;
  final List<String> skinToneVariants = [];
  List<String> keywords = [];

  bool get hasSkinTones => skinToneVariants.isNotEmpty;

  _EmojiEntry({
    required this.emoji,
    required this.name,
    required this.subgroup,
  });
}

class _Category {
  final String name;
  final String icon;
  final List<_EmojiEntry> emojis;

  _Category({required this.name, required this.icon, required this.emojis});
}

// ---------------------------------------------------------------------------

bool _isSkinToneVariant(List<String> codePoints) {
  return codePoints.any(_skinToneModifiers.contains);
}

// ---------------------------------------------------------------------------

List<_Category> _parse(String source) {
  final categories = <_Category>[];
  final skippedGroups = <String>{};

  String? currentGroup;
  String currentSubgroup = '';
  // All emojis for the current group keyed by group name.
  final Map<String, List<_EmojiEntry>> groupEmojis = {};
  // Track the last non-skin-tone emoji per group for attaching variants.
  final Map<String, _EmojiEntry?> lastBase = {};

  for (final rawLine in source.split('\n')) {
    final line = rawLine.trim();

    // ── Group header ────────────────────────────────────────────────────────
    if (line.startsWith('# group:')) {
      final groupName = line.substring('# group:'.length).trim();
      currentGroup = groupName;
      if (_skipGroups.contains(groupName)) {
        skippedGroups.add(groupName);
        continue;
      }
      if (!groupEmojis.containsKey(groupName)) {
        groupEmojis[groupName] = [];
        lastBase[groupName] = null;
      }
      continue;
    }

    // ── Subgroup header ──────────────────────────────────────────────────────
    if (line.startsWith('# subgroup:')) {
      currentSubgroup = line.substring('# subgroup:'.length).trim();
      continue;
    }

    // ── Skip skipped / unknown groups ────────────────────────────────────────
    if (currentGroup == null || skippedGroups.contains(currentGroup)) continue;

    // ── Only fully-qualified entries ─────────────────────────────────────────
    if (!line.contains('; fully-qualified')) continue;

    // ── Parse entry line ─────────────────────────────────────────────────────
    // Format: "<code points> ; fully-qualified # <emoji> E<ver> <name>"
    final semicolonIdx = line.indexOf(';');
    if (semicolonIdx < 0) continue;
    final hashIdx = line.indexOf('#', semicolonIdx);
    if (hashIdx < 0) continue;

    final codePointPart = line.substring(0, semicolonIdx).trim();
    final commentPart = line.substring(hashIdx + 1).trim();

    // commentPart: "😀 E1.0 grinning face"
    // Split on Unicode whitespace; first token = emoji, second = version, rest = name.
    final commentTokens = commentPart.split(RegExp(r'\s+'));
    if (commentTokens.length < 3) continue;

    // The emoji character is taken directly from the comment (already rendered UTF-8).
    final emojiChar = commentTokens[0];
    // commentTokens[1] is the emoji version (e.g. "E1.0") — not needed.
    final name = commentTokens.sublist(2).join(' ');

    final codePoints = codePointPart
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    final emojis = groupEmojis[currentGroup]!;

    if (_isSkinToneVariant(codePoints)) {
      // Attach to the last base emoji for this group.
      final base = lastBase[currentGroup];
      if (base != null) {
        base.skinToneVariants.add(emojiChar);
      }
      continue;
    }

    final entry = _EmojiEntry(
      emoji: emojiChar,
      name: name,
      subgroup: currentSubgroup,
    );
    emojis.add(entry);
    lastBase[currentGroup] = entry;
  }

  // Build ordered category list (preserve order of first appearance).
  final seen = <String>{};
  for (final rawLine in source.split('\n')) {
    final line = rawLine.trim();
    if (line.startsWith('# group:')) {
      final groupName = line.substring('# group:'.length).trim();
      if (_skipGroups.contains(groupName)) continue;
      if (seen.add(groupName) && groupEmojis.containsKey(groupName)) {
        final emojis = groupEmojis[groupName]!;
        if (emojis.isNotEmpty) {
          final icon = _groupIcons[groupName] ?? emojis.first.emoji;
          categories
              .add(_Category(name: groupName, icon: icon, emojis: emojis));
        }
      }
    }
  }

  return categories;
}

// ---------------------------------------------------------------------------

String _escapeString(String s) {
  // Escape backslashes and single quotes for single-quoted Dart string literals.
  return s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}

String _generateDart(List<_Category> categories) {
  final buf = StringBuffer();

  buf.writeln('// GENERATED CODE – DO NOT EDIT BY HAND.');
  buf.writeln('// Run `dart tools/generate_emoji_data.dart` to regenerate.');
  buf.writeln('// Sources:');
  buf.writeln('//   $_sourceUrl');
  buf.writeln('//   $_cldrAnnotationsUrl');
  buf.writeln('//   $_extraKeywordsPath');
  buf.writeln('//');
  buf.writeln('// ignore_for_file: lines_longer_than_80_chars');
  buf.writeln();
  buf.writeln("part of 'emoji_picker.dart';");
  buf.writeln();
  buf.writeln('const List<LdEmojiCategory> _ldEmojiData = [');

  for (final cat in categories) {
    buf.writeln('  LdEmojiCategory(');
    buf.writeln("    name: '${_escapeString(cat.name)}',");
    buf.writeln("    icon: '${_escapeString(cat.icon)}',");
    buf.writeln('    emojis: [');
    for (final entry in cat.emojis) {
      buf.write(
        "      LdEmojiEntry(emoji: '${_escapeString(entry.emoji)}', "
        "name: '${_escapeString(entry.name)}', "
        "subgroup: '${_escapeString(entry.subgroup)}'",
      );
      if (entry.skinToneVariants.isNotEmpty) {
        final variants = entry.skinToneVariants
            .map((v) => "'${_escapeString(v)}'")
            .join(', ');
        buf.write(', skinToneVariants: [$variants]');
      }
      if (entry.keywords.isNotEmpty) {
        final kws =
            entry.keywords.map((k) => "'${_escapeString(k)}'").join(', ');
        buf.write(', keywords: [$kws]');
      }
      buf.writeln('),');
    }
    buf.writeln('    ],');
    buf.writeln('  ),');
  }

  buf.writeln('];');
  return buf.toString();
}

// ---------------------------------------------------------------------------

/// Parses the CLDR English annotations JSON and returns a map from emoji
/// character to list of keyword strings.
Map<String, List<String>> _parseCldrAnnotations(String json) {
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  // Structure: { "annotations": { "identity": {...}, "annotations": { "😀": { "default": [...], "tts": [...] } } } }
  final outer = decoded['annotations'] as Map<String, dynamic>;
  final entries = outer['annotations'] as Map<String, dynamic>;

  final result = <String, List<String>>{};
  for (final MapEntry(:key, :value) in entries.entries) {
    final annotation = value as Map<String, dynamic>;
    final defaults = annotation['default'];
    if (defaults is List) {
      result[key] = defaults.cast<String>();
    }
  }
  return result;
}

/// Loads extra keywords from [path]. Missing file → empty map.
///
/// JSON format: `{ "😀": ["joyful", "delighted"], ... }`
Map<String, List<String>> _loadExtraKeywords(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    print('No extra keywords file at $path (skipping).');
    return {};
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) {
    throw FormatException('Extra keywords file must be a JSON object: $path');
  }
  final result = <String, List<String>>{};
  for (final MapEntry(:key, :value) in decoded.entries) {
    if (value is List) {
      result[key.toString()] = value.map((e) => e.toString()).toList();
    }
  }
  return result;
}

/// Case-insensitive merge that preserves first-seen spelling (CLDR first).
List<String> _mergeKeywords(List<String> primary, List<String> extra) {
  final seen = <String>{};
  final merged = <String>[];
  for (final raw in [...primary, ...extra]) {
    final keyword = raw.trim();
    if (keyword.isEmpty) continue;
    if (seen.add(keyword.toLowerCase())) {
      merged.add(keyword);
    }
  }
  return merged;
}

/// Annotates each entry with CLDR keywords plus extras from
/// [tools/emoji_extra_keywords.json].
///
/// Keywords that duplicate the emoji name words are kept — the search layer
/// uses the combined text, so more signals are always better.
void _applyKeywords(
  List<_Category> categories,
  Map<String, List<String>> annotations,
  Map<String, List<String>> extra,
) {
  for (final cat in categories) {
    for (final entry in cat.emojis) {
      final cldr = annotations[entry.emoji] ?? const <String>[];
      final extras = extra[entry.emoji] ?? const <String>[];
      entry.keywords = _mergeKeywords(cldr, extras);
    }
  }
}

Future<void> main() async {
  // Download both sources in parallel.
  print('Downloading emoji-test.txt and CLDR annotations …');
  final results = await Future.wait([
    _download(_sourceUrl),
    _download(_cldrAnnotationsUrl),
  ]);

  final emojiSource = results[0];
  final cldrJson = results[1];

  print('Parsing emoji-test.txt …');
  final categories = _parse(emojiSource);

  print('Parsing CLDR annotations …');
  final annotations = _parseCldrAnnotations(cldrJson);

  print('Loading extra keywords from $_extraKeywordsPath …');
  final extra = _loadExtraKeywords(_extraKeywordsPath);

  print('Applying keywords …');
  _applyKeywords(categories, annotations, extra);

  var totalEmojis = 0;
  var withSkinTones = 0;
  var withKeywords = 0;
  var withExtras = 0;
  for (final cat in categories) {
    print('  ${cat.name}: ${cat.emojis.length} base emojis');
    totalEmojis += cat.emojis.length;
    withSkinTones += cat.emojis.where((e) => e.hasSkinTones).length;
    withKeywords += cat.emojis.where((e) => e.keywords.isNotEmpty).length;
    withExtras += cat.emojis.where((e) => extra.containsKey(e.emoji)).length;
  }
  print(
    'Total: $totalEmojis base emojis, $withSkinTones with skin tone variants, '
    '$withKeywords with keywords, $withExtras with extra keywords '
    '(${extra.length} extra entries loaded)',
  );

  final dart = _generateDart(categories);

  final outFile = File(_outputPath);
  await outFile.writeAsString(dart);
  print('Written to $_outputPath (${dart.length} bytes)');
}
