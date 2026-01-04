import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:collection/collection.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LdNotificationProvider extends StatelessWidget {
  final Widget child;
  final LdNotificationsController? notifier;
  final String? debugLabel;
  const LdNotificationProvider({required this.child, this.notifier, this.debugLabel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifier != null) {
      return ChangeNotifierProvider.value(value: notifier, child: child);
    }
    return ChangeNotifierProvider<LdNotificationsController>(
      create: (_) => LdNotificationsController(debugLabel: debugLabel),
      child: child,
    );
  }
}

class LdNotificationPortal extends StatelessWidget {
  final String? debugLabel;
  const LdNotificationPortal({super.key, required this.child, this.debugLabel});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<LdNotificationsController>(
      child: child,
      builder: (context, notifier, child) {
        final theme = LdTheme.of(context, listen: true);
        return Stack(
          children: [
            Positioned.fill(child: child!),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.paddingOf(context).left + theme.pad(size: LdSize.m).left,
                  right: MediaQuery.paddingOf(context).right + theme.pad(size: LdSize.m).right,
                  bottom: MediaQuery.paddingOf(context).bottom + theme.pad(size: LdSize.m).bottom,
                ),
                child: LdContainer(
                  maxWidth: theme.sizingConfig.containerMaxWidth / 2,
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
    final theme = _theme(context);

    return Container(
      padding: theme.pad(size: LdSize.m),
      decoration: BoxDecoration(
        color: _theme(context).surface,
        boxShadow: [ldShadowSticky],
        border: Border.all(
          color: LdTheme.of(context).floatingBorder,
          width: LdTheme.of(context).borderWidth,
        ),
        borderRadius: theme.radius(LdSize.l),
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
                  )),
                  ldSpacerM,
                  if (notification.canDismiss && notification is! LdAcknowledgeNotification)
                    // Dismiss button
                    LdButton.ghost(
                      color: _colorBundle(context),
                      onPressed: onDismiss,
                      child: const Icon(LucideIcons.x),
                    ).animate().fade(delay: 400.ms)
                ],
              )).animate().fade(delay: 300.ms),
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
          },
        );
      },
    );
  }
}
