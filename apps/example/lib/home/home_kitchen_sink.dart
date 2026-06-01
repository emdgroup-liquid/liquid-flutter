import 'package:flutter/material.dart';
import 'package:liquid/home/widgets/chat_card.dart';
import 'package:liquid/home/widgets/download_card.dart';
import 'package:liquid/home/widgets/molecule_card.dart';
import 'package:liquid/home/widgets/payments_card.dart';
import 'package:liquid/home/widgets/report_issue_card.dart';
import 'package:liquid/home/widgets/sales_card.dart';
import 'package:liquid/home/widgets/scanner_card.dart';
import 'package:liquid/home/widgets/sign_in_card.dart';
import 'package:liquid/home/widgets/stock_card.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

class _ShadeGradient extends StatelessWidget {
  final Widget child;
  const _ShadeGradient({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 0.8],
                  colors: [theme.background.withAlpha(0), theme.background],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeKitchenSink extends StatelessWidget {
  const HomeKitchenSink({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ResponsiveBuilder(
          builder: (context, size) {
            return switch (size.deviceScreenType) {
              DeviceScreenType.desktop || DeviceScreenType.tablet => _ShadeGradient(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LdAutoSpace(
                              children: [HomeMoleculeCard(), HomeDownloadCard(), HomeReportIssueCard()],
                            ),
                          ),
                          Expanded(
                            child: LdAutoSpace(children: [HomeSignInCard(), HomeScannerCard(), HomeSalesCard()]),
                          ),
                        ],
                      ).spaceL(),
                    ),
                  ],
                ).spaceL().padS(),
              ),
              _ => LdAutoSpace(children: [HomeMoleculeCard(), HomeDownloadCard(), HomeReportIssueCard()]),
            };
          },
        ),
      ],
    );
  }
}
