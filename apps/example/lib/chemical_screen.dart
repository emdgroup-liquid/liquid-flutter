import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ReflowHeader extends StatelessWidget {
  final Widget leading;
  final Widget child;
  const ReflowHeader({super.key, required this.leading, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, size) {
        final reflow = size.isDesktop || size.isTablet;

        if (reflow) {
          return Row(
            children: [
              leading,
              Expanded(child: child),
            ],
          ).spaceM();
        }
        return LdAutoSpace(children: [leading, child]);
      },
    );
  }
}

class _Potion {
  String name;
  String description;
  _Potion(this.name, this.description);
}

var potions = [
  _Potion("Alihotsy Draught", "A potion from the Alihotsy plant; causes hysterical laughter."),
  _Potion("Dreamless Sleep Potion", "A potion that places the taker in a sleep that is dreamless."),
  _Potion("Madame Glossy's Silver Polish", "A magical cleaning solution."),
  _Potion("Pepperup Potion", "Cures the common cold and produces steam coming out of the drinker's ears."),
  _Potion("Polyjuice Potion", "Allows the drinker to assume the form of someone else."),
  _Potion("Amortentia", "The most powerful love potion in existence."),
];

class ChemicalScreen extends StatefulWidget {
  const ChemicalScreen({super.key});

  @override
  State<ChemicalScreen> createState() => _ChemicalScreenState();
}

class _ChemicalScreenState extends State<ChemicalScreen> {
  final searchConfig = LdSearchConfig(
    onSearch: (query) {},
    getSuggestions: (query) => Future.value(potions.where((p) => p.name.contains(query)).toList()),
    buildSuggestion: (context, suggestion) {
      final potion = suggestion as _Potion;
      return LdListItem(
        title: Text(potion.name),
        onPressed: () {
          LdSearchAcceptSuggestion(suggestion: potion.name).dispatch(context);
        },
      );
    },
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      debugName: "Chemical screen",
      body: LdScaffoldBody(
        children: [
          LdBreadcrumb.fromStrings(const ["Chemicals", "Polyjuice potion"]),

          const _Quantity(),
          LdDivider(),
          const _ProductKeyInfos(),

          ldSpacerL,
          LdText.hs("Other potions"),
          ldSpacerM,
          const _OtherPotions(),
          ldSpacerL,
          LdText.hs("Stock"),
          const _Accordion(),
        ].autoSpace(context, animate: true),
      ),
    );
  }
}

class _Quantity extends StatefulWidget {
  const _Quantity();

  @override
  State<_Quantity> createState() => _QuantityState();
}

class _QuantityState extends State<_Quantity> with TickerProviderStateMixin {
  late AnimationController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _quantityController.animateTo(0.5, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdText.hl("Polyjuice potion"),
        LdMute(child: LdText.l("Made with real human hair")),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LdModalBuilder(
              useRootNavigator: true,
              builder: (context, onPress) {
                return LdButton(
                  leading: const Icon(LucideIcons.arrowDown),
                  onPressed: onPress,
                  child: const Text("Deduct"),
                );
              },
              modal: LdModalRoute(
                context: context,
                pageBuilder: (context) => LdScaffold(
                  body: LdAppBar(
                    title: const Text("Deduct"),
                    child: LdScaffoldBody(
                      shrinkWrap: true,
                      minimumPadding: EdgeInsets.zero,
                      children: [
                        AnimatedBuilder(
                          animation: _quantityController,
                          builder: (context, child) {
                            return LdSlider(
                              min: 0,
                              max: 1,
                              step: 0.01,
                              value: _quantityController.value,
                              onChanged: (value) {
                                _quantityController.value = value;
                              },
                            );
                          },
                        ).padL(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            LdButton.outline(
              leading: const Icon(LucideIcons.shoppingBag),
              onPressed: () {
                LdNotificationsController.of(
                  context,
                ).addNotification(LdNotification(type: LdNotificationType.info, message: "Added to cart"));
              },
              child: const Text("Add to cart"),
            ),
            LdButton.outline(
              leading: const Icon(LucideIcons.download),
              onPressed: () {
                LdNotificationsController.of(context).addNotification(
                  LdNotification(type: LdNotificationType.error, message: "Downloading certificate failed"),
                );
              },
              child: const Text("Acces certificate"),
            ),
          ],
        ),
      ],
    );

    return ReflowHeader(
      leading: AnimatedBuilder(
        animation: _quantityController,
        builder: (context, child) {
          return LdOrb(_quantityController.value, size: 100, paintBackground: true);
        },
      ),
      child: header,
    );
  }
}

class _Accordion extends StatelessWidget {
  const _Accordion();

  @override
  Widget build(BuildContext context) {
    return LdCard(
      padding: EdgeInsets.zero,
      child: LdAccordion(
        itemCount: 5,
        childBuilder: ((context, n) {
          return Container(padding: const EdgeInsets.all(16), child: LdText.ps("Accordion content $n"));
        }),
        headerBuilder: ((context, n) {
          return Text(["Stock", "Ingredients", "Preparation", "Usage", "Side effects"][n]);
        }),
      ),
    );
  }
}

class _OtherPotions extends StatelessWidget {
  const _OtherPotions();

  @override
  Widget build(BuildContext context) {
    return LdCard(
      padding: EdgeInsets.zero,
      child: LdTable<_Potion>(
        header: Row(
          children: [
            Flexible(child: LdText.l("Other potions")),
            const Spacer(),
            LdButton(
              mode: LdButtonMode.outline,
              onPressed: () {
                LdNotificationsController.of(
                  context,
                ).addNotification(LdNotification(type: LdNotificationType.info, message: "Redirecting to shop"));
              },
              child: const Text("Shop for more"),
            ),
          ],
        ),
        columns: [
          LdCol(title: "Name"),
          LdCol(title: "Description"),
        ],
        rows: potions,
        rowCount: potions.length,
        buildRow: (potion) {
          return [LdText.ps(potion.name), LdText.ps(potion.description)];
        },
      ),
    );
  }
}

class _ProductKeyInfos extends StatefulWidget {
  const _ProductKeyInfos();

  @override
  State<_ProductKeyInfos> createState() => _ProductKeyInfosState();
}

class _ProductKeyInfosState extends State<_ProductKeyInfos> {
  double _boilingPoint = 321;
  Timer? _timer;
  double _brewingPressure = 3;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _boilingPoint = Random().nextDouble() * 1000;
        _brewingPressure = Random().nextDouble() * 100;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdHorizontalScroll(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: LdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdText.h("5-4"),
                LdMute(child: LdText.caption("pH")),
              ],
            ),
          ),
        ),

        SizedBox(
          width: 150,
          child: LdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdCounter(value: _boilingPoint),
                LdMute(child: LdText.caption("Boiling point")),
              ],
            ),
          ),
        ),

        SizedBox(
          width: 150,
          child: LdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdCounter(value: _brewingPressure, precision: 2),
                LdMute(child: LdText.caption("Brewing pressure")),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChemicalShell extends StatelessWidget {
  final Widget child;
  const ChemicalShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      debugName: "Chemical shell",
      body: LdTabNavigation(
        scrollBehavior: LdAppBarScrollBehavior.mobileOnly,
        activeRoute: GoRouterState.of(context).uri.path,
        tabs: [
          LdNavigationTab(label: "Chemical", icon: const Icon(LucideIcons.beaker), route: "/chemical"),
          LdNavigationTab(label: "Details", icon: const Icon(LucideIcons.book), route: "/chemical-detail"),
          LdNavigationTab(label: "Usage", icon: const Icon(LucideIcons.book), route: "/chemical-usage"),
          LdNavigationTab(label: "Exit", icon: const Icon(LucideIcons.x), route: "/"),
        ],
        onTabPressed: (route) {
          context.replace(route);
        },
        child: child,
      ),
    );
  }
}
