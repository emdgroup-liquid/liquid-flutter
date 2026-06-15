/// How the monkey master list responds to item taps.
enum LdMonkeyInteractionMode {
  /// Single tap opens detail ([LdMonkeySelection.updateViewing]); multi-select
  /// uses selection controls.
  browse,

  /// Selection only — never navigates to detail. Used by pickers such as
  /// [LdMonkeyPickerScope].
  pick,
}
