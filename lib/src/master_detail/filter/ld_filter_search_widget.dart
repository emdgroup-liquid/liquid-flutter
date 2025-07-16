import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        final query = await Navigator.of(context, rootNavigator: true).push<String>(
          _SearchRoute(
            searchFilter: widget.filter,
            onSearch: (value) {
              widget.filter.searchText = value;
              widget.filter.isOn = value.isNotEmpty;
              widget.onFilterChanged(widget.filter);
            },
            triggerRect: _getTriggerRect(),
          ),
        );
        setState(() {
          _disabled = false;
        });
        if (query == null) {
          return;
        }
        _controller.text = query;
        widget.filter.searchText = query;
        widget.filter.isOn = query.isNotEmpty;
        widget.onFilterChanged(widget.filter);
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
    final isTop =
        _getTriggerRect()?.center.dy != null && _getTriggerRect()!.center.dy < MediaQuery.sizeOf(context).height / 2;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () {
          _triggerNode.requestFocus();
        },
      },
      child: Padding(
        padding: !isTop ? LdTheme.of(context).pad().copyWith(left: 0, right: 0) : EdgeInsets.zero,
        child: LdInput(
          focusNode: _triggerNode,
          leading: const Icon(Icons.search),
          key: _triggerKey,
          disabled: _disabled,
          hint: widget.filter.hint ?? LiquidLocalizations.of(context).search,
          controller: _controller,
        ),
      ),
    );
  }
}

class _SearchRoute<T extends Identifiable<IdType>, IdType, Suggestion> extends ModalRoute<String> {
  final LdFilterSearchOption<T, IdType, Suggestion> searchFilter;

  final Rect? triggerRect;

  final Function(String) onSearch;

  _SearchRoute({required this.searchFilter, this.triggerRect, required this.onSearch});

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final size = MediaQuery.sizeOf(context);

    // Check if triggerRect is in the top or bottom of the view
    // We'll consider "top" if the center of the rect is in the upper half of the view, otherwise "bottom"
    final bool isTop = triggerRect != null ? (triggerRect!.center.dy < size.height / 2) : true;

    final left = triggerRect?.left ?? 0;
    final width = triggerRect?.width ?? 100;

    final top = isTop ? max(triggerRect!.top, viewInsets.top) : null;
    final bottom = isTop ? null : max(size.height - triggerRect!.bottom, viewInsets.bottom);

    return Stack(
      children: [
        Positioned(
          top: top,
          bottom: bottom,
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

  void _onSearchChanged(String? value) {
    _suggestionTimer?.cancel();
    _suggestionTimer = Timer(const Duration(milliseconds: 100), () {
      _suggestionController.trigger();
    });
  }

  @override
  void dispose() {
    _suggestionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FocusTraversalGroup(
        child: LdSubmit<List<Suggestion>, void>(
          controller: _suggestionController,
          builder: LdSubmitCustomBuilder<List<Suggestion>, void>(
            builder: (context, controller, state) => DecoratedBox(
              decoration: BoxDecoration(
                color: LdTheme.of(context).neutralShade(2),
                borderRadius: LdTheme.of(context).radius(LdSize.s),
                border: Border.all(
                  color: LdTheme.of(context).border,
                  width: 1,
                ),
                boxShadow: [
                  ldShadowSticky,
                ],
              ),
              child: FocusTraversalGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdInput(
                      controller: _controller,
                      autofocus: true,
                      leading: const Icon(Icons.search),
                      hint: widget.filter.hint ?? LiquidLocalizations.of(context).search,
                      onChanged: _onSearchChanged,
                      onClear: () {
                        Navigator.of(context).maybePop('');
                      },
                      onSubmitted: (value) {
                        Navigator.of(context).maybePop(value ?? '');
                      },
                    ),
                    if (controller.state.result?.isNotEmpty ?? false)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => const LdDivider(),
                          itemCount: controller.state.result?.length ?? 0,
                          itemBuilder: (context, index) =>
                              widget.filter.buildSuggestion?.call(context, controller.state.result![index]) ??
                              LdListItem(
                                borderRadius: LdTheme.of(context).radius(LdSize.s),
                                onTap: () {
                                  _controller.text = controller.state.result![index].toString();
                                  Navigator.of(context).maybePop(controller.state.result![index].toString());
                                },
                                title: Text(
                                  controller.state.result![index].toString(),
                                ),
                              ),
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
