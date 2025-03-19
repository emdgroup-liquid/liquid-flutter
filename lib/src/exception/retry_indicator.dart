import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdExceptionRetryIndicator extends StatelessWidget {
  final LdRetryState retryState;
  Duration get remainingRetryTime =>
      retryState.remainingRetryTime ?? Duration.zero;
  Duration get totalRetryDelay => retryState.totalRetryDelay ?? Duration.zero;

  const LdExceptionRetryIndicator({
    super.key,
    required this.retryState,
  });

  double get progress =>
      (remainingRetryTime.inMilliseconds / totalRetryDelay.inMilliseconds)
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
          LiquidLocalizations.of(context).retryIn(
            remainingRetryTime.inSeconds,
          ),
        ),
      ],
    );
  }
}
