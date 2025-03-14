import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdExceptionRetryIndicator extends StatelessWidget {
  final int attempt;

  final Duration remainingTime;
  final Duration totalRetryTime;

  const LdExceptionRetryIndicator({
    super.key,
    required this.attempt,
    required this.remainingTime,
    required this.totalRetryTime,
  });

  double get progress =>
      (remainingTime.inMilliseconds / totalRetryTime.inMilliseconds)
          .clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            color: LdTheme.of(context).primaryColor,
            backgroundColor: LdTheme.of(context).neutralShade(3),
          ),
        ),
        ldSpacerS,
        LdTextLs(
          LiquidLocalizations.of(context).retryIn(remainingTime.inSeconds),
        ),
      ],
    );
  }
}
