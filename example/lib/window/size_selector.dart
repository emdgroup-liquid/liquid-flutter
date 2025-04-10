import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class SizeSelector extends StatefulWidget {
  const SizeSelector({super.key});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  @override
  Widget build(BuildContext context) {
    var themeService = Provider.of<LdTheme>(context, listen: false);
    var size = themeService.themeSize;

    return LdSwitch<LdThemeSize>(
        value: size,
        onChanged: (newSize) {
          setState(() {
            themeService.setThemeSize(newSize);
          });
        },
        label: "Theme Size",
        children: const {
          LdThemeSize.s: Text("Small", maxLines: 1),
          LdThemeSize.m: Text("Medium", maxLines: 1),
          LdThemeSize.l: Text("Large", maxLines: 1),
        });
  }
}
