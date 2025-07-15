import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterSearchWidget<T extends Identifiable<IdType>, IdType, Suggestion> extends StatefulWidget {
  const LdFilterSearchWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final LdFilterSearchOption<T, IdType, Suggestion> filter;
  final void Function(LdFilterSearchOption<T, IdType, Suggestion> filter) onFilterChanged;

  @override
  State<LdFilterSearchWidget<T, IdType, Suggestion>> createState() =>
      _LdFilterSearchWidgetState<T, IdType, Suggestion>();
}

class _LdFilterSearchWidgetState<T extends Identifiable<IdType>, IdType, Suggestion>
    extends State<LdFilterSearchWidget<T, IdType, Suggestion>> {
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _triggerNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _disabled = false;

  @override
  void initState() {
    super.initState();

    _triggerNode.addListener(() async {
      if (_triggerNode.hasFocus) {
        setState(() {
          _disabled = true;
        });
        await Navigator.of(context, rootNavigator: true).push(
          _SearchRoute(
            searchFilter: widget.filter,
            triggerRect: _getTriggerRect(),
          ),
        );
        _controller.text = widget.filter.searchText;
        setState(() {
          _disabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _triggerNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  RenderBox? _getInputRenderBox() {
    return _triggerKey.currentContext?.findRenderObject() as RenderBox?;
  }

  Offset _getInputPosition() {
    final renderObject = _getInputRenderBox();
    return renderObject?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Rect? _getTriggerRect() {
    final renderObject = _getInputRenderBox();
    return Rect.fromLTWH(
      _getInputPosition().dx,
      _getInputPosition().dy,
      renderObject?.size.width ?? 0,
      renderObject?.size.height ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdInput(
      focusNode: _triggerNode,
      key: _triggerKey,
      disabled: _disabled,
      hint: widget.filter.hint ?? LiquidLocalizations.of(context).search,
      controller: _controller,
    );
  }
}

class _SearchRoute<T extends Identifiable<IdType>, IdType, Suggestion> extends ModalRoute<void> {
  final LdFilterSearchOption<T, IdType, Suggestion> searchFilter;

  final Rect? triggerRect;

  _SearchRoute({required this.searchFilter, this.triggerRect});

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final size = MediaQuery.sizeOf(context);

    // Check if triggerRect is in the top or bottom of the view
    // We'll consider "top" if the center of the rect is in the upper half of the view, otherwise "bottom"
    final bool isTop = triggerRect != null ? (triggerRect!.center.dy < size.height / 2) : true;

    final left = triggerRect?.left ?? 0;
    final width = triggerRect?.width ?? 100;

    return Stack(
      children: [
        Positioned(
          top: isTop ? max(triggerRect!.top, viewInsets.top) : null,
          bottom: isTop ? null : min(triggerRect!.bottom, viewInsets.bottom),
          left: left,
          width: width,
          child: _SearchWidget(
            filter: searchFilter,
            isTop: isTop,
          ),
        ),
      ],
    );
  }

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class _SearchWidget<T extends Identifiable<IdType>, IdType, Suggestion> extends StatefulWidget {
  const _SearchWidget({required this.filter, required this.isTop});

  final bool isTop;

  final LdFilterSearchOption<T, IdType, Suggestion> filter;

  @override
  State<_SearchWidget<T, IdType, Suggestion>> createState() => _SearchWidgetState<T, IdType, Suggestion>();
}

class _SearchWidgetState<T extends Identifiable<IdType>, IdType, Suggestion>
    extends State<_SearchWidget<T, IdType, Suggestion>> {
  Timer? _debounceTimer;
  Timer? _suggestionTimer;
  late final _controller = TextEditingController(text: widget.filter.searchText);

  late final LdSubmitController<List<Suggestion>, String> _suggestionController = LdSubmitController(
    config: LdSubmitConfig(
      withHaptics: false,
      action: _fetchSuggestions,
    ),
  );

  Future<List<Suggestion>> _fetchSuggestions(void arg) async {
    final query = _controller.text;

    if (query.isEmpty) {
      return [];
    }

    final suggestsions = await widget.filter.getSuggestions?.call(query);

    return suggestsions as List<Suggestion>;
  }

  @override
  void initState() {
    super.initState();
  }

  void _triggerSearch(String value) {
    widget.filter.searchText = value;
    widget.filter.isOn = widget.filter.searchText.isNotEmpty;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer

    _debounceTimer = Timer(widget.filter.debounceDelay, () {});
  }

  void _onSearchChanged(String? value) {
    _triggerSearch(value ?? '');

    _suggestionTimer?.cancel();
    _suggestionTimer = Timer(const Duration(milliseconds: 100), () {
      _suggestionController.trigger();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _suggestionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LdSpring(
        position: 1,
        initialPosition: 0,
        builder: (context, state, child) => Container(
          padding: widget.isTop ? LdTheme.of(context).pad() * state.position.clamp(0, 2) : null,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: LdTheme.of(context).neutralShade(2),
            boxShadow: [
              ldShadowSticky,
            ],
            borderRadius: LdTheme.of(context).radius(LdSize.s),
          ),
          child: child,
        ),
        child: FocusTraversalGroup(
          child: LdSubmit<List<Suggestion>, void>(
            controller: _suggestionController,
            builder: LdSubmitCustomBuilder<List<Suggestion>, void>(
              builder: (context, controller, state) => FocusTraversalGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdInput(
                      controller: _controller,
                      autofocus: true,
                      hint: widget.filter.hint ?? LiquidLocalizations.of(context).search,
                      onChanged: _onSearchChanged,
                      showClear: true,
                      onClear: () {
                        _triggerSearch('');
                        Navigator.of(context).maybePop();
                      },
                      onSubmitted: (value) {
                        _triggerSearch(value ?? '');
                        Navigator.of(context).maybePop();
                      },
                    ),
                    if (controller.state.result?.isNotEmpty ?? false)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            ...controller.state.result!.mapIndexed(
                              (index, e) =>
                                  widget.filter.buildSuggestion?.call(context, e) ??
                                  LdListItem(
                                    borderRadius: LdTheme.of(context).radius(LdSize.s),
                                    onTap: () {
                                      _controller.text = e.toString();
                                      _triggerSearch(e.toString());
                                      Navigator.of(context).maybePop();
                                    },
                                    title: Text(
                                      e.toString(),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ].reverseIf(!widget.isTop),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _ConditionalReverse on List<Widget> {
  List<Widget> reverseIf(bool condition) {
    if (condition) {
      return reversed.toList();
    }
    return this;
  }
}
