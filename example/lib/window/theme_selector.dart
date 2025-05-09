import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  @override
  Widget build(BuildContext context) {
    var themeService = Provider.of<LdTheme>(context, listen: true);
    var theme = themeService.palette;

    final themes = {
      "Shad Default": shadDefault,
      "EMD Light Purple": emdLightPurple,
      "Shad Default Dark": shadDefaultDark,
      "EMD Night Runner": emdNightRunner,
      "EMD Dark Blue": emdDarkBlue,
      "EMD Dark Purple": emdDarkPurple,
      "EMD Dark Forest": emdDarkForest,
    };

    return LdSelect<LdPalette>(
      label: "Theme",
      value: theme,
      items: themes.entries
          .map(
            (e) => LdSelectItem(
              child: Text(e.key),
              value: e.value,
            ),
          )
          .toList(),
      onChange: (value) {
        themeService.setPalette(value);
      },
    );
  }
}
