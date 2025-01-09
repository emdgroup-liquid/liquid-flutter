import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// a collection of collapsible items in a group.
class LdAccordion extends StatefulWidget {
  /// Function that is called to build each item in the accordion.
  final Widget Function(BuildContext context, int n) childBuilder;

  /// Function that is called to build each header in the accordion.
  final Widget Function(BuildContext context, int n) headerBuilder;

  /// The number of items in the accordion.
  final int itemCount;

  /// The index of the items that should be open by default.
  final Set<int> initialOpenIndex;

  /// The padding to apply to the header.
  final EdgeInsets? headerPadding;

  /// The padding to apply to the child.
  final EdgeInsets? childPadding;

  /// Whether or not multiple items can be open at once.
  final bool allowMultipleOpen;

  /// The duration of the animation.
  final Duration speed;

  /// The curve to use when expanding.
  final Curve curveExpand;

  /// The curve to use when collapsing.
  final Curve curveCollapse;

  /// Whether or not to elevate the active item.
  final bool elevateActive;

  const LdAccordion({
    required this.childBuilder,
    required this.headerBuilder,
    required this.itemCount,
    this.allowMultipleOpen = false,
    this.childPadding,
    this.curveCollapse = Curves.easeOut,
    this.curveExpand = Curves.easeIn,
    this.elevateActive = false,
    this.headerPadding,
    this.initialOpenIndex = const {},
    this.speed = const Duration(milliseconds: 300),
    Key? key,
  }) : super(key: key);

  /// Creates an accordion from a list of [LdAccordionItem]s.
  factory LdAccordion.fromList(
    List<LdAccordionItem> items, {
    Key? key,
    bool elevateActive = false,
    bool allowMultipleOpen = false,
    Set<int> initialOpenIndex = const {},
  }) {
    return LdAccordion(
        childBuilder: (context, n) => items[n].child,
        itemCount: items.length,
        headerBuilder: (context, n) => items[n].header,
        elevateActive: elevateActive,
        allowMultipleOpen: allowMultipleOpen,
        initialOpenIndex: initialOpenIndex,
        key: key);
  }

  @override
  State<LdAccordion> createState() => _LdAccordionState();
}

/// item of an accordion used in utility constructor [LdAccordion.fromList].
class LdAccordionItem {
  final Widget child;
  final Widget header;
  LdAccordionItem({required this.child, required this.header});
}

class _LdAccordionChild extends StatelessWidget {
  final Widget child;
  final Widget header;
  final bool elevateActive;
  final Duration speed;

  final EdgeInsets headerPadding;
  final EdgeInsets childPadding;
  final Function() onPressed;
  final Curve curveExpand;
  final Curve curveCollapse;
  final bool collapsed;

  const _LdAccordionChild(
      {required this.collapsed,
      required this.child,
      required this.elevateActive,
      required this.onPressed,
      required this.headerPadding,
      required this.childPadding,
      required this.speed,
      required this.header,
      required this.curveExpand,
      required this.curveCollapse,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    var color =
        LdSurfaceInfo.of(context).isSurface ? theme.background : theme.surface;

    return AnimatedContainer(
      duration: speed,
      margin: EdgeInsets.symmetric(
        vertical: elevateActive && !collapsed ? 4 : 0,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: !collapsed ? color : null,
        borderRadius: elevateActive ? theme.radius(LdSize.s) : null,
        boxShadow: elevateActive && !collapsed ? [ldShadowDefault] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LdTouchableSurface(
            onTap: onPressed,
            active: !collapsed,
            mode: LdTouchableSurfaceMode.neutralGhost,
            color: theme.palette.primary,
            builder: (contxt, colorBundle, status) => Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                color: colorBundle.surface,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      child: header,
                      style: ldBuildTextStyle(
                        theme,
                        LdTextType.label,
                        LdSize.m,
                        color: colorBundle.text,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: colorBundle.icon,
                    ),
                    duration: const Duration(milliseconds: 150),
                    turns: !collapsed ? 0.25 : 0,
                  ),
                ],
              ),
            ),
          ),
          LdCollapse(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LdDivider(),
                  Padding(
                    padding: childPadding,
                    child: child,
                  ),
                ],
              ),
              collapsed: collapsed)
        ],
      ),
    );
  }
}

class _LdAccordionState extends State<LdAccordion> {
  Set<int> openIndex = {};

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    var headerPadding = widget.headerPadding ?? theme.pad(size: LdSize.s);
    var childPadding = widget.childPadding ?? theme.pad(size: LdSize.s);

    return FocusTraversalGroup(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      for (final n in List.generate(widget.itemCount, (index) => index))
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LdAccordionChild(
                curveCollapse: widget.curveCollapse,
                curveExpand: widget.curveExpand,
                collapsed: !openIndex.contains(n),
                child: widget.childBuilder(context, n),
                elevateActive: widget.elevateActive,
                headerPadding: headerPadding,
                speed: widget.speed,
                childPadding: childPadding,
                onPressed: () => _onTap(n),
                header: widget.headerBuilder(context, n)),
            if (n != widget.itemCount - 1 && !widget.elevateActive)
              const LdDivider(),
          ],
        ),
    ]));
  }

  @override
  void didUpdateWidget(covariant LdAccordion oldWidget) {
    // if allowMultiple is changed to false and there are several items open we close all but the last
    if (widget.allowMultipleOpen != oldWidget.allowMultipleOpen) {
      if (!widget.allowMultipleOpen) {
        if (openIndex.isNotEmpty) {
          openIndex = {openIndex.last};
        }
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    setState(() {
      openIndex = Set<int>.from(widget.initialOpenIndex);
    });
    super.initState();
  }

  void _onTap(int n) {
    if (openIndex.contains(n)) {
      setState(() {
        openIndex.remove(n);
      });
      return;
    }
    setState(() {
      if (widget.allowMultipleOpen) {
        openIndex.add(n);
      } else {
        openIndex = {n};
      }
    });
  }
}
