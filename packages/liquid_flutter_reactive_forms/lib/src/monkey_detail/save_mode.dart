/// How [LdMonkeyReactiveDetailForm] persists edits.
enum LdReactiveFormSaveMode {
  /// Save on blur / field commit only; no submit button.
  onBlur,

  /// Explicit save button appended below the children when dirty and valid.
  manualSubmit,

  /// [onBlur] on mobile, [manualSubmit] on desktop.
  adaptive,

  /// No automatic save and no built-in submit button.
  ///
  /// The caller is responsible for placing their own save trigger (e.g. a
  /// button in an app bar) and driving saving via
  /// [LdMonkeyDetailFormScope.of(context).save].
  /// Blur-save hooks are disabled — [LdMonkeyDetailFormFieldHooks.onBlurred]
  /// and [LdMonkeyDetailFormFieldHooks.onCommitted] return null.
  custom,
}
