import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdAppBarCloseModalButton extends StatelessWidget {
  const LdAppBarCloseModalButton({super.key});

  static bool canShow(BuildContext context) {
    if (!context.mounted) return false;

    final parentShows = LdAppBarImpliedFeature.close.shownByParent(context);
    if (parentShows) return false;

    if (!context.isInLdModal) return false;

    if (!context.isInTopAppBar) return false;

    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute && parentRoute.barrierDismissible;
  }

  @override
  Widget build(BuildContext context) {
    return LdButton.ghost(
      onPressed: () => Navigator.of(context).maybePop(),
      child: const Icon(LucideIcons.x),
    );
  }
}
