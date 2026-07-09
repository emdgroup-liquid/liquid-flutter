import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DemoCodeDialog extends StatelessWidget {
  final String demoCode;

  const DemoCodeDialog({super.key, required this.demoCode});

  @override
  Widget build(BuildContext context) {
    return LdModalBuilder(
      builder: (context, onPress) => LdButton(
        leading: const Icon(LucideIcons.code),
        size: LdSize.s,
        mode: LdButtonMode.outline,
        onPressed: onPress,
        child: const Text("Show Code"),
      ),
      modal: LdModalRoute(
        context: context,
        pageBuilder: (context) {
          final ldTheme = LdTheme.of(context, listen: false);
          return LdScaffold(
            body: LdAppBar(
              title: const Text("Code Example"),
              child: LdScaffoldBody(
                children: [
                  SingleChildScrollView(
                    child: HighlightView(
                      demoCode,
                      language: 'dart',
                      theme: atomOneDarkTheme,
                      padding: const EdgeInsets.all(16),
                      textStyle: TextStyle(
                        fontFamily: ldTheme.monoFontFamily,
                        package: ldTheme.monoFontFamilyPackage,
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
