import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

    return LdAutoSpace(
      children: [
        LdTextL("Theme"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var item in themes.entries)
              LdTouchableSurface(
                mode: LdTouchableSurfaceMode.outline,
                color: item.value.primary,
                active: theme == item.value,
                onTap: () {
                  themeService.setPalette(item.value);
                },
                builder: (context, colorBundle, status) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colorBundle.surface,
                      border: Border.all(
                        color: colorBundle.border,
                      ),
                      borderRadius: LdTheme.of(context).radius(LdSize.m),
                    ),
                    height: 48,
                    width: 48,
                    child: Center(
                      child: item.value.isDark
                          ? Icon(
                              LucideIcons.moon,
                              color: colorBundle.text,
                            )
                          : Icon(
                              LucideIcons.sun,
                              color: colorBundle.text,
                            ),
                    ),
                  );
                },
              )
          ],
        ),
      ],
    );
  }
}
