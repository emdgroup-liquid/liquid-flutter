import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/size_reporting_widget.dart';
import 'package:liquid_flutter/src/spring.dart';

class LdExpandablePageView extends StatefulWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool reverse;

  const LdExpandablePageView({
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    super.key,
  });

  @override
  LdExpandablePageViewState createState() => LdExpandablePageViewState();
}

class LdExpandablePageViewState extends State<LdExpandablePageView> {
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
      builder: (context, state, child) => SizedBox(
        height: state.position.clamp(0, double.infinity),
        child: child,
      ),
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: _itemBuilder,
        onPageChanged: widget.onPageChanged,
        reverse: widget.reverse,
      ),
    );
  }

  void _onSizeChange(int index, double height) {
    if (_heights[index] == height) {
      return;
    }

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
