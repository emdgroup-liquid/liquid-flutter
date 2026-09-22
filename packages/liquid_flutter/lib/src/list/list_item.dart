import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/shuttle_safe_key.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

part 'list_item.variants.g.dart';

typedef OnSelectionChanged = void Function(bool selected);

enum LdSelectionControl { none, radio, checkbox }

class LdListItemDragConfig {
  final void Function() onDragStarted;
  final void Function(DragUpdateDetails details) onDragUpdate;
  final void Function(DraggableDetails details) onDragEnd;
  final void Function(Velocity velocity, Offset offset) onDragCanceled;
  final void Function(BuildContext context) feedbackBuilder;
  final bool isDragging;

  const LdListItemDragConfig({
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCanceled,
    required this.feedbackBuilder,
    required this.isDragging,
  });
}

@Variants([
  Variant('trailingForward', defaults: {'trailing': 'const LdListDefaultTrailingForward()'}),
])
class LdListItemWidget extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final bool active;
  final Widget? subtitle;
  final VoidCallback? onPressed;
  final double? width;
  final bool selectDisabled;
  final OnSelectionChanged? onSelectionChanged;
  final LdSelectionControl selectionControl;
  final Widget? subContent;
  final bool isSelected;
  final FocusNode? focusNode;
  final bool disabled;
  final bool tradeLeadingForSelectionControl;
  final LdColor? color;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isOdd;
  final BoxShadow? shadow;

  final bool showDragHandle;

  final LdListItemDragConfig? dragCallbacks;

  final bool tradeTrailingForDragHandle;

  @ContextConfigurable()
  const LdListItemWidget({
    super.key,
    this.active = false,
    this.borderRadius,
    this.disabled = false,
    this.isSelected = false,
    this.leading,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.selectDisabled = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl = true,
    this.showDragHandle = false,
    this.dragCallbacks,
    this.tradeTrailingForDragHandle = true,
    this.shadow,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.isOdd = false,
    this.selectionControl = LdSelectionControl.none,
  });

  @override
  State<LdListItemWidget> createState() => _LdListItemWidgetState();
}

class _LdListItemWidgetState extends State<LdListItemWidget> with AutomaticKeepAliveClientMixin {
  final _innerContentKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  didUpdateWidget(LdListItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dragCallbacks?.isDragging != oldWidget.dragCallbacks?.isDragging) {
      updateKeepAlive();
    }
  }

  // We need to keep the item alive while it is being dragged so that
  // the drag callbacks are not lost.
  @override
  bool get wantKeepAlive => widget.dragCallbacks?.isDragging ?? false;

  Widget _buildSelectionControls(BuildContext context, bool disabledState) {
    if (widget.selectionControl == LdSelectionControl.none) return const SizedBox.shrink();
    return Row(
      children: [
        switch (widget.selectionControl) {
          LdSelectionControl.radio => ExcludeFocus(
              child: LdRadio(
                checked: widget.isSelected,
                color: widget.color,
                disabled: disabledState,
                onChanged: (value) {
                  widget.onSelectionChanged?.call(value);
                },
              ),
            ),
          LdSelectionControl.checkbox => ExcludeFocus(
              child: LdCheckbox(
                checked: widget.isSelected,
                color: widget.color,
                disabled: disabledState,
                onChanged: (value) {
                  widget.onSelectionChanged?.call(value);
                },
              ),
            ),
          LdSelectionControl.none => const SizedBox.shrink(),
        },
        ldSpacerM,
      ],
    );
  }

  Widget _buildIconTheme(Widget child, LdTheme theme) {
    return IconTheme(
      data: IconThemeData(
        color: theme.text,
        size: theme.labelSize(LdSize.l),
      ),
      child: child,
    );
  }

  Widget _buildLeading(BuildContext context, LdTheme theme) {
    if (widget.leading == null) return const SizedBox.shrink();
    return LdAvatarConfigProvider(
      config: LdAvatarConfig(
        color: widget.color,
      ),
      child: _buildIconTheme(
        LdReveal.quick(
          axes: const {Axis.horizontal},
          revealed: !(widget.selectionControl != LdSelectionControl.none && widget.tradeLeadingForSelectionControl),
          initialRevealed:
              !(widget.selectionControl != LdSelectionControl.none && widget.tradeLeadingForSelectionControl),
          child: Row(
            children: [
              widget.leading!,
              ldSpacerM,
            ],
          ),
        ),
        theme,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, LdTheme theme) {
    if (widget.trailing == null) return const SizedBox.shrink();
    return LdReveal.quick(
      axes: const {Axis.horizontal},
      revealed: !(widget.showDragHandle && widget.tradeTrailingForDragHandle),
      initialRevealed: !(widget.showDragHandle && widget.tradeTrailingForDragHandle),
      child: _buildIconTheme(
        Row(
          children: [ldSpacerM, widget.trailing!],
        ),
        theme,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, LdTheme theme) {
    if (widget.title == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.label,
        LdSize.m,
        color: theme.text,
      ),
      maxLines: 1,
      child: widget.title!,
    );
  }

  Widget _buildSubtitle(BuildContext context, LdTheme theme) {
    if (widget.subtitle == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.paragraph,
        lineHeight: 1.5,
        LdSize.s,
        color: theme.textMuted,
      ),
      maxLines: 1,
      child: widget.subtitle!,
    );
  }

  EdgeInsets _effectivePadding(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    if (widget.padding != null) return widget.padding!;
    return theme.balPad(LdSize.m);
  }

  Widget _buildSubContent(BuildContext context, LdTheme theme) {
    if (widget.subContent == null) return const SizedBox.shrink();
    return widget.subContent!;
  }

  bool get _isDisabled {
    return switch (widget.selectionControl) {
      (LdSelectionControl.none) => widget.disabled,
      (LdSelectionControl.radio) => widget.selectDisabled,
      (LdSelectionControl.checkbox) => widget.selectDisabled,
    };
  }

  Widget _buildInnerContent(BuildContext context, LdColorBundle? bundle) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      key: _innerContentKey,
      width: widget.width ?? double.infinity,
      padding: _effectivePadding(context),
      decoration: BoxDecoration(
        boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        color: bundle?.surface ?? context.surfaceColor,
        borderRadius: widget.borderRadius,
        border: bundle != null
            ? Border.all(
                color: bundle.border,
                width: theme.borderWidth,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: widget.width != double.infinity ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LdReveal.quick(
            key: Key("selection-controls"),
            axes: const {Axis.horizontal},
            revealed: widget.selectionControl != LdSelectionControl.none,
            initialRevealed: widget.selectionControl != LdSelectionControl.none,
            child: _buildSelectionControls(context, _isDisabled),
          ),
          if (widget.leading != null) _buildLeading(context, theme),
          Flexible(
            fit: widget.width != double.infinity ? FlexFit.tight : FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) _buildTitle(context, theme),
                if (widget.subtitle != null) _buildSubtitle(context, theme),
                if (widget.subContent != null) _buildSubContent(context, theme),
              ],
            ),
          ),
          if (widget.trailing != null) _buildTrailing(context, theme),
          LdReveal.quick(
            key: Key("drag-handle"),
            axes: const {Axis.horizontal},
            revealed: widget.showDragHandle,
            initialRevealed: widget.showDragHandle,
            child: Draggable(
                feedback: Icon(LucideIcons.gripHorizontal),
                onDragStarted: widget.dragCallbacks?.onDragStarted,
                onDragUpdate: widget.dragCallbacks?.onDragUpdate,
                onDragEnd: widget.dragCallbacks?.onDragEnd,
                onDraggableCanceled: widget.dragCallbacks?.onDragCanceled,
                child: Icon(LucideIcons.gripHorizontal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = LdTheme.of(context, listen: true);

    final isShuttle = Provider.of<LdIsShuttle?>(context, listen: true)?.value ?? false;
    final effectiveFocusNode = isShuttle ? null : widget.focusNode;

    final bool isInteractive = widget.selectionControl != LdSelectionControl.none || widget.onPressed != null;

    if (!isInteractive) {
      return _buildInnerContent(context, null);
    }

    return Opacity(
      opacity: widget.dragCallbacks?.isDragging ?? false ? 0.5 : 1.0,
      child: LdTouchableSurface(
        focusNode: effectiveFocusNode,
        isOdd: widget.isOdd,
        onPressed: () {
          if (widget.selectionControl != LdSelectionControl.none) {
            widget.onSelectionChanged?.call(!widget.isSelected);
          } else {
            widget.onPressed?.call();
          }
        },
        active: widget.active || (widget.selectionControl != LdSelectionControl.none && widget.isSelected),
        disabled: _isDisabled || (widget.dragCallbacks?.isDragging ?? false),
        builder: (contxt, status, _) {
          final colorBundle = neutralGhostColor(theme, status);
          return _buildInnerContent(context, colorBundle);
        },
      ),
    );
  }
}

class LdListDefaultTrailingForward extends StatelessWidget {
  const LdListDefaultTrailingForward({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Icon(
      LucideIcons.chevronRight,
      size: theme.labelSize(LdSize.l) * 1.2,
      color: theme.textMuted,
    );
  }
}
