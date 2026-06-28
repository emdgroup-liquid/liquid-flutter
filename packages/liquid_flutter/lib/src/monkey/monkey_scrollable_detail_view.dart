import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyScrollableDetailView<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;
  const LdMonkeyScrollableDetailView({super.key, required this.buildDetail});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyStreamSelection<T, IdType>(
      buildItem: buildDetail,
      builder: (context, itemWidgets) => LdScaffoldBody(
        children: itemWidgets,
      ),
    );
  }
}
