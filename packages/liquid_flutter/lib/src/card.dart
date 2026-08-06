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

    return Padding(
      padding: flat ? EdgeInsets.all(theme.borderWidth) : EdgeInsets.zero,
      child: Container(
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
          // Stretch needs a bounded max width; inside a Row (or other
          // unbounded main-axis parent) that would create infinite tight
          // width constraints ("BoxConstraints forces an infinite width").
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAlign = constraints.hasBoundedWidth
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.start;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAlign,
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
                    ),
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
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
