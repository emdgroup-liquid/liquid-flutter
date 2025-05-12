import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class LdModal {
  /// The content of the sheet.
  final Widget Function(BuildContext context)? modalContent;

  /// The slivers to be added to the sheet. Used instead of [modalContent] if provided.
  final List<Widget> Function(BuildContext context)? contentSlivers;

  /// Whether the sheet should scale the content behind when opened. Defaults to true on iOS mobile devices.
  final bool? enableScaling;

  /// Whether the sheet can be dismissed
  final bool userCanDismiss;

  /// Whether to show the dismiss button
  final bool showDismissButton;

  /// Callback for when the sheet is dismissed.
  final VoidCallback? onDismiss;

  /// Whether the sheet should disable scrolling. Defaults to false.
  final bool disableScrolling;

  /// The actions to be added to the sheet.
  final List<Widget> Function(BuildContext context)? actions;

  /// The mode of the modal.
  final LdModalTypeMode? mode;

  /// Override the modal index. By default the LdPortalController will increment the index for each modal.
  final int? index;

  final Key? key;

  @Deprecated(
    "No longer used. Widget will build header if [title] is provided.",
  )
  final bool noHeader;

  final EdgeInsets? contentPadding;

  final EdgeInsets? headerPadding;

  final EdgeInsets? actionBarPadding;

  /// The title of the modal.
  final Widget? title;

  /// A list of listenables to be injected into the modal. That can be read
  /// from the various builder contexts, useful for updating the modal content
  /// based on external state like a viewmodel.
  final List<ListenableProvider> Function(BuildContext dialogContext)?
      injectables;

  /// The size of the modal.
  final LdSize? size;

  /// Fixed dialog size
  final Size? fixedDialogSize;

  /// The radius for the top of the modal.
  final double? topRadius;

  /// The radius for the bottom of the modal.
  final double? bottomRadius;

  /// The inset for the modal from the edges of the screen.
  final EdgeInsets? insets;

  /// Whether the modal should use safe area. Defaults to true.
  final bool useSafeArea;

  /// Whether to show the drag handle. Defaults to true.
  @Deprecated("No longer an option. Will not render drag handle.")
  final bool? showDragHandle;

  final Widget Function(BuildContext context)? actionBar;

  LdModal({
    this.enableScaling,
    this.modalContent,
    this.key,
    this.userCanDismiss = true,
    this.disableScrolling = false,
    this.noHeader = false,
    this.showDragHandle,
    this.contentPadding,
    this.headerPadding,
    this.title,
    this.actions,
    this.contentSlivers,
    this.mode = LdModalTypeMode.auto,
    this.showDismissButton = true,
    this.injectables,
    this.onDismiss,
    this.size,
    this.actionBar,
    this.actionBarPadding,
    this.topRadius,
    this.bottomRadius,
    this.insets,
    this.useSafeArea = false,
    this.fixedDialogSize,
    this.index,
  }) {
    assert(!(userCanDismiss == false && showDismissButton),
        "showDismissButton is true but userCanDismiss is false");
  }

  bool get shouldScale {
    return enableScaling == true ||
        (!kIsWeb && Platform.isIOS && mode != LdModalTypeMode.dialog);
  }

  bool get _enableDrag => userCanDismiss;

  /// Whether the modal in auto mode should show a sheet based on the
  /// device type.
  bool _autoShowsSheet(BuildContext context) {
    if (!context.mounted) return false;
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;

    final deviceType = getDeviceType(mediaQuery.size);
    return deviceType == DeviceScreenType.watch ||
        deviceType == DeviceScreenType.mobile;
  }

  /// Returns whether [mode] or screen size of [context] will
  /// result in  a sheet being shown
  bool _isSheet(BuildContext context) =>
      mode == LdModalTypeMode.sheet ||
      (mode == LdModalTypeMode.auto && _autoShowsSheet(context));

  bool _hasSabGradient(BuildContext context) =>
      actionBar != null && _isSheet(context);

  /// Returns the correct [WoltModalType] based on the [mode] and [context].
  WoltModalType _getSheetType(BuildContext context, {int index = 0}) {
    final theme = LdTheme.of(context);

    if (_isSheet(context)) {
      return LdSheetType(
        theme: theme,
        topRadius: topRadius,
        bottomRadius: bottomRadius,
        index: this.index ?? index,
      );
    }
    return LdDialogType(
      theme: theme,
      size: size ?? LdSize.m,
      fixedSize: fixedDialogSize,
      index: this.index ?? index,
    );
  }

  Widget _getInjectables(
    BuildContext context,
    Widget Function(BuildContext context) builder,
  ) {
    final _controller = LdPortalController.maybeOf(context);

    if (injectables == null && _controller == null) {
      return builder(context);
    }

    return MultiProvider(
      providers: [
        ...(injectables != null ? injectables!(context) : []),
        if (_controller != null) ListenableProvider.value(value: _controller),
      ],
      builder: (ctx, _) => builder(ctx),
    );
  }

  Widget? _getTrailingNavBarWidget(BuildContext context) {
    if (actions != null) {
      return _getInjectables(
        context,
        (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...actions!(context),
              ],
            ),
          ],
        ),
      );
    }

    if (userCanDismiss && showDismissButton) {
      final dismissButton = Builder(builder: (context) {
        return LdButtonVague(
          mode: title != null ? LdButtonMode.ghost : LdButtonMode.vague,
          child: const Icon(LucideIcons.x),
          onPressed: () {
            onDismiss?.call();
            Navigator.of(context).pop();
          },
        );
      });

      if (topRadius != null && title == null) {
        return _getInjectables(
          context,
          (context) => Column(
            children: [dismissButton],
          ),
        );
      }

      return _getInjectables(
        context,
        (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dismissButton,
          ],
        ),
      );
    }

    return null;
  }

  EdgeInsets _navigationBarPadding(BuildContext context) {
    if (headerPadding != null) {
      return headerPadding!;
    }

    if (topRadius != null) {
      return EdgeInsets.only(
        top: topRadius! / 2,
        left: topRadius! / 2,
        right: topRadius! / 2,
        bottom: topRadius! / 2,
      );
    }

    return LdTheme.of(context).pad(size: LdSize.m);
  }

  EdgeInsets _contentPadding(BuildContext context) {
    final theme = LdTheme.of(context);

    if (contentPadding != null) {
      return contentPadding!;
    }

    EdgeInsets defaultContentPadding = EdgeInsets.zero;

    if (topRadius != null) {
      defaultContentPadding = EdgeInsets.only(
        top: topRadius! / 2,
        left: topRadius! / 2,
        right: topRadius! / 2,
        bottom: topRadius! / 2,
      );
    } else {
      defaultContentPadding = theme.pad(size: LdSize.l);
    }

    if (_hasSabGradient(context)) {
      defaultContentPadding += EdgeInsets.only(
        bottom: theme.paddingSize(size: LdSize.m),
      );
    }

    return defaultContentPadding;
  }

  EdgeInsets _sabPadding(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    if (actionBarPadding != null) {
      return actionBarPadding!;
    } else {
      EdgeInsets sabPadding = LdTheme.of(context).pad(size: LdSize.l);
      // Add some more padding for sheets
      if (_isSheet(context)) {
        if (theme.screenRadius != 0) {
          if (theme.screenRadius / 2 > sabPadding.left) {
            sabPadding = EdgeInsets.all(
              theme.screenRadius / 2,
            );
          }
        }
      }
      return sabPadding;
    }
  }

  List<SliverWoltModalSheetPage> _getPageList(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final sizeNotifier = ValueNotifier<Size>(Size.zero);

    return [
      SliverWoltModalSheetPage(
        backgroundColor: theme.surface,
        hasSabGradient: false,
        surfaceTintColor: theme.surface,
        stickyActionBar: _getStickyActionBar(context, sizeNotifier),
        mainContentSliversBuilder: (context) => [
          SliverStickyHeader.builder(
              overlapsContent: title == null,
              builder: (context, state) => Container(
                    padding: _navigationBarPadding(context),
                    decoration: BoxDecoration(
                      color: title != null ? theme.surface : null,
                      border: title != null
                          ? Border(
                              bottom: BorderSide(
                                color: theme.border,
                                width: 1,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (title != null)
                          Expanded(
                            child: DefaultTextStyle(
                              style: ldBuildTextStyle(
                                theme,
                                LdTextType.label,
                                LdSize.m,
                              ),
                              child: title!,
                            ),
                          ),
                        _getTrailingNavBarWidget(context) ??
                            const SizedBox.shrink(),
                      ],
                    ),
                  ),
              sliver: SliverToBoxAdapter(
                child: LdAutoBackground(
                    isSurface: false,
                    child: _getInjectables(
                      context,
                      (context) => ValueListenableBuilder<Size>(
                        valueListenable: sizeNotifier,
                        builder: (context, size, child) {
                          return Padding(
                            padding: _contentPadding(context) +
                                EdgeInsets.only(bottom: size.height),
                            child: modalContent != null
                                ? modalContent!(context)
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    )),
              )),
          if (contentSlivers != null) ...contentSlivers!(context),
        ],
        hasTopBarLayer: false,
      ),
    ];
  }

  Widget? _getStickyActionBar(
      BuildContext context, ValueNotifier<Size> sizeNotifier) {
    if (actionBar == null) {
      return null;
    }

    final sabPadding = _sabPadding(context);

    return _getInjectables(
      context,
      (context) => LdAutoBackground(
        child: MeasureSize(
          sizeNotifier: sizeNotifier,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_hasSabGradient(context)) ...[
                const LdDivider(
                  height: 1,
                ),
                Padding(
                  padding: sabPadding,
                  child: actionBar!(context),
                )
              ] else
                _LdActionBarGradient(
                  child: Padding(
                    padding: sabPadding,
                    child: actionBar!(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  WoltModalSheetRoute asRoute(RouteSettings settings, BuildContext context) {
    return WoltModalSheetRoute(
      useSafeArea: useSafeArea,
      barrierDismissible: userCanDismiss,
      enableDrag: _enableDrag,
      showDragHandle: false,
      modalBarrierColor: _getModalBarrierColor(context),
      settings: settings,
      pageContentDecorator: _getContentDecorator,
      modalTypeBuilder: (context) => _getSheetType(
        context,
        index: index ?? 0,
      ),
      pageListBuilderNotifier: ValueNotifier(
        (context) => _getPageList(context),
      ),
      onModalDismissedWithBarrierTap: onDismiss,
      onModalDismissedWithDrag: onDismiss,
    );
  }

  Widget _getContentDecorator(Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // add this
      sized: false, // important
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // set color to transparent
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: userCanDismiss,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            onDismiss?.call();
          }
        },
        child: Builder(builder: (context) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () {
                Navigator.of(context).maybePop();
              },
            },
            child: LdPortal(child: child),
          );
        }),
      ),
    );
  }

  Color _getModalBarrierColor(BuildContext context) {
    final theme = LdTheme.of(context);
    return theme.palette.neutral.shades[8].withAlpha(150);
  }

  /// Show the modal.
  Future<dynamic> show(
    BuildContext context, {
    bool useRootNavigator = false,
  }) async {
    final res = await WoltModalSheet.show(
      modalDecorator: (child) => KeyedSubtree(
        child: child,
        key: key,
      ),
      barrierDismissible: userCanDismiss,
      context: context,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      showDragHandle: false,
      modalBarrierColor: _getModalBarrierColor(context),
      enableDrag: userCanDismiss,
      pageContentDecorator: _getContentDecorator,
      modalTypeBuilder: (_) => _getSheetType(
        context,
        index: 0,
      ),
      pageListBuilder: (_) => _getPageList(context),
    );

    return res;
  }
}

class _LdActionBarGradient extends StatelessWidget {
  const _LdActionBarGradient({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        boxShadow: [
          BoxShadow(
            color: theme.background.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: child,
    );
  }
}
