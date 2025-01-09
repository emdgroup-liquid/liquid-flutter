import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/input_color_bundle.dart';

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
  const LdSelect(
      {required this.items,
      this.label,
      this.onChange,
      this.size = LdSize.m,
      this.placeholder,
      this.disabled = false,
      this.focusNode,
      this.value,
      this.valid = true,
      this.onSurface = false,
      Key? key})
      : super(key: key);

  @override
  State<LdSelect<T>> createState() => _LdSelectState<T>();
}

class _LdSelectState<T> extends State<LdSelect<T>> {
  bool isOpen = false;

  late FocusNode? _focusNode;

  final _controller = ScrollController();

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInitialItem(
      LdSelectItem<T>? activeItem, Color placeholderColor, LdTheme theme) {
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

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    final size = widget.size;

    var activeItem = widget.items
        .firstWhereOrNull((element) => element.value == widget.value);

    return DefaultTextStyle(
      style: TextStyle(
          color: widget.disabled ? theme.textMuted : theme.text,
          package: theme.fontFamilyPackage,
          fontFamily: theme.fontFamily,
          fontSize: theme.paragraphSize(size),
          height: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Include label if not null
          LdFormLabel(label: widget.label, size: size),
          Focus(
            focusNode: _focusNode,
            child: Builder(builder: (context) {
              return PortalTarget(
                visible: isOpen,
                anchor: const Aligned(
                  widthFactor: 1,
                  follower: Alignment.topCenter,
                  shiftToWithinBound: AxisFlag(y: true),
                  target: Alignment.topCenter,
                ),
                portalFollower: SafeArea(
                    child: Container(
                        clipBehavior: Clip.hardEdge,
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
                              padding: theme.balPad(size),
                              child: _buildInitialItem(
                                activeItem,
                                theme.textMuted,
                                theme,
                              ),
                            ),
                            const LdDivider(
                              height: 1,
                            ),
                            Scrollbar(
                              controller: _controller,
                              thumbVisibility: true,
                              child: ListView.separated(
                                shrinkWrap: true,
                                controller: _controller,
                                itemCount: widget.items.length,
                                separatorBuilder: (context, index) =>
                                    const LdDivider(
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  var e = widget.items[index];

                                  return LdTouchableSurface(
                                    key: e.key ?? ValueKey(e.value),
                                    disabled: e.enabled == false,
                                    active: activeItem == e,
                                    mode: LdTouchableSurfaceMode.neutralGhost,
                                    onTap: () {
                                      setState(() {
                                        isOpen = false;
                                      });
                                      widget.onChange?.call(e.value);
                                    },
                                    builder: (contxt, colorBundle, status) {
                                      return Container(
                                        padding: theme.balPad(size),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: colorBundle.surface,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              child: activeItem == e
                                                  ? Icon(
                                                      Icons.done,
                                                      color: colorBundle.text,
                                                      size: 12,
                                                    )
                                                  : null,
                                            ),
                                            ldSpacerS,
                                            DefaultTextStyle(
                                              child: Expanded(child: e.child),
                                              style: TextStyle(
                                                color: colorBundle.text,
                                                package:
                                                    theme.fontFamilyPackage,
                                                fontFamily: theme.fontFamily,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ).animate().custom(
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animation, child) {
                                    return ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5 *
                                              animation,
                                        ),
                                        child: child);
                                  }),
                            ),
                          ],
                        ))),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.onSurface ? theme.background : theme.surface,
                    borderRadius: theme.radius(LdSize.s),
                  ),
                  child: LdTouchableSurface(
                      disabled: widget.disabled,
                      onTap: () async {
                        setState(() {
                          isOpen = true;
                        });

                        await Future.delayed(const Duration(milliseconds: 200));

                        final selectedIndex = widget.items.indexWhere(
                            (element) => element.value == widget.value);

                        if (selectedIndex == -1) {
                          return;
                        }

                        final fraction = selectedIndex / widget.items.length;

                        _controller.animateTo(
                          _controller.position.maxScrollExtent * fraction,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                      color: theme.palette.primary,
                      builder: (context, _, status) {
                        final colors = LdInputColorBundle.fromTheme(
                          theme,
                          onSurface: widget.onSurface,
                          isValid: widget.valid,
                        ).fromTouchableStatus(status);

                        final initialItem = _buildInitialItem(
                          activeItem,
                          colors.placeholder,
                          theme,
                        );

                        return Container(
                          width: double.infinity,
                          padding: theme.balPad(size),
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
                      }),
                ),
              );
            }),
          ),
          PortalTarget(
            child: Container(),
            visible: isOpen,
            portalFollower: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withAlpha(0)),
              ),
              onTap: () {
                setState(() {
                  isOpen = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
