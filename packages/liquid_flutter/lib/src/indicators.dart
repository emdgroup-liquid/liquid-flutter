import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'indicators.variants.g.dart';

enum LdIndicatorType {
  info,
  warning,
  canceled,
  error,
  success,
  loading,
  pending,
  ongoing,
}

@Variants([
  Variant('info', defaults: {'type': 'LdIndicatorType.info'}),
  Variant('warning', defaults: {'type': 'LdIndicatorType.warning'}),
  Variant('canceled', defaults: {'type': 'LdIndicatorType.canceled'}),
  Variant('error', defaults: {'type': 'LdIndicatorType.error'}),
  Variant('success', defaults: {'type': 'LdIndicatorType.success'}),
  Variant('loading', defaults: {'type': 'LdIndicatorType.loading'}),
  Variant('pending', defaults: {'type': 'LdIndicatorType.pending'}),
  Variant('ongoing', defaults: {'type': 'LdIndicatorType.ongoing'}),
])
class _LdIndicatorWidget extends StatelessWidget {
  final LdIndicatorType type;
  final LdSize size;
  final double? customSize;

  const _LdIndicatorWidget({
    required this.type,
    this.size = LdSize.m,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = customSize ?? LdTheme.of(context).labelSize(this.size);

    if (type == LdIndicatorType.loading) {
      return Container(
          width: size * 1.6,
          height: size * 1.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LdTheme.of(context, listen: true).neutralShade(4),
          ),
          child: Center(
            child: LdLoader(
              size: size * 0.9,
            ),
          ));
    }

    return SvgPicture.asset(
      package: "liquid_flutter",
      switch (type) {
        LdIndicatorType.info => "assets/info.svg",
        LdIndicatorType.warning => "assets/warning.svg",
        LdIndicatorType.canceled => "assets/canceled.svg",
        LdIndicatorType.error => "assets/cross.svg",
        LdIndicatorType.success => "assets/checkmark.svg",
        LdIndicatorType.pending => "assets/pending.svg",
        LdIndicatorType.ongoing => "assets/ongoing.svg",
        LdIndicatorType.loading => "",
      },
      height: size * 1.6,
      width: size * 1.6,
    );
  }
}
