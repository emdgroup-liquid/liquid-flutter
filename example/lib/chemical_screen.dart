import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Potion {
  String name;
  String description;
  _Potion(this.name, this.description);
}

var potions = [
  _Potion("Alihotsy Draught",
      "A potion from the Alihotsy plant; causes hysterical laughter."),
  _Potion("Dreamless Sleep Potion",
      "A potion that places the taker in a sleep that is dreamless."),
  _Potion("Madame Glossy's Silver Polish", "A magical cleaning solution."),
  _Potion("Pepperup Potion",
      "Cures the common cold and produces steam coming out of the drinker's ears."),
  _Potion("Polyjuice Potion",
      "Allows the drinker to assume the form of someone else."),
  _Potion("Amortentia", "The most powerful love potion in existence."),
  _Potion("Felix Felicis",
      "Also called Liquid Luck, makes the drinker lucky for a period of time."),
  _Potion("Skele-Gro", "Potion for regrowing bones."),
  _Potion("Wolfsbane Potion", "Alleviates the symptoms of lycanthropy."),
  _Potion("Veritaserum", "A powerful truth serum."),
  _Potion("Draught of Peace", "Relieves anxiety and soothes agitation."),
  _Potion("Confusing Concoction", "Causes confusion in the drinker."),
  _Potion("Invisibility Potion",
      "Renders the drinker invisible for a short period of time."),
];

class ChemicalScreen extends StatefulWidget {
  const ChemicalScreen({super.key});

  @override
  State<ChemicalScreen> createState() => _ChemicalScreenState();
}

class _ChemicalScreenState extends State<ChemicalScreen> {
  final searchConfig = LdSearchConfig(
      onSearch: (query) {},
      getSuggestions: (query) =>
          Future.value(potions.where((p) => p.name.contains(query)).toList()),
      buildSuggestion: (context, suggestion) {
        final potion = suggestion as _Potion;
        return LdListItem(
            title: Text(potion.name),
            onPressed: () {
              LdSearchAcceptSuggestion(suggestion: potion.name)
                  .dispatch(context);
            });
      });

  @override
  void dispose() {
    super.dispose();
    searchConfig.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      debugName: "Chemical screen",
      appBarScrollBehavior: LdAppBarScrollBehavior.mobileOnly,
      secondaryAppBar: LdAppBar(
        debugName: "Secondary app bar",
        actions: [
          LdButton(
            leading: const Icon(LucideIcons.shoppingBag),
            onPressed: () {
              LdNotificationsController.of(context).addNotification(
                LdNotification(
                  type: LdNotificationType.success,
                  message: "Added to cart",
                ),
              );
            },
            child: const Text("Add to cart"),
          ),
          LdButton(
            leading: const Icon(LucideIcons.download),
            onPressed: () {
              LdNotificationsController.of(context).addNotification(
                LdNotification(
                    type: LdNotificationType.success,
                    message: "Downloading certificate"),
              );
            },
            child: const Text("Download certificate"),
          ),
        ],
        searchConfig: searchConfig,
      ),
      appBar: LdAppBar(
        debugName: "Primary app bar ",
        title: const Text("Chemical"),
      ),
      body: LdScaffoldBody(
        children: [
          LdBreadcrumb.fromStrings(
            const ["Chemicals", "Polyjuice potion"],
          ),
          const _Quantity(),
          const _ProductKeyInfos(),
          ldSpacerL,
          LdAutoSpace(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const LdDivider(),
            LdButton(
                child: const Text("Save"),
                onPressed: () {
                  LdNotificationsController.of(context)
                      .addNotification(LdNotification(
                    type: LdNotificationType.success,
                    message: "Saved",
                  ));
                })
          ]),
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
    _quantityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _quantityController.animateTo(0.5, curve: Curves.easeInOut);
  }

  void _deduct(amount) {
    _quantityController.animateTo(
        (_quantityController.value - amount).clamp(0, 1),
        duration: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: AnimatedBuilder(
                  animation: _quantityController,
                  builder: (context, child) {
                    return LdOrb(
                      _quantityController.value,
                      size: 100,
                      paintBackground: true,
                    );
                  }),
            ),
            ldSpacerM,
            Expanded(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdText.hl(
                    "Polyjuice potion",
                  ),
                  LdText.l(
                    "Made with real human hair",
                  ),
                ],
              ),
            )
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LdModalBuilder(
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
                  appBar: LdAppBar(
                    title: const Text("Deduct"),
                  ),
                  body: LdScaffoldBody(
                    children: [
                      LdListItem(
                          title: const Text("Deduct 0.1l"),
                          leading: const Icon(LucideIcons.arrowDown),
                          onPressed: () {
                            _deduct(0.1);
                            Navigator.of(context).pop();
                          }),
                      LdListItem(
                          title: const Text("Deduct 0.2l"),
                          leading: const Icon(LucideIcons.arrowDown),
                          onPressed: () {
                            _deduct(0.2);
                            Navigator.of(context).pop();
                          }),
                      LdListItem(
                          title: const Text("Deduct 0.5l"),
                          leading: const Icon(LucideIcons.arrowDown),
                          onPressed: () {
                            _deduct(0.5);
                            Navigator.of(context).pop();
                          }),
                      LdListItem(
                          title: const Text("Add 0.1l"),
                          leading: const Icon(LucideIcons.arrowUp),
                          onPressed: () {
                            _deduct(-0.1);
                            Navigator.of(context).pop();
                          }),
                      LdDivider(),
                      LdListItem(
                          title: const Text("Refill entirely"),
                          leading: const Icon(LucideIcons.arrowUp),
                          onPressed: () {
                            _deduct(-1);
                            Navigator.of(context).pop();
                          }),
                    ],
                  ),
                ),
              ),
            ),
            LdButton(
                mode: LdButtonMode.vague,
                leading: const Icon(LucideIcons.shoppingBag),
                onPressed: () {
                  LdNotificationsController.of(context)
                      .addNotification(LdNotification(
                    type: LdNotificationType.info,
                    message: "Added to cart",
                  ));
                },
                child: const Text("Add to cart")),
            LdButton(
                mode: LdButtonMode.vague,
                leading: const Icon(LucideIcons.download),
                onPressed: () {
                  LdNotificationsController.of(context)
                      .addNotification(LdNotification(
                    type: LdNotificationType.error,
                    message: "Downloading certificate failed",
                  ));
                },
                child: const Text(
                  "Acces certificate",
                )),
          ],
        ),
      ],
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
            return Container(
              padding: const EdgeInsets.all(16),
              child: LdText.ps("Accordion content $n"),
            );
          }),
          headerBuilder: ((context, n) {
            return Text([
              "Stock",
              "Ingredients",
              "Preparation",
              "Usage",
              "Side effects"
            ][n]);
          })),
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
            Flexible(
              child: LdText.l(
                "Other potions",
              ),
            ),
            const Spacer(),
            LdButton(
                mode: LdButtonMode.outline,
                onPressed: () {
                  LdNotificationsController.of(context).addNotification(
                    LdNotification(
                      type: LdNotificationType.info,
                      message: "Redirecting to shop",
                    ),
                  );
                },
                child: const Text("Shop for more")),
          ],
        ),
        columns: [LdCol(title: "Name"), LdCol(title: "Description")],
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
        _brewingPressure = Random().nextDouble() * 10;
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
    return LdCard(
      padding: LdTheme.of(context).pad(size: LdSize.l),
      child: Wrap(spacing: 32, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdText.h("5-4"),
            LdMute(
              child: LdText.l(
                "pH",
              ),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdCounter(value: _boilingPoint),
            LdMute(
                child: LdText.l(
              "Boiling point",
            )),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdCounter(
              value: _brewingPressure,
              precision: 2,
            ),
            LdMute(
              child: LdText.l(
                "Brewing pressure",
              ),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdText.h(
              "Very",
            ),
            LdMute(
              child: LdText.l(
                "Magic",
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class ChemicalShell extends StatelessWidget {
  final Widget child;
  const ChemicalShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      resizeToAvoidBottomInset: false,
      debugName: "Chemical shell",
      appBarScrollBehavior: LdAppBarScrollBehavior.mobileOnly,
      appBarPlacement: LdScaffoldAppBarPlacement.mobileBottomDesktopTop,
      appBar: TabNavigation(
        activeRoute: GoRouterState.of(context).uri.path,
        tabs: [
          LdNavigationTab(
              label: "Chemical",
              icon: const Icon(LucideIcons.beaker),
              route: "/chemical"),
          LdNavigationTab(
              label: "Details",
              icon: const Icon(LucideIcons.book),
              route: "/chemical-detail"),
          LdNavigationTab(
              label: "Usage",
              icon: const Icon(LucideIcons.book),
              route: "/chemical-usage"),
          LdNavigationTab(
              label: "Exit", icon: const Icon(LucideIcons.x), route: "/"),
        ],
        onTabPressed: (route) {
          context.replace(route);
        },
      ),
      body: child,
    );
  }
}
