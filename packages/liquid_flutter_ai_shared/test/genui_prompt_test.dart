import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:test/test.dart';

void main() {
  test('buildLdGenuiSystemPrompt includes catalog components', () {
    final prompt = buildLdGenuiSystemPrompt();
    expect(prompt, contains(kLdGenuiCatalogPromptMarker));
    expect(prompt, contains('LdMultipleChoice'));
    expect(prompt, contains('LdConfirm'));
    expect(prompt, contains('LdCallout'));
    expect(prompt, contains('LdCardGallery'));
    expect(prompt, contains('LdWeatherCard'));
    expect(prompt, contains('LdCalendarEvent'));
    expect(prompt, contains('LdTimeline'));
    expect(prompt, contains('LdDetailList'));
    expect(prompt, contains('allowCustom'));
    expect(prompt, contains(kLdGenuiCatalogId));
    expect(prompt, contains('```genui'));
    expect(prompt, isNot(contains('LdColumn')));
    expect(prompt, isNot(contains('LdText')));
    expect(prompt, isNot(contains('LdSlider')));
    expect(prompt, isNot(contains('LdBatchMultipleChoice')));
  });

  test('buildLdGenuiSystemPrompt surfaces string enum values', () {
    final prompt = buildLdGenuiSystemPrompt();
    expect(
      prompt,
      contains('layout (enum radio|chips|list)'),
    );
    expect(
      prompt,
      contains('type* (enum info|warning|success|error)'),
    );
    expect(
      prompt,
      contains('"type":"info"'),
    );
    expect(prompt, contains(kLdGenuiCatalogPromptEndMarker));
  });
}
