import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'attachment_config.dart';
import 'attachment_custom.dart';
import 'attachment_labels.dart';
import 'attachment_models.dart';
import 'attachment_picker_controller.dart';
import 'attachment_result.dart';
import 'platform/attachment_services.dart';
import 'platform/attachment_services_scope.dart';
import 'tabs/contacts_tab.dart';
import 'tabs/file_tab.dart';
import 'tabs/gallery_tab.dart';
import 'tabs/location_tab.dart';
import 'widgets/empty_state.dart';

/// A rich, Telegram-style attachment picker.
///
/// Presents a gallery tab (live camera + recents), a file tab, a location tab,
/// and a contacts tab, depending on [LdAttachmentPickerConfig.allowedTypes].
/// All native capabilities are resolved through [LdAttachmentServices], so the
/// widget is fully swappable and testable.
class LdAttachmentPicker extends StatefulWidget {
  const LdAttachmentPicker({
    super.key,
    this.services,
    this.config = const LdAttachmentPickerConfig(),
    this.labels = const LdAttachmentPickerLabels(),
    this.onComplete,
  });

  /// Overrides the services bundle. When null, the nearest
  /// [LdAttachmentServicesScope] is used, falling back to the native bundle.
  final LdAttachmentServices? services;

  final LdAttachmentPickerConfig config;
  final LdAttachmentPickerLabels labels;

  /// Called with the final selection, or `null` when dismissed.
  ///
  /// When null, the picker pops its enclosing route with the result.
  final ValueChanged<List<LdPickedAttachment>?>? onComplete;

  @override
  State<LdAttachmentPicker> createState() => _LdAttachmentPickerState();
}

class _LdAttachmentPickerState extends State<LdAttachmentPicker> {
  LdAttachmentPickerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) {
      return;
    }
    final services =
        widget.services ??
        LdAttachmentServicesScope.maybeOf(context) ??
        LdAttachmentServices.native();
    _controller = LdAttachmentPickerController(
      services: services,
      config: widget.config,
      labels: widget.labels,
    )..onComplete = _complete;
  }

  void _complete(List<LdPickedAttachment>? result) {
    final callback = widget.onComplete;
    if (callback != null) {
      callback(result);
      return;
    }
    Navigator.of(context).maybePop(result);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.tabs.isEmpty) {
          return LdScaffold(
            body: LdAttachmentEmptyState(
              icon: LucideIcons.paperclip,
              message: controller.labels.noSources,
            ),
          );
        }

        final content = _buildTab(context, controller);

        return LdScaffold(
          body: LdAppBar.bottom(
            actions: _buildActions(context, controller),
            title: LdCounterText.template(
              "%value% selected",
              value: controller.selectionCount.toDouble(),
            ),
            attachedMode: LdAppBarAttachedMode.floating,
            scrollBehavior: switch (controller.showTabBar) {
              false => LdAppBarScrollBehavior.static,
              true => LdAppBarScrollBehavior.hidden,
            },
            child: LdTabNavigation(
              scrollBehavior: switch (controller.showTabBar) {
                true => LdAppBarScrollBehavior.static,
                false => LdAppBarScrollBehavior.hidden,
              },
              position: LdAppBarPositionMode.bottom,
              tabs: [
                for (final tab in controller.tabs)
                  LdNavigationTab(
                    label: tab.isCustom
                        ? tab.custom!.label
                        : controller.labels.tabLabel(tab.builtIn!),
                    icon: Icon(
                      tab.isCustom ? tab.custom!.icon : _iconFor(tab.builtIn!),
                    ),
                    route: tab.id,
                  ),
              ],
              activeRoute: controller.activeTabId,
              onTabPressed: controller.setActiveTab,
              child: content,
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(LdAttachmentTab tab) => switch (tab) {
    LdAttachmentTab.gallery => LucideIcons.images,
    LdAttachmentTab.file => LucideIcons.file,
    LdAttachmentTab.location => LucideIcons.mapPin,
    LdAttachmentTab.contacts => LucideIcons.users,
  };

  List<Widget> _buildActions(
    BuildContext context,
    LdAttachmentPickerController controller,
  ) {
    if (!controller.multiple || !controller.hasSelection) {
      return const [];
    }
    return [
      LdButton.filled(
        key: const ValueKey('ld-attach-confirm'),
        size: LdSize.l,
        onPressed: controller.confirm,
        child: Icon(LucideIcons.check),
      ),
    ];
  }

  Widget _buildTab(
    BuildContext context,
    LdAttachmentPickerController controller,
  ) {
    final tab = controller.activeTab;
    if (tab == null) {
      return LdAttachmentEmptyState(
        icon: LucideIcons.paperclip,
        message: controller.labels.noSources,
      );
    }
    if (tab.isCustom) {
      return tab.custom!.pageBuilder(
        context,
        LdAttachmentCustomController(
          labels: controller.labels,
          pick: controller.pickAndConfirm,
          complete: controller.completeWith,
        ),
      );
    }
    return switch (tab.builtIn!) {
      LdAttachmentTab.gallery => LdGalleryTab(controller: controller),
      LdAttachmentTab.file => LdFileTab(controller: controller),
      LdAttachmentTab.location => LdLocationTab(controller: controller),
      LdAttachmentTab.contacts => LdContactsTab(controller: controller),
    };
  }
}

/// Opens [LdAttachmentPicker] as a modal sheet and resolves to the picked
/// attachments (or `null` when dismissed).
Future<List<LdPickedAttachment>?> showLdAttachmentPicker(
  BuildContext context, {
  LdAttachmentServices? services,
  LdAttachmentPickerConfig config = const LdAttachmentPickerConfig(),
  LdAttachmentPickerLabels labels = const LdAttachmentPickerLabels(),
  bool useRootNavigator = true,
  double topGapRatio = 0.07,
}) {
  return LdModalRoute<List<LdPickedAttachment>?>(
    context: context,
    topGapRatio: topGapRatio,
    barrierDismissible: true,
    pageBuilder: (modalContext) => LdAttachmentPicker(
      services: services,
      config: config,
      labels: labels,
      onComplete: (result) => Navigator.of(modalContext).pop(result),
    ),
  ).show(context, useRootNavigator: useRootNavigator);
}
