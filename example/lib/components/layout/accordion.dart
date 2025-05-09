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
            LdTextP(
              "The LdAccordion component provides a way to organize content into collapsible sections. "
              "It's useful for presenting information in a compact format where users can expand sections they're interested in.",
            ),
            LdTextP(
              "You can create an accordion either by using the standard constructor with builders for headers and content, "
              "or by using the convenient LdAccordion.fromList constructor with predefined LdAccordionItem objects.",
            ),
            ComponentWell(
              onSurface: _onSurface,
              title: const LdTextHs("Demo"),
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_elevate) ...[
                    LdCard(padding: EdgeInsets.zero, child: accordion),
                    const LdTextL(
                        "Accordion is placed inside an LdCard with no padding")
                  ] else
                    accordion
                ],
              ),
            ),
            LdToggle(
              label: "Allow multiple open",
              checked: _allowMultiple,
              onChanged: _toggleAllowMultiple,
            ),
            LdToggle(
              label: "Elevate",
              checked: _elevate,
              onChanged: _toggleElevate,
            ),
            LdToggle(
                label: "On Surface background",
                checked: _onSurface,
                onChanged: _toggleOnSurface),
            LdDivider(),
            ComponentWell(
                title: const LdTextHs(".fromList constructor"),
                child: Column(
                  children: [
                    LdAccordion.fromList(
                      [
                        LdAccordionItem(
                          child: const Text(
                            "This is some content in an accordion",
                          ),
                          header: const Text("Header"),
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ));
  }
}
