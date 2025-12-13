import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAppBarAction extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
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
    return LdButton(
      active: active,
      onPressed: onPressed,
      disabled: disabled,
      loading: loading,
      loadingText: loadingText,
      color: color,
      leading: isMobile && preferLeadingOnMobile ? null : leading,
      trailing: trailing,
      child: isMobile && preferLeadingOnMobile && leading != null ? leading! : child,
    );
  }
}
