import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A compact centered empty state for a picker tab.
class LdAttachmentEmptyState extends StatelessWidget {
  const LdAttachmentEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;

  /// Optional action shown below the message (e.g. "Allow access").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: LdTheme.of(context).pad(size: LdSize.l),
        child: LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LdAvatar(child: Icon(icon)),
            LdText.p(message, textAlign: TextAlign.center, maxLines: 3),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
