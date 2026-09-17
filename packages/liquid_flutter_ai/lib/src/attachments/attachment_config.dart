import 'attachment_custom.dart';
import 'attachment_models.dart';

/// A tab shown in the picker's navigation.
///
/// Wraps either a built-in [LdAttachmentTab] or a host-provided
/// [LdAttachmentCustomTab] so both can share the same navigation list.
class LdAttachmentTabSpec {
  const LdAttachmentTabSpec.builtIn(LdAttachmentTab this.builtIn)
    : custom = null;

  const LdAttachmentTabSpec.custom(LdAttachmentCustomTab this.custom)
    : builtIn = null;

  final LdAttachmentTab? builtIn;
  final LdAttachmentCustomTab? custom;

  bool get isCustom => custom != null;

  /// Stable route id, unique across all tabs.
  String get id => builtIn?.name ?? custom!.id;
}

/// Configuration for [LdAttachmentPicker].
class LdAttachmentPickerConfig {
  /// Which attachment kinds are offered. Disabled kinds are omitted from the
  /// tab bar and their entry points are hidden.
  ///
  /// Defaults to all kinds.
  final Set<LdAttachmentKind> allowedTypes;

  /// Which media kinds the gallery tab queries. Defaults to images and videos.
  final Set<LdMediaType> mediaTypes;

  /// Whether the in-picker camera (live preview + capture) is offered.
  final bool cameraEnabled;

  /// Whether "Scan Document" is offered when the platform supports it.
  final bool scanDocumentEnabled;

  /// Whether more than one attachment can be selected at once.
  final bool multiple;

  /// Optional upper bound on the number of selectable attachments.
  final int? maxSelection;

  /// Optional override for the sheet header title.
  final String? title;

  /// Optional override for the number of columns in the gallery grid.
  final int galleryColumns;

  /// Host-provided tabs, appended after the built-in tabs.
  final List<LdAttachmentCustomTab> customTabs;

  const LdAttachmentPickerConfig({
    this.allowedTypes = const {
      LdAttachmentKind.image,
      LdAttachmentKind.video,
      LdAttachmentKind.file,
      LdAttachmentKind.location,
      LdAttachmentKind.contact,
    },
    this.mediaTypes = const {LdMediaType.image, LdMediaType.video},
    this.cameraEnabled = true,
    this.scanDocumentEnabled = true,
    this.multiple = true,
    this.maxSelection,
    this.title,
    this.galleryColumns = 3,
    this.customTabs = const [],
  });

  static const List<LdAttachmentKind> _tabOrder = [
    LdAttachmentKind.image,
    LdAttachmentKind.video,
    LdAttachmentKind.file,
    LdAttachmentKind.location,
    LdAttachmentKind.contact,
  ];

  /// Whether the gallery tab is available.
  bool get galleryEnabled =>
      allowedTypes.contains(LdAttachmentKind.image) ||
      allowedTypes.contains(LdAttachmentKind.video);

  /// The tabs implied by [allowedTypes] plus [customTabs], in order.
  List<LdAttachmentTabSpec> get tabs => [
    if (galleryEnabled)
      const LdAttachmentTabSpec.builtIn(LdAttachmentTab.gallery),
    if (allowedTypes.contains(LdAttachmentKind.file))
      const LdAttachmentTabSpec.builtIn(LdAttachmentTab.file),
    if (allowedTypes.contains(LdAttachmentKind.location))
      const LdAttachmentTabSpec.builtIn(LdAttachmentTab.location),
    if (allowedTypes.contains(LdAttachmentKind.contact))
      const LdAttachmentTabSpec.builtIn(LdAttachmentTab.contacts),
    for (final custom in customTabs) LdAttachmentTabSpec.custom(custom),
  ];

  /// Route id of the tab shown when the picker opens.
  String get initialTabId => tabs.first.id;

  /// Which kinds are allowed inside the gallery tab.
  Set<LdAttachmentKind> get galleryKinds => {
    if (allowedTypes.contains(LdAttachmentKind.image) &&
        mediaTypes.contains(LdMediaType.image))
      LdAttachmentKind.image,
    if (allowedTypes.contains(LdAttachmentKind.video) &&
        mediaTypes.contains(LdMediaType.video))
      LdAttachmentKind.video,
  };

  bool get canSelectMore => multiple;

  int get effectiveMaxSelection => maxSelection ?? (multiple ? 1 << 20 : 1);

  /// The ordered list of enabled kinds, used for deterministic tab logic.
  List<LdAttachmentKind> get enabledKinds =>
      _tabOrder.where(allowedTypes.contains).toList(growable: false);

  LdAttachmentPickerConfig copyWith({
    Set<LdAttachmentKind>? allowedTypes,
    Set<LdMediaType>? mediaTypes,
    bool? cameraEnabled,
    bool? scanDocumentEnabled,
    bool? multiple,
    int? maxSelection,
    String? title,
    int? galleryColumns,
    List<LdAttachmentCustomTab>? customTabs,
  }) {
    return LdAttachmentPickerConfig(
      allowedTypes: allowedTypes ?? this.allowedTypes,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      scanDocumentEnabled: scanDocumentEnabled ?? this.scanDocumentEnabled,
      multiple: multiple ?? this.multiple,
      maxSelection: maxSelection ?? this.maxSelection,
      title: title ?? this.title,
      galleryColumns: galleryColumns ?? this.galleryColumns,
      customTabs: customTabs ?? this.customTabs,
    );
  }
}
