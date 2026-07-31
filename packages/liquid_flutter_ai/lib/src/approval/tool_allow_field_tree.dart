import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact exact/wildcard/not-defined field tree for picker and editor.
class LdToolAllowFieldTree extends StatelessWidget {
  const LdToolAllowFieldTree({
    super.key,
    required this.session,
    required this.onPinChanged,
    this.emptyLabel = 'No arguments to pin.',
  });

  final LdToolAllowFieldSession session;
  final void Function(String path, LdToolAllowFieldPin pin) onPinChanged;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (session.pins.isEmpty) {
      return LdText.l(emptyLabel);
    }

    return _FieldBranch(
      parentPath: '',
      session: session,
      onPinChanged: onPinChanged,
    );
  }
}

class _FieldBranch extends StatelessWidget {
  const _FieldBranch({
    required this.parentPath,
    required this.session,
    required this.onPinChanged,
  });

  final String parentPath;
  final LdToolAllowFieldSession session;
  final void Function(String path, LdToolAllowFieldPin pin) onPinChanged;

  @override
  Widget build(BuildContext context) {
    final childKeys = ldChildKeysForPath(session, parentPath);
    if (childKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: LdTheme.of(context).border),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final key in childKeys)
              _FieldRow(
                path: parentPath.isEmpty ? key : '$parentPath.$key',
                keyLabel: key,
                session: session,
                onPinChanged: onPinChanged,
              ),
          ],
        ).spaceS(),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.path,
    required this.keyLabel,
    required this.session,
    required this.onPinChanged,
  });

  final String path;
  final String keyLabel;
  final LdToolAllowFieldSession session;
  final void Function(String path, LdToolAllowFieldPin pin) onPinChanged;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final pin =
        session.pins[path] ??
        const LdToolAllowFieldPin(mode: LdToolAllowPinMode.notAllowed);
    final isObject = session.objectPaths.contains(path);
    final meta = session.schemaMeta[path];
    final callOrPinValue = pin.values.isNotEmpty ? pin.values.first : null;
    final kind =
        meta?.kind ??
        (isObject
            ? LdToolAllowValueKind.object
            : callOrPinValue is List
            ? LdToolAllowValueKind.array
            : LdToolAllowValueKind.unknown);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 1,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.border)),
              ),
            ),
            SizedBox(width: 3),
            LdText.ls('$keyLabel:'),
            SizedBox(width: 3),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: LdContextMenu(
                  positionMode: LdContextPositionMode.relativeTrigger,
                  zoomMode: LdContextZoomMode.never,
                  scaleFromTrigger: false,
                  builder: (context, isShuttle, open, isOpen, child) {
                    final isWildcard = pin.mode == LdToolAllowPinMode.wildcard;
                    final isNotAllowed =
                        pin.mode == LdToolAllowPinMode.notAllowed;
                    final linkColor = switch (isNotAllowed) {
                      true => theme.textMuted,
                      false => switch (isWildcard) {
                        true => theme.warningColor,
                        false => theme.primaryColor,
                      },
                    };
                    // Labels default to w700; keep Fixed/Not allowed regular so
                    // wildcards read clearly as bold.
                    final labelStyle =
                        ldBuildTextStyle(
                          theme,
                          LdTextType.label,
                          LdSize.s,
                          color: linkColor,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor,
                          fontWeight: isWildcard
                              ? FontWeight.w700
                              : FontWeight.w400,
                        );
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: open,
                        behavior: HitTestBehavior.opaque,
                        child: Text(pin.summaryLabel, style: labelStyle),
                      ),
                    );
                  },
                  menuBuilder: (context) {
                    return _PinEditMenu(
                      path: path,
                      pin: pin,
                      isObject: isObject,
                      kind: kind,
                      itemKind: meta?.itemKind ?? LdToolAllowValueKind.unknown,
                      enumOptions: meta?.enumOptions ?? const [],
                      onPinChanged: onPinChanged,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        LdReveal(
          revealed: pin.mode == LdToolAllowPinMode.exact && isObject,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: _FieldBranch(
              parentPath: path,
              session: session,
              onPinChanged: onPinChanged,
            ),
          ),
        ),
      ],
    ).spaceS();
  }
}

class _PinEditMenu extends StatefulWidget {
  const _PinEditMenu({
    required this.path,
    required this.pin,
    required this.isObject,
    required this.kind,
    required this.itemKind,
    required this.enumOptions,
    required this.onPinChanged,
  });

  final String path;
  final LdToolAllowFieldPin pin;
  final bool isObject;
  final LdToolAllowValueKind kind;
  final LdToolAllowValueKind itemKind;
  final List<Object?> enumOptions;
  final void Function(String path, LdToolAllowFieldPin pin) onPinChanged;

  @override
  State<_PinEditMenu> createState() => _PinEditMenuState();
}

class _PinEditMenuState extends State<_PinEditMenu> {
  late LdToolAllowPinMode _mode;
  late List<Object?> _values;
  final _draftController = TextEditingController();

  bool get _isArray => widget.kind == LdToolAllowValueKind.array;

  @override
  void initState() {
    super.initState();
    _mode = widget.pin.mode;
    _values = List<Object?>.from(widget.pin.values);
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  void _emit(LdToolAllowFieldPin pin) {
    widget.onPinChanged(widget.path, pin);
  }

  void _setMode(LdToolAllowPinMode mode) {
    setState(() => _mode = mode);
    _emit(
      LdToolAllowFieldPin(
        mode: mode,
        values: mode == LdToolAllowPinMode.exact ? _values : const [],
      ),
    );
    if (mode != LdToolAllowPinMode.exact) {
      maybePopContextMenu(context);
    }
  }

  void _setValues(List<Object?> values) {
    if (values.isEmpty) {
      setState(() => _values = []);
      _setMode(LdToolAllowPinMode.notAllowed);
      return;
    }
    setState(() => _values = values);
    _emit(LdToolAllowFieldPin(mode: LdToolAllowPinMode.exact, values: values));
  }

  Object? _parseDraft(String raw, {required LdToolAllowValueKind kind}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return switch (kind) {
      LdToolAllowValueKind.boolean =>
        trimmed.toLowerCase() == 'true'
            ? true
            : trimmed.toLowerCase() == 'false'
            ? false
            : null,
      LdToolAllowValueKind.integer => int.tryParse(trimmed),
      LdToolAllowValueKind.number => num.tryParse(trimmed),
      LdToolAllowValueKind.string ||
      LdToolAllowValueKind.unknown ||
      LdToolAllowValueKind.array ||
      LdToolAllowValueKind.object => trimmed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Material(
      color: theme.surface,
      borderRadius: theme.radius(LdSize.m),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
        child: LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LdText.ls('Mode', color: theme.textMuted),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in LdToolAllowPinMode.values)
                  LdButton(
                    size: LdSize.s,
                    mode: _mode == mode
                        ? LdButtonMode.filled
                        : LdButtonMode.outline,
                    onPressed: () => _setMode(mode),
                    child: Text(switch (mode) {
                      LdToolAllowPinMode.exact => 'Fixed',
                      LdToolAllowPinMode.wildcard => 'Any',
                      LdToolAllowPinMode.notAllowed => 'Not allowed',
                    }),
                  ),
              ],
            ),
            if (_mode == LdToolAllowPinMode.exact && !widget.isObject) ...[
              LdDivider(),
              LdText.ls(
                _isArray ? 'Allowed arrays (OR)' : 'Allowed values',
                color: theme.textMuted,
              ),
              if (_isArray)
                _buildArrayAlternativesEditor(context, theme)
              else ...[
                if (_values.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < _values.length; i++)
                        LdTag(
                          child: Text('${_values[i]}'),
                          onDismiss: () {
                            final next = List<Object?>.from(_values)
                              ..removeAt(i);
                            _setValues(next);
                          },
                        ),
                    ],
                  ),
                _buildScalarValueEditor(context),
              ],
            ],
            if (_mode == LdToolAllowPinMode.exact && widget.isObject)
              LdText.p(
                'Nested fields are edited below this row.',
                size: LdSize.s,
                color: theme.textMuted,
              ),
          ],
        ).padM(),
      ),
    );
  }

  List<List<Object?>> get _arrayAlternatives {
    if (_values.isEmpty) {
      return [];
    }
    return [
      for (final value in _values)
        if (value is List) List<Object?>.from(value) else <Object?>[value],
    ];
  }

  void _setArrayAlternatives(List<List<Object?>> alts) {
    if (alts.isEmpty) {
      setState(() => _values = []);
      _setMode(LdToolAllowPinMode.notAllowed);
      return;
    }
    _setValues([for (final alt in alts) List<Object?>.from(alt)]);
  }

  Widget _buildArrayAlternativesEditor(BuildContext context, LdTheme theme) {
    final alts = _arrayAlternatives;
    final itemKind = widget.itemKind == LdToolAllowValueKind.unknown
        ? LdToolAllowValueKind.string
        : widget.itemKind;

    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LdText.p(
          'Each block is one allowed array. The call matches if it equals any block.',
          size: LdSize.s,
          color: theme.textMuted,
        ),
        for (var altIndex = 0; altIndex < alts.length; altIndex++)
          _ArrayAlternativeCard(
            index: altIndex,
            elements: alts[altIndex],
            itemKind: itemKind,
            enumOptions: widget.enumOptions,
            onChanged: (elements) {
              final next = <List<Object?>>[
                for (var i = 0; i < alts.length; i++)
                  if (i == altIndex) elements else alts[i],
              ];
              _setArrayAlternatives(next);
            },
            onRemove: () {
              final next = <List<Object?>>[
                for (var i = 0; i < alts.length; i++)
                  if (i != altIndex) alts[i],
              ];
              _setArrayAlternatives(next);
            },
          ),
        LdButton.outline(
          size: LdSize.s,
          width: double.infinity,
          leading: Icon(LucideIcons.plus),
          onPressed: () {
            _setArrayAlternatives([...alts, <Object?>[]]);
          },
          child: Text('Add allowed array'),
        ),
      ],
    );
  }

  Widget _buildScalarValueEditor(BuildContext context) {
    if (widget.kind == LdToolAllowValueKind.boolean) {
      return Row(
        children: [
          for (final value in [true, false])
            LdButton.outline(
              size: LdSize.s,
              onPressed: () {
                if (!_values.contains(value)) {
                  _setValues([..._values, value]);
                }
              },
              child: Text('$value'),
            ),
        ],
      ).spaceS();
    }

    if (widget.enumOptions.isNotEmpty) {
      return LdAutoSpace(
        children: [
          for (final option in widget.enumOptions)
            LdButton.outline(
              size: LdSize.s,
              width: double.infinity,
              onPressed: () {
                if (!_values.contains(option)) {
                  _setValues([..._values, option]);
                }
              },
              child: Text('$option'),
            ),
        ],
      );
    }

    final kind = widget.kind;
    return Row(
      children: [
        Expanded(
          child: LdInput(
            size: LdSize.s,
            hint: 'Add value',
            controller: _draftController,
            keyboardType: switch (kind) {
              LdToolAllowValueKind.integer ||
              LdToolAllowValueKind.number => TextInputType.number,
              _ => TextInputType.text,
            },
            onSubmitted: (_) {
              final parsed = _parseDraft(_draftController.text, kind: kind);
              if (parsed == null) {
                return;
              }
              if (!_values.contains(parsed)) {
                _setValues([..._values, parsed]);
              }
              _draftController.clear();
            },
          ),
        ),
        LdButton.ghost(
          size: LdSize.s,
          onPressed: () {
            final parsed = _parseDraft(_draftController.text, kind: kind);
            if (parsed == null) {
              return;
            }
            if (!_values.contains(parsed)) {
              _setValues([..._values, parsed]);
            }
            _draftController.clear();
          },
          child: Icon(LucideIcons.plus),
        ),
      ],
    ).spaceS();
  }
}

class _ArrayAlternativeCard extends StatefulWidget {
  const _ArrayAlternativeCard({
    required this.index,
    required this.elements,
    required this.itemKind,
    required this.enumOptions,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final List<Object?> elements;
  final LdToolAllowValueKind itemKind;
  final List<Object?> enumOptions;
  final ValueChanged<List<Object?>> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ArrayAlternativeCard> createState() => _ArrayAlternativeCardState();
}

class _ArrayAlternativeCardState extends State<_ArrayAlternativeCard> {
  final _draftController = TextEditingController();

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  Object? _parseDraft(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return switch (widget.itemKind) {
      LdToolAllowValueKind.boolean =>
        trimmed.toLowerCase() == 'true'
            ? true
            : trimmed.toLowerCase() == 'false'
            ? false
            : null,
      LdToolAllowValueKind.integer => int.tryParse(trimmed),
      LdToolAllowValueKind.number => num.tryParse(trimmed),
      _ => trimmed,
    };
  }

  void _add(Object? value) {
    if (value == null || widget.elements.contains(value)) {
      return;
    }
    widget.onChanged([...widget.elements, value]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Container(
      padding: theme.pad(size: LdSize.s),
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: theme.radius(LdSize.s),
      ),
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.elements.isEmpty)
            LdText.p('Empty array []', size: LdSize.s, color: theme.textMuted)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < widget.elements.length; i++)
                  LdTag(
                    child: Text('${widget.elements[i]}'),
                    onDismiss: () {
                      final next = List<Object?>.from(widget.elements)
                        ..removeAt(i);
                      widget.onChanged(next);
                    },
                  ),
              ],
            ),
          if (widget.enumOptions.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final option in widget.enumOptions)
                  LdButton.outline(
                    size: LdSize.s,
                    onPressed: () => _add(option),
                    child: Text('$option'),
                  ),
              ],
            )
          else if (widget.itemKind == LdToolAllowValueKind.boolean)
            Row(
              children: [
                for (final value in [true, false])
                  LdButton.outline(
                    size: LdSize.s,
                    onPressed: () => _add(value),
                    child: Text('$value'),
                  ),
              ],
            ).spaceS()
          else
            Row(
              children: [
                Expanded(
                  child: LdInput(
                    size: LdSize.s,
                    hint: switch (widget.itemKind) {
                      LdToolAllowValueKind.integer => 'Add integer',
                      LdToolAllowValueKind.number => 'Add number',
                      _ => 'Add string',
                    },
                    controller: _draftController,
                    keyboardType: switch (widget.itemKind) {
                      LdToolAllowValueKind.integer ||
                      LdToolAllowValueKind.number => TextInputType.number,
                      _ => TextInputType.text,
                    },
                    onSubmitted: (_) {
                      _add(_parseDraft(_draftController.text));
                      _draftController.clear();
                    },
                  ),
                ),
                LdButton.ghost(
                  size: LdSize.s,
                  onPressed: () {
                    _add(_parseDraft(_draftController.text));
                    _draftController.clear();
                  },
                  child: Icon(LucideIcons.plus),
                ),
                LdButton.ghost(
                  size: LdSize.s,
                  onPressed: widget.onRemove,
                  child: Icon(LucideIcons.trash2),
                ),
              ],
            ).spaceS(),
        ],
      ),
    );
  }
}
