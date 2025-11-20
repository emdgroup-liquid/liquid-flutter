import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/detail_page.dart';

class LdMonkeyScrollableDetailView<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget Function(BuildContext context, LdPaginatorItem<T> item) buildDetail;
  const LdMonkeyScrollableDetailView({super.key, required this.buildDetail});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyStreamSelection<T, IdType>(
      builder: (context, items) => LdScaffoldBody(
        children: [
          ...items.map((e) => KeyedSubtree(key: ValueKey(e.value?.id), child: buildDetail(context, e))),
        ],
      ),
    );
  }
}
