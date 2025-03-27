import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A utility widget that displays a sheet when a button is pressed. Attention: This requries are flutter_portal to be placed at the root of your application. See https://pub.dev/packages/flutter_portal
class LdModalBuilder extends StatefulWidget {
  /// The builder for the button that opens the sheet. Calll the `onPress` callback to open the sheet.
  final Widget Function(
    BuildContext context,
    Future<dynamic> Function() onPress,
  ) builder;

  final LdModal modal;

  final bool useRootNavigator;

  /// Creates a new sheet builder.

  const LdModalBuilder({
    required this.builder,
    required this.modal,
    this.useRootNavigator = false,
    Key? key,
  }) : super(key: key);

  @override
  State<LdModalBuilder> createState() => LdModalBuilderState();
}

class LdModalBuilderState extends State<LdModalBuilder> {
  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> open(BuildContext context) async {
    final safeContext = widget.useRootNavigator
        ? Navigator.of(context, rootNavigator: true)
        : Navigator.of(context);

    return await widget.modal.show(
      safeContext.context,
      useRootNavigator: widget.useRootNavigator,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure the sheet is not bigger than the screen

    return widget.builder(
      context,
      () => open(context),
    );
  }
}
