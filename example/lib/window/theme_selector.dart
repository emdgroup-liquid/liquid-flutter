import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  @override
  Widget build(BuildContext context) {
    var themeService = Provider.of<LdTheme>(context, listen: false);
    var theme = themeService.palette;

    return LdSelect<LdPalette>(
        label: "Color palette",
        onChange: (newTheme) {
          setState(() {
            themeService.setPalette(newTheme);
          });
        },
        onSurface: true,
        value: theme,
        items: [
          LdSelectItem(
            child: const Text("Shad Default"),
            value: shadDefault,
          ),
          LdSelectItem(
            child: const Text("Shad Default Dark"),
            value: shadDefaultDark,
          ),
          LdSelectItem(
            value: emdNightRunner,
            child: const Text("Night Runner EMD"),
          ),
          LdSelectItem(
            value: emdDarkBlue,
            child: const Text("Dark Blue EMD"),
          ),
          LdSelectItem(
            value: emdLightPurple,
            child: const Text("Light purple EMD"),
          ),
          LdSelectItem(
            value: emdDarkPurple,
            child: const Text("Dark purple EMD"),
          ),
          LdSelectItem(
            value: emdDarkForest,
            child: const Text("Dark forest EMD"),
          ),
          LdSelectItem(
            value: emdLightBlue,
            child: const Text("Light Blue EMD"),
          ),

          /*
          const LdSelectItem(
            child: Text("Bubblegum"),
            value: bubblegum,
          ),
          const LdSelectItem(
            child: Text("Solvent"),
            value: solvent,
          ),
          const LdSelectItem(
            child: Text("Shake"),
            value: shake,
          ),*/
          /*LdSelectItem(
            child: const Text("Ocean"),
            value: ocean,
          ),
          LdSelectItem(
            child: const Text("M-Trust Light"),
            value: mTrustLight,
          ),
          LdSelectItem(
            child: const Text("M-Trust Dark"),
            value: mTrustDark,
          ),
          LdSelectItem(
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Deep Ocean"),
                  ldSpacerS,
                  LdTag(
                    child: Text("Beta"),
                    size: LdSize.s,
                  )
                ],
              ),
            ),
            value: deepOcean,
          ),
          LdSelectItem(
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Dark Forest"),
                  ldSpacerS,
                  LdTag(
                    child: Text("Beta"),
                    size: LdSize.s,
                  )
                ],
              ),
            ),
            value: darkForest,
          ),
          LdSelectItem(
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Pink panther"),
                  ldSpacerS,
                  LdTag(
                    child: Text("Beta"),
                    size: LdSize.s,
                  )
                ],
              ),
            ),
            value: pinkPanther,
          ),
          LdSelectItem(
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Dark nights"),
                  ldSpacerS,
                  LdTag(
                    child: Text("Beta"),
                    size: LdSize.s,
                  )
                ],
              ),
            ),
            value: darkNights,
          ),
          LdSelectItem(
            child: const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Dark days"),
                  ldSpacerS,
                  LdTag(
                    child: Text("Beta"),
                    size: LdSize.s,
                  )
                ],
              ),
            ),
            value: darkDays,
          ),*/
        ]);
  }
}
