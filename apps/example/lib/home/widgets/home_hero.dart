import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return SizedBox(
      width: double.infinity,
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m)),
            clipBehavior: Clip.hardEdge,
            child: Image.asset('liquid_flutter_icon.jpg', width: 64, height: 64),
          ),
          ldSpacerM,
          Flexible(
            child: LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LdText.hl('Build for every platform \n with Liquid Flutter', textAlign: TextAlign.center),
                LdMute(
                  child: LdText.ll(
                    'Cross platform design system for Flutter. With first class support for desktop and mobile.',
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    LdTag(child: Text('Web')),
                    LdTag(child: Text('MacOS')),
                    LdTag(child: Text('Windows')),
                    LdTag(child: Text('Linux')),
                    LdTag(child: Text('Android')),
                    LdTag(child: Text('iOS')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).padL(),
    );
  }
}
