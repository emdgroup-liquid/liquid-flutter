import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HeadlineFontSelector extends StatefulWidget {
  const HeadlineFontSelector({super.key});

  @override
  State<HeadlineFontSelector> createState() => _HeadlineFontSelectorState();
}

class _HeadlineFontSelectorState extends State<HeadlineFontSelector> {
  String _family = "Lato";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdChoose<String>(
      mode: LdChooseMode.modal,
      label: "Headline font family",
      items: GoogleFonts.asMap().entries.map(
            (entry) => LdSelectItem(
              value: entry.key,
              child: Text(entry.key),
            ),
          ),
      onChange: (p0) async {
        final font = GoogleFonts.getFont(p0.first);

        await GoogleFonts.pendingFonts();

        // ignore: use_build_context_synchronously
        LdNotificationsController.of(context).success(
          "Font changed to ${p0.first}",
        );

        theme.headlineFontFamily = font.fontFamily!;

        theme.fontFamilyPackage = null;

        setState(() {
          _family = p0.first;
        });
      },
      value: {_family},
    );
  }
}
