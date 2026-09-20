import 'package:flutter/foundation.dart';

import 'attachment_config.dart';
import 'attachment_labels.dart';
import 'attachment_models.dart';
import 'attachment_result.dart';
import 'platform/attachment_services.dart';

/// State for an [LdAttachmentPicker] session.
///
/// Owns the active tab and the current selection. Tab widgets are otherwise
/// responsible for loading their own data through [services], so this stays
/// small and easy to test.
class LdAttachmentPickerController extends ChangeNotifier {
  LdAttachmentPickerController({
    required this.services,
    required this.config,
    required this.labels,
  }) : _activeTabId = _initialTabId(services, config);

  final LdAttachmentServices services;
  final LdAttachmentPickerConfig config;
  final LdAttachmentPickerLabels labels;

  /// Invoked with the final selection, or `null` when the picker is dismissed.
  ValueChanged<List<LdPickedAttachment>?>? onComplete;

  String _activeTabId;
  String get activeTabId => _activeTabId;

  /// Built-in and custom tabs from [config], minus those the current platform
  /// cannot back (e.g. gallery on Windows, contacts on web).
  List<LdAttachmentTabSpec> get tabs => [
    for (final tab in config.tabs)
      if (_isTabSupported(services, tab)) tab,
  ];

  /// The currently active tab, or the first tab when the id is unknown.
  LdAttachmentTabSpec? get activeTab {
    final visible = tabs;
    if (visible.isEmpty) {
      return null;
    }
    for (final tab in visible) {
      if (tab.id == _activeTabId) {
        return tab;
      }
    }
    return visible.first;
  }

  /// Whether the bottom tab bar should be shown.
  bool get showTabBar => tabs.length > 1 && selectionCount == 0;

  final List<LdPickedAttachment> _selection = [];

  List<LdPickedAttachment> get selection => List.unmodifiable(_selection);

  int get selectionCount => _selection.length;
  bool get hasSelection => _selection.isNotEmpty;
  bool get canSelectMore => _selection.length < config.effectiveMaxSelection;
  bool get multiple => config.multiple;

  int? selectionIndex(String id) {
    final index = _selection.indexWhere((a) => a.id == id);
    return index < 0 ? null : index;
  }

  bool isSelected(String id) => selectionIndex(id) != null;

  void setActiveTab(String id) {
    if (id == _activeTabId) {
      return;
    }
    for (final tab in tabs) {
      if (tab.id == id) {
        _activeTabId = id;
        notifyListeners();
        return;
      }
    }
  }

  /// Toggles [attachment]; returns whether it is now selected.
  bool toggleSelection(LdPickedAttachment attachment) {
    final index = selectionIndex(attachment.id);
    if (index != null) {
      _selection.removeAt(index);
      notifyListeners();
      return false;
    }
    if (!canSelectMore) {
      return false;
    }
    _selection.add(attachment);
    notifyListeners();
    return true;
  }

  /// Handles a tap on a selectable attachment.
  ///
  /// In single-select mode this replaces the selection and completes the
  /// picker immediately; otherwise it toggles.
  void handleTap(LdPickedAttachment attachment) {
    if (!multiple) {
      _selection
        ..clear()
        ..add(attachment);
      notifyListeners();
      confirm();
      return;
    }
    toggleSelection(attachment);
  }

  /// Adds a freshly produced attachment (camera capture, file, location,
  /// contact). In single-select mode this completes the picker immediately.
  void pickAndConfirm(LdPickedAttachment attachment) {
    if (!multiple) {
      _selection
        ..clear()
        ..add(attachment);
      notifyListeners();
      confirm();
      return;
    }
    addSelection(attachment);
  }

  /// Adds [attachment] to the selection if there is room.
  bool addSelection(LdPickedAttachment attachment) {
    if (isSelected(attachment.id) || !canSelectMore) {
      return false;
    }
    _selection.add(attachment);
    notifyListeners();
    return true;
  }

  /// Adds [attachment] (when there is room) and finishes the picker.
  ///
  /// Used by one-shot sources such as a picked location or place, where
  /// choosing an item should immediately resolve the picker even in
  /// multi-select mode.
  void completeWith(LdPickedAttachment attachment) {
    if (!isSelected(attachment.id) && canSelectMore) {
      _selection.add(attachment);
    }
    notifyListeners();
    confirm();
  }

  void removeSelection(String id) {
    final index = selectionIndex(id);
    if (index == null) {
      return;
    }
    _selection.removeAt(index);
    notifyListeners();
  }

  void clearSelection() {
    if (_selection.isEmpty) {
      return;
    }
    _selection.clear();
    notifyListeners();
  }

  /// Completes the picker with the current selection.
  void confirm() {
    onComplete?.call(hasSelection ? List.unmodifiable(_selection) : null);
  }

  /// Dismisses the picker without a result.
  void cancel() => onComplete?.call(null);

  // --- Gallery permission -------------------------------------------------

  LdPermissionState _mediaPermission = LdPermissionState.notDetermined;
  bool _mediaPermissionResolved = false;
  bool _mediaPermissionLoading = false;

  LdPermissionState get mediaPermission => _mediaPermission;

  /// Whether the gallery permission has been checked at least once.
  bool get mediaPermissionResolved => _mediaPermissionResolved;

  bool get mediaPermissionLoading => _mediaPermissionLoading;

  /// Whether the user granted limited access and can manage the selection.
  bool get isLimited =>
      _mediaPermission == LdPermissionState.limited &&
      services.media.supportsLimitedAccess;

  bool get hasMediaAccess =>
      _mediaPermission == LdPermissionState.authorized ||
      _mediaPermission == LdPermissionState.limited;

  /// Reads (and optionally requests) the gallery permission.
  Future<void> loadMediaPermission({bool request = false}) async {
    if (_mediaPermissionLoading) {
      return;
    }
    _mediaPermissionLoading = true;
    notifyListeners();
    try {
      _mediaPermission = request
          ? await services.media.requestPermission()
          : await services.media.permissionState();
      _mediaPermissionResolved = true;
    } catch (error, stackTrace) {
      debugPrint(
        'LdAttachmentPicker: failed to resolve media permission: '
        '$error\n$stackTrace',
      );
      _mediaPermissionResolved = true;
    } finally {
      _mediaPermissionLoading = false;
      notifyListeners();
    }
  }

  /// Presents the system limited-library picker.
  Future<void> presentLimited() async {
    try {
      await services.media.presentLimited();
    } catch (error, stackTrace) {
      debugPrint(
        'LdAttachmentPicker: failed to present limited picker: '
        '$error\n$stackTrace',
      );
    }
  }

  /// Opens the operating system's app settings page.
  Future<void> openSettings() async {
    try {
      await services.permissions.openAppSettings();
    } catch (error, stackTrace) {
      debugPrint(
        'LdAttachmentPicker: failed to open app settings: '
        '$error\n$stackTrace',
      );
    }
  }

  static String _initialTabId(
    LdAttachmentServices services,
    LdAttachmentPickerConfig config,
  ) {
    for (final tab in config.tabs) {
      if (_isTabSupported(services, tab)) {
        return tab.id;
      }
    }
    return '';
  }

  static bool _isTabSupported(
    LdAttachmentServices services,
    LdAttachmentTabSpec tab,
  ) {
    if (tab.isCustom) {
      return true;
    }
    return switch (tab.builtIn!) {
      LdAttachmentTab.gallery => services.media.isSupported,
      LdAttachmentTab.file => true,
      LdAttachmentTab.location => true,
      LdAttachmentTab.contacts => services.contacts.isSupported,
    };
  }
}
