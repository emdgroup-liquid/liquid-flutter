import 'package:flutter/material.dart';
import 'package:liquid/components/component_api.dart';
import 'package:liquid_flutter/documentation.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ComponentsAccordion extends StatelessWidget {
  final Set<String> components;

  const ComponentsAccordion({
    Key? key,
    required this.components,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LdDocComponent> relevantComponents = ldDocComponents
        .where((element) => components.contains(element.name))
        .toList();

    return LdCard(
      padding: EdgeInsets.zero,
      child: LdAccordion(
        curveExpand: Curves.easeInOut,
        curveCollapse: Curves.easeInOut,
        childBuilder: ((context, n) {
          var component = relevantComponents[n];
          return SelectableRegion(
              selectionControls: MaterialTextSelectionControls(),
              focusNode: FocusNode(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (component.description.isNotEmpty)
                    LdText(component.description),
                  ComponentApi(component: component)
                ],
              ));
        }),
        itemCount: relevantComponents.length,
        headerBuilder: (context, n) {
          final component = relevantComponents[n];
          return Row(
            children: [
              Text(
                component.name,
              ),
              ldSpacerL,
              Expanded(
                  child: LdMute(
                      child: LdTextLs(
                component.description.isNotEmpty ? component.description : "",
                maxLines: 1,
              )))
            ],
          );
        },
      ),
    );
  }
}
