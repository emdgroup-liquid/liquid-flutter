import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/spring.dart';

class ExpandablePageView extends StatefulWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool reverse;

  const ExpandablePageView({
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    super.key,
  });

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  PageController? _pageController;
  Map<int, double> _heights = {};
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage] ?? 0;

  @override
  void initState() {
    super.initState();
    _heights = {};
    _pageController = widget.controller ?? PageController();
    _currentPage = _pageController?.initialPage ?? 0;
    _pageController?.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController?.removeListener(_updatePage);
    if (widget.controller == null) _pageController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdSpring(
      position: _currentHeight,
      builder: (context, state) => SizedBox(
        height: state.position.clamp(0, double.infinity),
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: _itemBuilder,
          onPageChanged: widget.onPageChanged,
          reverse: widget.reverse,
        ),
      ),
    );
  }

  void _onSizeChange(int index, double height) {
    setState(() {
      _heights[index] = height;
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.itemBuilder(context, index);
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: SizeReportingWidget(
        onSizeChange: (size) => _onSizeChange(index, size.height),
        child: item,
      ),
    );
  }

  void _updatePage() {
    final newPage = _pageController?.page?.round();

    if (_currentPage != newPage || _currentHeight != _heights[newPage ?? 0]) {
      setState(() {
        _currentPage = newPage ?? _currentPage;
      });
    }
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    required this.child,
    required this.onSizeChange,
    super.key,
  });

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) {
      return;
    }
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      if (size != null) widget.onSizeChange(size);
    }
  }
}
