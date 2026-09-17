import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A tappable action row used by the file and location tabs
/// (e.g. "Select from Files", "Scan Document", "Send My Current Location").
class LdAttachmentActionTile extends StatelessWidget {
  const LdAttachmentActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LdCard(
      padding: EdgeInsets.zero,
      child: LdListItem(
        leading: LdAvatar(child: Icon(icon)),
        title: LdText.l(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null
            ? null
            : LdText.ps(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: trailing,
        onPressed: onTap,
      ),
    );
  }
}
