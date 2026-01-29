import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A utility widget that displays a sheet when a button is pressed.
class LdModalBuilder extends StatefulWidget {
  /// The builder for the button that opens the sheet. Calll the `onPress` callback to open the sheet.
  final Widget Function(
    BuildContext context,
    Future<dynamic> Function() onPress,
  ) builder;

  final LdModalRoute modal;

  final bool useRootNavigator;

  /// Creates a new sheet builder.

  const LdModalBuilder({
    required this.builder,
    required this.modal,
    this.useRootNavigator = false,
    super.key,
  });

  @override
  State<LdModalBuilder> createState() => LdModalBuilderState();
}

class LdModalBuilderState extends State<LdModalBuilder> {
  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> open(BuildContext context) async {
    final safeContext = widget.useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);

    // Call the builder to create a fresh route instance
    final route = LdModalRoute(
      context: widget.modal.context,
      pageBuilder: widget.modal.pageBuilder,
      barrierDismissible: widget.modal.barrierDismissible,
      modalTypeMode: widget.modal.modalTypeMode,
      scaleParent: widget.modal.scaleParent,
      maintainState: widget.modal.maintainState,
      dialogSize: widget.modal.dialogSize,
      sheetBorderRadius: widget.modal.sheetBorderRadius,
      fixedDialogSize: widget.modal.fixedDialogSize,
      sheetAspectRatio: widget.modal.sheetAspectRatio,
      dialogBorderRadius: widget.modal.dialogBorderRadius,
      sheetBreakpoint: widget.modal.sheetBreakpoint,
      sheetInsets: widget.modal.sheetInsets,
      barrierLabel: widget.modal.barrierLabel,
      settings: widget.modal.settings,
    );
    return await safeContext.push(route);
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
