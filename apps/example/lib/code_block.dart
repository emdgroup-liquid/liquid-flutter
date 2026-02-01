import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid/source_code.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final bool expanded;
  final bool showCopyButton;
  final bool wrapCard;

  const CodeBlock({
    super.key,
    required this.code,
    this.language = "dart",
    this.expanded = false,
    this.showCopyButton = true,
    this.wrapCard = true,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  final int maxLines = 10;
  late int lines;

  @override
  void initState() {
    lines = widget.code.trim().split("\n").length;
    expanded = widget.expanded;

    super.initState();
  }

  bool expanded = false;

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = LdTheme.of(context).platform.isDesktop;
    final tr = LiquidLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, _) => LdWrapConditional(
        condition: widget.wrapCard,
        builder: (context, child) => LdCard(child: child),
        child: Stack(
          children: [
            SourceCode(code: widget.code),
            if (isDesktop && widget.showCopyButton)
              Align(
                alignment: Alignment.topRight,
                child: LdButton(
                  color: shadSky,
                  size: LdSize.s,
                  mode: LdButtonMode.outline,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.code));
                    LdNotificationsController.of(
                      context,
                    ).addNotification(LdNotification(message: tr.copiedToClipboard, type: LdNotificationType.success));
                  },
                  child: Text(tr.copy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
