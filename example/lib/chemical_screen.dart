import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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
  _Potion("Madame Glossy's Silver Polish", "A magical cleaning solution.")
];

class ChemicalScreen extends StatefulWidget {
  const ChemicalScreen({super.key});

  @override
  State<ChemicalScreen> createState() => _ChemicalScreenState();
}

class _ChemicalScreenState extends State<ChemicalScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      LdContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LdAutoSpace(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LdBreadcrumb.fromStrings(
              const ["Home", "Chemicals", "Polyjuice potion"],
            ),
            const _Quantity(),
            const _ProductKeyInfos(),
            ldSpacerL,
            LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LdDivider(),
                  const LdInput(
                    label: "Notes",
                    hint: "Add a note....",
                    maxLines: 3,
                  ),
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
            LdTextHs("Other potions"),
            ldSpacerM,
            const _OtherPotions(),
            ldSpacerL,
            LdTextHs("Stock"),
            const _Accordion(),
          ]),
        ]),
      ),
    ]);
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
                  const LdTextHl(
                    "Polyjuice potion",
                  ),
                  const LdTextL(
                    "Made with real human hair",
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
                        modal: LdModal(
                          headerPadding:
                              LdTheme.of(context).pad(size: LdSize.m),
                          contentPadding: EdgeInsets.zero,
                          modalContent: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
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
                                  })
                            ],
                          ),
                          title: const Text("Deduct"),
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
              ),
            )
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
              child: LdTextPs("Accordion content $n"),
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
            const Flexible(
              child: LdTextL(
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
          return [LdTextPs(potion.name), LdTextPs(potion.description)];
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
            LdTextH("5-4"),
            LdMute(
              child: LdTextL(
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
                child: LdTextL(
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
              child: LdTextL(
                "Brewing pressure",
              ),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdTextH(
              "Very",
            ),
            LdMute(
              child: LdTextL(
                "Magic",
              ),
            )
          ],
        ),
      ]),
    );
  }
}
