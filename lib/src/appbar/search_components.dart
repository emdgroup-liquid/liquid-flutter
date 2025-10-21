import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  final FocusNode _inputWrapperFocusNode = FocusNode();
  final FocusScopeNode _suggestionsFocusNode = FocusScopeNode();

  OverlayEntry? _overlayEntry;
  late final ValueNotifier<Rect?> _inputRectNotifier;

  late final StreamSubscription<Intent> _intentSubscription;

  @override
  void initState() {
    super.initState();
    _inputRectNotifier = ValueNotifier<Rect?>(null);
    _intentSubscription = LdScaffoldState.of(context).intentRouter.listen(_onScaffoldIntent);
    widget.searchConfig.inputFocusNode.addListener(_onFocusChanged);
  }

  void _onScaffoldIntent(Intent intent) {
    if (intent is SearchIntent) {
      widget.searchConfig.inputFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    widget.searchConfig.inputFocusNode.removeListener(_onFocusChanged);
    _intentSubscription.cancel();
    _inputWrapperFocusNode.dispose();
    _suggestionsFocusNode.dispose();

    _inputRectNotifier.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onFocusChanged() async {
    final hasFocus = widget.searchConfig.inputFocusNode.hasFocus;
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
          searchConfig: widget.searchConfig,
          onSuggestionAccepted: _onSuggestionAccepted,
          inputRectNotifier: _inputRectNotifier,
          suggestionsFocusNode: _suggestionsFocusNode,
          isBottomNavigationBar: widget.isBottomNavigationBar,
          onDismiss: _closeOverlay,
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeOverlay() {
    print("🔍 Closing overlay");
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.searchConfig.inputFocusNode.unfocus();
  }

  void _onSuggestionAccepted(String suggestion) {
    widget.searchConfig.inputController.text = suggestion;
    widget.searchConfig.onSearch(suggestion);
    _closeOverlay();
    widget.searchConfig.inputFocusNode.nextFocus();
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
    print("🔍 Building search input");
    return Actions(
      actions: <Type, Action<Intent>>{SearchIntent: SearchAction(searchFocusNode: widget.searchConfig.inputFocusNode)},
      dispatcher: LoggerDispatcher(),
      child: LdWrapConditional(
        condition: !widget.fullWidth,
        builder: (context, child) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: child,
        ),
        child: Row(
          children: [
            Expanded(
              child: Focus(
                focusNode: _inputWrapperFocusNode,
                onKeyEvent: _onKeyEvent,
                child: LdInput(
                  key: _inputKey,
                  textInputAction: TextInputAction.search,
                  hint: LiquidLocalizations.of(context).search,
                  controller: widget.searchConfig.inputController,
                  onSubmitted: (text) => widget.searchConfig.onSearch(text),
                  focusNode: widget.searchConfig.inputFocusNode,
                ),
              ),
            ),
            LdReveal(
              revealed: widget.searchConfig.inputFocusNode.hasFocus ||
                  _suggestionsFocusNode.hasFocus ||
                  widget.searchConfig.inputController.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: LdButtonVague(
                  child: const Icon(LucideIcons.x),
                  onPressed: () {
                    widget.searchConfig.inputController.clear();
                    widget.searchConfig.onSearch('');
                    _closeOverlay();
                  },
                ),
              ),
            ),
          ],
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
  final void Function(String suggestion) onSuggestionAccepted;

  const LdSearchSuggestionsOverlay({
    super.key,
    required this.searchConfig,
    required this.inputRectNotifier,
    required this.isBottomNavigationBar,
    required this.onDismiss,
    required this.suggestionsFocusNode,
    required this.onSuggestionAccepted,
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
    widget.searchConfig.inputController.addListener(_onTextChanged);

    // Listen to input rect changes
    widget.inputRectNotifier.addListener(_onInputRectChanged);

    // Initial query
    _currentQuery = widget.searchConfig.inputController.text;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();

    widget.searchConfig.inputController.removeListener(_onTextChanged);
    widget.inputRectNotifier.removeListener(_onInputRectChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final newQuery = widget.searchConfig.inputController.text;
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
    _fadeController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final inputRect = widget.inputRectNotifier.value;

    if (inputRect == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _close,
              child: Padding(
                padding: MediaQuery.of(context).padding.atLeast(MediaQuery.of(context).viewInsets),
                child: Stack(
                  children: [
                    // Suggestions container
                    _placeOverlay(
                      screenSize,
                      inputRect,
                      Container(
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
                        child: FocusScope(
                          node: widget.suggestionsFocusNode,
                          child: _buildSuggestionsContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          top: 0,
          bottom: inputRect.height + LdTheme.of(context).pad(size: LdSize.m).vertical * 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              child,
            ],
          ));
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
      builder: LdSubmitCenteredBuilder<List<dynamic>, String>(
        resultBuilder: (context, result, controller) {
          final suggestions = result;

          if (suggestions.isEmpty) {
            if (_currentQuery.isNotEmpty) {
              return Container(
                padding: LdTheme.of(context).pad(size: LdSize.m),
                child: Text(
                  'No suggestions found',
                  style: TextStyle(
                    color: LdTheme.of(context).textMuted,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          return NotificationListener<LdSearchAcceptSuggestion>(
            onNotification: (notification) {
              widget.searchConfig.inputController.text = notification.suggestion.toString();
              widget.onSuggestionAccepted(notification.suggestion.toString());
              return true;
            },
            child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(), // This ensures proper order
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return widget.searchConfig.buildSuggestion!.call(context, suggestion);
                  },
                )),
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

class LoggerDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }

  @override
  (bool, Object?) invokeActionIfEnabled(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    return super.invokeActionIfEnabled(action, intent, context);
  }
}
