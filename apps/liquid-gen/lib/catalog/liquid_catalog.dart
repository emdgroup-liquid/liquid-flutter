import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Catalog of Liquid Flutter widgets for GenUI
class LiquidCatalog {
  static Catalog get catalog => Catalog([
        ..._textWidgets,
        ..._layoutWidgets,
        ..._formWidgets,
        ..._listWidgets,
        ..._feedbackWidgets,
        ..._otherWidgets,
      ]);

  // Text widgets
  static List<CatalogItem> get _textWidgets => [
        _ldTextH,
        _ldTextHl,
        _ldTextHs,
        _ldTextHxs,
        _ldTextP,
        _ldTextPl,
        _ldTextPs,
        _ldTextPxs,
        _ldTextL,
        _ldTextLl,
        _ldTextLs,
        _ldTextLxs,
        _ldTextCaption,
      ];

  static final _ldTextH = CatalogItem(
    name: 'LdText.h',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The headline text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.h(text);
    },
  );

  static final _ldTextHl = CatalogItem(
    name: 'LdText.hl',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The large headline text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.hl(text);
    },
  );

  static final _ldTextHs = CatalogItem(
    name: 'LdText.hs',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The small headline text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.hs(text);
    },
  );

  static final _ldTextHxs = CatalogItem(
    name: 'LdText.hxs',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The extra-small headline text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.hxs(text);
    },
  );

  static final _ldTextP = CatalogItem(
    name: 'LdText.p',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The paragraph text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.p(text);
    },
  );

  static final _ldTextPl = CatalogItem(
    name: 'LdText.pl',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The large paragraph text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.pl(text);
    },
  );

  static final _ldTextPs = CatalogItem(
    name: 'LdText.ps',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The small paragraph text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.ps(text);
    },
  );

  static final _ldTextPxs = CatalogItem(
    name: 'LdText.pxs',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The extra-small paragraph text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.pxs(text);
    },
  );

  static final _ldTextL = CatalogItem(
    name: 'LdText.l',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The label text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.l(text);
    },
  );

  static final _ldTextLl = CatalogItem(
    name: 'LdText.ll',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The large label text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.ll(text);
    },
  );

  static final _ldTextLs = CatalogItem(
    name: 'LdText.ls',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The small label text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.ls(text);
    },
  );

  static final _ldTextLxs = CatalogItem(
    name: 'LdText.lxs',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The extra-small label text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.lxs(text);
    },
  );

  static final _ldTextCaption = CatalogItem(
    name: 'LdText.caption',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'The caption text to display'),
      },
      required: ['text'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdText.caption(text);
    },
  );

  // Layout widgets
  static List<CatalogItem> get _layoutWidgets => [
        _ldScaffold,
        _ldAppBar,
        _ldScaffoldBody,
        _ldAutoSpace,
        _ldCard,
        _ldContainer,
      ];

  static final _ldScaffold = CatalogItem(
    name: 'LdScaffold',
    dataSchema: S.object(
      properties: {
        'appBars': S.list(items: S.object()),
        'body': S.object(),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final appBarsJson = json['appBars'] as List<dynamic>?;
      List<LdAppBar>? appBars;
      if (appBarsJson != null) {
        appBars = [];
        for (final barData in appBarsJson) {
          if (barData is Map) {
            // Extract component name - GenUI data structure has component name as key
            final componentId = barData.keys.firstOrNull;
            if (componentId != null && componentId is String) {
              final barWidget = itemContext.buildChild(componentId);
              if (barWidget is LdAppBar) {
                appBars.add(barWidget);
              }
            }
          }
        }
      }

      final bodyData = json['body'];
      Widget? child;
      if (bodyData != null && bodyData is Map) {
        // Extract component name from data structure
        // GenUI expects data like {"LdScaffoldBody": {...}} or just the data with component id
        final componentId = bodyData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      }
      return LdScaffold(
        appBars: appBars,
        body: child ?? const SizedBox(),
      );
    },
  );

  static final _ldAppBar = CatalogItem(
    name: 'LdAppBar',
    dataSchema: S.object(
      properties: {
        'title': S.string(),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget? title;
      final titleData = json['title'];
      if (titleData is String) {
        title = LdText.h(titleData);
      } else if (titleData != null && titleData is Map) {
        // Extract component name from data structure
        final componentId = titleData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          title = itemContext.buildChild(componentId);
        }
      }
      return LdAppBar(title: title);
    },
  );

  static final _ldScaffoldBody = CatalogItem(
    name: 'LdScaffoldBody',
    dataSchema: S.object(
      properties: {
        'addContainer': S.boolean(description: 'Whether to add container padding'),
        'children': S.list(items: S.object()),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final addContainer = json['addContainer'] as bool? ?? false;
      final childrenJson = json['children'] as List<dynamic>?;
      final children = childrenJson
            ?.map((child) {
              if (child is Map) {
                final componentId = child.keys.firstOrNull;
                if (componentId != null && componentId is String) {
                  return itemContext.buildChild(componentId);
                }
              }
              return null;
            })
            .whereType<Widget>()
            .toList() ??
          [];
      return LdScaffoldBody(
        addContainer: addContainer,
        children: children,
      );
    },
  );

  static final _ldAutoSpace = CatalogItem(
    name: 'LdAutoSpace',
    dataSchema: S.object(
      properties: {
        'children': S.list(items: S.object()),
      },
      required: ['children'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final childrenJson = json['children'] as List<dynamic>? ?? [];
      final children = childrenJson
          .map((child) {
            if (child is Map) {
              final componentId = child.keys.firstOrNull;
              if (componentId != null && componentId is String) {
                return itemContext.buildChild(componentId);
              }
            }
            return null;
          })
          .whereType<Widget>()
          .toList();
      return LdAutoSpace(children: children);
    },
  );

  static final _ldCard = CatalogItem(
    name: 'LdCard',
    dataSchema: S.object(
      properties: {
        'padding': S.object(
          properties: {
            'left': S.number(),
            'top': S.number(),
            'right': S.number(),
            'bottom': S.number(),
          },
        ),
        'child': S.object(),
        'children': S.list(items: S.object()),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final paddingJson = json['padding'] as Map<String, dynamic>?;
      EdgeInsets? padding;
      if (paddingJson != null) {
        padding = EdgeInsets.fromLTRB(
          (paddingJson['left'] as num?)?.toDouble() ?? 0,
          (paddingJson['top'] as num?)?.toDouble() ?? 0,
          (paddingJson['right'] as num?)?.toDouble() ?? 0,
          (paddingJson['bottom'] as num?)?.toDouble() ?? 0,
        );
      }

      Widget? child;
      final childData = json['child'];
      final childrenJson = json['children'] as List<dynamic>?;
      if (childrenJson != null && childrenJson.isNotEmpty) {
        final widgets = childrenJson
            .map((c) {
              if (c is Map) {
                final componentId = c.keys.firstOrNull;
                if (componentId != null && componentId is String) {
                  return itemContext.buildChild(componentId);
                }
              }
              return null;
            })
            .whereType<Widget>()
            .toList();
        if (widgets.isEmpty) {
          child = null;
        } else if (widgets.length == 1) {
          child = widgets.first;
        } else {
          child = LdAutoSpace(children: widgets);
        }
      } else if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      }

      return LdCard(
        padding: padding,
        child: child ?? const SizedBox(),
      );
    },
  );

  static final _ldContainer = CatalogItem(
    name: 'LdContainer',
    dataSchema: S.object(
      properties: {
        'child': S.object(),
        'children': S.list(items: S.object()),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget child = const SizedBox();
      final childData = json['child'];
      final childrenJson = json['children'] as List<dynamic>?;
      if (childrenJson != null && childrenJson.isNotEmpty) {
        final widgets = childrenJson
            .map((c) {
              if (c is Map) {
                final componentId = c.keys.firstOrNull;
                if (componentId != null && componentId is String) {
                  return itemContext.buildChild(componentId);
                }
              }
              return null;
            })
            .whereType<Widget>()
            .toList();
        if (widgets.isNotEmpty) {
          child = widgets.length == 1
              ? widgets.first
              : LdAutoSpace(children: widgets);
        }
      } else if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      }
      return LdContainer(child: child);
    },
  );

  // Form widgets
  static List<CatalogItem> get _formWidgets => [
        _ldButton,
        _ldInput,
        _ldCheckbox,
        _ldSwitch,
        _ldSelect,
        _ldSlider,
      ];

  static final _ldButton = CatalogItem(
    name: 'LdButton',
    dataSchema: S.object(
      properties: {
        'mode': S.string(description: 'Button mode variant: filled, outline, ghost, or vague'),
        'child': S.object(description: 'Button child as widget'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget? child;
      final childData = json['child'];
      if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      }

      final modeStr = json['mode'] as String?;
      LdButtonMode? mode;
      if (modeStr != null) {
        mode = switch (modeStr) {
          'outline' => LdButtonMode.outline,
          'ghost' => LdButtonMode.ghost,
          'vague' => LdButtonMode.vague,
          _ => LdButtonMode.filled,
        };
      }

      return LdButton(
        mode: mode,
        onPressed: () async {},
        child: child ?? const SizedBox(),
      );
    },
  );

  static final _ldInput = CatalogItem(
    name: 'LdInput',
    dataSchema: S.object(
      properties: {
        'hint': S.string(description: 'Placeholder hint text'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final hint = json['hint'] as String? ?? '';
      return LdInput(
        hint: hint,
        controller: null,
      );
    },
  );

  static final _ldCheckbox = CatalogItem(
    name: 'LdCheckbox',
    dataSchema: S.object(
      properties: {
        'checked': S.boolean(description: 'Whether the checkbox is checked'),
        'label': S.string(description: 'Label text for the checkbox'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      return LdCheckbox(
        checked: json['checked'] as bool? ?? false,
        label: json['label'] as String?,
        onChanged: (_) {},
      );
    },
  );

  static final _ldSwitch = CatalogItem(
    name: 'LdSwitch',
    dataSchema: S.object(
      properties: {
        'value': S.boolean(description: 'Current switch value'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final value = json['value'] as bool? ?? false;
      return LdSwitch<bool>(
        value: value,
        children: {true: const Text('On'), false: const Text('Off')},
        onChanged: (_) {},
      );
    },
  );

  static final _ldSelect = CatalogItem(
    name: 'LdSelect',
    dataSchema: S.object(
      properties: {
        'value': S.string(description: 'Selected value'),
        'items': S.list(
          items: S.object(
            properties: {
              'value': S.string(),
              'label': S.string(),
            },
          ),
        ),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final value = json['value'] as String?;
      final itemsJson = json['items'] as List<dynamic>?;
      final items = itemsJson
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  final itemValue = item['value'] as String?;
                  final label = item['label'] as String? ?? itemValue ?? '';
                  if (itemValue != null) {
                    return LdSelectItem<String>(
                      value: itemValue,
                      child: Text(label),
                    );
                  }
                }
                return null;
              })
              .whereType<LdSelectItem<String>>()
              .toList() ??
          [];
      return LdSelect<String>(
        value: value,
        items: items,
        onChanged: (_) {},
      );
    },
  );

  static final _ldSlider = CatalogItem(
    name: 'LdSlider',
    dataSchema: S.object(
      properties: {
        'hint': S.string(description: 'Hint text for the slider'),
        'label': S.string(description: 'Label text for the slider'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      return LdSlider(
        onSlideComplete: () {},
        hint: json['hint'] as String?,
        label: json['label'] as String?,
      );
    },
  );

  // List widgets
  static List<CatalogItem> get _listWidgets => [
        _ldList,
        _ldListItem,
        _ldListEmpty,
      ];

  static final _ldList = CatalogItem(
    name: 'LdList',
    dataSchema: S.object(
      properties: {
        'children': S.list(items: S.object()),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final childrenJson = json['children'] as List<dynamic>? ?? [];
      final items = childrenJson
          .map((child) {
            if (child is Map) {
              final componentId = child.keys.firstOrNull;
              if (componentId != null && componentId is String) {
                return itemContext.buildChild(componentId);
              }
            }
            return null;
          })
          .whereType<Widget>()
          .toList();
      if (items.isEmpty) return const SizedBox();
      if (items.length == 1) return items.first;
      return LdAutoSpace(children: items);
    },
  );

  static final _ldListItem = CatalogItem(
    name: 'LdListItem',
    dataSchema: S.object(
      properties: {
        'title': S.string(),
        'children': S.list(items: S.object()),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget? title;
      final titleData = json['title'];
      final childrenJson = json['children'] as List<dynamic>?;
      if (childrenJson != null && childrenJson.isNotEmpty) {
        final widgets = childrenJson
            .map((c) {
              if (c is Map) {
                final componentId = c.keys.firstOrNull;
                if (componentId != null && componentId is String) {
                  return itemContext.buildChild(componentId);
                }
              }
              return null;
            })
            .whereType<Widget>()
            .toList();
        if (widgets.isEmpty) {
          title = null;
        } else if (widgets.length == 1) {
          title = widgets.first;
        } else {
          title = LdAutoSpace(children: widgets);
        }
      } else if (titleData is String) {
        title = LdText.p(titleData);
      } else if (titleData != null && titleData is Map) {
        // Extract component name from data structure
        final componentId = titleData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          title = itemContext.buildChild(componentId);
        }
      }
      return LdListItem(title: title ?? const SizedBox());
    },
  );

  static final _ldListEmpty = CatalogItem(
    name: 'LdListEmpty',
    dataSchema: S.object(),
    widgetBuilder: (itemContext) {
      return LdListEmpty();
    },
  );

  // Feedback widgets
  static List<CatalogItem> get _feedbackWidgets => [
        _ldHint,
      ];

  static final _ldHint = CatalogItem(
    name: 'LdHint',
    dataSchema: S.object(
      properties: {
        'type': S.string(description: 'Hint type: info, error, warning, or success'),
        'message': S.string(description: 'Hint message text'),
        'child': S.object(),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget child = const SizedBox();
      final childData = json['child'];
      final message = json['message'] as String?;
      if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      } else if (message != null) {
        child = LdText.p(message);
      }

      final typeStr = json['type'] as String? ?? 'info';
      final hintType = switch (typeStr) {
        'error' => LdHintType.error,
        'warning' => LdHintType.warning,
        'success' => LdHintType.success,
        _ => LdHintType.info,
      };

      return LdHint(type: hintType, child: child);
    },
  );

  // Other widgets
  static List<CatalogItem> get _otherWidgets => [
        _ldBadge,
        _ldTag,
        _ldAvatar,
        _ldDivider,
        _ldBundle,
      ];

  static final _ldBadge = CatalogItem(
    name: 'LdBadge',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'Badge text'),
        'child': S.object(),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget child = const SizedBox();
      final childData = json['child'];
      final text = json['text'] as String?;
      if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      } else if (text != null) {
        child = Text(text);
      }
      return LdBadge(child: child);
    },
  );

  static final _ldTag = CatalogItem(
    name: 'LdTag',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'Tag text'),
        'child': S.object(),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      Widget child = const SizedBox();
      final childData = json['child'];
      final text = json['text'] as String?;
      if (childData != null && childData is Map) {
        // Extract component name from data structure
        final componentId = childData.keys.firstOrNull;
        if (componentId != null && componentId is String) {
          child = itemContext.buildChild(componentId);
        }
      } else if (text != null) {
        child = Text(text);
      }
      return LdTag(child: child);
    },
  );

  static final _ldAvatar = CatalogItem(
    name: 'LdAvatar',
    dataSchema: S.object(
      properties: {
        'text': S.string(description: 'Avatar text/initials'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final text = json['text'] as String? ?? '';
      return LdAvatar(child: Text(text));
    },
  );

  static final _ldDivider = CatalogItem(
    name: 'LdDivider',
    dataSchema: S.object(
      properties: {
        'height': S.number(description: 'Divider height'),
      },
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final height = (json['height'] as num?)?.toDouble();
      return LdDivider(height: height);
    },
  );

  static final _ldBundle = CatalogItem(
    name: 'LdBundle',
    dataSchema: S.object(
      properties: {
        'children': S.list(items: S.object()),
      },
      required: ['children'],
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as Map<String, Object?>;
      final childrenJson = json['children'] as List<dynamic>? ?? [];
      final children = childrenJson
          .map((child) {
            if (child is Map) {
              final componentId = child.keys.firstOrNull;
              if (componentId != null && componentId is String) {
                return itemContext.buildChild(componentId);
              }
            }
            return null;
          })
          .whereType<Widget>()
          .toList();
      return LdBundle(children: children);
    },
  );
}
