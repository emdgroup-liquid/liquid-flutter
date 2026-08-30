part of 'emoji_picker.dart';

/// A single emoji entry parsed from the Unicode emoji-test.txt file.
///
/// Only `fully-qualified` entries from the Unicode data are included.
/// Skin-tone variant entries are not listed separately — they are attached
/// to their base emoji's [skinToneVariants] list.
class LdEmojiEntry {
  /// The emoji character(s), e.g. `"😀"` or `"👋"`.
  final String emoji;

  /// Human-readable name, e.g. `"grinning face"`.
  final String name;

  /// Unicode subgroup, e.g. `"face-smiling"`.
  final String subgroup;

  /// Whether this emoji has skin-tone variants.
  bool get hasSkinTones => skinToneVariants.isNotEmpty;

  /// Skin-tone variants in order:
  /// light, medium-light, medium, medium-dark, dark.
  ///
  /// Empty when the base emoji does not support skin tones.
  final List<String> skinToneVariants;

  /// Search keywords for this emoji, e.g. `["grin", "happy", "smile"]`.
  ///
  /// Used to improve search relevance beyond substring-matching the [name].
  /// Populated from Unicode CLDR English annotations, merged with extras from
  /// `tools/emoji_extra_keywords.json` at generation time.
  /// Empty when no keyword data is available for this emoji.
  final List<String> keywords;

  const LdEmojiEntry({
    required this.emoji,
    required this.name,
    required this.subgroup,
    this.skinToneVariants = const [],
    this.keywords = const [],
  });
}

/// A group of [LdEmojiEntry] items belonging to the same Unicode category.
///
/// Categories match the `# group:` sections in the Unicode emoji-test.txt file,
/// minus the `Component` group (which contains raw modifier code points).
class LdEmojiCategory {
  /// Unicode group name, e.g. `"Smileys & Emotion"`.
  final String name;

  /// A representative emoji used as the tab icon.
  final String icon;

  /// All base emoji entries for this category (no skin-tone variants).
  final List<LdEmojiEntry> emojis;

  const LdEmojiCategory({
    required this.name,
    required this.icon,
    required this.emojis,
  });
}
