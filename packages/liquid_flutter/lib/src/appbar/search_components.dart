import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

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
  final GlobalKey _inputKey = GlobalKey();

  final _inputWrapperFocusNode = FocusScopeNode();
  final _suggestionsFocusNode = FocusScopeNode();
  late final TextEditingController _inputController = TextEditingController(
    text: widget.searchConfig.initialQuery,
  );

  OverlayEntry? _overlayEntry;
  late final ValueNotifier<Rect?> _inputRectNotifier;

  StreamSubscription<Intent>? _intentSubscription;

  @override
  void initState() {
    super.initState();
    _inputRectNotifier = ValueNotifier<Rect?>(null);

    _inputWrapperFocusNode.addListener(_onFocusChanged);
  }

  @override
  didUpdateWidget(LdSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchConfig.initialQuery != widget.searchConfig.initialQuery) {
      _inputController.text = widget.searchConfig.initialQuery ?? '';
    }
  }

  @override
  void dispose() {
    _inputWrapperFocusNode.removeListener(_onFocusChanged);
    _intentSubscription?.cancel();
    _inputWrapperFocusNode.dispose();
    _suggestionsFocusNode.dispose();
    _inputController.dispose();

    _inputRectNotifier.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onFocusChanged() async {
    final hasFocus = _inputWrapperFocusNode.hasFocus;
    final suggestionsHasFocus = _suggestionsFocusNode.hasFocus;

    await Future.delayed(const Duration(milliseconds: 50));

    if (hasFocus && widget.searchConfig.getSuggestions != null && !suggestionsHasFocus) {
      _showSuggestionsOverlay();
    } else if (!hasFocus && !suggestionsHasFocus) {
      _closeOverlay();
    }

    setState(() {});
  }

  void _updateInputRect() {
    if (!mounted) {
      return;
    }

    // Get the input field position
    final RenderBox? renderBox = _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final inputRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

    _inputRectNotifier.value = inputRect;
  }

  void _showSuggestionsOverlay() {
    if (!mounted) {
      return;
    }

    _updateInputRect();
    // Show the suggestions overlay using Overlay instead of ModalRoute
    _showOverlay();
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return LdSearchSuggestionsOverlay(
          inputController: _inputController,
          searchConfig: widget.searchConfig,
          onSuggestionAccepted: _onSuggestionAccepted,
          inputRectNotifier: _inputRectNotifier,
          suggestionsFocusNode: _suggestionsFocusNode,
          inputFocusNode: _inputWrapperFocusNode,
          isBottomNavigationBar: widget.isBottomNavigationBar,
          onDismiss: _closeOverlay,
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSuggestionAccepted(String suggestion) {
    _inputController.text = suggestion;
    widget.searchConfig.onSearch(suggestion);
    _closeOverlay();
    _inputWrapperFocusNode.unfocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.tab) {
        _suggestionsFocusNode.nextFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Update input rect when the widget rebuilds (e.g., when layout changes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null) {
        _updateInputRect();
      }
    });
    return Actions(
      actions: <Type, Action<Intent>>{SearchIntent: SearchAction(searchFocusNode: _inputWrapperFocusNode)},
      child: LdWrapConditional(
        condition: !widget.fullWidth,
        builder: (context, child) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250, minWidth: 200),
          child: child,
        ),
        child: Focus(
          focusNode: _inputWrapperFocusNode,
          onKeyEvent: _onKeyEvent,
          child: LdInput(
            key: _inputKey,
            textInputAction: TextInputAction.search,
            hint: widget.searchConfig.hint ?? LiquidLocalizations.of(context).search,
            controller: _inputController,
            showClear: true,
            onSubmitted: (text) {
              widget.searchConfig.onSearch(text);
              _inputWrapperFocusNode.unfocus();
            },
            onCleared: () {
              widget.searchConfig.onSearch('');
              _inputWrapperFocusNode.unfocus();
              _closeOverlay();
            },
          ),
        ),
      ),
    );
  }
}

class LdSearchSuggestionsOverlay extends StatefulWidget {
  final LdSearchConfig searchConfig;
  final ValueNotifier<Rect?> inputRectNotifier;
  final bool isBottomNavigationBar;
  final VoidCallback onDismiss;
  final FocusScopeNode suggestionsFocusNode;
  final FocusNode inputFocusNode;
  final void Function(String suggestion) onSuggestionAccepted;
  final TextEditingController inputController;

  const LdSearchSuggestionsOverlay({
    super.key,
    required this.searchConfig,
    required this.inputRectNotifier,
    required this.isBottomNavigationBar,
    required this.onDismiss,
    required this.suggestionsFocusNode,
    required this.inputFocusNode,
    required this.onSuggestionAccepted,
    required this.inputController,
  });

  @override
  State<LdSearchSuggestionsOverlay> createState() => _LdSearchSuggestionsOverlayState();
}

class _LdSearchSuggestionsOverlayState extends State<LdSearchSuggestionsOverlay> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    // Listen to text changes
    widget.inputController.addListener(_onTextChanged);

    // Listen to input rect changes
    widget.inputRectNotifier.addListener(_onInputRectChanged);

    // Initial query
    _currentQuery = widget.inputController.text;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();

    widget.inputController.removeListener(_onTextChanged);
    widget.inputRectNotifier.removeListener(_onInputRectChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final newQuery = widget.inputController.text;
    if (newQuery != _currentQuery) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _currentQuery = newQuery;
          });
        }
      });
    }
  }

  void _onInputRectChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _close() {
    widget.inputFocusNode.unfocus();
    _fadeController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final inputRect = widget.inputRectNotifier.value;

    if (inputRect == null) {
      return const SizedBox.shrink();
    }

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
                  onDismiss: _close,
                  color: Colors.transparent,
                ),
              ),
              _placeOverlay(
                screenSize,
                inputRect,
                FocusScope(
                  node: widget.suggestionsFocusNode,
                  child: _buildSuggestionsContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeOverlay(Size screenSize, Rect inputRect, Widget child) {
    const maxHeight = 300.0;
    const padding = 16.0;

    if (!widget.isBottomNavigationBar) {
      // Desktop: position below the input field
      final width = inputRect.width;
      final left = inputRect.left;
      final top = inputRect.bottom + 4;

      return Positioned(
        left: left,
        top: top,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight), child: child),
      );
    } else {
      return Positioned(
        left: padding,
        right: padding,
        bottom: screenSize.height - inputRect.top + 2 * padding,
        top: MediaQuery.of(context).viewPadding.top,
        child: child,
      );
    }
  }

  Widget _buildSuggestionsContent() {
    return LdSubmit<List<dynamic>, String>(
      arg: _currentQuery,
      config: LdSubmitConfig(
          autoTrigger: true,
          action: (query) async {
            if (query == null || query.isEmpty || widget.searchConfig.getSuggestions == null) {
              return <dynamic>[];
            }
            final result = await widget.searchConfig.getSuggestions!(query);
            return result;
          }),
      child: Builder(
        builder: (context) {
          final controller = context.watch<LdSubmitController<List<dynamic>, String>>();
          final state = controller.state;

          final result = state.result;
          final suggestions = result;
          final theme = LdTheme.of(context);

          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: theme.surface.withAlpha(255),
              borderRadius: theme.radius(LdSize.m),
              border: Border.all(
                color: theme.border,
                width: theme.borderWidth,
              ),
              boxShadow: [
                ldShadowSticky,
              ],
            ),
            child: NotificationListener<LdSearchAcceptSuggestion>(
              onNotification: (notification) {
                widget.onSuggestionAccepted(notification.suggestion.toString());
                return true;
              },
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(), // This ensures proper order
                child: switch (state.type) {
                  LdSubmitStateType.result => ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: suggestions?.length ?? 0,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions?[index];
                        return widget.searchConfig.buildSuggestion!.call(context, suggestion);
                      },
                    ),
                  LdSubmitStateType.loading => Center(
                      child: LdLoader().padL(),
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
        },
      ),
    );
  }
}

class LdSearchAcceptSuggestion extends Notification {
  const LdSearchAcceptSuggestion({required this.suggestion});

  final dynamic suggestion;
}
