import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldMultipleChoice = CatalogItem(
  name: 'LdMultipleChoice',
  dataSchema: ldMultipleChoiceSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final options = objectList(d['options']);
    final selectedRef = d['selected'];
    final path =
        bindingPath(selectedRef, '${ctx.id}.selected') ?? '${ctx.id}.selected';

    if (selectedRef is String) {
      ctx.dataContext.update(DataPath(path), selectedRef);
    }

    return BoundString(
      dataContext: ctx.dataContext,
      value: {'path': path},
      builder: (context, selected) {
        return _MultipleChoice(
          catalogContext: ctx,
          label: d['label'] as String?,
          description: d['description'] as String?,
          options: options,
          selected: selected,
          path: path,
          layout: d['layout'] as String? ?? 'radio',
          allowCustom: d['allowCustom'] as bool? ?? false,
          customLabel: d['customLabel'] as String?,
          customHint: d['customHint'] as String? ?? 'Enter your own…',
          submitLabel: d['submitLabel'] as String? ?? 'Submit',
        );
      },
    );
  },
);

class _MultipleChoice extends StatefulWidget {
  final CatalogItemContext catalogContext;
  final String? label;
  final String? description;
  final List<JsonMap> options;
  final String? selected;
  final String path;
  final String layout;
  final bool allowCustom;
  final String? customLabel;
  final String customHint;
  final String submitLabel;

  const _MultipleChoice({
    required this.catalogContext,
    required this.label,
    required this.description,
    required this.options,
    required this.selected,
    required this.path,
    required this.layout,
    required this.allowCustom,
    required this.customLabel,
    required this.customHint,
    required this.submitLabel,
  });

  @override
  State<_MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<_MultipleChoice> {
  late final TextEditingController _customCtrl;

  Set<String> get _optionValues => widget.options
      .map((o) => o['value'] as String?)
      .whereType<String>()
      .toSet();

  /// Custom text wins whenever the input is non-empty.
  bool get _isCustomSelected =>
      widget.allowCustom && _customCtrl.text.trim().isNotEmpty;

  String? get _effectiveSelection {
    if (_isCustomSelected) return _customCtrl.text.trim();
    final selected = widget.selected;
    if (selected == null || selected.isEmpty) return null;
    return selected;
  }

  @override
  void initState() {
    super.initState();
    _customCtrl = TextEditingController();
    _syncFromSelected(widget.selected);
  }

  @override
  void didUpdateWidget(covariant _MultipleChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _syncFromSelected(widget.selected);
    }
  }

  void _syncFromSelected(String? selected) {
    if (!widget.allowCustom) return;
    final isCustom =
        selected != null &&
        selected.isNotEmpty &&
        !_optionValues.contains(selected);
    final next = isCustom ? selected : '';
    if (_customCtrl.text == next) return;
    _customCtrl.text = next;
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _selectOption(String value) {
    if (_customCtrl.text.isNotEmpty) {
      _customCtrl.clear();
    }
    widget.catalogContext.dataContext.update(DataPath(widget.path), value);
    setState(() {});
  }

  void _onCustomChanged(String value) {
    final trimmed = value.trim();
    widget.catalogContext.dataContext.update(DataPath(widget.path), trimmed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        if (widget.label != null) LdText.h(widget.label!),
        if (widget.description != null) LdText.p(widget.description!),
        ldSpacerL,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._buildOptions()],
        ).spaceS(),

        if (widget.allowCustom) ...[ldSpacerL, ldSpacerL, _buildCustom()],
        LdDivider(),
        Align(
          alignment: Alignment.centerRight,
          child: LdButton(
            mode: LdButtonMode.filled,
            size: LdSize.l,
            disabled: _effectiveSelection == null,
            onPressed: () {
              final selected = _effectiveSelection;
              if (selected == null) return;
              widget.catalogContext.dispatchEvent(
                UserActionEvent(
                  name: 'multipleChoiceSubmit',
                  sourceComponentId: widget.catalogContext.id,
                  timestamp: DateTime.now(),
                  context: {'selected': selected},
                ),
              );
            },
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOptions() {
    return switch (widget.layout) {
      'chips' => [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final opt in widget.options) _chip(opt)],
        ),
      ],
      'list' => [
        LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [for (final opt in widget.options) _listOption(opt)],
          ),
        ),
      ],
      _ => [for (final opt in widget.options) _radio(opt)],
    };
  }

  Widget _radio(JsonMap opt) {
    final val = opt['value'] as String?;
    final lbl = opt['label'] as String?;
    if (val == null || lbl == null) return const SizedBox.shrink();
    return LdRadio(
      label: lbl,
      checked: !_isCustomSelected && val == widget.selected,
      onChanged: (_) => _selectOption(val),
    );
  }

  Widget _chip(JsonMap opt) {
    final val = opt['value'] as String?;
    final lbl = opt['label'] as String?;
    if (val == null || lbl == null) return const SizedBox.shrink();
    final selected = !_isCustomSelected && val == widget.selected;
    return LdButton(
      mode: selected ? LdButtonMode.filled : LdButtonMode.outline,

      onPressed: () => _selectOption(val),
      child: Text(lbl),
    );
  }

  Widget _listOption(JsonMap opt) {
    final val = opt['value'] as String?;
    final lbl = opt['label'] as String?;
    if (val == null || lbl == null) return const SizedBox.shrink();
    final description = opt['description'] as String?;
    final selected = !_isCustomSelected && val == widget.selected;
    return LdListItem(
      title: Text(lbl),
      subtitle: description != null && description.isNotEmpty
          ? Text(description)
          : null,
      selectionControl: LdSelectionControl.radio,
      isSelected: selected,
      onSelectionChanged: (_) => _selectOption(val),
      onPressed: () => _selectOption(val),
    );
  }

  Widget _buildCustom() {
    return LdInput(
      label: widget.customLabel,
      hint: widget.customHint,
      controller: _customCtrl,
      onChanged: _onCustomChanged,
    );
  }
}
