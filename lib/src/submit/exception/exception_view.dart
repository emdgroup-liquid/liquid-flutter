import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/exception_dialog.dart';
import 'package:provider/provider.dart';

/// Renders an LdException
class LdExceptionView extends StatelessWidget {
  final LdException? exception;
  final VoidCallback? retry;

  final Axis direction;

  const LdExceptionView({
    super.key,
    required this.exception,
    this.retry,
    this.direction = Axis.vertical,
  });

  factory LdExceptionView.fromDynamic(
    dynamic error,
    BuildContext context, {
    Axis direction = Axis.vertical,
    VoidCallback? retry,
  }) {
    final exceptionMapper = context.read<LdExceptionMapper?>() ??
        LdExceptionMapper(
          localizations: LiquidLocalizations.of(context),
        );

    final ldException = exceptionMapper.handle(error);

    return LdExceptionView(
      exception: ldException,
      retry: retry,
      direction: direction,
    );
  }

  LdColor color(BuildContext context) {
    switch (exception?.type) {
      case LdHintType.warning:
        return LdTheme.of(context).warning;
      case LdHintType.success:
        return LdTheme.of(context).success;
      default:
        return LdTheme.of(context).error;
    }
  }

  _buildRetryButton(BuildContext context) {
    final isRetrying = (exception?.retryState?.delay ?? 0) > 0;
    final text = isRetrying
        ? LiquidLocalizations.of(context).retryIn(
            Duration(milliseconds: exception!.retryState!.delay).inSeconds,
          )
        : LiquidLocalizations.of(context).retry;
    if (!isRetrying && exception?.canRetry == false) {
      // hide the button if the exception can't be retried and there is no retry
      // countdown.
      return const SizedBox.shrink();
    }
    return LdButton(
      child: Text(text),
      mode: LdButtonMode.filled,
      color: LdTheme.of(context).error,
      disabled: exception?.canRetry == false,
      onPressed: retry ?? () {},
    );
  }

  _buildDialogButton(BuildContext context, VoidCallback moreInfo) {
    return LdButton(
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LiquidLocalizations.of(context).moreInfo,
          ),
        ],
      ),
      mode: LdButtonMode.outline,
      color: color(context),
      onPressed: moreInfo,
    );
  }

  _buildHorizontal(BuildContext context, VoidCallback moreInfo) {
    return LdAutoSpace(
      children: [
        LdHint(
          child: Text(exception?.message ?? ""),
          type: exception?.type ?? LdHintType.error,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogButton(context, moreInfo),
            if (retry != null || exception?.retryState != null) ...[
              ldSpacerM,
              _buildRetryButton(context)
            ],
          ],
        )
      ],
    );
  }

  _buildVertical(BuildContext context, VoidCallback moreInfo) {
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdHint(
          type: exception?.type ?? LdHintType.error,
          size: LdSize.l,
        ),
        LdTextP(exception?.message ?? ""),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _buildDialogButton(context, moreInfo)),
            if (retry != null) ...[
              ldSpacerM,
              Flexible(
                child: _buildRetryButton(context),
              )
            ],
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdModalBuilder(
      modal: LdModal(
        size: LdSize.xs,
        modalContent: (context) => LdExceptionDialog(
          error: exception,
          close: () => Navigator.of(context).pop(),
        ),
      ),
      builder: (context, open) => switch (direction) {
        (Axis.horizontal) => _buildHorizontal(context, open),
        (Axis.vertical) => _buildVertical(context, open),
      },
    );
  }
}
