import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

typedef LdMonkeyRouteDefinitionsChildBuilder<T extends Identifiable<IdType>, IdType> = Widget
    Function(
  BuildContext context,
  LdMonkeyResolvedRouteDefinitions<T, IdType> resolved,
);

/// Resolves [filtersBuilder] and [sortOptionsBuilder] before building [child].
class LdMonkeyRouteDefinitionsResolver<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyRouteDefinitionsResolver({
    super.key,
    required this.filtersBuilder,
    required this.sortOptionsBuilder,
    required this.child,
    this.routeDefinitionsLoadingText,
  });

  final LdMonkeyFiltersBuilder<T, IdType> filtersBuilder;
  final LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder;
  final LdMonkeyRouteDefinitionsLoadingTextBuilder? routeDefinitionsLoadingText;
  final LdMonkeyRouteDefinitionsChildBuilder<T, IdType> child;

  @override
  State<LdMonkeyRouteDefinitionsResolver<T, IdType>> createState() =>
      _LdMonkeyRouteDefinitionsResolverState<T, IdType>();
}

class _LdMonkeyRouteDefinitionsResolverState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyRouteDefinitionsResolver<T, IdType>> {
  LdMonkeyResolvedRouteDefinitions<T, IdType>? _lastResolved;

  String _effectiveLoadingText(BuildContext context) {
    return widget.routeDefinitionsLoadingText?.call(context) ??
        LiquidLocalizations.of(context).loadingRouteDefinitions;
  }

  void _rememberResolved(LdMonkeyResolvedRouteDefinitions<T, IdType> resolved) {
    if (_lastResolved == resolved) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _lastResolved != resolved) {
        setState(() => _lastResolved = resolved);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadingText = _effectiveLoadingText(context);

    return LdSubmit<LdMonkeyResolvedRouteDefinitions<T, IdType>, void>(
      config: LdSubmitConfig<LdMonkeyResolvedRouteDefinitions<T, IdType>, void>(
        autoTrigger: true,
        allowResubmit: true,
        loadingText: loadingText,
        action: (_) => resolveMonkeyRouteDefinitions<T, IdType>(
          context: context,
          filtersBuilder: widget.filtersBuilder,
          sortOptionsBuilder: widget.sortOptionsBuilder,
        ),
      ),
      child: _LdMonkeyRouteDefinitionsSubmitBuilder<T, IdType>(
        loadingText: loadingText,
        lastResolved: _lastResolved,
        onRememberResolved: _rememberResolved,
        childBuilder: widget.child,
      ),
    );
  }
}

class _LdMonkeyRouteDefinitionsSubmitBuilder<T extends Identifiable<IdType>, IdType>
    extends StatelessWidget {
  const _LdMonkeyRouteDefinitionsSubmitBuilder({
    required this.loadingText,
    required this.lastResolved,
    required this.onRememberResolved,
    required this.childBuilder,
  });

  final String loadingText;
  final LdMonkeyResolvedRouteDefinitions<T, IdType>? lastResolved;
  final ValueChanged<LdMonkeyResolvedRouteDefinitions<T, IdType>> onRememberResolved;
  final LdMonkeyRouteDefinitionsChildBuilder<T, IdType> childBuilder;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LdSubmitController<LdMonkeyResolvedRouteDefinitions<T, IdType>, void>>();
    final state = controller.state;

    return switch (state.type) {
      LdSubmitStateType.error when lastResolved == null => Center(
          child: LdExceptionView(
            exception: state.error!.localize(context),
            direction: Axis.vertical,
            retryController: controller.retryController,
          ),
        ),
      LdSubmitStateType.error when lastResolved != null => _buildShellWithOptionalOverlay(
          context,
          lastResolved!,
          showOverlay: false,
          error: state.error,
          controller: controller,
        ),
      LdSubmitStateType.loading when lastResolved == null => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LdLoader(size: 32),
              ldSpacerS,
              LdText.p(loadingText),
            ],
          ),
        ),
      LdSubmitStateType.loading when lastResolved != null => _buildShellWithOptionalOverlay(
          context,
          lastResolved!,
          showOverlay: true,
        ),
      LdSubmitStateType.result => () {
          final resolved = state.result as LdMonkeyResolvedRouteDefinitions<T, IdType>;
          onRememberResolved(resolved);
          return _buildShellWithOptionalOverlay(
            context,
            resolved,
            showOverlay: false,
          );
        }(),
      LdSubmitStateType.idle => const SizedBox.shrink(),
      _ => lastResolved != null
          ? _buildShellWithOptionalOverlay(context, lastResolved!, showOverlay: false)
          : const SizedBox.shrink(),
    };
  }

  Widget _buildShellWithOptionalOverlay(
    BuildContext context,
    LdMonkeyResolvedRouteDefinitions<T, IdType> resolved, {
    required bool showOverlay,
    LdException? error,
    LdSubmitController<LdMonkeyResolvedRouteDefinitions<T, IdType>, void>? controller,
  }) {
    final shell = childBuilder(context, resolved);

    if (error != null && controller != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          shell,
          ColoredBox(
            color: LdTheme.of(context).background.withValues(alpha: 0.7),
            child: Center(
              child: LdExceptionView(
                exception: error.localize(context),
                direction: Axis.vertical,
                retryController: controller.retryController,
              ),
            ),
          ),
        ],
      );
    }

    if (!showOverlay) {
      return shell;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        shell,
        ColoredBox(
          color: LdTheme.of(context).background.withValues(alpha: 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LdLoader(size: 32),
                ldSpacerS,
                LdText.p(loadingText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
