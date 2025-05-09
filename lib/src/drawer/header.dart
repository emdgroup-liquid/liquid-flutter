import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';

/// The header of a drawer, that contains the application or menu title
class LdDrawerHeader extends StatelessWidget {
  final Widget title;
  final bool showBack;
  final ScrollController? scrollController;

  const LdDrawerHeader({
    required this.title,
    this.showBack = true,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<LdTheme>(context, listen: false);

    var isDektop =
        kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    final header = SafeArea(
      top: !isDektop,
      bottom: false,
      minimum: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DefaultTextStyle(
                style: ldBuildTextStyle(
                  theme,
                  LdTextType.headline,
                  LdSize.s,
                ),
                child: title),
          ),
          if (showBack)
            LdButton(
                mode: LdButtonMode.ghost,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(LucideIcons.arrowLeft))
        ],
      ),
    );

    if (scrollController != null) {
      return LdBlurringHeader(
        child: header,
        scrollController: scrollController!,
      );
    }

    return header;
  }
}
