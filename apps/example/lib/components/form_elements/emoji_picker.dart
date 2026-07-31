import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class EmojiPickerDemo extends StatefulWidget {
  const EmojiPickerDemo({super.key});

  @override
  State<EmojiPickerDemo> createState() => _EmojiPickerDemoState();
}

class _EmojiPickerDemoState extends State<EmojiPickerDemo> {
  String? _selectedEmoji;
  String? _secondEmoji;

  Future<void> _openPicker({
    required void Function(String) onSelected,
    String? currentValue,
    int initialCategoryIndex = 0,
    bool allowEmptySelection = false,
  }) {
    return LdModalRoute(
      context: context,
      dialogSize: LdSize.m,
      pageBuilder: (ctx) => LdEmojiPickerModal(
        allowEmptySelection: allowEmptySelection,
        value: currentValue,
        initialCategoryIndex: initialCategoryIndex,
        onEmojiSelected: onSelected,
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/emoji_picker.dart",
      title: "LdEmojiPickerModal",
      apiComponents: const ["LdEmojiPickerModal", "LdEmojiEntry", "LdEmojiCategory"],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            "LdEmojiPickerModal is an emoji selection modal with category tabs, "
            "fuzzy search, and skin-tone support. Push it inside an LdModalRoute "
            "to prompt the user to pick an emoji.",
          ),

          // ── Basic picker ──────────────────────────────────────────────────
          ComponentWell(
            title: const Text("Basic picker"),
            description: const Text(
              "Tap the button to open the modal. The picker organises all "
              "Unicode emoji into category tabs (LdTabNavigation). Emojis "
              "that support skin tones show a context-menu popover on "
              "long-press or right-click.",
            ),
            child: Center(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LdButton(
                    onPressed: () => _openPicker(
                      currentValue: _selectedEmoji,
                      onSelected: (e) => setState(() => _selectedEmoji = e),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedEmoji ?? '😀', style: const TextStyle(fontSize: 22)),
                        ldHSpacerS,
                        Text(_selectedEmoji == null ? 'Pick an emoji' : 'Change emoji'),
                      ],
                    ),
                  ),
                  if (_selectedEmoji != null) LdText.l('Selected: $_selectedEmoji'),
                ],
              ),
            ),
          ),

          // ── Fuzzy search ──────────────────────────────────────────────────
          ComponentWell(
            title: const Text("Fuzzy search"),
            description: const Text(
              "Type in the search bar to fuzzy-match emoji by name across all "
              "categories. Try \"heart\", \"hand\", or \"flag\".",
            ),
            child: Center(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LdButton.outline(
                    onPressed: () =>
                        _openPicker(currentValue: _secondEmoji, onSelected: (e) => setState(() => _secondEmoji = e)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_secondEmoji ?? '🔍', style: const TextStyle(fontSize: 22)),
                        ldHSpacerS,
                        const Text('Search for an emoji'),
                      ],
                    ),
                  ),
                  if (_secondEmoji != null) LdText.l('Selected: $_secondEmoji'),
                ],
              ),
            ),
          ),

          // ── Start on a specific category ──────────────────────────────────
          ComponentWell(
            title: const Text("Start on a specific category"),
            description: const Text(
              "Pass initialCategoryIndex to open the picker on a different "
              "tab. The example below starts on \"Animals & Nature\" (index 2).",
            ),
            child: Center(
              child: LdButton.ghost(
                onPressed: () => _openPicker(initialCategoryIndex: 2, onSelected: (_) {}),
                child: const Text('Open Animals & Nature'),
              ),
            ),
          ),

          // ── Data access ───────────────────────────────────────────────────
          ComponentWell(
            title: const Text("Accessing emoji data"),
            description: const Text(
              "ldEmojiData exposes the full categorised emoji dataset. "
              "You can use it independently of the modal.",
            ),
            child: LdCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: ldEmojiData.map((cat) {
                  return LdListItem(
                    leading: LdAvatar(child: LdEmoji(cat.icon)),
                    title: Text(cat.name),
                    trailing: LdBadge(child: Text('${cat.emojis.length}')),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
