import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlatformSelector extends StatefulWidget {
  const PlatformSelector({super.key});

  @override
  State<PlatformSelector> createState() => _PlatformSelectorState();
}

class _PlatformSelectorState extends State<PlatformSelector> {
  @override
  Widget build(BuildContext context) {
    var themeService = Provider.of<LdTheme>(context, listen: true);
    var platform = themeService.platform;

    final platforms = {
      "macOS": LdPlatform.macos,
      "iOS": LdPlatform.ios,
      "Android": LdPlatform.android,
      "Linux": LdPlatform.linux,
      "Windows": LdPlatform.windows,
      "Web Android": LdPlatform.webAndroid,
      "Web iOS": LdPlatform.webIOS,
      "Web macOS": LdPlatform.webMacOS,
      "Web Windows": LdPlatform.webWindows,
      "Web Linux": LdPlatform.webLinux,
      "Web Unknown": LdPlatform.webUnknown,
    };

    return LdSelect<LdPlatform>(
      label: "Platform",
      value: platform,
      items: platforms.entries.map((e) => LdSelectItem(child: Text(e.key), value: e.value)).toList(),
      onChanged: (value) {
        themeService.platform = value;
      },
    );
  }
}
