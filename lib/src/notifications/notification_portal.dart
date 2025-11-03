import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:collection/collection.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:liquid_flutter/src/notifications/radius_aware_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LdNotificationProvider extends StatelessWidget {
  final Widget child;
  final LdNotificationsController? notifier;

  const LdNotificationProvider({required this.child, this.notifier, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifier != null) {
      return ChangeNotifierProvider.value(value: notifier, child: child);
    }
    return ChangeNotifierProvider<LdNotificationsController>(
      create: (_) => LdNotificationsController(),
      child: child,
    );
  }
}

class LdNotificationPortal extends StatelessWidget {
  const LdNotificationPortal({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<LdNotificationsController>(
      child: child,
      builder: (context, notifier, child) {
        final hasBigNotification = notifier.notifications.any(
          (e) => e.showBackdrop,
        );
        final theme = LdTheme.of(context, listen: true);
        return Stack(
          children: [
            child!,
            if (hasBigNotification) ...[
              Positioned.fill(
                  child: Container(
                color: theme.palette.neutral.shades.last.withAlpha(50),
              )),
              ModalBarrier(
                dismissible: true,
                onDismiss: () => notifier.onDismissNotification(
                  notifier.notifications.lastWhere(
                    (element) => element.showBackdrop,
                  ),
                ),
              ),
            ],
            ImplicitBlur(
              key: const ValueKey("notification-portal"),
              sigma: hasBigNotification ? 10 : 0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.paddingOf(context).left + theme.pad(size: LdSize.m).left,
                    right: MediaQuery.paddingOf(context).right + theme.pad(size: LdSize.m).right,
                    bottom: MediaQuery.paddingOf(context).bottom + theme.pad(size: LdSize.m).bottom,
                  ),
                  child: Stack(
                    children: notifier.notifications.mapIndexed((
                      index,
                      notification,
                    ) {
                      return LdNotificationWidget(
                        key: notification.key,
                        index: notifier.notifications.length - index - 1,
                        notification: notification,
                        removing: notification.removing,
                        didConfirm: notification.didConfirm,
                        onDismiss: () {
                          notifier.onDismissNotification(notification);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class LdNotificationWidget extends StatelessWidget {
  final LdNotification notification;
  final int index;
  final bool removing;
  final bool didConfirm;
  final VoidCallback onDismiss;

  const LdNotificationWidget({
    super.key,
    required this.notification,
    this.removing = false,
    this.didConfirm = false,
    this.index = 0,
    required this.onDismiss,
  });

  LdColor _colorBundle(BuildContext context) {
    if (notification.color != null) {
      return notification.color!;
    }
    final theme = LdTheme.of(context, listen: true);

    if (didConfirm) {
      return theme.palette.success;
    }

    switch (notification.type) {
      case LdNotificationType.loading:
      case LdNotificationType.acknowledge:
      case LdNotificationType.info:
        return theme.palette.primary;
      case LdNotificationType.success:
        return theme.palette.success;
      case LdNotificationType.warning:
        return theme.palette.warning;
      case LdNotificationType.error:
        return theme.palette.error;
    }
  }

  LdTheme _theme(BuildContext context) => LdTheme.of(context, listen: true);

  Widget _icon(BuildContext context) {
    final size = _theme(context).labelSize(LdSize.s);

    if (didConfirm) {
      return const LdIndicator(type: LdIndicatorType.success);
    }

    if (notification.type == LdNotificationType.loading) {
      return LdLoader(size: size * 2);
    }

    return LdIndicator(
        type: switch (notification.type) {
      LdNotificationType.info => LdIndicatorType.info,
      LdNotificationType.success => LdIndicatorType.success,
      LdNotificationType.warning => LdIndicatorType.warning,
      LdNotificationType.error => LdIndicatorType.error,
      _ => LdIndicatorType.info,
    });
  }

  Widget _buildAcknowledgeButton(BuildContext context) {
    final notification = this.notification as LdAcknowledgeNotification;

    final ackText = notification.acknowledgeText ?? LiquidLocalizations.of(context).ok;
    return LdButton(
      key: notification.dismissKey,
      autoFocus: true,
      child: Text(ackText),
      onPressed: onDismiss,
      width: double.infinity,
    );
  }

  Widget _buildNotificationBody(BuildContext context) {
    final isTextOnly = notification is! LdAcknowledgeNotification;

    final theme = _theme(context);

    return RadiusAwarePadding(
      fallbackSize: LdSize.l,
      innerRadiusSize: isTextOnly ? LdSize.m : LdSize.s,
      decoration: BoxDecoration(
        color: _theme(context).background,
        boxShadow: [ldShadowSticky],
        border: Border.all(
          color: LdTheme.of(context).border,
          width: LdTheme.of(context).borderWidth,
        ),
      ),
      child: LdAutoSpace(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: _theme(context).pad(size: LdSize.xs),
                child: _icon(context),
              ).animate().fade(delay: 200.ms),
              ldSpacerM,
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    child: LdAutoSpace(
                      children: [
                        // Text of the notification
                        LdText.p(
                          notification.message,
                          overflow: TextOverflow.fade,
                        ),
                        if (notification.subMessage != null)
                          LdText.ps(notification.subMessage!,
                              overflow: TextOverflow.fade, color: _theme(context).textMuted),
                      ],
                    ),
                  ),
                  ldSpacerM,
                  if (notification.canDismiss && notification is! LdAcknowledgeNotification)
                    // Dismiss button
                    LdButton.ghost(
                      color: _colorBundle(context),
                      onPressed: onDismiss,
                      child: const Icon(LucideIcons.x),
                    ).animate().fade(delay: 400.ms)
                ],
              )),
            ],
          ),
          if (notification is LdAcknowledgeNotification) _buildAcknowledgeButton(context),
        ],
      ),
    ).animate().shimmer(
          duration: 500.ms,
          color: _colorBundle(context).hover(theme.isDark),
        );
  }

  @override
  Widget build(BuildContext context) {
    double yOffset = index * 10;

    if (removing) {
      yOffset = 100;
    }

    return LdSpring(
        initialPosition: 0,
        position: 1 - index * 0.1,
        child: _buildNotificationBody(context),
        builder: (context, state, child) {
          return LdSpring(
              initialPosition: 0,
              position: yOffset,
              child: child,
              builder: (context, yOffset, child) {
                return Transform.translate(
                  offset: Offset(0, yOffset.position),
                  child: Transform.scale(
                    scale: state.position,
                    child: child,
                  ),
                );
              });
        });
  }
}
