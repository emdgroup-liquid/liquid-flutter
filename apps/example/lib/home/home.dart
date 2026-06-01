import 'package:flutter/material.dart';
import 'package:liquid/home/home_demos_section.dart';
import 'package:liquid/home/home_getting_started.dart';
import 'package:liquid/home/home_kitchen_sink.dart';
import 'package:liquid/home/widgets/home_hero.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return LdScaffoldBody(
      addContainer: true,
      children: [
        HomeHero(),
        HomeKitchenSink(),
        LdAutoSpace(children: [HomeDemosSection(), HomeGettingStarted()]),
      ],
    );
  }
}
