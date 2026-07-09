import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Renders an LdException
class LdExceptionView extends StatelessWidget {
  /// The exception to render
  final LdException exception;

  /// The controller for managing retry operations
  final LdRetryController? retryController;

  /// A callback to retry the action that caused the exception
  /// If null, the retry button will not be displayed
  final VoidCallback? retry;

  /// The direction of the exception view, either [Axis.vertical] or
  /// [Axis.horizontal].
  final Axis direction;

  /// Whether to show the indicator
  final bool showIndicator;

  const LdExceptionView({
    super.key,
    required this.exception,
    this.retryController,
    this.retry,
    this.showIndicator = true,
    this.direction = Axis.vertical,
  }) : assert(
          retryController == null || retry == null,
          'Cannot provide both retryController and retry. Use only one.',
        );

  LdColor color(BuildContext context) {
    switch (exception.type) {
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

  Widget _buildRetryButton(BuildContext context, LdRetryController? controller) {
    return LdButton(
      key: const Key('retry-button'),
      mode: LdButtonMode.filled,
      color: LdTheme.of(context).error,
      onPressed: controller?.retry ?? retry ?? () {},
      loading: controller?.state.isRetrying == true,
      child: Text(LiquidLocalizations.of(context).retry),
    );
  }

  Widget _buildRetryIndicator(BuildContext context, LdRetryController? controller) {
    if (!(controller?.showRetryIndicator == true)) return const SizedBox();
    return LdExceptionRetryIndicator(
      retryState: controller!.state,
      cancelRetry: controller.reset,
    );
  }

  LdButton _buildDialogButton(BuildContext context, VoidCallback moreInfo) {
    return LdButton(
      key: const Key('more-info-button'),
      autoLoading: false,
      mode: LdButtonMode.outline,
      color: color(context),
      onPressed: moreInfo,
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LiquidLocalizations.of(context).moreInfo,
          ),
        ],
      ),
    );
  }

  LdAutoSpace _buildHorizontal(
    BuildContext context,
    VoidCallback moreInfo,
    LdRetryController? controller,
  ) {
    final localizedException = exception.localize(context);
    return LdAutoSpace(
      children: [
        if (showIndicator)
          LdReveal.quick(
            revealed: true,
            initialRevealed: false,
            child: localizedException.customIconBuilder?.call(context) ??
                LdHint(
                  type: exception.type,
                  child: Text(
                    localizedException.message,
                    key: const Key('exception-message'),
                  ),
                ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller?.showRetryButton == true) ...[
              LdReveal.quick(
                revealed: true,
                initialRevealed: false,
                child: _buildRetryButton(context, controller),
              ),
            ],
            LdReveal.quick(
              revealed: localizedException.moreInfo != null,
              initialRevealed: false,
              child: _buildDialogButton(context, moreInfo),
            ),
          ],
        ).spaceM(),
        if (localizedException.additionalBuilder != null) ...[
          localizedException.additionalBuilder!(context),
        ],
      ],
    );
  }

  LdAutoSpace _buildVertical(
    BuildContext context,
    VoidCallback moreInfo,
    LdRetryController? controller,
  ) {
    final localizedException = exception.localize(context);
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIndicator)
          localizedException.customIconBuilder?.call(context) ??
              LdHint(
                type: exception.type,
                size: LdSize.l,
              ),
        LdText.p(
          localizedException.message,
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (localizedException.moreInfo != null) _buildDialogButton(context, moreInfo),
            if (controller?.showRetryButton == true) ...[
              ldSpacerM,
              _buildRetryButton(context, controller),
            ],
          ],
        ),
        if (localizedException.additionalDetailsBuilder != null) ...[
          localizedException.additionalDetailsBuilder!(context),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = retryController ?? _createRetryController();

    return StreamBuilder<LdRetryState>(
        stream: controller?.stateStream ?? const Stream.empty(),
        builder: (context, snapshot) {
          return LdAutoSpace(crossAxisAlignment: CrossAxisAlignment.center, children: [
            LdModalBuilder(
              useRootNavigator: true,
              modal: LdModalRoute(
                context: context,
                pageBuilder: (context) => LdExceptionDialog(
                  error: exception,
                ),
              ),
              builder: (context, open) => switch (direction) {
                (Axis.horizontal) => _buildHorizontal(context, open, controller),
                (Axis.vertical) => _buildVertical(context, open, controller),
              },
            ),
            _buildRetryIndicator(context, controller),
          ]);
        });
  }
}
