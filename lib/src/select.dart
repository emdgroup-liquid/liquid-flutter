import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/input_color_bundle.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

class LdSelectItem<T> {
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
  final Function(T)? onChange;
  const LdSelect({
    required this.items,
    this.label,
    this.onChange,
    this.size = LdSize.m,
    this.placeholder,
    this.disabled = false,
    this.focusNode,
    this.value,
    this.valid = true,
    this.onSurface = false,
    Key? key,
  }) : super(key: key);

  @override
  State<LdSelect<T>> createState() => _LdSelectState<T>();
}

class _LdSelectState<T> extends State<LdSelect<T>> {
  // --- State and Controllers ---
  bool isOpen = false;
  late FocusNode? _focusNode;
  late FocusScopeNode? _focusNodeChildren;
  final _overlayController = OverlayPortalController();
  final _controller = ScrollController();
  final _menuKey = GlobalKey();

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

  /// Calculates dropdown constraints and offset to keep it within the screen
  (BoxConstraints, Offset) _insetDropdownSafely(
    BuildContext context,
    RenderBox menuBox,
  ) {
    final mediaQuery = MediaQuery.of(Scaffold.maybeOf(context)?.context ?? context);

    final screenSize = mediaQuery.size;

    final dy = menuBox.localToGlobal(Offset.zero).dy;

    final viewInsets = mediaQuery.viewPadding;

    final maxWidth = screenSize.width - viewInsets.right - viewInsets.left;
    final maxHeight = screenSize.height - viewInsets.bottom - dy;

    return (
      BoxConstraints(
        minWidth: menuBox.size.width,
        maxWidth: menuBox.size.width.clamp(0, maxWidth),
        minHeight: 0,
        maxHeight: maxHeight,
      ),
      Offset(
        menuBox.localToGlobal(Offset.zero).dx,
        dy,
      ),
    );
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
    return LdTouchableSurface(
      key: item.key ?? ValueKey(item.value),
      disabled: item.enabled == false,
      active: isActive,
      autoFocus: autoFocus,
      mode: LdTouchableSurfaceMode.neutralGhost,
      onTap: () async {
        setState(() {
          isOpen = false;
        });
        _overlayController.hide();
        LdHaptics.vibrate(HapticsType.selection);
        _focusNode?.requestFocus();
        widget.onChange?.call(item.value);
      },
      builder: (contxt, colorBundle, status) {
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
                child: Expanded(child: item.child),
                style: defaultTextStyle.copyWith(
                  color: colorBundle.text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the dropdown menu overlay
  Widget _buildDropdownMenuOverlay({
    required BuildContext context,
    required LdTheme theme,
    required LdSelectItem<T>? activeItem,
    required TextStyle defaultTextStyle,
  }) {
    final menuBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (menuBox == null) {
      return const SizedBox.shrink();
    }
    final (constraints, offset) = _insetDropdownSafely(context, menuBox);
    return Stack(
      children: [
        ModalBarrier(
          dismissible: true,
          color: Colors.transparent,
          onDismiss: () {
            setState(() {
              isOpen = false;
            });
            _overlayController.hide();
            _focusNode?.requestFocus();
          },
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: FocusScope(
            node: _focusNodeChildren,
            child: Column(
              children: [
                TapRegion(
                  onTapOutside: (details) {
                    setState(() {
                      isOpen = false;
                    });
                  },
                  child: LdSpring(
                    position: isOpen ? 1 : 0,
                    initialPosition: 0,
                    onAnimationEnd: (context, state) {
                      if (state.position == 0) {
                        _overlayController.hide();
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        constraints: constraints,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: theme.radius(LdSize.s),
                          boxShadow: [ldShadowSticky],
                          border: Border.all(
                            color: theme.palette.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: theme.balPad(widget.size),
                              child: DefaultTextStyle(
                                style: defaultTextStyle,
                                child: _buildInitialItem(
                                  activeItem,
                                  theme.textMuted,
                                  theme,
                                ),
                              ),
                            ),
                            const LdDivider(height: 1),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: ((constraints.maxHeight - menuBox.size.height) * state.position.clamp(0, 1)),
                                maxWidth: constraints.maxWidth,
                              ),
                              child: Scrollbar(
                                controller: _controller,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  controller: _controller,
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
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the dropdown button (the visible part before opening the menu)
  Widget _buildDropdownButton({
    required BuildContext context,
    required LdTheme theme,
    required LdSelectItem<T>? activeItem,
    required TextStyle defaultTextStyle,
  }) {
    final colors = LdInputColorBundle.fromTheme(
      theme,
      onSurface: widget.onSurface,
      isValid: widget.valid,
    ).fromTouchableStatus(LdTouchableStatus());
    final initialItem = DefaultTextStyle(
      child: _buildInitialItem(
        activeItem,
        colors.placeholder,
        theme,
      ),
      style: defaultTextStyle,
    );
    return Container(
      key: _menuKey,
      decoration: BoxDecoration(
        color: widget.onSurface ? theme.background : theme.surface,
        borderRadius: theme.radius(LdSize.s),
      ),
      child: LdTouchableSurface(
        disabled: widget.disabled,
        focusNode: _focusNode,
        onTap: () async {
          setState(() {
            isOpen = true;
          });
          _overlayController.show();
          await Future.delayed(const Duration(milliseconds: 200));
          final selectedIndex = widget.items.indexWhere((element) => element.value == widget.value);
          if (selectedIndex == -1) {
            return;
          }
          final fraction = selectedIndex / widget.items.length;
          _controller.animateTo(
            _controller.position.maxScrollExtent * fraction,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          _focusNodeChildren?.requestFocus();
        },
        color: theme.palette.primary,
        builder: (context, _, status) {
          final colors = LdInputColorBundle.fromTheme(
            theme,
            onSurface: widget.onSurface,
            isValid: widget.valid,
          ).fromTouchableStatus(status);
          final initialItem = DefaultTextStyle(
            child: _buildInitialItem(
              activeItem,
              colors.placeholder,
              theme,
            ),
            style: defaultTextStyle,
          );
          return Container(
            width: double.infinity,
            padding: theme.balPad(widget.size),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: theme.radius(LdSize.s),
              border: Border.all(
                color: colors.border,
                width: 1.5,
              ),
            ),
            child: initialItem,
          );
        },
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
      lineHeight: 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Include label if not null
        LdFormLabel(label: widget.label, size: size),
        Builder(
          builder: (context) {
            return OverlayPortal.targetsRootOverlay(
              controller: _overlayController,
              overlayChildBuilder: (context) => _buildDropdownMenuOverlay(
                context: context,
                theme: theme,
                activeItem: activeItem,
                defaultTextStyle: defaultTextStyle,
              ),
              child: _buildDropdownButton(
                context: context,
                theme: theme,
                activeItem: activeItem,
                defaultTextStyle: defaultTextStyle,
              ),
            );
          },
        ),
      ],
    );
  }
}
