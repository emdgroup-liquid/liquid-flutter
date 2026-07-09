import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/ld_with_implicit_delay.dart';
import 'package:liquid_flutter/src/submit/builders/submit_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _submitController = context.read<LdSubmitController<T, Arg>>();
    _subscription?.cancel();
    _subscription = _submitController.stateStream.listen(_onStateChanged);
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
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _overlayController.hide();
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget buildDialog(
    BuildContext context,
    LdSubmitController<T, Arg> controller,
  ) {
    return widget.loadingBuilder != null
        ? widget.loadingBuilder!(context, controller)
        : LdAutoSpace(
            animate: true,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: switch (controller.state.type) {
                  LdSubmitStateType.loading => LdIndicator.loading(customSize: 24, key: const Key('loading-indicator')),
                  LdSubmitStateType.result => LdIndicator.success(customSize: 24, key: const Key('success-indicator')),
                  LdSubmitStateType.error => LdIndicator.error(customSize: 24, key: const Key('error-indicator')),
                  _ => SizedBox.shrink(),
                },
              ),
              if (controller.state.type != LdSubmitStateType.error)
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
              if (controller.state.type == LdSubmitStateType.error)
                if (widget.errorBuilder != null)
                  widget.errorBuilder!(context, controller.state.error!, controller)
                else
                  LdExceptionView(
                    exception: controller.state.error!.localize(context),
                    direction: Axis.vertical,
                    retryController: controller.retryController,
                    showIndicator: false,
                  ).padL().animate().scaleXY(),
              if (controller.state.type == LdSubmitStateType.result)
                if (controller.canCancel)
                  LdButton.ghost(
                    onPressed: controller.cancel,
                    child: Text(LiquidLocalizations.of(context).cancel),
                  ),
            ],
          ).padL();
  }

  void _handleDismiss() {
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
  }

  Widget _overlayChildBuilder(BuildContext context) {
    final theme = LdTheme.of(context);
    return LdWithImplicitDelay(
        delay: const Duration(milliseconds: 600),
        initialCondition: false,
        condition: _submitController.state.type == LdSubmitStateType.result,
        builder: (context, condition) {
          return AnimatedOpacity(
            opacity: condition ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                ModalBarrier(
                  onDismiss: _handleDismiss,
                  color: theme.palette.neutral.shades[8].withAlpha(150),
                ),
                Padding(
                  padding: MediaQuery.of(context).padding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 300,
                        minHeight: 200,
                        maxWidth: 400,
                        maxHeight: 400,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: LdTheme.of(context).background,
                          border: Border.all(
                            color: LdTheme.of(context).stroke,
                            width: theme.borderWidth,
                          ),
                          borderRadius: LdTheme.of(context).radius(LdSize.l),
                        ),
                        child: Column(
                          children: [
                            if (_submitController.canCancel || _submitController.canRetry)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  LdButton.vague(
                                    onPressed: _handleDismiss,
                                    child: Icon(LucideIcons.x),
                                  ),
                                ],
                              ),
                            Expanded(
                              child: Center(
                                child: switch (_submitController.state.type) {
                                  (LdSubmitStateType.loading || LdSubmitStateType.result || LdSubmitStateType.error) =>
                                    buildDialog(context, _submitController),
                                  (_) => Container(),
                                },
                              ),
                            ),
                          ],
                        ).padS(),
                      ).padL().animate().scaleXY(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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
          LdSubmitButton<T, Arg>(),
      ],
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _overlayChildBuilder,
      overlayLocation: switch (widget.targetRoot) {
        true => OverlayChildLocation.rootOverlay,
        false => OverlayChildLocation.nearestOverlay,
      },
      child: child,
    );
  }
}
