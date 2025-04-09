import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid/source_code.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final bool expanded;

  const CodeBlock({
    Key? key,
    required this.code,
    this.language = "dart",
    this.expanded = false,
  }) : super(key: key);

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
    bool isDesktop =
        kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return LayoutBuilder(
      builder: (context, _) => LdCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            SourceCode(
              code: widget.code,
              padding: LdTheme.of(context).pad(),
            ),
            if (isDesktop)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LdButton(
                    color: shadSky,
                    size: LdSize.s,
                    mode: LdButtonMode.outline,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.code));
                      LdNotificationsController.of(context).addNotification(
                        LdNotification(
                          message: "Copied to clipboard",
                          type: LdNotificationType.success,
                        ),
                      );
                    },
                    child: const Text("Copy"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
