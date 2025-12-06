import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';

enum AppBarPosition {
  top,
  bottom,
}

class LdAppBarScrollWrapper extends StatefulWidget {
  final Widget child;
  final AppBarPosition position;
  final LdAppBarScrollBehavior scrollBehavior;

  const LdAppBarScrollWrapper({
    super.key,
    required this.child,
    required this.position,
    required this.scrollBehavior,
  });

  @override
  State<LdAppBarScrollWrapper> createState() => LdAppBarScrollWrapperState();
}

class LdAppBarScrollWrapperState extends State<LdAppBarScrollWrapper> {
  double _lastScrollOffset = 0.0;
  ValueNotifier<double>? _scrollOffsetNotifier;
  AppBarRegistryState? _registryState;
  VoidCallback? _registryListener;
  LdAppBarRegistryKey? _registryKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the registry key from context
    _registryKey = context.maybeAppBarRegistryKey();

    // Find the scaffold's scroll offset ValueNotifier by walking the tree
    final scaffoldState = LdScaffoldState.maybeOf(context);
    if (scaffoldState != null) {
      _scrollOffsetNotifier = scaffoldState.bodyScrollOffset;
      _scrollOffsetNotifier?.addListener(_handleScrollOffsetChange);
    }

    // Find and listen to registry state
    final newRegistryState = AppBarRegistry.maybeStateOf(context);
    if (_registryState != newRegistryState) {
      if (_registryState != null && _registryListener != null) {
        _registryState!.removeListener(_registryListener!);
      }
      _registryListener = null;

      _registryState = newRegistryState;

      if (_registryState != null) {
        _registryListener = () {
          if (mounted) {
            setState(() {});
          }
        };
        _registryState!.addListener(_registryListener!);
      }
    }
  }

  @override
  void dispose() {
    _scrollOffsetNotifier?.removeListener(_handleScrollOffsetChange);
    if (_registryListener != null) {
      _registryState?.removeListener(_registryListener!);
    }
    super.dispose();
  }

  void _handleScrollOffsetChange() {
    if (_scrollOffsetNotifier == null || _registryState == null || _registryKey == null) {
      return;
    }

    final scrollOffset = _scrollOffsetNotifier!.value;
    final level = _registryState!.getLevel(_registryKey!, widget.position);
    final adjustedScrollOffset = scrollOffset - level * 150;

    final currentInfo = _registryState!.getAppBarInfo(_registryKey!);
    if (currentInfo == null) {
      _lastScrollOffset = adjustedScrollOffset;
      return;
    }
    final scrolledUnder = scrollOffset > 10;

    _updateAppBarOffset(adjustedScrollOffset, currentInfo, scrolledUnder);
    _lastScrollOffset = adjustedScrollOffset;
  }

  void _updateAppBarOffset(double scrollOffset, AppBarInfo currentInfo, bool scrolledUnder) {
    final double scrollDelta = scrollOffset - _lastScrollOffset;
    final bool isScrollingDown = scrollDelta > 0;
    final bool isScrollingUp = scrollDelta < 0;

    double maxOffset = currentInfo.innerHeight + currentInfo.verticalMargin;

    double newOffset;
    // Bottom appBar: hide downward (positive offset) down means delta is positive.
    if (isScrollingDown) {
      newOffset = min(currentInfo.offset + scrollDelta * 0.5, maxOffset);
    } else if (isScrollingUp) {
      newOffset = max(currentInfo.offset + scrollDelta, 0);
    } else {
      newOffset = currentInfo.offset;
    }

    // Update registry directly with new offset
    if (_registryState != null && _registryKey != null) {
      _registryState!.updateAppBarInfo(
        _registryKey!,
        currentInfo.copyWith(offset: newOffset, scrollUnder: scrolledUnder),
      );
    }
  }

  bool _shouldHideAppBar() {
    final isMobile = LdTheme.of(context).platform.isMobile;
    return switch (widget.scrollBehavior) {
      LdAppBarScrollBehavior.static => false,
      LdAppBarScrollBehavior.mobileOnly => isMobile,
      LdAppBarScrollBehavior.always => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final shouldHide = _shouldHideAppBar();
    final currentInfo =
        _registryState != null && _registryKey != null ? _registryState!.getAppBarInfo(_registryKey!) : null;
    final offset = currentInfo?.offset ?? 0.0;
    final effectiveOffset = widget.position == AppBarPosition.top ? -offset : offset;

    final positionedChild = ValueListenableBuilder<double>(
      valueListenable: _scrollOffsetNotifier ?? ValueNotifier(0.0),
      builder: (context, scrollValue, child) {
        return LdWrapConditional(
          condition: shouldHide,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, effectiveOffset),
            child: child,
          ),
          child: widget.child,
        );
      },
    );

    // Position the app bar in the stack, accounting for cumulative height
    if (widget.position == AppBarPosition.top) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: positionedChild,
      );
    } else {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: positionedChild,
      );
    }
  }
}
