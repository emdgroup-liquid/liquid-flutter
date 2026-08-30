import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

String _searchText(LdEmojiEntry entry) => '${entry.name} ${entry.keywords.join(' ')}'.toLowerCase();

LdEmojiEntry _entry(String emoji) {
  return ldEmojiData.expand((category) => category.emojis).firstWhere((entry) => entry.emoji == emoji);
}

void main() {
  test('every emoji has search keywords', () {
    var count = 0;
    for (final category in ldEmojiData) {
      for (final entry in category.emojis) {
        count += 1;
        expect(
          entry.keywords,
          isNotEmpty,
          reason: '${entry.emoji} ${entry.name}',
        );
      }
    }
    expect(count, greaterThan(1000));
  });

  test('common aliases match by keyword', () {
    expect(_searchText(_entry('🇩🇪')), contains('deutschland'));
    expect(_searchText(_entry('🇺🇸')), contains('usa'));
    expect(_searchText(_entry('🇬🇧')), contains('uk'));
    expect(_searchText(_entry('🏳️‍🌈')), contains('pride'));
    expect(_searchText(_entry('🔥')), contains('lit'));
    expect(_searchText(_entry('🍕')), contains('italian'));
    expect(_searchText(_entry('🤔')), contains('hmm'));
  });
}
