import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

double defaultRadiusXs = 2.0;
double defaultRadiusS = 4.0;
double defaultRadiusM = 8.0;
double defaultRadiusL = 16.0;

double sharpRadius = 0.0;

double roundedRadiusXs = 4.0;
double roundedRadiusS = 8.0;
double roundedRadiusM = 16.0;
double roundedRadiusL = 32.0;

enum RadiusMode {
  sharp,
  standard,
  rounded,
}

class RadiusSelector extends StatefulWidget {
  const RadiusSelector({super.key});

  @override
  State<RadiusSelector> createState() => _RadiusSelectorState();
}

class _RadiusSelectorState extends State<RadiusSelector> {
  RadiusMode _mode = RadiusMode.standard;

  @override
  Widget build(BuildContext context) {
    return LdSwitch<RadiusMode>(
        label: "Radius Mode",
        onChanged: (p0) {
          final theme = LdTheme.of(context);

          switch (p0) {
            case RadiusMode.sharp:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: sharpRadius,
                radiusS: sharpRadius,
                radiusM: sharpRadius,
                radiusL: sharpRadius,
              );
              break;
            case RadiusMode.standard:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: defaultRadiusXs,
                radiusS: defaultRadiusS,
                radiusM: defaultRadiusM,
                radiusL: defaultRadiusL,
              );
              break;
            case RadiusMode.rounded:
              theme.sizingConfig = LdSizingConfig(
                radiusXS: roundedRadiusXs,
                radiusS: roundedRadiusS,
                radiusM: roundedRadiusM,
                radiusL: roundedRadiusL,
              );
              break;
          }
          setState(() {
            _mode = p0;
          });
        },
        children: const {
          RadiusMode.sharp: Text("Sharp", maxLines: 1),
          RadiusMode.standard: Text("Standard", maxLines: 1),
          RadiusMode.rounded: Text("Rounded", maxLines: 1),
        },
        value: _mode);
  }
}
