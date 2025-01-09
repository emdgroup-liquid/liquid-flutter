import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
  const ChemicalScreen({Key? key}) : super(key: key);

  @override
  State<ChemicalScreen> createState() => _ChemicalScreenState();
}

class _ChemicalScreenState extends State<ChemicalScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: LdTheme.of(context).pad(size: LdSize.l) * 2,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdBreadcrumb.fromStrings(
                    const ["Home", "Chemicals", "Polyjuice potion"],
                  ),
                  const _Quantity(),
                  const _ProductKeyInfos(),
                  ldSpacerL,
                  LdAutoSpace(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            LdButton(
                                child: const Text("Add to cart"),
                                mode: LdButtonMode.outline,
                                leading: const Icon(Icons.shopping_bag),
                                onPressed: () {
                                  LdNotificationsController.of(context)
                                      .addNotification(LdNotification(
                                    type: LdNotificationType.info,
                                    message: "Added to cart",
                                  ));
                                }),
                            LdButton(
                                child: const Text(
                                  "Acces certificate",
                                ),
                                mode: LdButtonMode.outline,
                                leading: const Icon(Icons.download),
                                onPressed: () {
                                  LdNotificationsController.of(context)
                                      .addNotification(LdNotification(
                                    type: LdNotificationType.error,
                                    message: "Downloading certificate failed",
                                  ));
                                }),
                          ],
                        ),
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
                  const _OtherPotions(),
                  ldSpacerL,
                  const _Accordion(),
                ]),
          ]),
        ]);
  }
}

class _Quantity extends StatefulWidget {
  const _Quantity({
    Key? key,
  }) : super(key: key);

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
                  LdModalBuilder(
                    builder: (context, onPress) {
                      return LdButtonOutline(
                        size: LdSize.s,
                        leading: const Icon(Icons.arrow_downward),
                        child: const Text("Deduct"),
                        onPressed: onPress,
                      );
                    },
                    modal: LdModal(
                      modalContent: (context) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LdButton(
                                child: const Text("Deduct 0.1l"),
                                onPressed: () {
                                  _deduct(0.1);
                                  Navigator.of(context).pop();
                                }),
                            ldSpacerM,
                            LdButton(
                                child: const Text("Deduct 0.2l"),
                                onPressed: () {
                                  _deduct(0.2);
                                  Navigator.of(context).pop();
                                }),
                            ldSpacerM,
                            LdButton(
                                child: const Text("Deduct 0.5l"),
                                onPressed: () {
                                  _deduct(0.5);
                                  Navigator.of(context).pop();
                                }),
                            ldSpacerM,
                            ldSpacerM,
                            LdButton(
                                child: const Text("Add 0.1l"),
                                onPressed: () {
                                  _deduct(-0.1);
                                  Navigator.of(context).pop();
                                }),
                            ldSpacerM,
                            LdButton(
                                child: const Text("Refill entirely"),
                                onPressed: () {
                                  _deduct(-1);
                                  Navigator.of(context).pop();
                                })
                          ],
                        ),
                      ),
                      title: const Text("Deduct"),
                    ),
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
  const _Accordion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LdCard(
      padding: EdgeInsets.zero,
      child: LdAccordion(
          itemCount: 5,
          initialOpenIndex: const {1},
          childBuilder: ((context, n) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Text("Accordion content $n"),
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
  const _OtherPotions({
    Key? key,
  }) : super(key: key);

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
                child: const Text("Shop for more"),
                mode: LdButtonMode.outline,
                onPressed: () {
                  LdNotificationsController.of(context).addNotification(
                    LdNotification(
                      type: LdNotificationType.info,
                      message: "Redirecting to shop",
                    ),
                  );
                }),
          ],
        ),
        columns: [LdCol(title: "Name"), LdCol(title: "Description")],
        rows: potions,
        rowCount: potions.length,
        buildRow: (potion) {
          return [Text(potion.name), Text(potion.description)];
        },
      ),
    );
  }
}

class _ProductKeyInfos extends StatelessWidget {
  const _ProductKeyInfos({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LdCard(
      child: Wrap(spacing: 32, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdTextHs("5-4"),
            LdTextL(
              "pH",
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdTextHs("321°C"),
            LdTextL(
              "Boiling point",
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdTextHs("3 Bar"),
            LdTextL(
              "Brewing pressure",
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdTextHs(
              "Very",
            ),
            LdTextL(
              "Magic",
            )
          ],
        ),
      ]),
    );
  }
}
