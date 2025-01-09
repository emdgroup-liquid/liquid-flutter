import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';
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

  /// Callback for when the sheet is dismissed.
  final VoidCallback? onDismiss;

  /// Whether the sheet should disable scrolling. Defaults to false.
  final bool disableScrolling;

  /// The actions to be added to the sheet.
  final List<Widget> Function(BuildContext context)? actions;

  /// The mode of the modal.
  final LdModalTypeMode? mode;

  final Key? key;

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

  LdModal({
    this.enableScaling,
    this.modalContent,
    this.key,
    this.userCanDismiss = true,
    this.disableScrolling = false,
    this.noHeader = false,
    this.padding,
    this.title,
    this.actions,
    this.contentSlivers,
    this.mode = LdModalTypeMode.auto,
    this.injectables,
    this.onDismiss,
    this.size,
  });

  bool get shouldScale {
    return enableScaling == true || (!kIsWeb && Platform.isIOS);
  }

  WoltModalType _getSheetType(BuildContext context, {index = 0}) {
    return switch (mode) {
      LdModalTypeMode.sheet => LdSheetType(
          theme: LdTheme.of(context),
          index: index,
        ),
      LdModalTypeMode.dialog => LdDialogType(
          theme: LdTheme.of(context),
          size: size ?? LdSize.m,
          index: index,
        ),
      _ => ldAutoModalType(
          context,
          size ?? LdSize.m,
          index,
        ),
    };
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

  Widget _getTrailingNavBarWidget(BuildContext context) {
    if (userCanDismiss && actions == null) {
      final theme = LdTheme.of(context);
      return _getInjectables(
        context,
        (context) => Padding(
          padding: EdgeInsets.only(
            right: padding?.right ?? theme.paddingSize(size: LdSize.m),
          ),
          child: LdButtonGhost(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.clear),
          ),
        ),
      );
    }

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

    return const SizedBox.shrink();
  }

  List<SliverWoltModalSheetPage> _getPageList(BuildContext context) {
    return [
      if (contentSlivers != null)
        SliverWoltModalSheetPage(
          backgroundColor: LdTheme.of(context).surface,
          mainContentSliversBuilder: (context) => contentSlivers!(context)
              .map(
                (e) => SliverPadding(
                  padding: padding ?? LdTheme.of(context).pad(size: LdSize.l),
                  sliver: e,
                ),
              )
              .toList(),
          trailingNavBarWidget: _getTrailingNavBarWidget(
            context,
          ),
          isTopBarLayerAlwaysVisible: title != null && !noHeader,
          topBar: title != null ? _getTopBar(context) : null,
          navBarHeight: noHeader ? 0 : 48,
        ),
      if (modalContent != null)
        WoltModalSheetPage(
          backgroundColor: LdTheme.of(context).surface,
          child: _getInjectables(
            context,
            (context) => Portal(
              child: Padding(
                padding: padding ?? LdTheme.of(context).pad(size: LdSize.l),
                child: modalContent!(context),
              ),
            ),
          ),
          trailingNavBarWidget: noHeader == false
              ? _getTrailingNavBarWidget(
                  context,
                )
              : null,
          isTopBarLayerAlwaysVisible: title != null && !noHeader,
          topBar: title != null ? _getTopBar(context) : null,
          navBarHeight: noHeader ? 0 : 48,
          hasTopBarLayer: !noHeader,
        ),
    ];
  }

  Widget? _getTopBar(BuildContext context) {
    if (title == null) {
      return null;
    }

    return _getInjectables(
      context,
      (context) => Column(children: [
        Expanded(
          child: Row(children: [
            DefaultTextStyle(
              style: ldBuildTextStyle(
                LdTheme.of(context),
                LdTextType.label,
                LdSize.m,
              ),
              child: title!,
            )
          ]).padM(),
        ),
        const LdDivider(height: 1)
      ]),
    );
  }

  bool get barrierDismissible => userCanDismiss;

  bool get enableDrag => userCanDismiss && !noHeader;

  bool get isTopBarLayerAlwaysVisible => title != null && !noHeader;

  bool get showDragHandle => userCanDismiss && !noHeader;

  WoltModalSheetRoute asRoute(RouteSettings settings) {
    return WoltModalSheetRoute(
      barrierDismissible: userCanDismiss,
      enableDrag: enableDrag,
      settings: settings,
      modalTypeBuilder: (context) => _getSheetType(context),
      pageListBuilderNotifier: ValueNotifier(
        (context) => _getPageList(context),
      ),
    );
  }

  Future<dynamic> show(BuildContext context) async {
    final _controller = LdPortalController.maybeOf(context);

    LdPortalEntry? entry;
    int index = 0;

    if (_controller != null) {
      entry = _controller.registerEntry(
        scaleContent: shouldScale,
      );
      index = _controller.indexOf(entry);
    }

    final res = await WoltModalSheet.show(
      modalDecorator: (child) => KeyedSubtree(
        child: child,
        key: key,
      ),
      barrierDismissible: userCanDismiss,
      context: context,
      enableDrag: userCanDismiss && !noHeader,
      modalTypeBuilder: (_) => _getSheetType(
        context,
        index: index,
      ),
      pageListBuilder: (_) => _getPageList(context),
    );

    if (entry != null) {
      _controller?.removeEntry(entry);
    }

    return res;
  }
}
