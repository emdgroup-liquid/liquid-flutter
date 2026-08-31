import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// How [LdRawAppBar] sizes and places its bar surface.
enum LdRawAppBarLayout {
  /// Full-width row. [LdRawAppBar.content] expands between leading and trailing.
  expand,

  /// Intrinsic-width row, centered on the bar edge.
  center,
}

/// Chrome-less app bar that wraps [child] via [AppBarFrame].
///
/// Unlike [LdAppBar], this widget does not paint a shared surface. Place any
/// widget in [content] (for example a [Row] or [LdHorizontalScroll]). Optional
/// [leading] and [trailing] stay pinned beside [content].
///
/// Use [layout] to choose a full-width expanding row ([LdRawAppBarLayout.expand])
/// or an intrinsic-width cluster centered on the edge ([LdRawAppBarLayout.center]).
///
/// Pass [insideDecoration] / [outsideDecoration] (or the `*Builder` variants)
/// through to [AppBarFrame]. Builders win over static decorations when both
/// are set, and receive the current `isScrolledUnder` value.
///
/// ```dart
/// LdRawAppBar.bottom(
///   leading: LdButton.outline(
///     onPressed: () {},
///     child: const Icon(LucideIcons.plus),
///   ),
///   content: LdHorizontalScroll(
///     layout: LdHorizontalScrollLayout.scroll,
///     children: chips,
///   ),
///   trailing: LdButton.filled(
///     onPressed: () {},
///     child: const Icon(LucideIcons.arrowUp),
///   ),
///   child: list,
/// )
/// ```
class LdRawAppBar extends StatelessWidget {
  /// The subtree that this bar wraps.
  final Widget child;

  /// Bar body. Any widget: a [Row], [LdHorizontalScroll], input, etc.
  final Widget content;

  /// Optional widget pinned before [content].
  final Widget? leading;

  /// Optional widget pinned after [content].
  final Widget? trailing;

  /// Scroll-hide behaviour for this bar.
  final LdAppBarScrollBehavior scrollBehavior;

  /// Which edge this bar occupies.
  final LdAppBarPositionMode positionMode;

  /// Whether the bar fills the width or hugs and centers its children.
  final LdRawAppBarLayout layout;

  /// Inner padding of the bar surface. Defaults to [LdTheme.pad].
  final EdgeInsets? padding;

  /// Decoration for the inner bar surface. Overridden by [insideDecorationBuilder]
  /// when that is non-null.
  final BoxDecoration? insideDecoration;

  /// Decoration for the outer bar frame. Overridden by [outsideDecorationBuilder]
  /// when that is non-null.
  final BoxDecoration? outsideDecoration;

  /// Builds [insideDecoration] from the current `isScrolledUnder` value.
  final BoxDecoration? Function(bool isScrolledUnder)? insideDecorationBuilder;

  /// Builds [outsideDecoration] from the current `isScrolledUnder` value.
  final BoxDecoration? Function(bool isScrolledUnder)? outsideDecorationBuilder;

  final bool addContainer;

  final bool avoidViewInsets;

  final String? debugName;

  final bool attached;

  const LdRawAppBar({
    super.key,
    required this.child,
    required this.content,
    this.leading,
    this.trailing,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.positionMode = LdAppBarPositionMode.top,
    this.layout = LdRawAppBarLayout.expand,
    this.padding,
    this.insideDecoration,
    this.outsideDecoration,
    this.insideDecorationBuilder,
    this.outsideDecorationBuilder,
    this.addContainer = false,
    this.attached = false,
    this.avoidViewInsets = false,
    this.debugName,
  });

  factory LdRawAppBar.top({
    Key? key,
    required Widget child,
    required Widget content,
    Widget? leading,
    Widget? trailing,
    LdAppBarScrollBehavior scrollBehavior = LdAppBarScrollBehavior.static,
    LdRawAppBarLayout layout = LdRawAppBarLayout.expand,
    EdgeInsets? padding,
    BoxDecoration? insideDecoration,
    BoxDecoration? outsideDecoration,
    BoxDecoration? Function(bool isScrolledUnder)? insideDecorationBuilder,
    BoxDecoration? Function(bool isScrolledUnder)? outsideDecorationBuilder,
    bool addContainer = false,
    bool avoidViewInsets = false,
    String? debugName,
    bool floating = true,
  }) {
    return LdRawAppBar(
      key: key,
      child: child,
      content: content,
      leading: leading,
      trailing: trailing,
      scrollBehavior: scrollBehavior,
      positionMode: LdAppBarPositionMode.top,
      layout: layout,
      padding: padding,
      insideDecoration: insideDecoration,
      outsideDecoration: outsideDecoration,
      insideDecorationBuilder: insideDecorationBuilder,
      outsideDecorationBuilder: outsideDecorationBuilder,
      addContainer: addContainer,
      attached: floating,
      avoidViewInsets: avoidViewInsets,
      debugName: debugName,
    );
  }

  factory LdRawAppBar.bottom({
    Key? key,
    required Widget child,
    required Widget content,
    Widget? leading,
    Widget? trailing,
    LdAppBarScrollBehavior scrollBehavior = LdAppBarScrollBehavior.static,
    LdRawAppBarLayout layout = LdRawAppBarLayout.expand,
    EdgeInsets? padding,
    BoxDecoration? insideDecoration,
    BoxDecoration? outsideDecoration,
    BoxDecoration? Function(bool isScrolledUnder)? insideDecorationBuilder,
    BoxDecoration? Function(bool isScrolledUnder)? outsideDecorationBuilder,
    bool addContainer = false,
    bool floating = true,
    bool avoidViewInsets = false,
    String? debugName,
  }) {
    return LdRawAppBar(
      key: key,
      child: child,
      content: content,
      leading: leading,
      trailing: trailing,
      scrollBehavior: scrollBehavior,
      positionMode: LdAppBarPositionMode.bottom,
      layout: layout,
      padding: padding,
      insideDecoration: insideDecoration,
      outsideDecoration: outsideDecoration,
      insideDecorationBuilder: insideDecorationBuilder,
      outsideDecorationBuilder: outsideDecorationBuilder,
      addContainer: addContainer,
      avoidViewInsets: avoidViewInsets,
      debugName: debugName,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugName', debugName));
    properties.add(
      EnumProperty<LdAppBarScrollBehavior>('scrollBehavior', scrollBehavior),
    );
    properties.add(
      EnumProperty<LdAppBarPositionMode>('positionMode', positionMode),
    );
    properties.add(
      EnumProperty<LdRawAppBarLayout>('layout', layout),
    );
    properties.add(
      FlagProperty('addContainer', value: addContainer, ifTrue: 'enabled'),
    );
    properties.add(DiagnosticsProperty<Widget?>('leading', leading));
    properties.add(DiagnosticsProperty<Widget>('content', content));
    properties.add(DiagnosticsProperty<Widget?>('trailing', trailing));
    properties.add(
      DiagnosticsProperty<BoxDecoration?>('insideDecoration', insideDecoration),
    );
    properties.add(
      DiagnosticsProperty<BoxDecoration?>('outsideDecoration', outsideDecoration),
    );
  }

  LdAppBarPosition _effectivePosition(BuildContext context) {
    return switch (positionMode) {
      LdAppBarPositionMode.top => LdAppBarPosition.top,
      LdAppBarPositionMode.bottom => LdAppBarPosition.bottom,
      LdAppBarPositionMode.adaptive => switch (LdTheme.of(context).platform.isMobile) {
          true => LdAppBarPosition.bottom,
          _ => LdAppBarPosition.top,
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    final position = _effectivePosition(context);
    final theme = LdTheme.of(context);

    final barSurface = AnnotatedRegion<SystemUiOverlayStyle>(
      value: appBarSystemUiOverlayStyle(theme),
      child: Builder(
        builder: (context) {
          final isCenter = layout == LdRawAppBarLayout.center;
          final row = Row(
            mainAxisSize: isCenter ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) leading!,
              if (isCenter)
                content
              else
                Expanded(
                  child: content,
                ),
              if (trailing != null) trailing!,
            ],
          ).spaceS();

          return Padding(
            padding: MediaQuery.of(context).padding,
            child: switch (isCenter) {
              true => Align(
                  alignment: Alignment.center,
                  child: row,
                ),
              false => row,
            },
          );
        },
      ),
    );

    return AppBarFrame(
      addContainer: addContainer,
      avoidViewInsets: avoidViewInsets,
      debugName: debugName,
      position: position,
      attached: attached,
      scrollBehavior: scrollBehavior,
      wrappedChild: child,
      scrimColor: (scrolledUnder) => theme.primaryColor,
      insidePadding: padding ?? theme.pad(),
      insideDecoration: insideDecoration,
      outsideDecoration: outsideDecoration,
      insideDecorationBuilder: insideDecorationBuilder,
      outsideDecorationBuilder: outsideDecorationBuilder,
      child: barSurface,
    );
  }
}
