import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// An action button designed for use in app bars that adapts its appearance based on context.
///
/// This widget automatically detects whether it's being rendered in the main app bar or in
/// an overflow menu (context menu) and adjusts its appearance accordingly:
///
/// - **In the app bar**: Renders as a [LdButton] with the provided [child], [leading],
///   and [trailing] widgets. On mobile devices, if [preferLeadingOnMobile] is true and a
///   [leading] widget is provided, the leading icon replaces the child text to save space.
///
/// - **In the overflow menu**: Renders as a [LdListItem] with a more compact list item
///   appearance. The leading widget (if provided) is wrapped in an [LdAvatar], and the
///   [child] becomes the list item title. If [loading] is true, a loading indicator
///   is shown in the avatar, and [loadingText] (if provided) appears as the subtitle.
///
/// Actions that overflow from the app bar are automatically moved to the overflow menu
/// by the app bar's overflow handling system.
///
/// See also:
/// - [LdAppBar] for the app bar that hosts these actions
class LdAppBarAction extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final String? tooltip;
  final Widget child;
  final bool active;
  final FutureOr<void> Function() onPressed;
  final bool preferLeadingOnMobile;
  final bool disabled;
  final String? loadingText;
  final LdColor? color;

  final bool loading;

  const LdAppBarAction({
    super.key,
    this.leading,
    this.trailing,
    this.tooltip,
    this.active = false,
    this.preferLeadingOnMobile = true,
    this.disabled = false,
    this.color,
    this.loadingText,
    this.loading = false,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final modalRoute = ModalRoute.of(context);

    final isMobile = LdTheme.of(context).platform.isMobile;

    final isInContextMenu = modalRoute != null && modalRoute is LdContextMenuRoute;
    if (isInContextMenu) {
      return LdListItem(
        color: color,
        padding: LdTheme.of(context).pad(size: LdSize.s),
        active: active,
        disabled: disabled,
        leading: loading
            ? const LdAvatar(
                child: LdLoader(),
                size: LdSize.s,
              )
            : (leading != null
                ? LdAvatar(
                    child: leading!,
                    size: LdSize.s,
                  )
                : null),
        title: child,
        onPressed: onPressed,
        subtitle: loadingText != null && loading ? Text(loadingText!) : null,
      );
    }
    return LdWrapConditional(
      condition: tooltip != null,
      builder: (context, child) => Tooltip(
        message: tooltip!,
        child: child,
      ),
      child: LdButton(
        active: active,
        onPressed: onPressed,
        disabled: disabled,
        loading: loading,
        loadingText: loadingText,
        color: color,
        leading: isMobile && preferLeadingOnMobile ? null : leading,
        trailing: trailing,
        child: isMobile && preferLeadingOnMobile && leading != null ? leading! : child,
      ),
    );
  }
}
