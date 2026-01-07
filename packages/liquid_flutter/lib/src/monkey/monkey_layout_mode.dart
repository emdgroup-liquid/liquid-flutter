/// Defines the layout behavior of the master-detail interface.
enum LdMonkeyLayoutMode {
  /// Automatically switch between side-by-side and stacked layouts based on screen size.
  auto,

  /// Always display in side-by-side layout regardless of screen size.
  sideBySide,

  /// Always display in stacked layout regardless of screen size.
  neverSideBySide,
}
