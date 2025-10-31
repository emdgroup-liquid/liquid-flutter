import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:liquid/components/component_api.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_api_guard/models/doc_items.dart';

class ComponentsAccordion extends StatefulWidget {
  final Set<String> components;

  const ComponentsAccordion({
    super.key,
    required this.components,
    this.initialOpenIndex,
  });

  final Set<int>? initialOpenIndex;

  @override
  State<ComponentsAccordion> createState() => _ComponentsAccordionState();
}

class _ComponentsAccordionState extends State<ComponentsAccordion> {
  List<DocComponent> allDocComponents = [];

  @override
  void initState() {
    super.initState();
    _loadApiJson();
  }

  Future<void> _loadApiJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('../api_guard/api.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      final List<DocComponent> components = jsonList
          .map((json) => DocComponent.fromJson(json as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          allDocComponents = components;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading API JSON: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DocComponent> relevantComponents = allDocComponents
        .where((element) => widget.components.contains(element.name))
        .toList();

    return LdAccordion(
      curveExpand: Curves.easeInOut,
      wrapActiveInCard: true,
      curveCollapse: Curves.easeInOut,
      initialOpenIndex: widget.initialOpenIndex ?? {},
      childBuilder: ((context, n) {
        var component = relevantComponents[n];
        return SelectableRegion(
            selectionControls: MaterialTextSelectionControls(),
            focusNode: FocusNode(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (component.description.isNotEmpty)
                  LdText(component.description.replaceAll("///", "")),
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
                    child: LdText.ls(
              component.description.isNotEmpty
                  ? component.description.replaceAll("///", "")
                  : "",
              maxLines: 1,
            )))
          ],
        );
      },
    );
  }
}
