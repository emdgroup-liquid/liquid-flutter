import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A simple card component with a shadow to elevate it from the page. Header and Footer are optional and separated by color.
class LdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  final Widget? header;
  final Widget? footer;
  final bool expandChild;
  final bool flat;

  const LdCard({
    required this.child,
    this.header,
    this.footer,
    this.flat = true,
    this.expandChild = false,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: theme.radius(LdSize.m),
          border: flat
              ? Border.all(
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: theme.border,
                  width: theme.borderWidth,
                )
              : null,
          boxShadow: flat ? null : [ldShadowDefault]),
      child: LdAutoBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              LdAutoBackground(
                child: Container(
                  padding: padding ?? theme.pad(size: LdSize.m),
                  child: header,
                ),
              ),
              const LdDivider(
                height: 1,
              )
            ],
            expandChild
                ? Expanded(
                    child: Padding(
                      padding: padding ?? theme.pad(size: LdSize.m),
                      child: child,
                    ),
                  )
                : Padding(
                    padding: padding ?? theme.pad(size: LdSize.m),
                    child: child,
                  ),
            if (footer != null) ...[
              const LdDivider(
                height: 1,
              ),
              LdAutoBackground(
                child: Container(
                  padding: padding ?? theme.pad(size: LdSize.m),
                  child: footer,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
