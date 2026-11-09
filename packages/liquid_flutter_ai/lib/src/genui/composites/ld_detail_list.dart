import 'package:a2ui_core/a2ui_core.dart' show ComponentNode;
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

final ldDetailList = ldCatalogItem(
  name: 'LdDetailList',
  schema: ldDetailListSchema,
  parse: LdDetailListData.fromJson,
  builder: (node, _, data) => LdDetailList(node: node, data: data),
);

class LdDetailList extends StatelessWidget {
  const LdDetailList({super.key, required this.node, required this.data});

  final ComponentNode<ComponentImplementation> node;
  final LdDetailListData data;

  @override
  Widget build(BuildContext context) {
    final title = data.title;

    return LdAutoSpace(
      children: [
        if (title != null && title.isNotEmpty) LdText.h(title),
        LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final item in data.items)
                LdListItem.trailingForward(
                  title: Text(item.title),
                  subtitle: item.subtitle?.isNotEmpty == true
                      ? Text(item.subtitle!)
                      : null,
                  onPressed: () => _openDetail(context, item),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(BuildContext context, LdDetailListItem item) async {
    await LdModalRoute<void>(
      context: context,
      pageBuilder: (modalContext) => _LdDetailPage(node: node, item: item),
    ).show(context);
  }
}

class _LdDetailPage extends StatelessWidget {
  const _LdDetailPage({required this.node, required this.item});

  final ComponentNode<ComponentImplementation> node;
  final LdDetailListItem item;

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar.top(
        title: LdText.h(item.title),
        child: LdAppBar.bottom(
          actions: [
            for (final action in item.actions)
              LdFlexibleChild(
                child: LdButton(
                  width: double.infinity,
                  mode: compositeBtnMode(action.mode),
                  onPressed: () async {
                    await dispatchLdAction(node, action.action);
                  },
                  child: Text(action.label),
                ),
              ),
          ],
          child: LdScaffoldBody(children: [LdMarkdown(data: item.markdown)]),
        ),
      ),
    );
  }
}
