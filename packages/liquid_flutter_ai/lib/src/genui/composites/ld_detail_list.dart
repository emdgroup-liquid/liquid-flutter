import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

final ldDetailList = ldCatalogItem(
  name: 'LdDetailList',
  schema: ldDetailListSchema,
  parse: LdDetailListData.fromJson,
  builder: (ctx, data) => LdDetailList(catalogContext: ctx, data: data),
);

class LdDetailList extends StatelessWidget {
  const LdDetailList({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
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
                  onPressed: () => _openDetail(item),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(LdDetailListItem item) async {
    final buildContext = catalogContext.buildContext;
    await LdModalRoute<void>(
      context: buildContext,
      pageBuilder: (modalContext) =>
          _LdDetailPage(catalogContext: catalogContext, item: item),
    ).show(buildContext);
  }
}

class _LdDetailPage extends StatelessWidget {
  const _LdDetailPage({required this.catalogContext, required this.item});

  final CatalogItemContext catalogContext;
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
                    await dispatchLdAction(catalogContext, action.action);
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
