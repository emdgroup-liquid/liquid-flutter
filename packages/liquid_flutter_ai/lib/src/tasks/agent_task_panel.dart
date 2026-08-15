import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/agent_task.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// How long the list stays fully open after tasks are added or removed.
const _kTaskPeekHold = Duration(milliseconds: 1100);

/// Task panel (wraps [child] via [AppBarFrame] at the bottom).
///
/// Pair with [LdComposeBar] (bottom) so both sit in the app-bar frame stack.
///
/// Collapsed by default: one task row is visible (the in-progress task, or the
/// last non-terminal task) with edge fades. An outline button expands the list.
/// When tasks are added or removed, the list briefly peeks open then collapses.
class LdAgentTaskPanel extends StatefulWidget {
  final Widget child;
  final List<LdAgentTask> tasks;

  const LdAgentTaskPanel({super.key, required this.child, required this.tasks});

  @override
  State<LdAgentTaskPanel> createState() => _LdAgentTaskPanelState();
}

class _LdAgentTaskPanelState extends State<LdAgentTaskPanel> {
  var _userExpanded = false;
  var _peeking = false;
  Timer? _peekTimer;
  final _scrollController = ScrollController();
  final _rowKeys = <String, GlobalKey>{};

  bool get _expanded => _userExpanded || _peeking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.tasks.length > 1) {
        _startPeek();
      } else {
        _scrollToFocus();
      }
    });
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LdAgentTaskPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.tasks.map((t) => t.id).join('|');
    final newIds = widget.tasks.map((t) => t.id).join('|');
    if (oldIds == newIds) {
      // Status may have moved the focus target — keep scroll in sync even while
      // peeking (sticky user expand leaves offset alone).
      if (!_userExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
      }
      return;
    }

    _pruneKeys();
    if (_userExpanded) {
      return;
    }
    if (widget.tasks.length > 1) {
      _startPeek();
    } else {
      _cancelPeek();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
    }
  }

  void _pruneKeys() {
    final ids = widget.tasks.map((t) => t.id).toSet();
    _rowKeys.removeWhere((id, _) => !ids.contains(id));
  }

  GlobalKey _keyFor(String id) => _rowKeys.putIfAbsent(id, GlobalKey.new);

  void _startPeek() {
    if (_userExpanded || ldDisableAnimations) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
      return;
    }

    _peekTimer?.cancel();
    if (!_peeking) {
      setState(() => _peeking = true);
    }
    _peekTimer = Timer(_kTaskPeekHold, _endPeek);
    // Re-evaluate focus so the peek (and the collapse after) land on the
    // current in-progress / last non-terminal task.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
  }

  void _endPeek() {
    _peekTimer = null;
    if (!mounted || _userExpanded || !_peeking) {
      return;
    }
    setState(() => _peeking = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
  }

  void _cancelPeek() {
    _peekTimer?.cancel();
    _peekTimer = null;
    _peeking = false;
  }

  void _toggleExpanded() {
    final willCollapse = _expanded;
    _peekTimer?.cancel();
    _peekTimer = null;
    setState(() {
      _peeking = false;
      _userExpanded = !willCollapse;
    });
    if (willCollapse) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
    }
  }

  void _scrollToFocus() async {
    // Sticky user expand: leave their scroll alone. Peeking still updates so
    // membership / status changes retarget before collapse.
    if (!mounted || _userExpanded || widget.tasks.isEmpty) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final index = ldAgentTaskFocusIndex(widget.tasks);
    if (index < 0) {
      return;
    }
    final rowContext = _keyFor(widget.tasks[index].id).currentContext;
    if (rowContext == null) {
      return;
    }

    if (ldDisableAnimations) {
      if (!rowContext.mounted) {
        return;
      }
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
      return;
    }

    await Future.delayed(Duration(milliseconds: 500));

    if (!rowContext.mounted) {
      return;
    }

    Scrollable.ensureVisible(
      rowContext,
      alignment: 0.5,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return widget.child;
    }

    final theme = LdTheme.of(context);

    return AppBarFrame(
      position: LdAppBarPosition.bottom,
      insidePadding: theme.pad(),
      attached: true,
      scrollBehavior: LdAppBarScrollBehavior.static,
      outsideDecoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      wrappedChild: widget.child,
      child: Builder(
        builder: (context) {
          return Container(
            padding: MediaQuery.of(context).padding,
            child: _buildBody(context),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = LdTheme.of(context);
    final canExpand = widget.tasks.length > 1;
    final rowHeight = _taskRowHeight(theme);
    final gap = theme.paddingSize(size: LdSize.s);
    final animate = !ldDisableAnimations;
    final taskCount = widget.tasks.length;
    final contentHeight =
        rowHeight * taskCount + gap * (taskCount > 1 ? taskCount - 1 : 0);

    final list = LdScrollEdgeFade(
      fadeColor: theme.surface,
      controller: _scrollController,
      topScrimExtent: 0,
      bottomScrimExtent: 0,
      fadeExtent: rowHeight * 0.2,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          controller: _scrollController,
          physics: _expanded
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: [
              for (final task in widget.tasks)
                KeyedSubtree(
                  key: _keyFor(task.id),
                  child: _TaskRow(task: task),
                ),
            ],
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: _expanded
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: animate
                ? const Duration(milliseconds: 220)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            height: _expanded
                ? contentHeight
                : rowHeight + 2 * (rowHeight * 0.2),
            width: double.infinity,
            child: ClipRect(child: list),
          ),
        ),
        if (canExpand) ...[
          ldHSpacerS,
          LdButton.outline(
            size: LdSize.s,
            onPressed: _toggleExpanded,
            leading: Icon(
              _expanded ? LucideIcons.chevronDown : LucideIcons.chevronUp,
            ),
            child: Text("${widget.tasks.length} Tasks"),
          ),
        ],
      ],
    );
  }
}

/// Index of the task that should stay visible while the panel is collapsed.
///
/// Prefers the in-progress task; otherwise the last task that is not done or
/// failed; otherwise the last task.
@visibleForTesting
int ldAgentTaskFocusIndex(List<LdAgentTask> tasks) {
  final inProgress = tasks.indexWhere(
    (task) => task.status == LdAgentTaskStatus.inProgress,
  );
  if (inProgress >= 0) {
    return inProgress;
  }
  for (var i = tasks.length - 1; i >= 0; i--) {
    final status = tasks[i].status;
    if (status != LdAgentTaskStatus.done &&
        status != LdAgentTaskStatus.failed) {
      return i;
    }
  }
  return tasks.isEmpty ? -1 : tasks.length - 1;
}

double _taskRowHeight(LdTheme theme) {
  // LdIndicator paints at customSize * 1.6 (see indicators.dart).
  final indicatorHeight = theme.labelSize(LdSize.s) * 1.6;
  final labelHeight =
      theme.labelSize(LdSize.s) *
      ldLineHeight(LdTextType.label, size: LdSize.s);
  return indicatorHeight > labelHeight ? indicatorHeight : labelHeight;
}

class _TaskRow extends StatelessWidget {
  final LdAgentTask task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdIndicator(
          customSize: theme.labelSize(LdSize.s),
          type: switch (task.status) {
            LdAgentTaskStatus.pending => LdIndicatorType.pending,
            LdAgentTaskStatus.inProgress => LdIndicatorType.loading,
            LdAgentTaskStatus.done => LdIndicatorType.success,
            LdAgentTaskStatus.failed => LdIndicatorType.error,
          },
        ),
        Expanded(
          child: LdText.ls(
            task.label,
            color: task.status == LdAgentTaskStatus.done
                ? theme.textMuted
                : null,
          ),
        ),
      ],
    ).spaceS();
  }
}
