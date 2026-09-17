import 'package:flutter/widgets.dart';

import 'attachment_services.dart';

/// Provides an [LdAttachmentServices] bundle to the widget subtree.
///
/// Precedence when the picker resolves its services:
/// 1. an explicit `services` argument on the picker / `showLdAttachmentPicker`,
/// 2. the nearest [LdAttachmentServicesScope],
/// 3. [LdAttachmentServices.native].
class LdAttachmentServicesScope extends InheritedWidget {
  const LdAttachmentServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final LdAttachmentServices services;

  static LdAttachmentServices? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LdAttachmentServicesScope>()
      ?.services;

  static LdAttachmentServices of(BuildContext context) =>
      maybeOf(context) ?? LdAttachmentServices.native();

  @override
  bool updateShouldNotify(LdAttachmentServicesScope oldWidget) =>
      !identical(services, oldWidget.services);
}
