import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

part 'emoji_entry.dart';
part 'emoji_data.dart';

// ---------------------------------------------------------------------------
// Public data accessor
// ---------------------------------------------------------------------------

/// The full emoji dataset, grouped by Unicode category.
///
/// Data is generated from the Unicode emoji-test.txt file.
/// Re-run `dart tools/generate_emoji_data.dart` to update.
List<LdEmojiCategory> get ldEmojiData => _ldEmojiData;

// ---------------------------------------------------------------------------
// Skin-tone picker (LdContextMenu content)
// ---------------------------------------------------------------------------

class _SkinTonePicker extends StatelessWidget {
  final LdEmojiEntry entry;
  final void Function(String emoji) onSelect;

  const _SkinTonePicker({
    required this.entry,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final allVariants = [entry.emoji, ...entry.skinToneVariants];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Wrap(
        children: allVariants.map((variant) {
          return _EmojiCell(
            emoji: variant,
            size: LdSize.s,
            onTap: () {
              onSelect(variant);
              LdContextMenuDissmissNotification().dispatch(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single emoji cell
// ---------------------------------------------------------------------------

class _EmojiCell extends StatelessWidget {
  final String emoji;
  final LdSize size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  const _EmojiCell({
    required this.emoji,
    required this.onTap,
    this.size = LdSize.m,
    this.onLongPress,
    this.isActive = false,
  });

  double _fontSize(LdSize s) {
    switch (s) {
      case LdSize.xs:
        return 16;
      case LdSize.s:
        return 20;
      case LdSize.m:
        return 24;
      case LdSize.l:
        return 30;
    }
  }

  double _cellSize(LdSize s) {
    switch (s) {
      case LdSize.xs:
        return 28;
      case LdSize.s:
        return 36;
      case LdSize.m:
        return 44;
      case LdSize.l:
        return 52;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final cell = _cellSize(size);

    return LdTouchableSurface(
      onPressed: onTap,
      active: isActive,
      builder: (ctx, status, child) {
        final color = ghostColor(theme.primary, theme, status);
        return GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            width: cell,
            height: cell,
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: theme.radius(LdSize.s),
            ),
            child: child,
          ),
        );
      },
      child: Center(
        child: LdEmoji(
          emoji,
          style: TextStyle(fontSize: _fontSize(size)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emoji grid (category or search results)
// ---------------------------------------------------------------------------

class _EmojiGrid extends StatelessWidget {
  final List<LdEmojiEntry> emojis;
  final void Function(String emoji) onSelect;

  /// The currently-selected emoji string, if any. The matching cell is
  /// rendered in an active/highlighted state.
  final String? selectedEmoji;

  const _EmojiGrid({
    required this.emojis,
    required this.onSelect,
    this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context) {
    if (emojis.isEmpty) {
      return const LdListEmpty();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          final entry = emojis[index];

          // An emoji is considered "selected" when its base emoji or any of
          // its skin-tone variants matches the current value.
          final isSelected =
              selectedEmoji != null && (entry.emoji == selectedEmoji || entry.skinToneVariants.contains(selectedEmoji));

          if (!entry.hasSkinTones) {
            return _EmojiCell(
              emoji: entry.emoji,
              isActive: isSelected,
              onTap: () => onSelect(entry.emoji),
            ).padXS();
          }

          // Wrap in LdContextMenu for skin-tone picker (opens on long-press /
          // right-click; the primary tap still selects the base emoji).
          return LdContextMenu(
            positionMode: LdContextPositionMode.relativeTrigger,
            zoomMode: LdContextZoomMode.never,
            scaleFromTrigger: false,
            menuBuilder: (menuCtx) => _SkinTonePicker(entry: entry, onSelect: onSelect),
            builder: (ctx, _, trigger, isOpen, __) => _EmojiCell(
              emoji: entry.emoji,
              isActive: isOpen || isSelected,
              onTap: () => onSelect(entry.emoji),
              onLongPress: trigger,
            ),
          ).padXS();
        },
      );
    });
  }
}

// ---------------------------------------------------------------------------
// LdEmojiPickerModal
// ---------------------------------------------------------------------------

/// A modal emoji picker with category tabs and fuzzy search.
///
/// Push this inside an [LdModalRoute] to prompt the user to pick an emoji:
///
/// ```dart
/// Navigator.of(context).push(
///   LdModalRoute(
///     dialogSize: LdSize.m,
///     pageBuilder: (context) => LdEmojiPickerModal(
///       value: _currentEmoji,
///       onEmojiSelected: (emoji) => setState(() => _emoji = emoji),
///     ),
///   ),
/// );
/// ```
///
/// When [value] is provided the picker opens on the category that contains
/// the emoji and highlights the matching cell.
///
/// Emojis with skin-tone variants show a context menu on long-press (or
/// right-click on desktop) letting the user choose a tone before confirming.
class LdEmojiPickerModal extends StatefulWidget {
  /// Called with the selected emoji string when the user taps an emoji.
  final void Function(String emoji) onEmojiSelected;

  /// The currently-selected emoji. When set the picker scrolls to and
  /// highlights this emoji inside the grid.
  ///
  /// If the emoji belongs to a category, the picker opens on that category.
  /// [initialCategoryIndex] is ignored when [value] is provided and found.
  final String? value;

  /// The initially active category index. Defaults to 0 (Smileys).
  /// Ignored when [value] is set and successfully located in the data.
  final int initialCategoryIndex;

  final bool allowEmptySelection;

  const LdEmojiPickerModal({
    super.key,
    required this.onEmojiSelected,
    this.value,
    this.initialCategoryIndex = 0,
    this.allowEmptySelection = false,
  });

  @override
  State<LdEmojiPickerModal> createState() => _LdEmojiPickerModalState();
}

class _LdEmojiPickerModalState extends State<LdEmojiPickerModal> {
  late int _activeCategoryIndex;
  String _searchQuery = '';
  List<LdEmojiEntry> _searchResults = [];
  Timer? _debounce;

  // Flat list built once for fuzzy search.
  late final List<LdEmojiEntry> _allEmojis;

  @override
  void initState() {
    super.initState();
    _allEmojis = _ldEmojiData.expand((cat) => cat.emojis).toList();

    // If a current value is provided, open on the category that contains it.
    if (widget.value != null) {
      final categoryIndex = _categoryIndexForEmoji(widget.value!);
      _activeCategoryIndex = categoryIndex ?? widget.initialCategoryIndex.clamp(0, _ldEmojiData.length - 1);
    } else {
      _activeCategoryIndex = widget.initialCategoryIndex.clamp(0, _ldEmojiData.length - 1);
    }
  }

  /// Returns the index of the category that contains [emoji] (either as a
  /// base emoji or as a skin-tone variant), or `null` if not found.
  int? _categoryIndexForEmoji(String emoji) {
    for (var i = 0; i < _ldEmojiData.length; i++) {
      for (final entry in _ldEmojiData[i].emojis) {
        if (entry.emoji == emoji || entry.skinToneVariants.contains(emoji)) {
          return i;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // Build a combined search text from the emoji name and all CLDR
      // keywords so that queries like "happy", "sad", "love", or "fire"
      // match by keyword even when those words don't appear in the name.
      final results = ldFuzzySearchItems<LdEmojiEntry>(
        items: _allEmojis,
        query: query,
        searchText: (e) => e.keywords.isEmpty ? e.name : '${e.name} ${e.keywords.join(' ')}',
      );
      setState(() {
        _searchQuery = query;
        _searchResults = results;
      });
    });
  }

  void _onEmojiSelected(String emoji) {
    widget.onEmojiSelected(emoji);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _ldEmojiData.map((cat) {
      return LdNavigationTab(
        label: cat.name,
        icon: LdEmoji(cat.icon, style: const TextStyle(fontSize: 18)),
        route: cat.name,
      );
    }).toList();

    final activeCategory = _ldEmojiData[_activeCategoryIndex];
    final displayEmojis = _searchQuery.isNotEmpty ? _searchResults : activeCategory.emojis;

    return LdScaffold(
      body: LdAppBar(
        title: LdInput(
          hint: 'Search emojis…',
          autofocus: true,
          showClear: true,
          leading: const Icon(LucideIcons.search),
          onChanged: _onSearchChanged,
          onCleared: () => _onSearchChanged(''),
        ),
        actions: [
          if (widget.allowEmptySelection)
            LdAppBarAction(
              overflowMode: LdAppBarActionOverflowMode.pinned,
              child: Text(LiquidLocalizations.of(context).clearSelection),
              onPressed: () => _onEmojiSelected(''),
            ),
        ],
        child: LdTabNavigation(
          tabs: tabs,
          minTabWidth: 100,
          activeRoute: activeCategory.name,
          onTabPressed: (route) {
            final idx = _ldEmojiData.indexWhere((cat) => cat.name == route);
            if (idx >= 0) {
              setState(() {
                _activeCategoryIndex = idx;
                // Clear search when switching tabs
                if (_searchQuery.isNotEmpty) {
                  _searchQuery = '';
                  _searchResults = [];
                }
              });
            }
          },
          child: _EmojiGrid(
            emojis: displayEmojis,
            onSelect: _onEmojiSelected,
            selectedEmoji: widget.value,
          ),
        ),
      ),
    );
  }
}
