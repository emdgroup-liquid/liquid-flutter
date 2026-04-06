import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Legacy types - kept for compatibility but not actively used
enum LdScaffoldSlot {
  body,
  drawer,
}

enum EffectivePosition {
  top,
  bottom,
}

enum AppBarRole {
  primary,
  secondary,
}

class LdScaffoldAppBarState {
  final double innerHeight;
  final double verticalMargin;
  final double effectiveHeight;
  final double effectiveInnerHeight;
  final EffectivePosition effectivePosition;

  const LdScaffoldAppBarState({
    required this.innerHeight,
    required this.verticalMargin,
    required this.effectiveHeight,
    required this.effectiveInnerHeight,
    required this.effectivePosition,
  });
}

class LdScaffoldLayoutState {
  final ValueNotifier<double> bodyScrollOffset;
  final ValueNotifier<double> drawerScrollOffset;
  final ValueNotifier<double> appBarOffset;
  final ValueNotifier<double> secondaryAppBarOffset;
  final LdScaffoldSlot slot;
  final LdScaffoldLayoutState? parentLayoutState;
  final String? debugName;
  final bool isScrolled;

  final LdScaffoldAppBarState? appBarState;
  final LdScaffoldAppBarState? secondaryAppBarState;

  const LdScaffoldLayoutState({
    required this.slot,
    required this.bodyScrollOffset,
    required this.drawerScrollOffset,
    required this.appBarOffset,
    required this.secondaryAppBarOffset,
    required this.parentLayoutState,
    this.debugName,
    this.isScrolled = false,
    this.appBarState,
    this.secondaryAppBarState,
  });

  int get level {
    if (parentLayoutState == null) {
      return 0;
    }
    return parentLayoutState!.level + 1;
  }

  /// Returns the total height of the app bars in the tree. Does not take into account the scroll effect.
  EdgeInsets get totalInsets {
    List<LdScaffoldAppBarState> topAppBars = [];
    List<LdScaffoldAppBarState> bottomAppBars = [];

    // Walk up the tree and collect the app bars
    LdScaffoldLayoutState? currentLayoutState = this;
    while (currentLayoutState != null) {
      final appBarState = currentLayoutState.appBarState;
      final secondaryAppBarState = currentLayoutState.secondaryAppBarState;
      if (secondaryAppBarState?.effectivePosition == EffectivePosition.top) {
        topAppBars.add(secondaryAppBarState!);
      } else if (secondaryAppBarState?.effectivePosition == EffectivePosition.bottom) {
        bottomAppBars.add(secondaryAppBarState!);
      }
      if (appBarState?.effectivePosition == EffectivePosition.top) {
        topAppBars.add(appBarState!);
      } else if (appBarState?.effectivePosition == EffectivePosition.bottom) {
        bottomAppBars.add(appBarState!);
      }

      currentLayoutState = currentLayoutState.parentLayoutState;
    }

    double top = 0;
    double bottom = 0;

    for (var appBar in topAppBars) {
      top += appBar.innerHeight;
    }
    for (var appBar in bottomAppBars) {
      bottom += appBar.innerHeight;
    }

    if (topAppBars.isNotEmpty) {
      top += topAppBars.last.verticalMargin;
    }
    if (bottomAppBars.isNotEmpty) {
      bottom += bottomAppBars.last.verticalMargin;
    }

    return EdgeInsets.only(top: top, bottom: bottom);
  }

  String toDebugString() {
    return "$level - $debugName - $slot - ${appBarState?.effectiveHeight} - ${secondaryAppBarState?.effectiveHeight} \n ${parentLayoutState?.toDebugString()}";
  }

  int levelForEffectivePosition() {
    final effectivePosition = appBarState?.effectivePosition ?? EffectivePosition.top;
    int level = 0;
    LdScaffoldLayoutState? currentLayoutState = parentLayoutState;
    while (currentLayoutState != null) {
      if (currentLayoutState.appBarState?.effectivePosition == effectivePosition) {
        level++;
      }
      if (currentLayoutState.secondaryAppBarState?.effectivePosition == effectivePosition) {
        level++;
      }
      currentLayoutState = currentLayoutState.parentLayoutState;
    }
    return level;
  }

  double effectiveHeightOfOthers(EffectivePosition effectivePosition, AppBarRole appBarRole) {
    List<LdScaffoldAppBarState> appBars = [];

    LdScaffoldLayoutState? currentLayoutState = parentLayoutState;
    while (currentLayoutState != null) {
      final appBarState = currentLayoutState.appBarState;
      final secondaryAppBarState = currentLayoutState.secondaryAppBarState;
      if (appBarState?.effectivePosition == effectivePosition) {
        appBars.add(appBarState!);
      }
      if (secondaryAppBarState?.effectivePosition == effectivePosition) {
        appBars.add(secondaryAppBarState!);
      }
      currentLayoutState = currentLayoutState.parentLayoutState;
    }

    double total = 0;

    for (var appBar in appBars) {
      total += appBar.effectiveInnerHeight;
    }

    return total;
  }

  LdScaffoldLayoutState copyWith({
    ValueNotifier<double>? bodyScrollOffset,
    ValueNotifier<double>? drawerScrollOffset,
    ValueNotifier<double>? appBarOffset,
    ValueNotifier<double>? secondaryAppBarOffset,
    LdScaffoldSlot? slot,
    LdScaffoldLayoutState? parentLayoutState,
    String? debugName,
    LdScaffoldAppBarState? appBarState,
    LdScaffoldAppBarState? secondaryAppBarState,
    bool? isScrolled,
  }) {
    return LdScaffoldLayoutState(
      debugName: debugName ?? this.debugName,
      bodyScrollOffset: bodyScrollOffset ?? this.bodyScrollOffset,
      drawerScrollOffset: drawerScrollOffset ?? this.drawerScrollOffset,
      appBarOffset: appBarOffset ?? this.appBarOffset,
      secondaryAppBarOffset: secondaryAppBarOffset ?? this.secondaryAppBarOffset,
      parentLayoutState: parentLayoutState ?? this.parentLayoutState,
      slot: slot ?? this.slot,
      appBarState: appBarState ?? this.appBarState,
      secondaryAppBarState: secondaryAppBarState ?? this.secondaryAppBarState,
      isScrolled: isScrolled ?? this.isScrolled,
    );
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('debugName', debugName));
    properties.add(IntProperty('level', level));
    properties.add(EnumProperty<LdScaffoldSlot>('slot', slot));
    properties.add(DoubleProperty('bodyScrollOffset', bodyScrollOffset.value));
    properties.add(DoubleProperty('drawerScrollOffset', drawerScrollOffset.value));
    properties.add(DiagnosticsProperty<EdgeInsets>('effectiveInsets', totalInsets));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('appBarState', appBarState));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('secondaryAppBarState', secondaryAppBarState));
    properties.add(DiagnosticsProperty<LdScaffoldLayoutState?>('parentLayoutState', parentLayoutState));
  }

  @override
  String toString() {
    return '''LdScaffoldLayoutState(
    level: $level, 
    parentLayoutState: ${parentLayoutState?.toString().split('\n').join('\n    ')}, 
    slot: $slot,
    bodyScrollOffset: $bodyScrollOffset,
    drawerScrollOffset: $drawerScrollOffset,
    appBarState: ${appBarState?.toString().split('\n').join('\n    ')},
    secondaryAppBarState: ${secondaryAppBarState?.toString().split('\n').join('\n    ')},
    )''';
  }
}
