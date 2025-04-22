import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// A section in the drawer that can contain a collapsable sub-items
class LdDrawerItemSection extends StatefulWidget {
  final Widget? leading;
  final Widget child;
  final Widget? trailing;
  final bool disabled;
  final bool? active;
  final bool initiallyExpanded;
  final List<Widget>? children;
  final Function()? onTap;
  const LdDrawerItemSection(
      {this.leading,
      required this.child,
      this.trailing,
      this.initiallyExpanded = false,
      this.onTap,
      this.active,
      this.disabled = false,
      this.children,
      Key? key})
      : super(key: key);

  @override
  State<LdDrawerItemSection> createState() => _LdDrawerItemSectionState();
}

class _LdDrawerItemSectionState extends State<LdDrawerItemSection> {
  LdTheme get _theme => Provider.of<LdTheme>(context, listen: true);

  @override
  void initState() {
    _expanded = widget.initiallyExpanded;

    super.initState();
  }

  Widget _leading(Color color) {
    return Padding(
        padding: EdgeInsets.only(
          right: _theme.paddingSize(size: LdSize.s),
        ),
        child: IconTheme(
          data: IconThemeData(
            color: color,
            size: _theme.paragraphSize(LdSize.s),
          ),
          child: widget.leading!,
        ));
  }

  Widget get _trailingItem {
    if (widget.trailing != null) {
      return widget.trailing!;
    }
    if (widget.children != null) {
      return AnimatedRotation(
          child: const Icon(LucideIcons.chevronRight),
          duration: const Duration(milliseconds: 200),
          turns: _isExpanded ? 0.25 : 0);
    }
    return Container();
  }

  bool _expanded = false;
  bool get _isExpanded => widget.active != null ? widget.active! : _expanded;

  void _onTap() {
    if (widget.disabled) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!();
    }

    setState(() {
      _expanded = !_expanded;
    });
  }

  Widget buildItem(BuildContext context) {
    return LdTouchableSurface(
      active: widget.active == true,
      onTap: _onTap,
      color: _theme.palette.primary,
      builder: (context, colorBundle, status) => Container(
          padding: _theme.pad(size: LdSize.s),
          decoration: BoxDecoration(
            color: colorBundle.surface,
            borderRadius: _theme.radius(LdSize.m),
          ),
          child: Row(children: [
            widget.leading != null
                ? _leading(colorBundle.icon)
                : const SizedBox(
                    height: 10,
                    width: 10,
                  ),
            Expanded(
                child: DefaultTextStyle(
                    style: ldBuildTextStyle(
                      _theme,
                      LdTextType.label,
                      LdSize.m,
                      color: _theme.text,
                    ),
                    child: widget.child)),
            IconTheme(
              data: IconThemeData(
                color: colorBundle.icon,
                size: _theme.paragraphSize(LdSize.s),
              ),
              child: _trailingItem,
            ),
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children != null) {
      return Column(
        children: [
          buildItem(context),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: LdCollapse(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LdAutoSpace(
                    children: widget.children!,
                  ),
                ),
                collapsed: !_isExpanded),
          )
        ],
      );
    }
    return buildItem(context);
  }
}
