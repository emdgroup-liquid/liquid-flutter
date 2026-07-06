import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// ══════════════════════════════════════════════════════════════════════════════
// LdSearchInput
// ══════════════════════════════════════════════════════════════════════════════

class LdSearchInput extends StatefulWidget {
  final LdSearchConfig searchConfig;
  final bool fullWidth;
  final bool isBottomNavigationBar;

  const LdSearchInput({
    super.key,
    required this.searchConfig,
    this.fullWidth = false,
    this.isBottomNavigationBar = false,
  });

  @override
  State<LdSearchInput> createState() => _LdSearchInputState();
}

class _LdSearchInputState extends State<LdSearchInput> {
  // ── Input ──────────────────────────────────────────────────────────────────
  final GlobalKey _inputKey = GlobalKey();
  late FocusNode _inputFocusNode = widget.searchConfig.inputFocusNode ?? FocusNode();
  late final TextEditingController _inputController = TextEditingController(
    text: widget.searchConfig.initialQuery,
  );

  // ── Suggestions fetch ──────────────────────────────────────────────────────
  // The controller lives for the full lifetime of this widget so that cached
  // results survive overlay open/close cycles.
  late final LdSubmitController<List<dynamic>, String>? _suggestionsController;
  // ValueNotifier used as the `arg` for LdSubmit so changes auto-trigger.
  late final ValueNotifier<String>? _queryNotifier;
  Timer? _debounceTimer;

  // ── Overlay ────────────────────────────────────────────────────────────────
  OverlayEntry? _overlayEntry;
  late final ValueNotifier<Rect?> _inputRectNotifier = ValueNotifier(null);

  // ── Focus suggestions scope (keyboard navigation) ─────────────────────────
  final FocusScopeNode _suggestionsFocusNode = FocusScopeNode();

  StreamSubscription<Intent>? _intentSubscription;

  @override
  void initState() {
    super.initState();

    final hasSuggestions = widget.searchConfig.getSuggestions != null;

    if (hasSuggestions) {
      _queryNotifier = ValueNotifier(widget.searchConfig.initialQuery ?? '');
      _suggestionsController = LdSubmitController<List<dynamic>, String>(
        arg: _queryNotifier,
        config: LdSubmitConfig(
          autoTrigger: true,
          action: (query) async {
            if (query == null || query.isEmpty) return <dynamic>[];
            return await widget.searchConfig.getSuggestions!(query);
          },
        ),
      );
    } else {
      _queryNotifier = null;
      _suggestionsController = null;
    }

    _inputFocusNode.addListener(_onFocusChanged);
    _inputController.addListener(_onTextChanged);

    // init() registers devtools and fires the initial auto-trigger.
    // We schedule it post-frame like LdSubmit does.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suggestionsController?.init();
    });
  }

  @override
  void didUpdateWidget(LdSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchConfig.initialQuery != widget.searchConfig.initialQuery) {
      _inputController.text = widget.searchConfig.initialQuery ?? '';
    }
    if (oldWidget.searchConfig.inputFocusNode != widget.searchConfig.inputFocusNode) {
      _inputFocusNode.removeListener(_onFocusChanged);
      _inputFocusNode = widget.searchConfig.inputFocusNode ?? FocusNode();
      _inputFocusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChanged);
    _inputController.removeListener(_onTextChanged);
    _intentSubscription?.cancel();
    _debounceTimer?.cancel();

    // Only dispose the focus node if it was not provided by the parent.
    if (widget.searchConfig.inputFocusNode == null) {
      _inputFocusNode.dispose();
    }
    _suggestionsFocusNode.dispose();
    _inputController.dispose();
    _inputRectNotifier.dispose();

    _suggestionsController?.dispose();
    _queryNotifier?.dispose();

    _overlayEntry?.remove();
    super.dispose();
  }

  // ── Text / query ───────────────────────────────────────────────────────────

  void _onTextChanged() {
    final notifier = _queryNotifier;
    if (notifier == null) return;
    final newText = _inputController.text;
    if (newText == notifier.value) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) notifier.value = newText;
    });
  }

  // ── Focus ──────────────────────────────────────────────────────────────────

  void _onFocusChanged() {
    if (_inputFocusNode.hasFocus) {
      _openOverlay();
    }
    // Closing on blur is handled explicitly by each action (submit / accept /
    // clear / barrier tap).  We do NOT close here to avoid races between the
    // focus change and the action that caused it.
  }

  // ── Overlay lifecycle ──────────────────────────────────────────────────────

  void _updateInputRect() {
    if (!mounted) return;
    final box = _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    // Express the input's position in the overlay's own coordinate space so
    // that Positioned inside the OverlayEntry Stack uses the right origin.
    // Using localToGlobal without an ancestor would give screen-root coords,
    // which diverge from overlay-local coords whenever the Overlay is itself
    // offset (nested Navigator, embedded view, transformed ancestor, etc.).
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final pos = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    _inputRectNotifier.value = Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height);
  }

  void _openOverlay() {
    if (_overlayEntry != null || !mounted) return;
    if (widget.searchConfig.getSuggestions == null) return;
    _updateInputRect();
    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onSuggestionAccepted(String suggestion) {
    _inputController.text = suggestion;
    _queryNotifier?.value = suggestion;
    widget.searchConfig.onSearch(suggestion);
    _closeOverlay();
    _inputFocusNode.unfocus();
  }

  void _onSubmitted(String text) {
    widget.searchConfig.onSearch(text);
    _closeOverlay();
    _inputFocusNode.unfocus();
  }

  void _onCleared() {
    _queryNotifier?.value = '';
    widget.searchConfig.onSearch('');
    _closeOverlay();
    _inputFocusNode.unfocus();
  }

  void _onBarrierDismiss() {
    _closeOverlay();
    _inputFocusNode.unfocus();
  }

  // ── Key handling ───────────────────────────────────────────────────────────

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.tab) {
        _suggestionsFocusNode.nextFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ── Overlay builder ────────────────────────────────────────────────────────

  Widget _buildOverlay() {
    // The overlay reads from _suggestionsController via ChangeNotifierProvider
    // so it rebuilds whenever new suggestions arrive — without recreating any
    // state.
    return ChangeNotifierProvider<LdSubmitController<List<dynamic>, String>>.value(
      value: _suggestionsController!,
      child: LdSearchSuggestionsOverlay(
        inputRectNotifier: _inputRectNotifier,
        isBottomNavigationBar: widget.isBottomNavigationBar,
        onBarrierDismiss: _onBarrierDismiss,
        suggestionsFocusNode: _suggestionsFocusNode,
        onSuggestionAccepted: _onSuggestionAccepted,
        buildSuggestion: widget.searchConfig.buildSuggestion!,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null) _updateInputRect();
    });

    return LdWrapConditional(
      condition: !widget.fullWidth,
      builder: (context, child) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250, minWidth: 200),
        child: child,
      ),
      child: Focus(
        onKeyEvent: _onKeyEvent,
        child: ListenableBuilder(
          listenable: _suggestionsController ?? ValueNotifier(null),
          builder: (context, _) {
            final isLoading = _suggestionsController?.state.type == LdSubmitStateType.loading;
            return LdInput(
              key: _inputKey,
              focusNode: _inputFocusNode,
              textInputAction: TextInputAction.search,
              size: LdSize.s,
              hint: widget.searchConfig.hint ?? LiquidLocalizations.of(context).search,
              controller: _inputController,
              showClear: true,
              loading: isLoading,
              onSubmitted: _onSubmitted,
              onCleared: _onCleared,
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LdSearchSuggestionsOverlay
//
// Purely presentational.  All data comes from a
// LdSubmitController<List<dynamic>, String> provided above via
// ChangeNotifierProvider — no fetch logic lives here.
// ══════════════════════════════════════════════════════════════════════════════

class LdSearchSuggestionsOverlay extends StatefulWidget {
  final ValueNotifier<Rect?> inputRectNotifier;
  final bool isBottomNavigationBar;
  final VoidCallback onBarrierDismiss;
  final FocusScopeNode suggestionsFocusNode;
  final void Function(String suggestion) onSuggestionAccepted;
  final Widget Function(BuildContext, dynamic) buildSuggestion;

  const LdSearchSuggestionsOverlay({
    super.key,
    required this.inputRectNotifier,
    required this.isBottomNavigationBar,
    required this.onBarrierDismiss,
    required this.suggestionsFocusNode,
    required this.onSuggestionAccepted,
    required this.buildSuggestion,
  });

  @override
  State<LdSearchSuggestionsOverlay> createState() => _LdSearchSuggestionsOverlayState();
}

class _LdSearchSuggestionsOverlayState extends State<LdSearchSuggestionsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Stale-while-revalidate: the last successful list stays visible while a
  // re-fetch is in flight so the overlay never flashes empty.
  List<dynamic>? _lastSuggestions;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    widget.inputRectNotifier.addListener(_onInputRectChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    widget.inputRectNotifier.removeListener(_onInputRectChanged);
    super.dispose();
  }

  void _onInputRectChanged() {
    if (mounted) setState(() {});
  }

  void _onBarrierTapped() {
    // Fade out first so the animation is visible, then notify the parent.
    _fadeController.reverse().then((_) {
      if (mounted) widget.onBarrierDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputRect = widget.inputRectNotifier.value;
    if (inputRect == null) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: ModalBarrier(
                  dismissible: true,
                  onDismiss: _onBarrierTapped,
                  color: Colors.transparent,
                ),
              ),
              _placeOverlay(
                inputRect,
                FocusScope(
                  node: widget.suggestionsFocusNode,
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeOverlay(Rect inputRect, Widget child) {
    const double maxHeight = 300;
    const double padding = 16;

    if (!widget.isBottomNavigationBar) {
      // height is set explicitly so the Positioned has a non-zero layout box
      // for hit-testing — without it taps fall through to the ModalBarrier.
      return Positioned(
        left: inputRect.left,
        top: inputRect.bottom + 4,
        width: inputRect.width,
        height: maxHeight,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: maxHeight),
            child: child,
          ),
        ),
      );
    } else {
      final screenHeight = MediaQuery.of(context).size.height;
      return Positioned(
        left: padding,
        right: padding,
        bottom: screenHeight - inputRect.top + 2 * padding,
        top: MediaQuery.of(context).viewPadding.top,
        child: child,
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    final controller = context.watch<LdSubmitController<List<dynamic>, String>>();
    final state = controller.state;
    final theme = LdTheme.of(context);

    // Stale-while-revalidate: only advance the visible list on a fresh result.
    if (state.type == LdSubmitStateType.result) {
      _lastSuggestions = state.result;
    }

    // Don't render the card shell at all until there is something to show.
    final bool hasItems = _lastSuggestions != null && _lastSuggestions!.isNotEmpty;
    final bool hasContent = hasItems || state.type == LdSubmitStateType.error;
    if (!hasContent) return const SizedBox.shrink();

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.surface.withAlpha(255),
        borderRadius: theme.radius(LdSize.m),
        border: Border.all(color: theme.border, width: theme.borderWidth),
        boxShadow: [ldShadowSticky],
      ),
      child: NotificationListener<LdSearchAcceptSuggestion>(
        onNotification: (notification) {
          widget.onSuggestionAccepted(notification.suggestion.toString());
          return true;
        },
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: switch (state.type) {
            LdSubmitStateType.result || LdSubmitStateType.loading => ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _lastSuggestions?.length ?? 0,
                itemBuilder: (context, index) => widget.buildSuggestion(context, _lastSuggestions![index]),
              ),
            LdSubmitStateType.error => LdExceptionView(
                exception: state.error!,
                direction: Axis.vertical,
                retryController: controller.retryController,
              ),
            LdSubmitStateType.idle => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LdSearchAcceptSuggestion notification
// ══════════════════════════════════════════════════════════════════════════════

class LdSearchAcceptSuggestion extends Notification {
  const LdSearchAcceptSuggestion({required this.suggestion});

  final dynamic suggestion;
}
