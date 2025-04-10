import 'package:flutter/material.dart';
import 'package:liquid_flutter/documentation.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ComponentApi extends StatelessWidget {
  final DocComponent component;
  const ComponentApi({
    required this.component,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            var constructor = component.constructors[index];
            var namedParameters = constructor.signature.where(
              (e) => e.named,
            );
            var positionalParameters = constructor.signature.where(
              (e) => !e.named,
            );

            return DefaultTextStyle(
              style: TextStyle(
                  fontFamily: "NotoSansMono",
                  fontSize: 12,
                  color: LdTheme.of(context).text),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ldSpacerM,
                  if (positionalParameters.isEmpty)
                    Text(
                      "${constructor.name.isEmpty ? component.name : constructor.name}({",
                    )
                  else
                    Text(
                      "${constructor.name.isEmpty ? component.name : constructor.name}(",
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...positionalParameters.map((parameter) => Column(
                              children: [
                                Row(
                                  children: [
                                    if (parameter.description.isNotEmpty)
                                      LdTextPs(parameter.description),
                                    Text(
                                      parameter.type,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    ldSpacerS,
                                    Text(
                                      parameter.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    parameter == constructor.signature.last
                                        ? Container()
                                        : const Text(","),
                                  ],
                                ),
                              ],
                            )),
                        namedParameters.isNotEmpty &&
                                positionalParameters.isNotEmpty
                            ? const LdTextL(
                                "{",
                              )
                            : Container(),
                        ...namedParameters.map((parameter) => Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (parameter.required)
                                    LdTagSuccess(
                                        context: context,
                                        size: LdSize.s,
                                        child: const Text("Required")),
                                  ldSpacerXS,
                                  Expanded(
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                        text: parameter.type,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: parameter.required
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const TextSpan(text: " "),
                                      TextSpan(
                                        text: parameter.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (parameter ==
                                          constructor.signature.last)
                                        const TextSpan(text: ","),
                                    ])),
                                  ),
                                  ldSpacerS,
                                  parameter == constructor.signature.last
                                      ? Container()
                                      : const Text(","),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  namedParameters.isNotEmpty
                      ? const Text("});")
                      : const Text(
                          ");",
                          style: TextStyle(fontSize: 12),
                        ),
                  ldSpacerM,
                ],
              ),
            );
          }),
          separatorBuilder: ((context, index) => const LdDivider()),
          itemCount: component.constructors.length,
          shrinkWrap: true,
        ),
        ldSpacerM,
        const LdTextH(
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
                itemCount: component.properties.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const LdDivider(),
                itemBuilder: (context, index) {
                  var e = component.properties[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.description.isNotEmpty) LdTextPs(e.description),
                      ldSpacerS,
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          SizedBox(
                            child: Text(
                              e.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            e.type,
                          ),
                          ldSpacerM,
                          ...e.features.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: LdTag(
                                size: LdSize.s,
                                child: Text(e),
                              ),
                            ),
                          )
                        ],
                      ),
                      ldSpacerS,
                    ],
                  );
                })),
        ldSpacerL,
        const LdTextH(
          "Methods",
        ),
        ldSpacerM,
        Text(
          component.methods.join("\n"),
          style: const TextStyle(fontFamily: "NotoSansMono", fontSize: 12),
        ),
      ],
    );
  }
}
