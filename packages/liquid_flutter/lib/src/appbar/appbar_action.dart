import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Controls how an [LdAppBarAction] compacts when space in the app bar is tight.
enum LdAppBarActionCompactMode {
  /// Prefer text with a leading icon; fall back to icon-only via [LdOverflowAdaptiveChild].
  auto,

  /// Always render icon-only when [LdAppBarAction.leading] is set.
  always,

  /// Always render text with a leading icon.
  never,
}

/// An action button designed for use in app bars that adapts its appearance based on context.
///
/// This widget automatically detects whether it's being rendered in the main app bar or in
/// an overflow menu (context menu) and adjusts its appearance accordingly:
///
/// - **In the app bar**: Renders as a [LdButton] with the provided [child], [leading],
///   and [trailing] widgets. When [compactMode] is [LdAppBarActionCompactMode.auto] and a
///   [leading] widget is provided, the overflow layout prefers text with the leading icon
///   and falls back to icon-only when the app bar row is tight.
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
  final LdAppBarActionCompactMode compactMode;
  final LdButtonMode? buttonMode;
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
    this.compactMode = LdAppBarActionCompactMode.auto,
    this.disabled = false,
    this.color,
    this.loadingText,
    this.loading = false,
    required this.child,
    this.buttonMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isInContextMenu = context.read<LdAppBarActionDisplayMode?>() == LdAppBarActionDisplayMode.contextMenu;
    if (isInContextMenu) {
      return LdListItem(
        color: color,
        padding: LdTheme.of(context).pad(size: LdSize.s),
        active: active,
        disabled: disabled,
        leading: loading
            ? const LdAvatar(
                size: LdSize.s,
                child: LdLoader(),
              )
            : (leading != null
                ? LdAvatar(
                    size: LdSize.s,
                    child: leading!,
                  )
                : null),
        title: child,
        onPressed: onPressed,
        subtitle: loadingText != null && loading ? Text(loadingText!) : null,
      );
    }

    final useAdaptiveChild = compactMode == LdAppBarActionCompactMode.auto && leading != null;

    if (useAdaptiveChild) {
      return LdOverflowAdaptiveChild(
        expanded: _wrapTooltip(_buildButton(context, compact: false)),
        compact: _wrapTooltip(_buildButton(context, compact: true)),
      );
    }

    return _wrapTooltip(
      _buildButton(
        context,
        compact: compactMode == LdAppBarActionCompactMode.always && leading != null,
      ),
    );
  }

  Widget _wrapTooltip(Widget child) {
    return LdWrapConditional(
      condition: tooltip != null,
      builder: (context, wrappedChild) => Tooltip(
        message: tooltip!,
        child: wrappedChild,
      ),
      child: child,
    );
  }

  Widget _buildButton(BuildContext context, {required bool compact}) {
    return LdButton(
      active: active,
      onPressed: onPressed,
      mode: buttonMode,
      disabled: disabled,
      loading: loading,
      loadingText: loadingText,
      color: color,
      leading: compact ? null : leading,
      trailing: trailing,
      child: compact && leading != null ? leading! : child,
    );
  }
}

enum LdAppBarActionDisplayMode {
  appBar,
  contextMenu,
}
