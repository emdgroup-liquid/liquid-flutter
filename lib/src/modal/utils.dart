import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

Future<bool> confirmModal(
    {String? description,
    Widget? title,
    Widget? positive,
    Widget? negative,
    Widget? additionalContent,
    LdColor? confirmColor,
    LdColor? cancelColor,
    required BuildContext context,
    LdIndicatorType? indicatorType = LdIndicatorType.warning,
    bool useRootNavigator = false,
    bool allowDismiss = true}) async {
  final locale = LiquidLocalizations.of(context);

  final res = await LdModal(
    size: LdSize.s,
    title: title ?? Text(locale.confirm),
    modalContent: (context) => LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (indicatorType != null)
          LdIndicator(
            type: indicatorType,
            customSize: 24,
          ),
        if (description != null) LdTextP(description),
        if (additionalContent != null) additionalContent,
      ],
    ),
    actionBar: (context) => CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(false),
      },
      child: ResponsiveBuilder(builder: (context, constraints) {
        if (constraints.isMobile) {
          return Row(
            children: [
              Expanded(
                child: LdButtonGhost(
                  color: cancelColor,
                  child: negative ?? Text(locale.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              ldSpacerL,
              Expanded(
                child: LdButton(
                  autoFocus: true,
                  color: confirmColor,
                  child: positive ?? Text(locale.confirm),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: LdButtonGhost(
                  color: cancelColor,
                  child: negative ?? Text(locale.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              ldSpacerL,
              Flexible(
                child: LdButton(
                  color: confirmColor,
                  autoFocus: true,
                  child: positive ?? Text(locale.confirm),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          );
        }
      }),
    ),
  ).show(
    context,
    useRootNavigator: useRootNavigator,
  );

  return res == true;
}
