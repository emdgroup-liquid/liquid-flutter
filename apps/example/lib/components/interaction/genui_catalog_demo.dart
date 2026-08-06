import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

/// Live gallery of GenUI composite catalog items, rendered through
/// [LdGenuiSurfaceManager] with the same JSON agents emit.
class GenuiCatalogDemo extends StatefulWidget {
  const GenuiCatalogDemo({super.key});

  @override
  State<GenuiCatalogDemo> createState() => _GenuiCatalogDemoState();
}

class _GenuiCatalogDemoState extends State<GenuiCatalogDemo> {
  late final LdGenuiSurfaceManager _manager;
  StreamSubscription<Object>? _submitSub;
  String? _lastAction;

  static const _samples = <_GenuiSample>[
    _GenuiSample(
      title: 'LdMultipleChoice · radio',
      description: 'Radio layout with always-visible custom input and submit.',
      surfaceId: 'multiple-choice-radio',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"multiple-choice-radio"}}
{"version":"v0.9","updateDataModel":{"surfaceId":"multiple-choice-radio","path":"/","value":{"selected":"pasta"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"multiple-choice-radio","components":[{"id":"root","component":"LdMultipleChoice","label":"What should we cook?","description":"Pick one, or type your own.","selected":{"path":"/selected"},"layout":"radio","allowCustom":true,"customLabel":"Something else","customHint":"Enter your own…","submitLabel":"Cook this","options":[{"value":"pasta","label":"Pasta"},{"value":"salad","label":"Salad"},{"value":"soup","label":"Soup"}]}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdMultipleChoice · chips',
      description: 'Chip layout for compact single-select.',
      surfaceId: 'multiple-choice-chips',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"multiple-choice-chips"}}
{"version":"v0.9","updateDataModel":{"surfaceId":"multiple-choice-chips","path":"/","value":{"selected":"medium"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"multiple-choice-chips","components":[{"id":"root","component":"LdMultipleChoice","label":"Priority","description":"How urgent is this?","selected":{"path":"/selected"},"layout":"chips","allowCustom":true,"customHint":"Or type a custom priority…","submitLabel":"Set priority","options":[{"value":"low","label":"Low"},{"value":"medium","label":"Medium"},{"value":"high","label":"High"},{"value":"urgent","label":"Urgent"}]}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdMultipleChoice · list',
      description: 'List layout with radio selection and option descriptions.',
      surfaceId: 'multiple-choice-list',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"multiple-choice-list"}}
{"version":"v0.9","updateDataModel":{"surfaceId":"multiple-choice-list","path":"/","value":{"selected":"train"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"multiple-choice-list","components":[{"id":"root","component":"LdMultipleChoice","label":"How will you travel?","description":"Choose a transport mode.","selected":{"path":"/selected"},"layout":"list","allowCustom":true,"customLabel":"Something else","customHint":"Describe another way…","submitLabel":"Continue","options":[{"value":"train","label":"Train","description":"Direct ICEs from Berlin Hbf, ~4 hours door to door."},{"value":"flight","label":"Flight","description":"Fastest, but allow 2+ hours for airport transfers."},{"value":"car","label":"Car","description":"Flexible timing; parking near the venue is limited."},{"value":"bike","label":"Bike","description":"Scenic route along the canal if the weather holds."}]}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdConfirm',
      description: 'Approve / deny prompt with tone.',
      surfaceId: 'confirm',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"confirm"}}
{"version":"v0.9","updateComponents":{"surfaceId":"confirm","components":[{"id":"root","component":"LdConfirm","title":"Delete draft?","message":"This cannot be undone.","tone":"danger","primary":{"label":"Delete","action":{"name":"deleteDraft"}},"secondary":{"label":"Keep","action":{"name":"keepDraft"}}}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdCallout',
      description: 'Status banner without assembling LdHint.',
      surfaceId: 'callout',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"callout"}}
{"version":"v0.9","updateComponents":{"surfaceId":"callout","components":[{"id":"root","component":"LdCallout","type":"warning","title":"Quota nearly full","body":"You have used 92% of your monthly token budget."}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdCardGallery',
      description: 'Horizontal option cards with tags and markdown details.',
      surfaceId: 'card-gallery',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"card-gallery"}}
{"version":"v0.9","updateDataModel":{"surfaceId":"card-gallery","path":"/","value":{"selected":"r1"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"card-gallery","components":[{"id":"root","component":"LdCardGallery","title":"Tonight's recipes","selected":{"path":"/selected"},"cards":[{"id":"r1","title":"Tomato pasta","subtitle":"25 min","tags":["vegetarian","quick"],"markdown":"**Ingredients**: pasta, tomatoes, basil.","action":{"name":"pickRecipe","context":{"id":"r1"}}},{"id":"r2","title":"Miso soup","subtitle":"15 min","tags":["vegan","soup"],"markdown":"Simple dashi + tofu + greens.","action":{"name":"pickRecipe","context":{"id":"r2"}}},{"id":"r3","title":"Grain bowl","subtitle":"20 min","tags":["healthy","gluten-free"],"markdown":"Quinoa, roasted veg, tahini.","action":{"name":"pickRecipe","context":{"id":"r3"}}}]}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdWeatherCard',
      description: 'Opinionated weather snapshot.',
      surfaceId: 'weather',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"weather"}}
{"version":"v0.9","updateComponents":{"surfaceId":"weather","components":[{"id":"root","component":"LdWeatherCard","location":"Berlin","temperature":18,"unit":"c","condition":"partlyCloudy","summary":"Pleasant afternoon, light breeze.","high":21,"low":12,"humidity":55,"wind":"14 km/h W"}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdCalendarEvent',
      description: 'Single event summary card.',
      surfaceId: 'calendar-event',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"calendar-event"}}
{"version":"v0.9","updateComponents":{"surfaceId":"calendar-event","components":[{"id":"root","component":"LdCalendarEvent","title":"Design critique","start":"2026-08-05T14:00:00","end":"2026-08-05T15:00:00","location":"Studio B","description":"Bring latest **GenUI** gallery mocks.","action":{"name":"openEvent"}}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdTimeline',
      description: 'Vertical chronological sequence.',
      surfaceId: 'timeline',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"timeline"}}
{"version":"v0.9","updateComponents":{"surfaceId":"timeline","components":[{"id":"root","component":"LdTimeline","title":"Release checklist","items":[{"time":"09:00","title":"Freeze main","body":"Tag rc.1","tone":"info"},{"time":"11:30","title":"Run golden suite","body":"All packages","tone":"warning"},{"time":"16:00","title":"Publish","body":"liquid_flutter 23.1","tone":"success"}]}]}}
```
''',
    ),
    _GenuiSample(
      title: 'LdDetailList',
      description: 'List items open a markdown detail dialog with actions.',
      surfaceId: 'detail-list',
      genui: '''
```genui
{"version":"v0.9","createSurface":{"surfaceId":"detail-list"}}
{"version":"v0.9","updateComponents":{"surfaceId":"detail-list","components":[{"id":"root","component":"LdDetailList","title":"Open PRs","items":[{"id":"pr1","title":"feat(GenUI): composites","subtitle":"Ready for review","markdown":"## Summary\\nAdds catalog composites and demos.\\n\\n## Test plan\\n- Open GenUI gallery","actions":[{"label":"Approve","mode":"filled","action":{"name":"approvePr","context":{"id":"pr1"}}},{"label":"Comment","mode":"outline","action":{"name":"commentPr","context":{"id":"pr1"}}}]},{"id":"pr2","title":"fix(LdSlider): value inputs","subtitle":"In progress","markdown":"Slider value input polish.","actions":[{"label":"Open","mode":"outline","action":{"name":"openPr","context":{"id":"pr2"}}}]}]}]}}
```
''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _manager = LdGenuiSurfaceManager();
    _submitSub = _manager.controller.onSubmit.listen((message) {
      setState(() => _lastAction = message.toString());
    });
    for (final sample in _samples) {
      _manager.processMessageText(sample.genui);
    }
  }

  @override
  void dispose() {
    _submitSub?.cancel();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/components/interaction/genui_catalog_demo.dart',
      title: 'GenUI Catalog',
      category: 'Interaction',
      text:
          'Precomposed GenUI catalog items rendered through '
          'LdGenuiSurfaceManager using the same genui JSON agents emit.',
      demo: LdAutoSpace(
        children: [
          if (_lastAction != null)
            LdHint(type: LdHintType.info, withBackground: true, child: LdText.p('Last action: $_lastAction')),
          for (final sample in _samples)
            LdAutoSpace(
              children: [
                LdText.hs(sample.title),
                LdText.p(sample.description),
                LdCard(
                  child: LdGenuiSurfaceWidget(surfaceManager: _manager, surfaceId: sample.surfaceId),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GenuiSample {
  final String title;
  final String description;
  final String surfaceId;
  final String genui;

  const _GenuiSample({required this.title, required this.description, required this.surfaceId, required this.genui});
}
