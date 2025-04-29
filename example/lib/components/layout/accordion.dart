import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import '../component_well/component_well.dart';

class AccordionDemo extends StatefulWidget {
  const AccordionDemo({super.key});

  @override
  State<AccordionDemo> createState() => _AccordionDemoState();
}

class _AccordionDemoState extends State<AccordionDemo> {
  bool _onSurface = false;
  bool _allowMultiple = false;
  bool _elevate = false;

  _toggleElevate(bool newState) {
    setState(() {
      _elevate = newState;
    });
  }

  _toggleOnSurface(bool newState) {
    setState(() {
      _onSurface = newState;
    });
  }

  _toggleAllowMultiple(bool newState) {
    setState(() {
      _allowMultiple = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accordion = LdAccordion(
      headerBuilder: (context, n) => Text("Accordion $n"),
      elevateActive: _elevate,
      allowMultipleOpen: _allowMultiple,
      childBuilder: (context, n) => LdAutoSpace(
        children: [
          LdTextH("Content $n"),
          const FlutterLogo(),
        ],
      ),
      itemCount: 3,
    );

    return ComponentPage(
        title: "LdAccordion",
        demo: LdAutoSpace(
          children: [
            ComponentWell(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  const LdDivider(),
                  LdAccordion.fromList(
                    [
                      LdAccordionItem(
                        child: const Text("This is some content in an accordion"),
                        header: const Text("Header"),
                      ),
                    ],
                  ),
                  const LdDivider(),
                ],
              ),
            )),
            ComponentWell(
              onSurface: _onSurface,
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LdTextH(
                    "Standard",
                  ),
                  if (!_elevate) ...[
                    LdCard(padding: EdgeInsets.zero, child: accordion),
                    const LdTextL("Accordion is placed inside an LdCard with no padding")
                  ] else
                    accordion
                ],
              ),
            ),
            LdToggle(label: "Allow multiple open", checked: _allowMultiple, onChanged: _toggleAllowMultiple),
            LdToggle(label: "Elevate", checked: _elevate, onChanged: _toggleElevate),
            LdToggle(label: "On Surface background", checked: _onSurface, onChanged: _toggleOnSurface)
          ],
        ));
  }
}
