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
  final Function()? onPressed;
  const LdDrawerItemSection({
    this.leading,
    required this.child,
    this.trailing,
    this.initiallyExpanded = false,
    this.onPressed,
    this.active,
    this.disabled = false,
    this.children,
    super.key,
  });

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
          child: DefaultTextStyle(
              style: ldBuildTextStyle(
                _theme,
                LdTextType.label,
                LdSize.s,
                color: color,
              ),
              child: widget.leading!),
        ));
  }

  Widget get _trailingItem {
    if (widget.trailing != null) {
      return widget.trailing!;
    }
    if (widget.children != null && widget.children!.isNotEmpty) {
      return AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _isExpanded ? 0.25 : 0,
          child: const Icon(LucideIcons.chevronRight));
    }
    return Container();
  }

  bool _expanded = false;
  bool get _isExpanded => widget.active != null ? widget.active! : _expanded;

  void _onTap() {
    if (widget.disabled) {
      return;
    }
    if (widget.onPressed != null) {
      widget.onPressed!();
    }

    setState(() {
      _expanded = !_expanded;
    });
  }

  Widget buildItem(BuildContext context) {
    return LdTouchableSurface(
      active: widget.active == true,
      onPressed: _onTap,
      color: _theme.palette.primary,
      builder: (context, colorBundle, status, _) => Container(
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
    if (widget.children != null && widget.children!.isNotEmpty) {
      return Column(
        children: [
          buildItem(context),
          LdCollapse(
            collapsed: !_isExpanded,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: _theme.border),
                ),
              ),
              margin: const EdgeInsets.only(
                left: 8.0,
                top: 4,
              ),
              padding: const EdgeInsets.only(left: 8.0, top: 4),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: LdAutoSpace(
                  children: widget.children!,
                ),
              ),
            ),
          )
        ],
      );
    }
    return buildItem(context);
  }
}
