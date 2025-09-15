import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MacOSWindowControls extends StatelessWidget {
  const MacOSWindowControls({
    super.key,
    required bool showWindowControls,
  }) : _showWindowControls = showWindowControls;

  final bool _showWindowControls;

  @override
  Widget build(BuildContext context) {
    return LdReveal(
      initialRevealed: _showWindowControls,
      revealed: _showWindowControls,
      child: Row(
        children: [
          Tooltip(
            message: LiquidLocalizations.of(context).close,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).error,
              child: const Icon(Icons.circle, size: 14),
              onPressed: () {
                LdAppBar.callbacks?.onClose?.call();
              },
            ),
          ),
          Tooltip(
            message: LiquidLocalizations.of(context).minimize,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).warning,
              child: const Icon(Icons.circle, size: 14),
              onPressed: () {
                LdAppBar.callbacks?.onMinimize?.call();
              },
            ),
          ),
          Tooltip(
            message: LiquidLocalizations.of(context).maximize,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).success,
              child: const Icon(Icons.circle, size: 14),
              onPressed: () {
                LdAppBar.callbacks?.onMaximize?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}
