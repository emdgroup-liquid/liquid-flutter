import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final ldCardGallery = ldCatalogItem(
  name: 'LdCardGallery',
  schema: ldCardGallerySchema,
  parse: LdCardGalleryData.fromJson,
  builder: (ctx, data) => LdCardGallery(catalogContext: ctx, data: data),
);

class LdCardGallery extends StatelessWidget {
  const LdCardGallery({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdCardGalleryData data;

  @override
  Widget build(BuildContext context) {
    if (data.selected == null) {
      return _LdCardGalleryBody(
        catalogContext: catalogContext,
        data: data,
        selected: null,
      );
    }

    return bindWritableString(
      catalogContext,
      ref: data.selected,
      fallbackPath: '${catalogContext.id}.selected',
      builder: (context, selected) => _LdCardGalleryBody(
        catalogContext: catalogContext,
        data: data,
        selected: selected,
      ),
    );
  }
}

class _LdCardGalleryBody extends StatelessWidget {
  const _LdCardGalleryBody({
    required this.catalogContext,
    required this.data,
    required this.selected,
  });

  final CatalogItemContext catalogContext;
  final LdCardGalleryData data;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final title = data.title;

    return LdAutoSpace(
      children: [
        if (title != null && title.isNotEmpty) LdText.h(title),
        LdHorizontalScroll(
          spacing: LdSize.m,
          children: [
            for (final card in data.cards)
              _LdGalleryCard(
                card: card,
                selected: selected == card.id,
                onTap: () => _onCardTap(card),
              ),
          ],
        ),
      ],
    );
  }

  void _onCardTap(LdGalleryCard card) {
    if (data.selected != null) {
      catalogContext.dataContext.update(
        DataPath(
          writableStringPath(data.selected, '${catalogContext.id}.selected'),
        ),
        card.id,
      );
    }
    dispatchLdAction(
      catalogContext,
      card.action,
      extraContext: {'id': card.id},
    );
  }
}

class _LdGalleryCard extends StatelessWidget {
  const _LdGalleryCard({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final LdGalleryCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final subtitle = card.subtitle;
    final imageUrl = card.imageUrl;
    final markdown = card.markdown;
    final tags = card.tags;

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
              Row(
                children: [
                  Expanded(child: LdText.h(card.title)),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in tags)
                          LdTag(size: LdSize.s, child: Text(tag)),
                      ],
                    ),
                ],
              ),
              ldSpacerS,

              if (subtitle != null && subtitle.isNotEmpty)
                LdMute(child: LdText.caption(subtitle, size: LdSize.s)),
              if (markdown != null && markdown.isNotEmpty)
                LdMarkdown(data: markdown, shrinkWrap: true),
            ],
          ),
        ),
      ),
    );
  }
}
