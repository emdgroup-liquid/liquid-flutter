import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldMultipleChoice = ldCatalogItem(
  name: 'LdMultipleChoice',
  schema: ldMultipleChoiceSchema,
  parse: LdMultipleChoiceData.fromJson,
  builder: (ctx, data) => LdMultipleChoice(catalogContext: ctx, data: data),
);

class LdMultipleChoice extends StatelessWidget {
  const LdMultipleChoice({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdMultipleChoiceData data;

  @override
  Widget build(BuildContext context) {
    final path = writableStringPath(
      data.selected,
      '${catalogContext.id}.selected',
    );

    return bindWritableString(
      catalogContext,
      ref: data.selected,
      fallbackPath: path,
      builder: (context, selected) => _LdMultipleChoiceForm(
        catalogContext: catalogContext,
        data: data,
        selected: selected,
        path: path,
      ),
    );
  }
}

class _LdMultipleChoiceForm extends StatefulWidget {
  const _LdMultipleChoiceForm({
    required this.catalogContext,
    required this.data,
    required this.selected,
    required this.path,
  });

  final CatalogItemContext catalogContext;
  final LdMultipleChoiceData data;
  final String? selected;
  final String path;

  @override
  State<_LdMultipleChoiceForm> createState() => _LdMultipleChoiceFormState();
}

class _LdMultipleChoiceFormState extends State<_LdMultipleChoiceForm> {
  late final TextEditingController _customCtrl;

  LdMultipleChoiceData get _data => widget.data;

  Set<String> get _optionValues => _data.options.map((o) => o.value).toSet();

  /// Custom text wins whenever the input is non-empty.
  bool get _isCustomSelected =>
      _data.allowCustom && _customCtrl.text.trim().isNotEmpty;

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
  void didUpdateWidget(covariant _LdMultipleChoiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _syncFromSelected(widget.selected);
    }
  }

  void _syncFromSelected(String? selected) {
    if (!_data.allowCustom) return;
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
        if (_data.label != null) LdText.h(_data.label!),
        if (_data.description != null) LdText.p(_data.description!),
        ldSpacerL,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._buildOptions()],
        ).spaceS(),
        if (_data.allowCustom) ...[ldSpacerL, ldSpacerL, _buildCustom()],
        LdDivider(),
        Align(
          alignment: Alignment.centerRight,
          child: LdButton(
            mode: LdButtonMode.filled,
            size: LdSize.l,
            disabled: _effectiveSelection == null,
            onPressed: _submit,
            child: Text(_data.submitLabel),
          ),
        ),
      ],
    );
  }

  void _submit() {
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
  }

  List<Widget> _buildOptions() {
    return switch (_data.layout) {
      LdMultipleChoiceLayout.chips => [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final opt in _data.options) _chip(opt)],
        ),
      ],
      LdMultipleChoiceLayout.list => [
        LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [for (final opt in _data.options) _listOption(opt)],
          ),
        ),
      ],
      LdMultipleChoiceLayout.radio => [
        for (final opt in _data.options) _radio(opt),
      ],
    };
  }

  Widget _radio(LdLabeledOption opt) {
    return LdRadio(
      label: opt.label,
      checked: !_isCustomSelected && opt.value == widget.selected,
      onChanged: (_) => _selectOption(opt.value),
    );
  }

  Widget _chip(LdLabeledOption opt) {
    final selected = !_isCustomSelected && opt.value == widget.selected;
    return LdButton(
      mode: selected ? LdButtonMode.filled : LdButtonMode.outline,
      onPressed: () => _selectOption(opt.value),
      child: Text(opt.label),
    );
  }

  Widget _listOption(LdLabeledOption opt) {
    final description = opt.description;
    final selected = !_isCustomSelected && opt.value == widget.selected;
    return LdListItem(
      title: Text(opt.label),
      subtitle: description != null && description.isNotEmpty
          ? Text(description)
          : null,
      selectionControl: LdSelectionControl.radio,
      isSelected: selected,
      onSelectionChanged: (_) => _selectOption(opt.value),
      onPressed: () => _selectOption(opt.value),
    );
  }

  Widget _buildCustom() {
    return LdInput(
      label: _data.customLabel,
      hint: _data.customHint,
      controller: _customCtrl,
      onChanged: _onCustomChanged,
    );
  }
}
