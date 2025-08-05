import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_api_guard/models/doc_items.dart';
import '../code_block.dart';

class ComponentApi extends StatefulWidget {
  final DocComponent component;
  const ComponentApi({
    required this.component,
    super.key,
  });

  @override
  State<ComponentApi> createState() => _ComponentApiState();
}

class _ComponentApiState extends State<ComponentApi> {
  bool _showPrivate = false;

  String _generateConstructorSignature(DocConstructor constructor) {
    var namedParameters = constructor.signature
        .where((e) => e.named)
        .sortedByCompare((item) => item.required, (a, b) => a ? -1 : 1);

    var positionalParameters = constructor.signature.where((e) => !e.named);

    StringBuffer buffer = StringBuffer();

    // Constructor name
    String constructorName =
        constructor.name.isEmpty ? widget.component.name : constructor.name;
    buffer.write("$constructorName(");

    // Positional parameters
    for (int i = 0; i < positionalParameters.length; i++) {
      var parameter = positionalParameters.elementAt(i);
      if (parameter.description.isNotEmpty) {
        buffer.write("/// ${parameter.description}\n");
      }
      buffer.write("${parameter.type} ${parameter.name}");
      if (i < positionalParameters.length - 1 || namedParameters.isNotEmpty) {
        buffer.write(", ");
      }
    }

    // Named parameters
    if (namedParameters.isNotEmpty) {
      if (positionalParameters.isNotEmpty) {
        buffer.write("{");
      }

      for (int i = 0; i < namedParameters.length; i++) {
        var parameter = namedParameters.elementAt(i);
        if (parameter.description.isNotEmpty) {
          buffer.write("\n  /// ${parameter.description}");
        }
        buffer.write(
            "\n  ${parameter.required ? 'required ' : ''}${parameter.type} ${parameter.name}");
        if (i < namedParameters.length - 1) {
          buffer.write(",");
        }
      }

      if (positionalParameters.isNotEmpty) {
        buffer.write("\n}");
      }
    }

    buffer.write("\n);");

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    List<DocProperty> sortedProperties = widget.component.properties.toList();

    if (!_showPrivate) {
      sortedProperties =
          sortedProperties.where((e) => !e.name.startsWith('_')).toList();
    }

    sortedProperties.sort((a, b) {
      bool aIsPrivate = a.name.startsWith('_');
      bool bIsPrivate = b.name.startsWith('_');

      if (aIsPrivate && !bIsPrivate) return 1;
      if (!aIsPrivate && bIsPrivate) return -1;

      return a.name.compareTo(b.name);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            var constructor = widget.component.constructors[index];
            String constructorSignature =
                _generateConstructorSignature(constructor);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ldSpacerM,
                CodeBlock(
                  showCopyButton: false,
                  wrapCard: false,
                  code: constructorSignature,
                  language: "dart",
                ),
                ldSpacerM,
              ],
            );
          }),
          separatorBuilder: ((context, index) => const LdDivider()),
          itemCount: widget.component.constructors.length,
          shrinkWrap: true,
        ),
        ldSpacerM,
        const LdTextHs(
          "Properties",
        ),
        ldSpacerM,
        DefaultTextStyle(
            style: TextStyle(
                fontFamily: "NotoSansMono",
                fontSize: 12,
                color: LdTheme.of(context).text),
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedProperties.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const LdDivider(),
                itemBuilder: (context, index) {
                  var e = sortedProperties[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.description.isNotEmpty)
                        LdMute(
                          child: LdTextP(
                            e.description.replaceAll("///", ""),
                          ),
                        ),
                      ldSpacerS,
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          CodeBlock(
                            wrapCard: false,
                            showCopyButton: false,
                            code: [
                              if (e.features.isNotEmpty)
                                '${e.features.join(' ')} ',
                              e.type,
                              ' ',
                              e.name,
                            ].join(),
                          ),
                        ],
                      ),
                      ldSpacerS,
                    ],
                  );
                })),
        ldSpacerL,
        const LdTextHs(
          "Methods",
        ),
        ldSpacerM,
        Text(
          widget.component.methods.join("\n"),
          style: const TextStyle(fontFamily: "NotoSansMono", fontSize: 12),
        ),
      ],
    );
  }
}
