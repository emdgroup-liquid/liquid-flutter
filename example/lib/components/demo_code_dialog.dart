import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class DemoCodeDialog extends StatefulWidget {
  final String demoCode;

  const DemoCodeDialog({super.key, required this.demoCode});

  @override
  State<DemoCodeDialog> createState() => _DemoCodeDialogState();
}

class _DemoCodeDialogState extends State<DemoCodeDialog> {
  HighlighterTheme? _theme;
  HighlighterTheme? _themeDark;

  @override
  void initState() {
    prepareHighlighter();
    super.initState();
  }

  void prepareHighlighter() async {
    await Highlighter.initialize(['dart']);
    _themeDark = await HighlighterTheme.loadDarkTheme();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_theme == null) {
      return const Center(child: LdLoader());
    }

    final highlighter = Highlighter(
      language: 'dart',
      theme: _themeDark!,
    );

    var highlightedCode = highlighter.highlight(widget.demoCode);

    return LdModalBuilder(
      builder: (context, onPress) => LdButton(
        leading: const Icon(LucideIcons.code),
        size: LdSize.s,
        mode: LdButtonMode.outline,
        onPressed: onPress,
        child: const Text("Show Code"),
      ),
      modal: LdModal(
        title: const Text("Code Example"),
        modalContent: (context) => SelectableRegion(
          focusNode: FocusNode(),
          selectionControls: MaterialTextSelectionControls(),
          child: Container(
            color: shadZinc.shades.last,
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text.rich(
                highlightedCode,
                style: TextStyle(color: Colors.white),
              ),
            )),
          ),
        ),
      ),
    );
  }
}
