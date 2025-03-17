import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Widget to display when an error occurs while loading a list
class LdListError extends StatelessWidget {
  /// Error to display will be converted to string
  final Object error;

  /// The instance of the [LdRetryController] of the list
  final LdRetryController retryController;

  const LdListError(
      {Key? key, required this.error, required this.retryController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicWidth(
            child: LdExceptionView.fromDynamic(
              error,
              context,
              direction: Axis.vertical,
              retryController: retryController,
            ),
          ),
        ],
      ).padL(),
    );
  }
}
