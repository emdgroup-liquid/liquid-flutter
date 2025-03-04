import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
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

  final EdgeInsets? padding;

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
    this.padding,
    this.title,
    this.actions,
    this.contentSlivers,
    this.mode = LdModalTypeMode.auto,
    this.showDismissButton = true,
    this.injectables,
    this.onDismiss,
    this.size,
    this.actionBar,
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

  final Map<LdThemeSize, double> _actionBarHeight = {
    LdThemeSize.l: 150,
    LdThemeSize.m: 120,
    LdThemeSize.s: 64,
  };
  final double _contentActionBarPadding = 12;
  final double _defaultSheetInset = 2;

  bool get shouldScale {
    return enableScaling == true ||
        (!kIsWeb && Platform.isIOS && mode != LdModalTypeMode.dialog);
  }

  bool get barrierDismissible => userCanDismiss;
  bool get enableDrag => userCanDismiss;
  bool get isTopBarLayerAlwaysVisible => title != null;

  bool get _isMobile => kIsWeb || Platform.isIOS || Platform.isAndroid;

  bool _showDragHandle(BuildContext context) =>
      showDragHandle ?? (isSheet(context) && _isMobile);

  bool get hasTopBarLayer => title != null;

  double navbarHeight(BuildContext context) {
    final theme = LdTheme.of(context);
    final size = switch (theme.themeSize) {
      LdThemeSize.l => 82.0,
      LdThemeSize.m => 62.0,
      LdThemeSize.s => 38.0,
    };
    if (topRadius != null) {
      return max(topRadius! + 10, size);
    }

    return size;
  }

  /// Returns whether [mode] or screen size of [context] will
  /// result in  a sheet being shown
  bool isSheet(BuildContext context) =>
      mode == LdModalTypeMode.sheet ||
      (mode == LdModalTypeMode.auto && _autoShowsSheet(context));

  WoltModalType _getSheetType(BuildContext context, {int index = 0}) {
    if (isSheet(context)) {
      return LdSheetType(
        theme: LdTheme.of(context),
        topRadius: topRadius,
        bottomRadius: bottomRadius ?? LdTheme.of(context).screenRadius,
        index: this.index ?? index,
        insets: insets ?? EdgeInsets.all(_defaultSheetInset),
      );
    }

    return LdDialogType(
      theme: LdTheme.of(context),
      size: size ?? LdSize.m,
      fixedSize: fixedDialogSize,
      index: this.index ?? index,
    );
  }

  /// Whether the modal in auto mode should show a sheet based on the device type.
  bool _autoShowsSheet(BuildContext context) {
    final deviceType = getDeviceType(MediaQuery.sizeOf(context));
    return deviceType == DeviceScreenType.watch ||
        deviceType == DeviceScreenType.mobile;
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
      final theme = LdTheme.of(context);
      return _getInjectables(
        context,
        (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(
                  right: padding?.right ?? theme.paddingSize(size: LdSize.m),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...actions!(context),
                  ],
                )),
          ],
        ),
      );
    }

    if (userCanDismiss && showDismissButton) {
      final dismissButton = Builder(builder: (context) {
        return LdButton(
          size: LdSize.s,
          mode: title != null ? LdButtonMode.ghost : LdButtonMode.vague,
          child: const Icon(Icons.clear),
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
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: topRadius! / 2, right: topRadius! / 2),
                child: dismissButton,
              )
            ],
          ),
        );
      }

      return _getInjectables(
        context,
        (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: padding?.right ??
                    LdTheme.of(context).paddingSize(
                      size: LdSize.l,
                    ),
              ),
              child: dismissButton,
            ),
          ],
        ),
      );
    }

    return null;
  }

  List<SliverWoltModalSheetPage> _getPageList(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final contentPadding = padding ?? theme.pad(size: LdSize.l);

    final actionBarPadding = EdgeInsets.only(
      bottom: actionBar != null
          ? _actionBarHeight[theme.themeSize]! + _contentActionBarPadding
          : 0,
    );

    return [
      if (contentSlivers != null)
        SliverWoltModalSheetPage(
          backgroundColor: theme.background,
          surfaceTintColor: theme.background,
          sabGradientColor: theme.surface,
          hasSabGradient: hasSabGradient(context),
          stickyActionBar: _getStickyActionBar(context),
          mainContentSliversBuilder: (context) => contentSlivers!(context)
              .map(
                (e) => SliverPadding(
                  padding: contentPadding + actionBarPadding,
                  sliver: e,
                ),
              )
              .toList(),
          trailingNavBarWidget: _getTrailingNavBarWidget(
            context,
          ),
          isTopBarLayerAlwaysVisible: title != null,
          topBar: _getTopBar(context),
          navBarHeight: navbarHeight(context),
        ),
      if (modalContent != null)
        WoltModalSheetPage(
          backgroundColor: theme.background,
          surfaceTintColor: theme.background,
          sabGradientColor: theme.surface,
          hasSabGradient: hasSabGradient(context),
          stickyActionBar: _getStickyActionBar(context),
          child: _getInjectables(
            context,
            (context) => Padding(
              padding: contentPadding + actionBarPadding,
              child: modalContent!(context),
            ),
          ),
          trailingNavBarWidget: _getTrailingNavBarWidget(
            context,
          ),
          isTopBarLayerAlwaysVisible: isTopBarLayerAlwaysVisible,
          topBar: _getTopBar(context),
          navBarHeight: navbarHeight(context),
          hasTopBarLayer: hasTopBarLayer,
        ),
    ];
  }

  bool hasSabGradient(BuildContext context) =>
      actionBar != null && isSheet(context);

  Widget? _getStickyActionBar(BuildContext context) {
    if (actionBar == null) {
      return null;
    }

    final theme = LdTheme.of(context, listen: true);

    var sabPadding = padding ?? theme.pad(size: LdSize.l);

    // Add some more padding for sheets because they are
    // placed at the very bottom
    if (isSheet(context)) {
      sabPadding += EdgeInsets.only(
        bottom: theme.paddingSize(size: LdSize.l),
      );
    }

    return _getInjectables(
      context,
      (context) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: _actionBarHeight[theme.themeSize]!),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasSabGradient(context))
              const LdDivider(
                height: 1,
              ),
            Container(
              color: theme.surface,
              padding: sabPadding,
              child: Builder(builder: (context) {
                return actionBar!(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getTopBar(BuildContext context) {
    if (title == null) {
      return null;
    }

    final theme = LdTheme.of(context, listen: true);

    var padding = theme.pad(size: LdSize.m);

    if (topRadius != null) {
      padding = EdgeInsets.only(
        left: topRadius! / 2,
        right: topRadius! / 2,
      );
    }

    return _getInjectables(
      context,
      (context) => LdAutoBackground(
        child: Column(children: [
          if (_showDragHandle(context)) const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: padding,
              child: Row(children: [
                Flexible(
                  fit: topRadius != null ? FlexFit.tight : FlexFit.loose,
                  child: DefaultTextStyle(
                    style: ldBuildTextStyle(
                      theme,
                      LdTextType.label,
                      LdSize.m,
                      lineHeight: 1,
                    ),
                    textAlign: topRadius != null ? TextAlign.center : null,
                    maxLines: 1,
                    child: title!,
                  ),
                ),
              ]),
            ),
          ),
          const LdDivider(height: 1)
        ]),
      ),
    );
  }

  WoltModalSheetRoute asRoute(RouteSettings settings, BuildContext context) {
    return WoltModalSheetRoute(
      useSafeArea: useSafeArea,
      barrierDismissible: userCanDismiss,
      enableDrag: enableDrag,
      showDragHandle: _showDragHandle(context),
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
        child: LdPortal(child: child),
      ),
    );
  }

  Color _getModalBarrierColor(BuildContext context) {
    final theme = LdTheme.of(context);

    return theme.palette.neutral.shades.last.withAlpha(150);
  }

  Future<dynamic> show(BuildContext context,
      {bool useRootNavigator = false}) async {
    LdPortalController? controller;

    if (useRootNavigator) {
      //context = Navigator.of(context, rootNavigator: true).context;
      controller = LdPortalController.maybeOf(context);
    } else {
      controller = LdPortalController.maybeOf(context);
    }

    LdPortalEntry? entry;
    int index = 0;

    if (controller != null) {
      entry = controller.registerEntry(
        scaleContent: shouldScale,
      );
      index = controller.indexOf(entry);
    }

    final res = await WoltModalSheet.show(
      modalDecorator: (child) => KeyedSubtree(
        child: child,
        key: key,
      ),
      barrierDismissible: userCanDismiss,
      context: context,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      showDragHandle: _showDragHandle(context),
      modalBarrierColor: _getModalBarrierColor(context),
      enableDrag: userCanDismiss,
      pageContentDecorator: _getContentDecorator,
      modalTypeBuilder: (_) => _getSheetType(
        context,
        index: index,
      ),
      pageListBuilder: (_) => _getPageList(context),
    );

    if (entry != null) {
      if (controller?.open ?? false) controller?.removeEntry(entry);
    }

    return res;
  }
}
