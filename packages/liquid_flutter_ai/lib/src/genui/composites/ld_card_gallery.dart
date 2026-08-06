import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final ldCardGallery = CatalogItem(
  name: 'LdCardGallery',
  dataSchema: ldCardGallerySchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String?;
    final cards = objectList(d['cards']);
    final selectedRef = d['selected'];
    final path = selectedRef == null
        ? null
        : bindingPath(selectedRef, '${ctx.id}.selected');

    if (selectedRef is String && path != null) {
      ctx.dataContext.update(DataPath(path), selectedRef);
    }

    if (cards.isEmpty) {
      final error = FormatException(
        'LdCardGallery "${ctx.id}" requires at least one card',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    Widget gallery(String? selected) {
      return LdAutoSpace(
        children: [
          if (title != null && title.isNotEmpty) LdText.h(title),
          LdHorizontalScroll(
            spacing: LdSize.m,
            children: [
              for (final card in cards)
                _GalleryCard(
                  card: card,
                  selected: selected == card['id'],
                  onTap: () {
                    final id = card['id'] as String?;
                    if (id != null && path != null) {
                      ctx.dataContext.update(DataPath(path), id);
                    }
                    final action = card['action'] as JsonMap?;
                    if (action != null) {
                      dispatchAction(ctx, action, extraContext: {'id': id});
                    }
                  },
                ),
            ],
          ),
        ],
      );
    }

    if (path == null) return gallery(null);

    return BoundString(
      dataContext: ctx.dataContext,
      value: {'path': path},
      builder: (context, selected) => gallery(selected),
    );
  },
);

class _GalleryCard extends StatelessWidget {
  final JsonMap card;
  final bool selected;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  List<String> get _tags {
    final raw = card['tags'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final title = card['title'] as String? ?? '';
    final subtitle = card['subtitle'] as String?;
    final imageUrl = card['imageUrl'] as String?;
    final markdown = card['markdown'] as String?;
    final tags = _tags;

    return SizedBox(
      width: 260,
      child: LdTouchableSurface(
        active: selected,
        onPressed: onTap,
        builder: (context, status, child) => Container(
          padding: theme.pad(),
          decoration: BoxDecoration(
            color: neutralGhostColor(theme, status).surface,
            border: Border.all(color: theme.border, width: 1),
            borderRadius: theme.radius(LdSize.m),
          ),
          child: LdAutoSpace(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: theme.radius(LdSize.s),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.surface,
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.imageOff,
                          color: theme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              LdText.h(title),
              if (tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in tags)
                      LdTag(
                        size: LdSize.s,
                        child: Text(tag),
                      ),
                  ],
                ),
              if (subtitle != null && subtitle.isNotEmpty)
                LdMute(child: LdText.p(subtitle, size: LdSize.s)),
              if (markdown != null && markdown.isNotEmpty)
                LdMarkdown(data: markdown, shrinkWrap: true),
            ],
          ),
        ),
      ),
    );
  }
}
