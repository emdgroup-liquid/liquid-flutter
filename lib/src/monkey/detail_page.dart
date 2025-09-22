import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

/// The page rendered by [LdMonkey] to show the detail of the selected
/// items
class LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final PreferredSizeWidget Function(BuildContext context, Set<IdType> selection)? appBarBuilder;

  const LdMonkeyDetailPage({
    this.appBarBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final route = LdMonkey.of<T, IdType>(context);

    final isSideBySide = LdMonkeyContext.of<T, IdType>(context).isSideBySide;

    return StreamBuilder(
        stream: route.stateStream,
        initialData: route.state,
        builder: (context, asyncSnapshot) {
          final state = asyncSnapshot.data!;
          final selection = state.selectedItems;

          return Provider.value(
            value: LdMonkeySelection<T, IdType>(items: selection),
            child: StreamBuilder(
                key: ValueKey(selection.join(',')),
                stream: route.repository.watchItems(selection),
                builder: (context, snapshot) {
                  final primaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType>(
                    context,
                    LdMonkeyActionLocation.detailAppBar,
                  );

                  final secondaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType>(
                    context,
                    LdMonkeyActionLocation.detailSecondary,
                  );

                  return LdScaffold(
                    appBar: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Provider.value(
                          value: LdMonkeyActionLocation.detailAppBar,
                          child: appBarBuilder?.call(context, selection) ??
                              LdAppBar(
                                title: Text(
                                  selection.length > 1
                                      ? route.repository.pluralItemTitle
                                      : route.repository.singularItemTitle,
                                ),
                                actions: primaryActions.actions,
                                overflowMenuProviders: primaryActions.menuProviders,
                              ),
                        ),
                        if (isSideBySide && secondaryActions.hasActions) ...[
                          Provider.value(
                            value: LdMonkeyActionLocation.detailSecondary,
                            child: LdAppBar(
                              implyLeading: false,
                              disableSafeArea: true,
                              actions: secondaryActions.actions,
                              overflowMenuProviders: secondaryActions.menuProviders,
                            ),
                          ),
                        ],
                      ],
                    ),
                    bottomNavigationBar: !isSideBySide && secondaryActions.hasActions
                        ? Provider.value(
                            value: LdMonkeyActionLocation.detailSecondary,
                            child: LdAppBar(
                              implyLeading: false,
                              actions: secondaryActions.actions,
                              overflowMenuProviders: secondaryActions.menuProviders,
                            ),
                          )
                        : null,
                    body: SafeArea(
                      child: LdMonkeyDetailPageContent(
                        route: route,
                        selection: selection,
                      ),
                    ),
                  );
                }),
          );
        });
  }
}

class LdMonkeyDetailPageContent<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdMonkey<T, IdType> route;
  final Set<IdType> selection;
  const LdMonkeyDetailPageContent({super.key, required this.route, required this.selection});

  @override
  Widget build(BuildContext context) {
    return LdContainer(
      child: Stack(
        fit: StackFit.expand,
        children: selection
            .toList()
            .reversed
            .mapIndexed((index, id) {
              return Align(
                key: ValueKey(id),
                alignment: Alignment.center,
                child: LdSpring(
                  position: index.toDouble(),
                  initialPosition: 0,
                  builder: (context, state, child) {
                    final position = max(0, state.position);
                    return Transform.scale(
                        scale: 1 - (position * 0.02),
                        child: Transform.rotate(
                          angle: index % 3 * 0.02,
                          child: Transform.translate(
                            offset: Offset(0, position * 5),
                            child: child,
                          ),
                        ));
                  },
                  child: StreamBuilder<LdPaginatorItem<T>?>(
                    initialData: route.repository.getItemById(id),
                    stream: route.repository.watchItem(id),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return LdSubmit<T, IdType>(
                          config: LdSubmitConfig(
                            autoTrigger: true,
                            action: (arg) async {
                              final res = await route.repository.getById(id);
                              return res;
                            },
                          ),
                          builder: LdSubmitCenteredBuilder<T, IdType>(
                            resultBuilder: (context, result, _) => route.buildDetail(
                              context,
                              LdPaginatorItem(
                                value: result,
                                state: LdPaginatorItemState.loaded,
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.data?.state == LdPaginatorItemState.deleting) {
                        return LdReveal.quick(
                          initialRevealed: true,
                          revealed: false,
                          child: route.buildDetail(
                            context,
                            LdPaginatorItem(
                              value: snapshot.data!.value,
                              state: LdPaginatorItemState.deleting,
                            ),
                          ),
                        );
                      }

                      return route.buildDetail(context, snapshot.data!);
                    },
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }
}
