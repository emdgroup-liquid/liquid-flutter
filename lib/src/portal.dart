import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdPortalEntry {
  // Whether the content should scale when the portal is open.
  bool scaleContent;

  final Key key;

  LdPortalEntry({
    required this.key,
    this.scaleContent = false,
  });

  @override
  bool operator ==(Object other) {
    return other is LdPortalEntry &&
        other.key == key &&
        other.scaleContent == scaleContent;
  }

  @override
  int get hashCode => key.hashCode;
}

class LdPortalController extends ChangeNotifier {
  final List<LdPortalEntry> _entries = [];

  List<LdPortalEntry> get entries => _entries;

  bool get scaleContent => _entries.where((e) {
        return e.scaleContent;
      }).isNotEmpty;

  bool get open => _entries.isNotEmpty;

  LdPortalEntry registerEntry({bool scaleContent = false}) {
    final entry = LdPortalEntry(
      key: UniqueKey(),
      scaleContent: scaleContent,
    );

    _entries.add(entry);

    notifyListeners();

    return entry;
  }

  int indexOf(LdPortalEntry entry) {
    return _entries.indexWhere((e) => entry.key == e.key);
  }

  void removeEntry(LdPortalEntry entry) async {
    _entries.remove(entry);
    notifyListeners();
  }

  static LdPortalController of(BuildContext context, {bool listen = false}) {
    return Provider.of<LdPortalController>(context, listen: listen);
  }

  static LdPortalController? maybeOf(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<LdPortalController?>(context, listen: listen);
  }
}

class LdPortal extends StatelessWidget {
  final Widget child;
  final LdPortalController? controller;

  const LdPortal({
    Key? key,
    required this.child,
    this.controller,
  }) : super(key: key);

  SystemUiOverlayStyle defaultStyle(LdTheme theme) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          theme.isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: theme.surface,
      systemNavigationBarDividerColor: theme.border,
      systemNavigationBarIconBrightness:
          theme.isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: theme.isDark ? Brightness.dark : Brightness.light,
    );
  }

  SystemUiOverlayStyle scaledStyle(LdTheme theme) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: theme.surface,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness:
          theme.isDark ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderOrValue<LdPortalController>(
      create: (_) => LdPortalController(),
      value: controller,
      dispose: (context, value) => value.dispose(),
      child: child,
      builder: (context, child) {
        final controller = LdPortalController.of(context, listen: true);
        final theme = LdTheme.of(context);

        return DefaultTextStyle(
          style: TextStyle(
            color: LdTheme.of(context).text,
            package: theme.fontFamilyPackage,
            fontFamily: theme.fontFamily,
            decoration: TextDecoration.none,
          ),
          child: Stack(
            children: [
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: controller.scaleContent
                    ? scaledStyle(theme)
                    : defaultStyle(theme),
                child: Portal(
                  child: Focus(
                    descendantsAreFocusable: !controller.open,
                    child: LdSpring(
                      springConstant: 5,
                      initialPosition: 0,
                      position: controller.scaleContent ? 1 : 0,
                      builder: (context, state) {
                        return Transform.translate(
                          offset: Offset(0, state.position * 20),
                          child: Transform.scale(
                            scale: (state.position * -0.1 + 1).clamp(0.0, 1.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                state.position * theme.sizingConfig.radiusL,
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProviderOrValue<T extends Listenable> extends StatelessWidget {
  final T? value;

  final Create<T>? create;

  /// Dispose function for the provider, only used if [value] is null
  final Dispose<T>? dispose;

  final Widget Function(BuildContext, Widget?) builder;

  final Widget? child;

  const ProviderOrValue({
    super.key,
    this.value,
    this.create,
    this.child,
    this.dispose,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return ListenableProvider<T>.value(
        value: value!,
        child: child!,
        builder: builder,
      );
    } else {
      return ListenableProvider<T>(
        create: create!,
        child: child!,
        dispose: dispose,
        builder: builder,
      );
    }
  }
}
