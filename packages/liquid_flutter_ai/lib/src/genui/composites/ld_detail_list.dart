import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

final ldDetailList = CatalogItem(
  name: 'LdDetailList',
  dataSchema: ldDetailListSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String?;
    final items = objectList(d['items']);
    if (items.isEmpty) {
      final error = FormatException(
        'LdDetailList "${ctx.id}" requires at least one item',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    return LdAutoSpace(
      children: [
        if (title != null && title.isNotEmpty) LdText.h(title),
        LdCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final item in items)
                LdListItem.trailingForward(
                  title: Text(item['title'] as String? ?? ''),
                  subtitle: (item['subtitle'] as String?)?.isNotEmpty == true
                      ? Text(item['subtitle'] as String)
                      : null,
                  onPressed: () => _openDetail(ctx, item),
                ),
            ],
          ),
        ),
      ],
    );
  },
);

Future<void> _openDetail(CatalogItemContext ctx, JsonMap item) async {
  final buildContext = ctx.buildContext;
  final markdown = item['markdown'] as String? ?? '';
  final title = item['title'] as String? ?? '';
  final actions = objectList(item['actions']);

  await LdModalRoute<void>(
    context: buildContext,
    pageBuilder: (modalContext) {
      return LdScaffold(
        body: LdAppBar.top(
          title: LdText.h(title),
          child: LdAppBar.bottom(
            actions: [
              for (final action in actions)
                LdFlexibleChild(
                  child: LdButton(
                    width: double.infinity,

                    mode: compositeBtnMode(action['mode'] as String?),
                    onPressed: () async {
                      await dispatchAction(ctx, action['action'] as JsonMap?);
                    },
                    child: Text(action['label'] as String? ?? 'Action'),
                  ),
                ),
            ],
            child: LdScaffoldBody(children: [LdMarkdown(data: markdown)]),
          ),
        ),
      );
    },
  ).show(buildContext);
}
