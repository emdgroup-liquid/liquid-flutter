import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ComponentPage extends StatelessWidget {
  final String title;
  final List<String>? apiComponents;

  final String? text;
  final Widget? demo;

  const ComponentPage({
    super.key,
    required this.title,
    this.apiComponents,
    this.demo,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: LdContainer(
          child: LdAutoSpace(
            children: [
              // Breadcrumbs
              LdBreadcrumb.fromStrings([
                "Components",
                title,
              ]),

              LdTextHl(
                title,
              ),
              MarkdownBody(data: text ?? ""),
              // Demo

              demo ?? Container(),

              const LdTextH(
                "API Reference",
              ),

              ComponentsAccordion(components: apiComponents?.toSet() ?? {title}),
            ],
          ),
        ),
      ),
    );
  }
}
