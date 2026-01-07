import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:provider/provider.dart';

class LdSubmitDialogBuilder<T, Arg> extends LdSubmitBuilder<T, Arg> {
  const LdSubmitDialogBuilder({
    super.key,
    super.resultBuilder,
    super.errorBuilder,
    super.loadingBuilder,
    super.submitButtonBuilder,
    this.showSubmitButton,
    this.targetRoot = false,
  });

  final bool? showSubmitButton;

  final bool targetRoot;

  @override
  Widget build(BuildContext context) {
    return LdSubmitDialog<T, Arg>(
      resultBuilder: resultBuilder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      submitButtonBuilder: submitButtonBuilder,
      showSubmitButton: showSubmitButton,
    );
  }
}

class LdSubmitDialog<T, Arg> extends StatefulWidget {
  const LdSubmitDialog({
    super.key,
    this.resultBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.submitButtonBuilder,
    this.showSubmitButton,
    this.targetRoot = false,
  });

  final LdSubmitResultBuilder<T, Arg>? resultBuilder;
  final LdSubmitErrorBuilder<T, Arg>? errorBuilder;
  final LdSubmitLoadingBuilder<T, Arg>? loadingBuilder;
  final LdSubmitButtonBuilder<T, Arg>? submitButtonBuilder;
  final bool? showSubmitButton;

  final bool targetRoot;

  @override
  State<LdSubmitDialog<T, Arg>> createState() => _LdSubmitDialogState<T, Arg>();
}

class _LdSubmitDialogState<T, Arg> extends State<LdSubmitDialog<T, Arg>> {
  final _overlayController = OverlayPortalController();
  late LdSubmitController<T, Arg> _submitController;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _submitController = context.read<LdSubmitController<T, Arg>>();
    _subscription = _submitController.stateStream.listen(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onStateChanged(_submitController.state);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onStateChanged(LdSubmitState state) {
    if (!mounted) return;

    final open = state.type == LdSubmitStateType.loading || state.type == LdSubmitStateType.error;
    if (open) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  Widget buildLoadingDialog(
    BuildContext context,
    LdSubmitController<T, Arg> controller,
  ) {
    return widget.loadingBuilder != null
        ? widget.loadingBuilder!(context, controller)
        : LdAutoSpace(
            animate: true,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ldSpacerL,
              const LdLoader(
                size: 48,
              ),
              if (controller.config.loadingText != null)
                LdText.p(
                  controller.config.loadingText!,
                  textAlign: TextAlign.center,
                )
              else
                LdText.p(
                  LiquidLocalizations.of(context).loading,
                  textAlign: TextAlign.center,
                ),
              if (controller.canCancel)
                LdButton.ghost(
                  onPressed: controller.cancel,
                  child: Text(LiquidLocalizations.of(context).cancel),
                ),
            ],
          ).padL();
  }

  Widget buildErrorDialog(
    BuildContext context,
    LdSubmitController<T, Arg> controller,
  ) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, controller.state.error!, controller);
    }

    return LdExceptionView(
      exception: controller.state.error?.localize(context),
      direction: Axis.vertical,
      retryController: controller.retryController,
    ).padL();
  }

  Widget _overlayChildBuilder(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: LdTheme.of(context).palette.neutral.shades[8].withAlpha(200),
          ),
        ),
        ModalBarrier(onDismiss: () {
          if (_submitController.state.type == LdSubmitStateType.error) {
            if (_submitController.canRetry) {
              _submitController.reset();
            }
          }
          if (_submitController.state.type == LdSubmitStateType.loading) {
            if (_submitController.canCancel) {
              _submitController.cancel();
            }
          }
        }),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: LdTheme.of(context).surface,
              border: Border.all(
                color: LdTheme.of(context).border,
                width: 1,
              ),
              borderRadius: LdTheme.of(context).radius(LdSize.l),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 300,
                minHeight: 200,
                maxWidth: 400,
                maxHeight: 400,
              ),
              child: Center(
                child: switch (_submitController.state.type) {
                  (LdSubmitStateType.loading) => buildLoadingDialog(context, _submitController),
                  (LdSubmitStateType.error) => buildErrorDialog(context, _submitController),
                  (_) => Container(),
                },
              ),
            ),
          ).padL(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _submitController.state;

    final child = LdAutoSpace(
      children: [
        if (widget.resultBuilder != null && state.type == LdSubmitStateType.result)
          widget.resultBuilder!(
            context,
            state.result as T,
            _submitController,
          ),
        if (widget.submitButtonBuilder != null)
          widget.submitButtonBuilder!(context, _submitController)
        else if (widget.showSubmitButton == true || _submitController.config.autoTrigger == false)
          LdSubmitButton(
            controller: _submitController,
          ),
      ],
    );

    if (widget.targetRoot) {
      return OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: _overlayChildBuilder,
        overlayLocation: OverlayChildLocation.rootOverlay,
      );
    }
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _overlayChildBuilder,
      child: child,
    );
  }
}
