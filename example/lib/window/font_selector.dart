import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class FontSelector extends StatefulWidget {
  const FontSelector({super.key});

  @override
  State<FontSelector> createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {
  String _family = "Lato";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdChoose<String>(
      label: "Font family",
      mode: LdChooseMode.modal,
      items: GoogleFonts.asMap().keys.map(
            (font) => LdSelectItem(
              value: font,
              child: Text(font),
            ),
          ),
      onChange: (p0) async {
        final font = GoogleFonts.getFont(p0.first);

        await GoogleFonts.pendingFonts();

        // ignore: use_build_context_synchronously
        LdNotificationsController.of(context).success(
          "Font changed to ${p0.first}",
        );

        theme.fontFamily = font.fontFamily!;

        theme.fontFamilyPackage = null;

        setState(() {
          _family = p0.first;
        });
      },
      value: {_family},
    );
  }
}
