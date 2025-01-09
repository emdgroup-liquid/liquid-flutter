import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:collection/collection.dart';

import 'package:liquid_flutter/src/autospace.dart';
import 'package:liquid_flutter/src/button.dart';
import 'package:liquid_flutter/src/color/color.dart';

import 'package:liquid_flutter/src/indicators.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations.dart';
import 'package:liquid_flutter/src/loading.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:liquid_flutter/src/notifications/notification_input.dart';
import 'package:liquid_flutter/src/notifications/notifications_controller.dart';
import 'package:liquid_flutter/src/notifications/notification.dart';
import 'package:liquid_flutter/src/notifications/notification_type.dart';
import 'package:liquid_flutter/src/spring.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:liquid_flutter/variants.g.dart';
import 'package:provider/provider.dart';

class LdNotificationProvider extends StatelessWidget {
  final Widget child;
  final LdNotificationsController? notifier;

  const LdNotificationProvider({required this.child, this.notifier, Key? key})
      : super(key: key);

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
                  padding: MediaQuery.of(context).viewInsets,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 32.0,
                        left: 8,
                        right: 8,
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
                            onCancel: () {
                              notifier.onCancelledNotification(
                                notification as LdConfirmNotification,
                              );
                            },
                            onConfirm: () {
                              notifier.onConfirmedNotification(
                                notification as LdConfirmNotification,
                              );
                            },
                            onSubmitInput: (result) {
                              notifier.onInputSubmitted(
                                notification as LdInputNotification,
                                result,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
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
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Function(String) onSubmitInput;

  const LdNotificationWidget({
    super.key,
    required this.notification,
    this.removing = false,
    this.didConfirm = false,
    required this.onConfirm,
    required this.onSubmitInput,
    required this.onCancel,
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
      case LdNotificationType.enterText:
      case LdNotificationType.loading:
      case LdNotificationType.acknowledge:
      case LdNotificationType.info:
      case LdNotificationType.confirm:
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

  Widget _buildConfirmationButtons(BuildContext context) {
    final notification = this.notification as LdConfirmNotification;

    final cancelText = notification.cancelText ??
        LiquidLocalizations.of(
          context,
        ).cancel;
    final confirmText = notification.confirmText ??
        LiquidLocalizations.of(
          context,
        ).confirm;
    return Row(
      children: [
        Expanded(
          child: LdButtonOutline(
            disabled: didConfirm,
            key: notification.cancelKey,
            child: Text(cancelText),
            onPressed: onCancel,
          ).animate().fadeIn(delay: 100.ms),
        ),
        ldSpacerS,
        Expanded(
          child: LdButton(
            disabled: didConfirm,
            key: notification.confirmKey,
            child: Text(confirmText),
            onPressed: onConfirm,
          ).animate().fadeIn(delay: 150.ms),
        ),
      ],
    );
  }

  Widget _buildAcknowledgeButton(BuildContext context) {
    final notification = this.notification as LdAcknowledgeNotification;

    final ackText =
        notification.acknowledgeText ?? LiquidLocalizations.of(context).ok;
    return LdButton(
      key: notification.dismissKey,
      child: Text(ackText),
      onPressed: onDismiss,
      width: double.infinity,
    );
  }

  Widget _buildNotificationBody(BuildContext context) {
    final theme = _theme(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [ldShadowSticky],
      ),
      child: Container(
        width: min(
          400,
          MediaQuery.of(context).size.width * 0.9,
        ),
        clipBehavior: Clip.hardEdge,
        padding: _theme(context).pad(size: LdSize.m),
        decoration: BoxDecoration(
            color: _theme(context).surface,
            borderRadius: theme.radius(LdSize.s),
            border: Border.all(
              color: LdTheme.of(context).border,
              width: LdTheme.of(context).borderWidth,
            )),
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
                          LdTextP(
                            notification.message,
                            overflow: TextOverflow.fade,
                          ),
                          if (notification.subMessage != null)
                            LdTextPs(notification.subMessage!,
                                overflow: TextOverflow.fade,
                                color: _theme(context).textMuted),
                        ],
                      ),
                    ),
                    ldSpacerM,
                    if (notification.canDismiss &&
                        notification is! LdAcknowledgeNotification &&
                        notification is! LdConfirmNotification)
                      // Dismiss button
                      LdButtonGhost(
                        color: _colorBundle(context),
                        onPressed: onDismiss,
                        child: const Icon(Icons.clear),
                      ).animate().fade(delay: 400.ms)
                  ],
                )),
              ],
            ),
            // Buttons if the notification is a confirmation
            if (notification is LdConfirmNotification)
              _buildConfirmationButtons(context),
            if (notification is LdAcknowledgeNotification)
              _buildAcknowledgeButton(context),
            if (notification is LdInputNotification)
              NotificationInput(
                notification: notification as LdInputNotification,
                onSubmitted: (result) {
                  onSubmitInput(result);
                },
              )
          ],
        ),
      ).animate().shimmer(
            duration: 500.ms,
            color: _colorBundle(context).hover(theme.isDark),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double yOffset = index * 0.5;

    if (removing) {
      yOffset = 5;
    }

    return LdSpring(
        initialPosition: 0,
        position: removing ? 0 : 1 - index * 0.1,
        builder: (context, state) {
          return LdSpring(
              initialPosition: 0,
              position: yOffset,
              builder: (context, yOffset) {
                return Transform.translate(
                  offset: Offset(0, yOffset.position),
                  child: Transform.scale(
                    scale: state.position,
                    child: _buildNotificationBody(context),
                  ),
                );
              });
        });
  }
}
