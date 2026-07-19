import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart'
    hide LdForm;
import 'package:provider/provider.dart';

/// A reactive markdown editor field that binds to a [FormControl<String>] by
/// [formKey].
///
/// Wraps [LdMarkdownEditor] — a live WYSIWYG markdown editor in the style of
/// Typora / Obsidian.
///
/// Place this inside a [ReactiveForm] / [LdForm] widget tree.
/// The corresponding [LdReactiveFormItem] with the same [formKey] must be
/// present in the parent form's [items] list.
class LdFormMarkdownEditor extends StatelessWidget {
  final String formKey;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool? disabled;
  final bool expands;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  final void Function(String url, String title)? onLinkTap;
  final void Function(String tag)? onHashtagTap;
  final Widget? Function(String src, String alt)? imageBuilder;

  final LdHint? Function(ReactiveFormFieldState<String, String>)? hintBuilder;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const LdFormMarkdownEditor({
    super.key,
    required this.formKey,
    this.hintText,
    this.minLines,
    this.maxLines,
    this.disabled,
    this.expands = false,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.textInputAction = TextInputAction.newline,
    this.inputFormatters,
    this.onLinkTap,
    this.onHashtagTap,
    this.imageBuilder,
    this.hintBuilder,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<LdFormState?>();
    return ReactiveFormField<String, String>(
      formControlName: formKey,
      validationMessages: validationMessages ?? {},
      showErrors: ldReactiveFormShowErrors,
      builder: (state) => ldBuildFormFieldChrome(
        state: state,
        formKey: formKey,
        hintBuilder: hintBuilder,
        context: context,
        field: _LdFormMarkdownEditorField(
          state: state,
          hintText: hintText,
          minLines: minLines,
          maxLines: maxLines,
          expands: expands,
          disabled: disabled,
          autofocus: autofocus,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onLinkTap: onLinkTap,
          onHashtagTap: onHashtagTap,
          imageBuilder: imageBuilder,
          onBlurred: (value) => scope?.onFieldBlurred(formKey),
          onCommitted: (value) => scope?.onFieldCommitted(formKey),
        ),
      ),
    );
  }
}

class _LdFormMarkdownEditorField extends StatefulWidget {
  final ReactiveFormFieldState<String, String> state;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final bool? disabled;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String url, String title)? onLinkTap;
  final void Function(String tag)? onHashtagTap;
  final Widget? Function(String src, String alt)? imageBuilder;
  final void Function(String value)? onBlurred;
  final void Function(String value)? onCommitted;

  const _LdFormMarkdownEditorField({
    required this.state,
    this.hintText,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.disabled,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.textInputAction = TextInputAction.newline,
    this.inputFormatters,
    this.onLinkTap,
    this.onHashtagTap,
    this.imageBuilder,
    this.onBlurred,
    this.onCommitted,
  });

  @override
  State<_LdFormMarkdownEditorField> createState() =>
      _LdFormMarkdownEditorFieldState();
}

class _LdFormMarkdownEditorFieldState
    extends State<_LdFormMarkdownEditorField> {
  late final LdMarkdownEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller =
        LdMarkdownEditingController(text: widget.state.control.value ?? '');
  }

  @override
  void didUpdateWidget(covariant _LdFormMarkdownEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.state.control.value ?? '';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onBlurred?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.state.control;
    return LdMarkdownEditor(
      controller: _controller,
      focusNode: _focusNode,
      hintText: widget.hintText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      disabled: widget.disabled != true && control.disabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onLinkTap: widget.onLinkTap,
      onHashtagTap: widget.onHashtagTap,
      imageBuilder: widget.imageBuilder,
      onChanged: (value) {
        final modelValue = widget.state.control.value ?? '';
        if (value != modelValue) {
          widget.state.didChange(value);
        }
      },
      onSubmitted: (value) {
        widget.onCommitted?.call(value);
      },
    );
  }
}
