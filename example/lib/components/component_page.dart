import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ComponentPagePath {
  final String path;

  ComponentPagePath({required this.path});
}

class ComponentPage extends StatelessWidget {
  final String title;
  final String path;
  final List<String>? apiComponents;

  final String? text;
  final Widget? demo;

  const ComponentPage({
    super.key,
    required this.path,
    required this.title,
    this.apiComponents,
    this.demo,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<ComponentPagePath>.value(
      value: ComponentPagePath(path: path),
      child: SingleChildScrollView(
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

                ComponentsAccordion(
                  components: apiComponents?.toSet() ?? {title},
                  initialOpenIndex: {0},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
