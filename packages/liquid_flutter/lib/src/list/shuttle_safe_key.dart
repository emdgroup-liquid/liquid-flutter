import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef LdIsShuttle = bool;

class LdShuttleSafeKey extends StatelessWidget {
  const LdShuttleSafeKey({
    super.key,
    required this.child,
    required this.childKey,
  });

  final Widget child;

  final Key childKey;

  @override
  Widget build(BuildContext context) {
    final isShuttle = Provider.of<LdIsShuttle?>(context, listen: true) ?? false;
    if (isShuttle) {
      return child;
    }
    return KeyedSubtree(key: childKey, child: child);
  }
}
