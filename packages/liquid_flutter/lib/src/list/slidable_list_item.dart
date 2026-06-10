import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';

/// Post-trigger behavior for a slide action.
enum LdSlideActionDismissBehavior {
  /// Invoke [LdSlideAction.onTriggered], then spring the row closed.
  snapBack,

  /// Collapse the row with [LdReveal], then invoke [LdSlideAction.onTriggered]
  /// when the animation completes.
  dismiss,
}

/// A single action revealed when sliding a list item.
class LdSlideAction {
  const LdSlideAction({
    required this.onTriggered,
    this.icon,
    this.label,
    this.color,
    this.flex = 1,
    this.dismissBehavior = LdSlideActionDismissBehavior.snapBack,
  });

  final void Function(BuildContext context) onTriggered;
  final IconData? icon;
  final String? label;
  final LdColor? color;
  final int flex;
  final LdSlideActionDismissBehavior dismissBehavior;
}

/// A group of slide actions on one side of a list item.
class LdSlideActionPane {
  const LdSlideActionPane({
    required this.actions,
    this.threshold = 1.0,
  }) : assert(actions.length > 0);

  final List<LdSlideAction> actions;

  /// Fraction of the cumulative action width that must be revealed on release
  /// before swipe-through auto-triggers. At [1.0], each action fires only once it is
  /// fully visible when the drag ends.
  final double threshold;
}

/// Coordinates slidable list items so only one row stays open at a time.
class LdSlidableGroup extends StatefulWidget {
  const LdSlidableGroup({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<LdSlidableGroup> createState() => _LdSlidableGroupState();
}

class _LdSlidableGroupState extends State<LdSlidableGroup> {
  _LdSlidableListItemState? _openItem;

  void registerOpen(_LdSlidableListItemState item) {
    if (_openItem != null && _openItem != item) {
      _openItem!._close(animated: true);
    }
    _openItem = item;
  }

  void unregister(_LdSlidableListItemState item) {
    if (_openItem == item) {
      _openItem = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _openItem?._close(animated: true);
        }
        return false;
      },
      child: widget.child,
    );
  }
}

/// Wraps a list row and reveals slide actions on horizontal drag.
class LdSlidableListItem extends StatefulWidget {
  const LdSlidableListItem({
    required this.child,
    this.startActionPane,
    this.endActionPane,
    this.closeOnScroll = true,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final LdSlideActionPane? startActionPane;
  final LdSlideActionPane? endActionPane;
  final bool closeOnScroll;
  final bool enabled;

  @override
  State<LdSlidableListItem> createState() => _LdSlidableListItemState();
}

class _LdSlidableListItemState extends State<LdSlidableListItem> {
  static const _dragSlop = 8.0;
  static const _openThreshold = 0.4;
  static const _actionBaseWidth = 72.0;

  double _offset = 0;
  double _animationStart = 0;
  double _animationEnd = 0;
  bool _isDragging = false;
  bool _isAnimating = false;
  bool _isDismissing = false;
  bool _dragAxisResolved = false;
  bool _triggeredDuringGesture = false;
  bool _openedAtDragStart = false;
  int _animationKey = 0;
  LdSlideAction? _pendingDismissAction;

  Offset? _dragStartPosition;
  _LdSlidableGroupState? _group;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = context.findAncestorStateOfType<_LdSlidableGroupState>();
  }

  @override
  void dispose() {
    _group?.unregister(this);
    super.dispose();
  }

  int get _startFlex => widget.startActionPane?.actions.fold<int>(0, (sum, action) => sum + action.flex) ?? 0;

  int get _endFlex => widget.endActionPane?.actions.fold<int>(0, (sum, action) => sum + action.flex) ?? 0;

  double get _startPaneWidth => _startFlex * _actionBaseWidth;

  double get _endPaneWidth => _endFlex * _actionBaseWidth;

  bool get _isOpen => _offset.abs() > 0.5;

  void _close({required bool animated}) {
    if (_isDismissing) {
      return;
    }
    _animateTo(0, animated: animated);
  }

  void _animateTo(double target, {required bool animated}) {
    if (!animated || ldDisableAnimations) {
      setState(() {
        _offset = target;
        _isAnimating = false;
        _isDragging = false;
      });
      if (target == 0) {
        _group?.unregister(this);
      }
      return;
    }

    setState(() {
      _animationStart = _offset;
      _animationEnd = target;
      _offset = target;
      _isAnimating = true;
      _isDragging = false;
      _animationKey++;
    });
  }

  double _clampOffset(double value) {
    return value.clamp(-_endPaneWidth, _startPaneWidth);
  }

  List<double> _actionWidths(LdSlideActionPane pane, double paneWidth) {
    final totalFlex = pane.actions.fold<int>(0, (sum, action) => sum + action.flex);
    return pane.actions.map((action) => paneWidth * action.flex / totalFlex).toList(growable: false);
  }

  int? _actionIndexForCommit(
    double extent,
    LdSlideActionPane pane,
    double paneWidth,
  ) {
    final widths = _actionWidths(pane, paneWidth);
    var cumulative = 0.0;
    int? deepestQualified;

    for (var i = 0; i < pane.actions.length; i++) {
      cumulative += widths[i];
      if (extent >= cumulative * pane.threshold) {
        deepestQualified = i;
      }
    }

    return deepestQualified;
  }

  void _handleTrigger(LdSlideAction action) {
    if (_triggeredDuringGesture || _isDismissing) {
      return;
    }

    _triggeredDuringGesture = true;

    switch (action.dismissBehavior) {
      case LdSlideActionDismissBehavior.snapBack:
        action.onTriggered(context);
        _animateTo(0, animated: true);
      case LdSlideActionDismissBehavior.dismiss:
        _pendingDismissAction = action;
        setState(() {
          _isDismissing = true;
        });
        _animateTo(0, animated: true);
    }
  }

  /// Evaluates swipe-through on drag release when [offset] exceeds an action threshold.
  void _maybeAutoTriggerOnRelease(double offset) {
    if (_triggeredDuringGesture || _isDismissing) {
      return;
    }

    if (offset > 0 && widget.startActionPane != null) {
      final index = _actionIndexForCommit(
        offset,
        widget.startActionPane!,
        _startPaneWidth,
      );
      if (index != null) {
        _handleTrigger(widget.startActionPane!.actions[index]);
      }
      return;
    }

    if (offset < 0 && widget.endActionPane != null) {
      final index = _actionIndexForCommit(
        offset.abs(),
        widget.endActionPane!,
        _endPaneWidth,
      );
      if (index != null) {
        _handleTrigger(widget.endActionPane!.actions[index]);
      }
    }
  }

  double _snapThresholdPx(double paneWidth, double extent) {
    return _openedAtDragStart && extent < paneWidth
        ? paneWidth / 2
        : paneWidth * _openThreshold;
  }

  double _openTargetForPane({
    required double offset,
    required double paneWidth,
    required bool isStart,
  }) {
    final extent = offset.abs();
    if (extent == 0) {
      return 0;
    }

    final snapOpen = isStart ? paneWidth : -paneWidth;
    final threshold = _snapThresholdPx(paneWidth, extent);

    return extent >= threshold ? snapOpen : 0.0;
  }

  void _maybeHapticOnDragUpdate(double previousOffset, double nextOffset) {
    if (nextOffset > 0 && widget.startActionPane != null) {
      _maybeHapticForPane(
        previousExtent: previousOffset > 0 ? previousOffset : 0,
        nextExtent: nextOffset,
        pane: widget.startActionPane!,
        paneWidth: _startPaneWidth,
      );
      return;
    }

    if (nextOffset < 0 && widget.endActionPane != null) {
      _maybeHapticForPane(
        previousExtent: previousOffset < 0 ? previousOffset.abs() : 0,
        nextExtent: nextOffset.abs(),
        pane: widget.endActionPane!,
        paneWidth: _endPaneWidth,
      );
    }
  }

  void _maybeHapticForPane({
    required double previousExtent,
    required double nextExtent,
    required LdSlideActionPane pane,
    required double paneWidth,
  }) {
    final previousCommitIndex = _actionIndexForCommit(previousExtent, pane, paneWidth);
    final commitIndex = _actionIndexForCommit(nextExtent, pane, paneWidth);

    if (commitIndex != null &&
        commitIndex != previousCommitIndex &&
        (previousCommitIndex == null || commitIndex > previousCommitIndex)) {
      LdHaptics.vibrate(HapticsType.heavy);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled || _isDismissing) {
      return;
    }

    _dragStartPosition = details.localPosition;
    _dragAxisResolved = false;
    _triggeredDuringGesture = false;
    _openedAtDragStart = _isOpen;
    _isDragging = true;
    _isAnimating = false;
    _group?.registerOpen(this);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _isDismissing || !_isDragging) {
      return;
    }

    final start = _dragStartPosition;
    if (start == null) {
      return;
    }

    final delta = details.localPosition - start;
    if (!_dragAxisResolved) {
      if (delta.dx.abs() < _dragSlop && delta.dy.abs() < _dragSlop) {
        return;
      }
      if (delta.dy.abs() > delta.dx.abs()) {
        _isDragging = false;
        return;
      }
      _dragAxisResolved = true;
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dragDelta = isRtl ? -details.delta.dx : details.delta.dx;
    final previousOffset = _offset;
    final nextOffset = _clampOffset(_offset + dragDelta);

    _maybeHapticOnDragUpdate(previousOffset, nextOffset);

    setState(() {
      _offset = nextOffset;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled || _isDismissing || !_isDragging) {
      return;
    }

    if (!_dragAxisResolved) {
      setState(() {
        _isDragging = false;
      });
      return;
    }

    if (_triggeredDuringGesture) {
      setState(() {
        _isDragging = false;
      });
      return;
    }

    _maybeAutoTriggerOnRelease(_offset);

    if (_triggeredDuringGesture) {
      setState(() {
        _isDragging = false;
      });
      return;
    }

    final openTarget = switch (_offset) {
      > 0 => _openTargetForPane(
          offset: _offset,
          paneWidth: _startPaneWidth,
          isStart: true,
        ),
      < 0 => _openTargetForPane(
          offset: _offset,
          paneWidth: _endPaneWidth,
          isStart: false,
        ),
      _ => 0.0,
    };

    _animateTo(openTarget, animated: true);

    if (openTarget == 0) {
      _group?.unregister(this);
    }
  }

  void _handleDragCancel() {
    if (_isDismissing) {
      return;
    }

    _animateTo(_isOpen ? _offset : 0, animated: true);
    if (!_isOpen) {
      _group?.unregister(this);
    }
  }

  void _onDismissAnimationEnd() {
    if (!mounted || !_isDismissing) {
      return;
    }

    final action = _pendingDismissAction;
    _pendingDismissAction = null;
    action?.onTriggered(context);
  }

  Widget _buildActionTapTargets({
    required LdSlideActionPane pane,
    required bool isStart,
    required double revealedExtent,
  }) {
    if (revealedExtent <= 0 || _isDragging || _isDismissing || !widget.enabled) {
      return const SizedBox.shrink();
    }

    final paneWidth = isStart ? _startPaneWidth : _endPaneWidth;
    final widths = _actionWidths(pane, paneWidth);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final targets = <Widget>[];

    var consumed = 0.0;
    for (var i = 0; i < pane.actions.length; i++) {
      final actionWidth = widths[i];
      final remaining = revealedExtent - consumed;
      if (remaining <= 0) {
        break;
      }

      final visibleWidth = remaining < actionWidth ? remaining : actionWidth;
      consumed += actionWidth;

      targets.add(
        GestureDetector(
          key: ValueKey('ld-slide-target-${pane.actions[i].label}-$i'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTrigger(pane.actions[i]),
          child: SizedBox(
            width: visibleWidth,
            height: double.infinity,
          ),
        ),
      );
    }

    final orderedTargets = isStart ? targets.reversed.toList(growable: false) : targets;

    return Positioned(
      top: 0,
      bottom: 0,
      left: isStart ? (isRtl ? null : 0) : (isRtl ? 0 : null),
      right: isStart ? (isRtl ? 0 : null) : (isRtl ? null : 0),
      width: revealedExtent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: isStart
            ? (isRtl ? MainAxisAlignment.end : MainAxisAlignment.start)
            : (isRtl ? MainAxisAlignment.start : MainAxisAlignment.end),
        children: orderedTargets,
      ),
    );
  }

  int? _commitIndexForExtent(LdSlideActionPane pane, double paneWidth, double extent) {
    if (!_isDragging || extent <= 0) {
      return null;
    }

    return _actionIndexForCommit(extent, pane, paneWidth);
  }

  Widget _buildActionPane({
    required LdSlideActionPane pane,
    required bool isStart,
    required double revealedExtent,
  }) {
    final paneWidth = isStart ? _startPaneWidth : _endPaneWidth;
    final widths = _actionWidths(pane, paneWidth);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final commitIndex = _commitIndexForExtent(pane, paneWidth, revealedExtent);

    final cells = <Widget>[];
    for (var i = 0; i < pane.actions.length; i++) {
      cells.add(
        _LdSlideActionCell(
          action: pane.actions[i],
          width: widths[i],
          isCommitTarget: commitIndex == i,
        ),
      );
    }

    final orderedCells = isStart ? cells.reversed.toList(growable: false) : cells;

    return SizedBox(
      width: paneWidth,
      child: Row(
        mainAxisAlignment: isStart
            ? (isRtl ? MainAxisAlignment.end : MainAxisAlignment.start)
            : (isRtl ? MainAxisAlignment.start : MainAxisAlignment.end),
        children: orderedCells,
      ),
    );
  }

  Widget _buildSlidingForeground(Widget child) {
    final theme = LdTheme.of(context);
    final opaqueForeground = ColoredBox(
      color: theme.surface,
      child: SizedBox(
        width: double.infinity,
        child: child,
      ),
    );

    if (_isAnimating && !_isDragging) {
      return LdSpring(
        key: ValueKey(_animationKey),
        initialPosition: _animationStart,
        position: _animationEnd,
        mass: 2,
        springConstant: 20,
        dampingCoefficient: 15,
        onAnimationEnd: (_, __) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isAnimating = false;
          });
          if (_animationEnd == 0) {
            _group?.unregister(this);
          }
        },
        builder: (context, state, springChild) {
          return Transform.translate(
            offset: Offset(state.position, 0),
            child: springChild,
          );
        },
        child: opaqueForeground,
      );
    }

    return Transform.translate(
      offset: Offset(_offset, 0),
      child: opaqueForeground,
    );
  }

  Widget _buildContent() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final foreground = _buildSlidingForeground(
      GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onHorizontalDragCancel: _handleDragCancel,
        behavior: _isOpen ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
        child: IgnorePointer(
          ignoring: _isDragging || _isOpen,
          child: widget.child,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        if (widget.startActionPane != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: isRtl ? null : 0,
            right: isRtl ? 0 : null,
            child: _buildActionPane(
              pane: widget.startActionPane!,
              isStart: true,
              revealedExtent: _offset,
            ),
          ),
        if (widget.endActionPane != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: isRtl ? 0 : null,
            right: isRtl ? null : 0,
            child: _buildActionPane(
              pane: widget.endActionPane!,
              isStart: false,
              revealedExtent: _offset.abs(),
            ),
          ),
        foreground,
        if (widget.startActionPane != null && _offset > 0)
          _buildActionTapTargets(
            pane: widget.startActionPane!,
            isStart: true,
            revealedExtent: _offset,
          ),
        if (widget.endActionPane != null && _offset < 0)
          _buildActionTapTargets(
            pane: widget.endActionPane!,
            isStart: false,
            revealedExtent: _offset.abs(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled && widget.startActionPane == null && widget.endActionPane == null) {
      return widget.child;
    }

    Widget content = _buildContent();

    if (_isDismissing) {
      content = LdReveal(
        revealed: false,
        initialRevealed: true,
        axes: const {Axis.vertical},
        mass: 2,
        bufferSprings: 5,
        springConstant: 20,
        dampingCoefficient: 15,
        onAnimationEnd: (_, __) => _onDismissAnimationEnd(),
        child: content,
      );
    }

    return content;
  }
}

class _LdSlideActionCell extends StatelessWidget {
  const _LdSlideActionCell({
    required this.action,
    required this.width,
    required this.isCommitTarget,
  });

  final LdSlideAction action;
  final double width;
  final bool isCommitTarget;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final color = action.color ?? theme.palette.primary;
    final accent = color.center(theme.isDark);
    final background = accent;
    final foreground = color.contrastingText(background);
    final previewForeground = accent;

    return SizedBox(
      width: width,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        color: isCommitTarget ? background : theme.background,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (action.icon != null)
                    Icon(
                      action.icon,
                      color: isCommitTarget ? foreground : previewForeground,
                      size: theme.labelSize(LdSize.l),
                    ),
                  if (action.icon != null && action.label != null) ldSpacerXS,
                  if (action.label != null)
                    LdText.l(
                      action.label!,
                      color: isCommitTarget ? foreground : previewForeground,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
