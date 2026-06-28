/// How [LdMonkeyReactiveDetailForm] persists edits.
enum LdMonkeyDetailSaveMode {
  /// Save on blur / field commit only; no submit button.
  onBlur,

  /// Explicit save button when the form is dirty and valid.
  manualSubmit,

  /// [onBlur] on mobile, [manualSubmit] on desktop.
  adaptive,
}
