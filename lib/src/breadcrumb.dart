import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/intersperse.dart';

/// A breadcrumb widget.
class LdBreadcrumb extends StatelessWidget {
  const LdBreadcrumb({required this.children, super.key});
  final List<Widget> children;

  factory LdBreadcrumb.fromStrings(List<String> items) {
    return LdBreadcrumb(
      children: items
          .mapIndexed(
            (index, e) => Text(e),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: intersperse<Widget>(
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.textMuted,
                size: theme.paragraphSize(null),
              ),
            ), children.mapIndexed((index, element) {
          if (index == children.length - 1) {
            return IconTheme(
              data: IconThemeData(
                color: theme.primaryColor,
                size: theme.paragraphSize(null),
              ),
              child: DefaultTextStyle(
                child: element,
                style: TextStyle(
                  color: theme.primaryColor,
                  package: theme.fontFamilyPackage,
                  fontFamily: theme.fontFamily,
                ),
              ),
            );
          }
          return LdMute(
            child: IconTheme(
              data: IconThemeData(
                color: theme.textMuted,
                size: theme.paragraphSize(null),
              ),
              child: element,
            ),
          );
        })).toList());
  }
}
