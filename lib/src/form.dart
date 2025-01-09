import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

/// Hint for a form field
class LdFormHint {
  String hint;
  LdHintType type;
  LdFormHint(this.hint, this.type);
}

/// A form item in a [LdForm]
class LdFormItem {
  final Widget child;
  final String key;
  LdFormItem(this.key, this.child);
}

/// Liquid Design Form that wraps a [Form] widget
class LdForm extends StatefulWidget {
  final List<LdFormItem> fields;

  final bool loading;
  final bool disabled;

  final String? submitString;
  final LdButtonMode submitButtonMode;

  final Map<String, LdFormHint> hints;

  final Future<void> Function()? onSubmit;

  const LdForm({
    required this.fields,
    this.disabled = false,
    this.hints = const {},
    this.loading = false,
    this.onSubmit,
    this.submitButtonMode = LdButtonMode.filled,
    this.submitString,
    super.key,
  });

  @override
  State<LdForm> createState() => _LdFormState();
}

class _LdFormState extends State<LdForm> {
  bool _loading = false;

  Widget _buildHint(String key) {
    if (widget.hints.containsKey(key)) {
      return LdHint(
          child: Text(widget.hints[key]!.hint), type: widget.hints[key]!.type);
    }
    return Container(
      height: 28,
    );
  }

  Widget _buildField(LdFormItem field) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child:
          LdAutoSpace(crossAxisAlignment: CrossAxisAlignment.start, children: [
        field.child,
        LdCollapse(
            collapsed: !widget.hints.containsKey(field.key),
            child: _buildHint(field.key)),
      ]),
    );
  }

  @override
  void didUpdateWidget(covariant LdForm oldWidget) {
    if (widget.disabled) {
      FocusScope.of(context).unfocus();
    }

    super.didUpdateWidget(oldWidget);
  }

  Widget _buildSubmit(BuildContext context) {
    if (widget.onSubmit == null) {
      return Container();
    }
    return _buildField(LdFormItem(
        "submit",
        LdButton(
          child: Text(
              widget.submitString ?? LiquidLocalizations.of(context).submit),
          mode: widget.submitButtonMode,
          loading: widget.loading || _loading,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            setState(() {
              _loading = true;
            });
            await widget.onSubmit!();

            setState(() {
              _loading = false;
            });
          },
        )));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: widget.disabled,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1,
          child: Form(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                ...widget.fields.map(_buildField).toList(),
                _buildSubmit(context)
              ])),
        ));
  }
}
