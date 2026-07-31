import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _ldCatalogId = 'com.liquid.catalog';

Catalog buildLdCatalog() {
  return Catalog(
    [
      ldText,
      ldButton,
      ldCard,
      ldColumn,
      ldRow,
      ldHorizontalScroll,
      ldTextField,
      ldCheckbox,
      ldSlider,
      ldDivider,
      ldList,
      ldMultipleChoice,
      ldTabs,
      ldIcon,
      ldImage,
      ldBatchMultipleChoice,
    ],
    catalogId: _ldCatalogId,
    systemPromptFragments: const [
      'Use the Liquid Flutter GenUI catalog to render UI in response to user queries.',
      'Prefer LdColumn (uses auto-spacing) over nested Column for layout.',
      'Use LdRow for horizontal layouts with overflow handling (Flexible/Expanded).',
      'Use LdHorizontalScroll for scrollable collections of cards.',
      'Use LdBatchMultipleChoice when presenting multiple questions with options to submit together.',
    ],
  );
}

LdSize _size(String? s) => switch (s) {
  'xs' => LdSize.xs,
  's' => LdSize.s,
  'l' => LdSize.l,
  _ => LdSize.m,
};

// ──────────────────── LdColumn (LdAutoSpace) ────────────────────

final _colSchema = S.object(
  description: 'Liquid-flutter column with auto-spacing between children.',
  properties: {
    'justify': S.string(enumValues: ['start', 'center', 'end']),
    'align': S.string(enumValues: ['start', 'center', 'end', 'stretch']),
    'children': A2uiSchemas.componentArrayReference(),
  },
  required: ['children'],
);

CrossAxisAlignment _colAlign(String? a) => switch (a) {
  'center' => CrossAxisAlignment.center,
  'end' => CrossAxisAlignment.end,
  'stretch' => CrossAxisAlignment.stretch,
  _ => CrossAxisAlignment.start,
};

final ldColumn = CatalogItem(
  name: 'LdColumn',
  dataSchema: _colSchema,
  isImplicitlyFlexible: true,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final align = _colAlign(d['align'] as String?);
    return ComponentChildrenBuilder(
      childrenData: d['children'],
      dataContext: ctx.dataContext,
      buildChild: ctx.buildChild,
      getComponent: ctx.getComponent,
      explicitListBuilder: (ids, build, getComp, dc) {
        return LdAutoSpace(
          crossAxisAlignment: align,
          children: ids.map((id) => build(id, dc)).toList(),
        );
      },
      templateListWidgetBuilder: (context, data, componentId, path) {
        final values = _values(data);
        return LdAutoSpace(
          crossAxisAlignment: align,
          children: List.generate(values.length, (i) {
            return ctx.buildChild(
              componentId,
              ctx.dataContext.nested(DataPath('$path/$i')),
            );
          }),
        );
      },
    );
  },
);

// ──────────────────── LdRow ────────────────────

final _rowSchema = S.object(
  description: 'Horizontal row with overflow handling via Flexible/Expanded.',
  properties: {
    'children': A2uiSchemas.componentArrayReference(),
    'justify': S.string(
      enumValues: [
        'start',
        'center',
        'end',
        'spaceBetween',
        'spaceAround',
        'spaceEvenly',
      ],
    ),
    'align': S.string(enumValues: ['start', 'center', 'end', 'stretch']),
    'wrap': S.boolean(),
  },
  required: ['children'],
);

MainAxisAlignment _rowMain(String? a) => switch (a) {
  'center' => MainAxisAlignment.center,
  'end' => MainAxisAlignment.end,
  'spaceBetween' => MainAxisAlignment.spaceBetween,
  'spaceAround' => MainAxisAlignment.spaceAround,
  'spaceEvenly' => MainAxisAlignment.spaceEvenly,
  _ => MainAxisAlignment.start,
};

CrossAxisAlignment _rowCross(String? a) => switch (a) {
  'center' => CrossAxisAlignment.center,
  'end' => CrossAxisAlignment.end,
  'stretch' => CrossAxisAlignment.stretch,
  _ => CrossAxisAlignment.start,
};

final ldRow = CatalogItem(
  name: 'LdRow',
  dataSchema: _rowSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final main = _rowMain(d['justify'] as String?);
    final cross = _rowCross(d['align'] as String?);
    final wrap = d['wrap'] as bool? ?? false;

    return ComponentChildrenBuilder(
      childrenData: d['children'],
      dataContext: ctx.dataContext,
      buildChild: ctx.buildChild,
      getComponent: ctx.getComponent,
      explicitListBuilder: (ids, build, getComp, dc) {
        final children = ids.map((id) {
          final component = getComp(id);
          final child = build(id, dc);
          final weight = component?.properties['weight'] as int?;
          final type = component?.type ?? '';
          final implicitFlex =
              ctx.getCatalogItem(type)?.isImplicitlyFlexible ?? false;
          if (weight != null || implicitFlex) {
            return Flexible(
              flex: weight ?? 1,
              fit: weight != null ? FlexFit.tight : FlexFit.loose,
              child: child,
            );
          }
          return child;
        }).toList();
        if (wrap) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          );
        }
        return Row(
          mainAxisAlignment: main,
          crossAxisAlignment: cross,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
      templateListWidgetBuilder: (context, data, componentId, path) {
        final values = _values(data);
        final widgets = List.generate(values.length, (i) {
          return ctx.buildChild(
            componentId,
            ctx.dataContext.nested(DataPath('$path/$i')),
          );
        });
        if (wrap) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widgets,
          );
        }
        return Row(
          mainAxisAlignment: main,
          crossAxisAlignment: cross,
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        );
      },
    );
  },
);

// ──────────────────── LdText ────────────────────

final _textSchema = S.object(
  description: 'Styled text using liquid_flutter LdText.',
  properties: {
    'text': A2uiSchemas.stringReference(
      description: 'Literal or path-bound text string.',
    ),
    'styleHint': S.string(enumValues: ['h1', 'h2', 'h3', 'body', 'caption']),
  },
  required: ['text'],
);

final ldText = CatalogItem(
  name: 'LdText',
  dataSchema: _textSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final hint = d['styleHint'] as String?;
    return BoundString(
      dataContext: ctx.dataContext,
      value: d['text'],
      builder: (context, text) {
        if (text == null || text.isEmpty) return const SizedBox.shrink();
        return switch (hint) {
          'h1' => LdText.hl(text),
          'h2' => LdText.h(text),
          'h3' => LdText.hs(text),
          'caption' => LdText.caption(text),
          _ => LdText.p(text),
        };
      },
    );
  },
);

// ──────────────────── LdButton ────────────────────

final _btnSchema = S.object(
  description: 'Button using liquid_flutter LdButton.',
  properties: {
    'child': S.string(),
    'mode': S.string(enumValues: ['filled', 'outline', 'ghost', 'vague']),
    'action': S.object(
      properties: {
        'name': S.string(),
        'context': S.object(properties: {}, additionalProperties: true),
      },
      required: ['name'],
    ),
  },
  required: ['child', 'action'],
);

LdButtonMode _btnMode(String? m) => switch (m) {
  'outline' => LdButtonMode.outline,
  'ghost' => LdButtonMode.ghost,
  'vague' => LdButtonMode.vague,
  _ => LdButtonMode.filled,
};

final ldButton = CatalogItem(
  name: 'LdButton',
  dataSchema: _btnSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final childId = d['child'] as String;
    final mode = _btnMode(d['mode'] as String?);
    final action = d['action'] as JsonMap?;
    return LdButton(
      mode: mode,
      onPressed: action != null
          ? () async {
              final resolved = await resolveContext(
                ctx.dataContext,
                action['context'] as JsonMap?,
              );
              ctx.dispatchEvent(
                UserActionEvent(
                  name: action['name'] as String,
                  sourceComponentId: ctx.id,
                  context: resolved,
                ),
              );
            }
          : () {},
      child: ctx.buildChild(childId),
    );
  },
);

// ──────────────────── LdCard ────────────────────

final _cardSchema = S.object(
  description: 'Card using liquid_flutter LdCard.',
  properties: {
    'header': S.string(),
    'child': S.string(),
    'footer': S.string(),
    'flat': S.boolean(),
  },
  required: ['child'],
);

final ldCard = CatalogItem(
  name: 'LdCard',
  dataSchema: _cardSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final childId = d['child'] as String;
    return LdCard(
      flat: d['flat'] as bool? ?? false,
      header: d['header'] != null
          ? ctx.buildChild(d['header'] as String)
          : null,
      footer: d['footer'] != null
          ? ctx.buildChild(d['footer'] as String)
          : null,
      child: ctx.buildChild(childId),
    );
  },
);

// ──────────────────── LdHorizontalScroll ────────────────────

final _hscrollSchema = S.object(
  description: 'Horizontally scrollable row using LdHorizontalScroll.',
  properties: {
    'children': A2uiSchemas.componentArrayReference(),
    'spacing': S.string(enumValues: ['xs', 's', 'm', 'l']),
  },
  required: ['children'],
);

final ldHorizontalScroll = CatalogItem(
  name: 'LdHorizontalScroll',
  dataSchema: _hscrollSchema,
  widgetBuilder: (ctx) {
    final spacing = _size((ctx.data as JsonMap)['spacing'] as String?);
    return ComponentChildrenBuilder(
      childrenData: (ctx.data as JsonMap)['children'],
      dataContext: ctx.dataContext,
      buildChild: ctx.buildChild,
      getComponent: ctx.getComponent,
      explicitListBuilder: (ids, build, getComp, dc) {
        return LdHorizontalScroll(
          spacing: spacing,
          children: ids.map((id) => build(id, dc)).toList(),
        );
      },
      templateListWidgetBuilder: (context, data, componentId, path) {
        final values = _values(data);
        return LdHorizontalScroll(
          spacing: spacing,
          children: List.generate(values.length, (i) {
            return ctx.buildChild(
              componentId,
              ctx.dataContext.nested(DataPath('$path/$i')),
            );
          }),
        );
      },
    );
  },
);

// ──────────────────── LdTextField ────────────────────

final _tfSchema = S.object(
  description: 'Text input using liquid_flutter LdInput.',
  properties: {
    'label': S.string(),
    'text': A2uiSchemas.stringReference(
      description: 'Literal or path-bound text value.',
    ),
    'hint': S.string(),
    'multiline': S.boolean(),
    'obscure': S.boolean(),
  },
  required: ['text'],
);

final ldTextField = CatalogItem(
  name: 'LdTextField',
  dataSchema: _tfSchema,
  isImplicitlyFlexible: true,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final label = d['label'] as String?;
    final hint = d['hint'] as String? ?? '';
    final multiline = d['multiline'] as bool? ?? false;
    final obscure = d['obscure'] as bool? ?? false;

    return _BoundInput(
      dataContext: ctx.dataContext,
      textSource: d['text'],
      label: label,
      hint: hint,
      multiline: multiline,
      obscure: obscure,
    );
  },
);

class _BoundInput extends StatefulWidget {
  final DataContext dataContext;
  final Object? textSource;
  final String? label;
  final String hint;
  final bool multiline;
  final bool obscure;
  const _BoundInput({
    required this.dataContext,
    required this.textSource,
    this.label,
    required this.hint,
    required this.multiline,
    required this.obscure,
  });
  @override
  State<_BoundInput> createState() => _BoundInputState();
}

class _BoundInputState extends State<_BoundInput> {
  late final TextEditingController _ctrl;
  String? _path;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _resolveSrc();
  }

  void _resolveSrc() {
    final src = widget.textSource;
    if (src is JsonMap && src.containsKey('path')) {
      _path = src['path'] as String;
      _ctrl.text = widget.dataContext.getValue<String>(DataPath(_path!)) ?? '';
    } else if (src is String) {
      _ctrl.text = src;
    } else {
      _ctrl.text = src?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdInput(
      label: widget.label,
      hint: widget.hint,
      controller: _ctrl,
      obscureText: widget.obscure,
      minLines: widget.multiline ? 3 : 1,
      maxLines: widget.multiline ? null : 1,
      onChanged: (v) {
        if (_path != null) widget.dataContext.update(DataPath(_path!), v);
      },
    );
  }
}

// ──────────────────── LdCheckbox ────────────────────

final _cbSchema = S.object(
  description: 'Checkbox using liquid_flutter LdCheckbox.',
  properties: {'label': S.string(), 'value': A2uiSchemas.booleanReference()},
  required: ['label', 'value'],
);

final ldCheckbox = CatalogItem(
  name: 'LdCheckbox',
  dataSchema: _cbSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final valueRef = d['value'];
    final path = (valueRef is JsonMap && valueRef.containsKey('path'))
        ? valueRef['path'] as String
        : '${ctx.id}.value';

    return BoundString(
      dataContext: ctx.dataContext,
      value: d['label'],
      builder: (context, label) {
        return BoundBool(
          dataContext: ctx.dataContext,
          value: {'path': path},
          builder: (context, checked) {
            return LdCheckbox(
              label: label,
              checked: checked ?? false,
              onChanged: (v) => ctx.dataContext.update(DataPath(path), v),
            );
          },
        );
      },
    );
  },
);

// ──────────────────── LdSlider ────────────────────

final _sliderSchema = S.object(
  description: 'Slider using liquid_flutter LdSlider.',
  properties: {
    'min': S.number(),
    'max': S.number(),
    'value': A2uiSchemas.numberReference(),
    'steps': S.integer(),
  },
  required: ['value', 'min', 'max'],
);

final ldSlider = CatalogItem(
  name: 'LdSlider',
  dataSchema: _sliderSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final min = (d['min'] as num?)?.toDouble() ?? 0.0;
    final max = (d['max'] as num?)?.toDouble() ?? 100.0;
    final steps = (d['steps'] as int?) ?? 0;
    final valueRef = d['value'];
    final path = (valueRef is JsonMap && valueRef.containsKey('path'))
        ? valueRef['path'] as String
        : '${ctx.id}.value';

    return BoundNumber(
      dataContext: ctx.dataContext,
      value: {'path': path},
      builder: (context, val) {
        return SizedBox(
          width: 200,
          child: LdSlider(
            value: (val ?? min).toDouble(),
            min: min,
            max: max,
            step: steps.toDouble(),
            onChanged: (v) => ctx.dataContext.update(DataPath(path), v),
          ),
        );
      },
    );
  },
);

// ──────────────────── LdDivider ────────────────────

final _divSchema = S.object(description: 'Horizontal divider using LdDivider.');

final ldDivider = CatalogItem(
  name: 'LdDivider',
  dataSchema: _divSchema,
  widgetBuilder: (_) => const LdDivider(),
);

// ──────────────────── LdList ────────────────────

final _listSchema = S.object(
  description: 'Shrink-wrapped ListView of children.',
  properties: {'children': A2uiSchemas.componentArrayReference()},
  required: ['children'],
);

final ldList = CatalogItem(
  name: 'LdList',
  dataSchema: _listSchema,
  isImplicitlyFlexible: true,
  widgetBuilder: (ctx) {
    return ComponentChildrenBuilder(
      childrenData: (ctx.data as JsonMap)['children'],
      dataContext: ctx.dataContext,
      buildChild: ctx.buildChild,
      getComponent: ctx.getComponent,
      explicitListBuilder: (ids, build, getComp, dc) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: ids.map((id) => build(id, dc)).toList(),
        );
      },
      templateListWidgetBuilder: (context, data, componentId, path) {
        final values = _values(data);
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(values.length, (i) {
            return ctx.buildChild(
              componentId,
              ctx.dataContext.nested(DataPath('$path/$i')),
            );
          }),
        );
      },
    );
  },
);

// ──────────────────── LdMultipleChoice ────────────────────

final _mcSchema = S.object(
  description: 'Multiple choice selector using liquid_flutter radio buttons.',
  properties: {
    'label': S.string(),
    'selected': A2uiSchemas.stringReference(),
    'options': S.list(
      items: S.object(
        properties: {'value': S.string(), 'label': S.string()},
        required: ['value', 'label'],
      ),
    ),
  },
  required: ['selected', 'options'],
);

final ldMultipleChoice = CatalogItem(
  name: 'LdMultipleChoice',
  dataSchema: _mcSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final label = d['label'] as String?;
    final options =
        (d['options'] as List<Object?>?)?.whereType<JsonMap>().toList() ?? [];
    final selectedRef = d['selected'];
    final path = (selectedRef is JsonMap && selectedRef.containsKey('path'))
        ? selectedRef['path'] as String
        : '${ctx.id}.selected';

    return BoundString(
      dataContext: ctx.dataContext,
      value: {'path': path},
      builder: (context, selected) {
        return LdAutoSpace(
          children: [
            if (label != null) LdText.l(label, size: LdSize.s),
            ...options.map((opt) {
              final val = opt['value'] as String;
              final lbl = opt['label'] as String;
              return LdRadio(
                label: lbl,
                checked: val == selected,
                onChanged: (_) => ctx.dataContext.update(DataPath(path), val),
              );
            }),
          ],
        );
      },
    );
  },
);

// ──────────────────── LdTabs ────────────────────

final _tabsSchema = S.object(
  description: 'Tab switcher using liquid_flutter LdSwitch.',
  properties: {
    'selected': A2uiSchemas.stringReference(),
    'options': S.list(
      items: S.object(
        properties: {'value': S.string(), 'label': S.string()},
        required: ['value', 'label'],
      ),
    ),
  },
  required: ['selected', 'options'],
);

final ldTabs = CatalogItem(
  name: 'LdTabs',
  dataSchema: _tabsSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final options =
        (d['options'] as List<Object?>?)?.whereType<JsonMap>().toList() ?? [];
    final selectedRef = d['selected'];
    final path = (selectedRef is JsonMap && selectedRef.containsKey('path'))
        ? selectedRef['path'] as String
        : '${ctx.id}.selected';

    return BoundString(
      dataContext: ctx.dataContext,
      value: {'path': path},
      builder: (context, selected) {
        final Map<String, Widget> children = {};
        for (final opt in options) {
          final key = opt['value'] as String;
          final label = opt['label'] as String;
          children[key] = LdText.l(label, size: LdSize.s);
        }
        return LdSwitch<String>(
          value:
              selected ??
              (options.isNotEmpty ? options.first['value'] as String : ''),
          onChanged: (v) => ctx.dataContext.update(DataPath(path), v),
          children: children,
        );
      },
    );
  },
);

// ──────────────────── LdIcon ────────────────────

final _iconSchema = S.object(
  description: 'Icon using lucide_icons_flutter.',
  properties: {
    'name': S.string(),
    'size': S.string(enumValues: ['xs', 's', 'm', 'l']),
  },
  required: ['name'],
);

IconData _icn(String name) => switch (name) {
  'check' => LucideIcons.check,
  'x' => LucideIcons.x,
  'chevron-right' => LucideIcons.chevronRight,
  'chevron-down' => LucideIcons.chevronDown,
  'chevron-up' => LucideIcons.chevronUp,
  'chevron-left' => LucideIcons.chevronLeft,
  'plus' => LucideIcons.plus,
  'minus' => LucideIcons.minus,
  'search' => LucideIcons.search,
  'settings' => LucideIcons.settings,
  'user' => LucideIcons.user,
  'calendar' => LucideIcons.calendar,
  'clock' => LucideIcons.clock,
  'file' => LucideIcons.file,
  'folder' => LucideIcons.folder,
  'trash' => LucideIcons.trash2,
  'pen' => LucideIcons.pen,
  'edit' => LucideIcons.pen,
  'copy' => LucideIcons.copy,
  'link' => LucideIcons.link,
  'info' => LucideIcons.info,
  'star' => LucideIcons.star,
  'heart' => LucideIcons.heart,
  'share' => LucideIcons.share,
  'download' => LucideIcons.download,
  'upload' => LucideIcons.upload,
  'refresh' => LucideIcons.refreshCcw,
  'arrow-right' => LucideIcons.arrowRight,
  'arrow-left' => LucideIcons.arrowLeft,
  'arrow-up' => LucideIcons.arrowUp,
  'arrow-down' => LucideIcons.arrowDown,
  'ellipsis-horizontal' => LucideIcons.ellipsis,
  'ellipsis-vertical' => LucideIcons.ellipsisVertical,
  'eye' => LucideIcons.eye,
  'show' => LucideIcons.eye,
  'square' => LucideIcons.square,
  'stop' => LucideIcons.square,
  'play' => LucideIcons.play,
  'pause' => LucideIcons.pause,
  'menu' => LucideIcons.menu,
  _ => LucideIcons.circle,
};

final ldIcon = CatalogItem(
  name: 'LdIcon',
  dataSchema: _iconSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final name = d['name'] as String;
    final size = _size(d['size'] as String?);
    final iconSize = LdTheme.of(ctx.buildContext).labelSize(size);
    return Icon(_icn(name), size: iconSize);
  },
);

// ──────────────────── LdImage ────────────────────

final _imgSchema = S.object(
  description: 'Image display.',
  properties: {
    'url': S.string(),
    'width': S.number(),
    'height': S.number(),
    'fit': S.string(
      enumValues: ['contain', 'cover', 'fill', 'fitWidth', 'fitHeight'],
    ),
  },
  required: ['url'],
);

BoxFit _fit(String? f) => switch (f) {
  'contain' => BoxFit.contain,
  'cover' => BoxFit.cover,
  'fill' => BoxFit.fill,
  'fitWidth' => BoxFit.fitWidth,
  'fitHeight' => BoxFit.fitHeight,
  _ => BoxFit.cover,
};

final ldImage = CatalogItem(
  name: 'LdImage',
  dataSchema: _imgSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    return Image.network(
      d['url'] as String,
      width: (d['width'] as num?)?.toDouble(),
      height: (d['height'] as num?)?.toDouble(),
      fit: _fit(d['fit'] as String?),
    );
  },
);

// ──────────────────── LdBatchMultipleChoice ────────────────────

final _batchSchema = S.object(
  description:
      'A set of multiple choice questions presented together and submitted as a batch. '
      'Each question has a key, label, and list of options. Dispatches "batchSubmit" with all answers.',
  properties: {
    'title': S.string(),
    'questions': S.list(
      items: S.object(
        properties: {
          'key': S.string(),
          'label': S.string(),
          'options': S.list(
            items: S.object(
              properties: {'value': S.string(), 'label': S.string()},
              required: ['value', 'label'],
            ),
          ),
        },
        required: ['key', 'label', 'options'],
      ),
    ),
    'submitLabel': S.string(),
  },
  required: ['questions'],
);

final ldBatchMultipleChoice = CatalogItem(
  name: 'LdBatchMultipleChoice',
  dataSchema: _batchSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String?;
    final questions =
        (d['questions'] as List<Object?>?)?.whereType<JsonMap>().toList() ?? [];
    final submitLabel = d['submitLabel'] as String? ?? 'Submit';

    return _BatchMultipleChoice(
      title: title,
      questions: questions,
      submitLabel: submitLabel,
      context: ctx,
    );
  },
);

class _BatchMultipleChoice extends StatefulWidget {
  final String? title;
  final List<JsonMap> questions;
  final String submitLabel;
  final CatalogItemContext context;
  const _BatchMultipleChoice({
    required this.title,
    required this.questions,
    required this.submitLabel,
    required this.context,
  });
  @override
  State<_BatchMultipleChoice> createState() => _BatchMultipleChoiceState();
}

class _BatchMultipleChoiceState extends State<_BatchMultipleChoice> {
  late final Map<String, String?> _selections = {
    for (final q in widget.questions) q['key'] as String: null,
  };

  @override
  Widget build(BuildContext c) {
    return LdCard(
      flat: true,
      child: LdAutoSpace(
        children: [
          if (widget.title != null) LdText.hl(widget.title!),
          ...widget.questions.map(_q),
          LdButton(
            mode: LdButtonMode.filled,
            onPressed: _allAnswered ? _submit : () {},
            child: LdText.l(widget.submitLabel, size: LdSize.s),
          ),
        ],
      ),
    );
  }

  Widget _q(JsonMap q) {
    final key = q['key'] as String;
    final label = q['label'] as String;
    final options =
        (q['options'] as List<Object?>?)?.whereType<JsonMap>().toList() ?? [];
    return LdAutoSpace(
      children: [
        LdText.p(label),
        ...options.map((opt) {
          final val = opt['value'] as String;
          final lbl = opt['label'] as String;
          return LdRadio(
            label: lbl,
            checked: _selections[key] == val,
            onChanged: (_) => setState(() => _selections[key] = val),
          );
        }),
      ],
    );
  }

  bool get _allAnswered => _selections.values.every((v) => v != null);

  void _submit() {
    widget.context.dispatchEvent(
      UserActionEvent(
        name: 'batchSubmit',
        sourceComponentId: widget.context.id,
        context: {
          'answers': {for (final e in _selections.entries) e.key: e.value},
        },
      ),
    );
  }
}

// ──────────────────── Helpers ────────────────────

List<Object?> _values(Object? data) {
  if (data is List) return data;
  if (data is Map) return data.values.toList();
  return [];
}
