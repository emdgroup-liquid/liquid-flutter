import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Renders an LdException
class LdExceptionView extends StatelessWidget {
  /// The exception to render
  final LdException? exception;

  /// The controller for managing retry operations
  final LdRetryController? retryController;

  /// A callback to retry the action that caused the exception
  /// If null, the retry button will not be displayed
  final VoidCallback? retry;

  /// The direction of the exception view, either [Axis.vertical] or
  /// [Axis.horizontal].
  final Axis direction;

  const LdExceptionView({
    super.key,
    required this.exception,
    this.retryController,
    this.retry,
    this.direction = Axis.vertical,
  }) : assert(
          retryController == null || retry == null,
          'Cannot provide both retryController and retry. Use only one.',
        );

  /// Creates an LdExceptionView from a dynamic error.
  /// Uses the [LdExceptionMapper] to map the error to an LdException.
  factory LdExceptionView.fromDynamic(
    dynamic error,
    BuildContext context, {
    Axis direction = Axis.vertical,
    LdRetryController? retryController,
    VoidCallback? retry,
  }) {
    final exceptionMapper = context.read<LdExceptionMapper?>() ??
        LdExceptionMapper(
          localizations: LiquidLocalizations.of(context),
        );

    final ldException = exceptionMapper.handle(error);

    return LdExceptionView(
      exception: ldException,
      retryController: retryController,
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

  /// Creates a lightweight LdRetryController if a retry callback is provided
  LdRetryController? _createRetryController() {
    if (retry != null) {
      return LdRetryController(
        onRetry: retry!,
        config: LdRetryConfig.unlimitedManualRetries(),
      );
    }
    return retryController;
  }

  _buildRetryButton(BuildContext context, LdRetryController? controller) {
    return LdButton(
      child: Text(LiquidLocalizations.of(context).retry),
      key: const Key('retry-button'),
      mode: LdButtonMode.filled,
      color: LdTheme.of(context).error,
      onPressed: controller?.retry ?? () {},
      loading: controller?.state.isRetrying == true,
    );
  }

  _buildRetryIndicator(BuildContext context, LdRetryController? controller) {
    if (!(controller?.showRetryIndicator == true)) return const SizedBox();
    return LdExceptionRetryIndicator(
      retryState: controller!.state,
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

  _buildHorizontal(
    BuildContext context,
    VoidCallback moreInfo,
    LdRetryController? controller,
  ) {
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
            if (controller?.showRetryButton == true) ...[
              ldSpacerM,
              _buildRetryButton(context, controller),
            ],
          ],
        )
      ],
    );
  }

  _buildVertical(
    BuildContext context,
    VoidCallback moreInfo,
    LdRetryController? controller,
  ) {
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdHint(
          type: exception?.type ?? LdHintType.error,
          size: LdSize.l,
        ),
        LdTextP(
          exception?.message ?? "",
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogButton(context, moreInfo),
            if (controller?.showRetryButton == true) ...[
              ldSpacerM,
              _buildRetryButton(context, controller),
            ],
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _createRetryController();

    return StreamBuilder<LdRetryState>(
        stream: controller?.stateStream ?? const Stream.empty(),
        builder: (context, snapshot) {
          return LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LdModalBuilder(
                  useRootNavigator: true,
                  modal: LdModal(
                    size: LdSize.xs,
                    modalContent: (context) => LdExceptionDialog(
                      error: exception,
                    ),
                  ),
                  builder: (context, open) => switch (direction) {
                    (Axis.horizontal) =>
                      _buildHorizontal(context, open, controller),
                    (Axis.vertical) =>
                      _buildVertical(context, open, controller),
                  },
                ),
                _buildRetryIndicator(context, controller),
              ]);
        });
  }
}
