import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdListEmpty extends StatelessWidget {
  final Function? onRefresh;
  final String? text;

  const LdListEmpty({Key? key, this.onRefresh, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const LdAvatar(child: Icon(Icons.search_off)),
        ldSpacerM,
        LdTextP(text ?? LiquidLocalizations.of(context).noItemsFound),
        ldSpacerM,
        if (onRefresh != null)
          LdButton(
            child: Text(LiquidLocalizations.of(context).refresh),
            mode: LdButtonMode.outline,
            onPressed: () => onRefresh!(),
          ),
      ]),
    );
  }
}
