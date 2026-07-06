import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';

class LdSelectItem<T> with Identifiable<T> {
  @override
  T get id => value;

  final T value;
  final Key? key;
  final Widget child;
  final bool enabled;
  final String? searchString;

  const LdSelectItem({
    required this.value,
    this.key,
    required this.child,
    this.enabled = true,
    this.searchString,
  });
}

/// a wrapper around [DropdownButton]
class LdSelect<T> extends StatefulWidget {
  final String? label;
  final List<LdSelectItem<T>> items;
  final bool disabled;
  final LdSize size;
  final String? placeholder;
  final bool onSurface;
  final T? value;
  final FocusNode? focusNode;
  final bool valid;
  final Function(T)? onChanged;
  const LdSelect({
    required this.items,
    this.label,
    this.onChanged,
    this.size = LdSize.m,
    this.placeholder,
    this.disabled = false,
    this.focusNode,
    this.value,
    this.valid = true,
    this.onSurface = false,
    super.key,
  });

  @override
  State<LdSelect<T>> createState() => _LdSelectState<T>();
}

class _LdSelectState<T> extends State<LdSelect<T>> {
  // --- State and Controllers ---
  late FocusNode? _focusNode;
  late FocusScopeNode? _focusNodeChildren;
  final _controller = ScrollController();

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNodeChildren = FocusScopeNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller.dispose();
    _focusNodeChildren?.dispose();
    super.dispose();
  }

  /// Builds the initial item (selected or placeholder)
  Widget _buildInitialItem(LdSelectItem<T>? activeItem, Color placeholderColor, LdTheme theme) {
    return Row(
      children: [
        Expanded(
          child: activeItem?.child ??
              Text(
                widget.placeholder ?? "Select...",
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.label,
                  widget.size,
                  color: placeholderColor,
                ),
              ),
        ),
        Icon(
          Icons.expand_more,
          color: theme.primaryColor,
          size: theme.labelSize(widget.size),
        )
      ],
    );
  }

  /// Builds a single dropdown item
  Widget _buildDropdownItem({
    required BuildContext context,
    required LdSelectItem<T> item,
    required bool isActive,
    required bool autoFocus,
    required LdTheme theme,
    required TextStyle defaultTextStyle,
  }) {
    return ScrollIntoView(
      scroll: isActive,
      child: LdTouchableSurface(
        key: item.key ?? ValueKey(item.value),
        disabled: item.enabled == false,
        active: isActive,
        autoFocus: autoFocus,
        onPressed: () async {
          Navigator.of(context).pop();
          LdHaptics.vibrate(HapticsType.selection);
          _focusNode?.requestFocus();
          widget.onChanged?.call(item.value);
        },
        builder: (contxt, status, _) => Builder(builder: (context) {
          final colorBundle = neutralGhostColor(theme, status);
          return Container(
            padding: theme.balPad(widget.size),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorBundle.surface,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  child: isActive
                      ? Icon(
                          Icons.done,
                          color: colorBundle.text,
                          size: 12,
                        )
                      : null,
                ),
                ldSpacerS,
                DefaultTextStyle(
                  style: defaultTextStyle.copyWith(
                    color: colorBundle.text,
                  ),
                  child: Expanded(child: item.child),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Builds the dropdown menu content
  Widget _buildDropdownMenu({
    required BuildContext context,
    required LdTheme theme,
    required LdSelectItem<T>? activeItem,
    required TextStyle defaultTextStyle,
  }) {
    return FocusScope(
      node: _focusNodeChildren,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: ListView.separated(
          shrinkWrap: true,
          controller: _controller,
          padding: EdgeInsets.zero,
          itemCount: widget.items.length,
          separatorBuilder: (context, index) => const LdDivider(height: 1),
          itemBuilder: (context, index) {
            var e = widget.items[index];
            final isActive = activeItem == e;
            final autoFocus = isActive || (activeItem == null && index == 0);
            return _buildDropdownItem(
              context: context,
              item: e,
              isActive: isActive,
              autoFocus: autoFocus,
              theme: theme,
              defaultTextStyle: defaultTextStyle,
            );
          },
        ),
      ),
    );
  }

  /// Builds the dropdown button (the visible part before opening the menu)
  Widget _buildDropdownButton({
    required BuildContext context,
    required LdTheme theme,
    required LdSelectItem<T>? activeItem,
    required TextStyle defaultTextStyle,
    required VoidCallback open,
    required bool isOpen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.onSurface ? theme.background : theme.surface,
        borderRadius: theme.radius(LdSize.s),
      ),
      child: LdTouchableSurface(
        disabled: widget.disabled,
        focusNode: _focusNode,
        onPressed: () {
          open();
          _focusNodeChildren?.requestFocus();
        },
        active: isOpen,
        builder: (context, status, _) => Builder(builder: (context) {
          final colorBundle = inputColor(theme, status, isValid: widget.valid);
          final initialItem = DefaultTextStyle(
            style: defaultTextStyle,
            child: _buildInitialItem(activeItem, colorBundle.placeholder, theme),
          );
          return Container(
            width: double.infinity,
            padding: theme.balPad(widget.size),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: colorBundle.surface,
              borderRadius: theme.radius(LdSize.s),
              border: Border.all(
                color: colorBundle.border,
                width: 1.5,
              ),
            ),
            child: initialItem,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    final size = widget.size;
    var activeItem = widget.items.firstWhereOrNull((element) => element.value == widget.value);
    final defaultTextStyle = ldBuildTextStyle(
      theme,
      LdTextType.label,
      size,
      color: widget.disabled ? theme.textMuted : theme.text,
      lineHeight: 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Include label if not null
        if (widget.label != null)
          LdText.l(
            widget.label!,
            size: size,
          ),
        LdContextMenu(
          positionMode: LdContextPositionMode.relativeTrigger,
          zoomMode: LdContextZoomMode.never,
          dismissOnOutsideTap: true,
          inheritTriggerWidth: true,
          scaleFromTrigger: false,
          placeAboveTrigger: true,
          builder: (context, isShuttle, open, isOpen, child) {
            return _buildDropdownButton(
              context: context,
              isOpen: isOpen,
              theme: theme,
              activeItem: activeItem,
              defaultTextStyle: defaultTextStyle,
              open: open,
            );
          },
          menuBuilder: (context) {
            return _buildDropdownMenu(
              context: context,
              theme: theme,
              activeItem: activeItem,
              defaultTextStyle: defaultTextStyle,
            );
          },
        ),
      ],
    ).spaceS();
  }
}

class ScrollIntoView extends StatelessWidget {
  final bool scroll;
  final Widget child;
  const ScrollIntoView({super.key, required this.scroll, required this.child});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      }
    });
    return child;
  }
}
