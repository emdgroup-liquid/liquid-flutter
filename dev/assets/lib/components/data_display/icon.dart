import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';

var icons = {
  "three_d": LdIcons.three_d,
  "add": LdIcons.add,
  "atom": LdIcons.atom,
  "attention": LdIcons.attention,
  "audio": LdIcons.audio,
  "baby": LdIcons.baby,
  "bacteria_microscope_view": LdIcons.bacteria_microscope_view,
  "basket": LdIcons.basket,
  "battery_empty": LdIcons.battery_empty,
  "battery_full": LdIcons.battery_full,
  "battery_half": LdIcons.battery_half,
  "battery_low": LdIcons.battery_low,
  "battery": LdIcons.battery,
  "beaker": LdIcons.beaker,
  "bell": LdIcons.bell,
  "beard": LdIcons.beard,
  "big_cross": LdIcons.big_cross,
  "bin": LdIcons.bin,
  "bitcoin": LdIcons.bitcoin,
  "bottle": LdIcons.bottle,
  "bulb": LdIcons.bulb,
  "burger_menu": LdIcons.burger_menu,
  "burger": LdIcons.burger,
  "cabriolet": LdIcons.cabriolet,
  "calendar": LdIcons.calendar,
  "camcorder": LdIcons.camcorder,
  "camera": LdIcons.camera,
  "car": LdIcons.car,
  "cards": LdIcons.cards,
  "chat": LdIcons.chat,
  "checkmark": LdIcons.checkmark,
  "choir": LdIcons.choir,
  "clip": LdIcons.clip,
  "clock": LdIcons.clock,
  "cloud_download": LdIcons.cloud_download,
  "cloud_upload": LdIcons.cloud_upload,
  "cloud": LdIcons.cloud,
  "coffe": LdIcons.coffe,
  "control": LdIcons.control,
  "conversation": LdIcons.conversation,
  "copy": LdIcons.copy,
  "cost_center": LdIcons.cost_center,
  "coupon": LdIcons.coupon,
  "credit_card": LdIcons.credit_card,
  "cross": LdIcons.cross,
  "dashboard": LdIcons.dashboard,
  "data_storage": LdIcons.data_storage,
  "dna": LdIcons.dna,
  "documents_storage": LdIcons.documents_storage,
  "documents": LdIcons.documents,
  "dollar": LdIcons.dollar,
  "donut": LdIcons.donut,
  "dot": LdIcons.dot,
  "download": LdIcons.download,
  "eco": LdIcons.eco,
  "education": LdIcons.education,
  "electric_car": LdIcons.electric_car,
  "energy": LdIcons.energy,
  "euro": LdIcons.euro,
  "external_export": LdIcons.external_export,
  "fast_forward": LdIcons.fast_forward,
  "favorite": LdIcons.favorite,
  "files": LdIcons.files,
  "filter": LdIcons.filter,
  "finance": LdIcons.finance,
  "first_aid": LdIcons.first_aid,
  "flask": LdIcons.flask,
  "football": LdIcons.football,
  "gamepad": LdIcons.gamepad,
  "half_dot": LdIcons.half_dot,
  "half_star": LdIcons.half_star,
  "house": LdIcons.house,
  "hyperlink": LdIcons.hyperlink,
  "initial_m": LdIcons.initial_m,
  "jpeg": LdIcons.jpeg,
  "keys": LdIcons.keys,
  "laptop_mobile": LdIcons.laptop_mobile,
  "laptop": LdIcons.laptop,
  "layer": LdIcons.layer,
  "list": LdIcons.list,
  "location": LdIcons.location,
  "lock_save": LdIcons.lock_save,
  "logistic": LdIcons.logistic,
  "m_card": LdIcons.m_card,
  "magnifier": LdIcons.magnifier,
  "mail": LdIcons.mail,
  "matryoshka": LdIcons.matryoshka,
  "medical_file": LdIcons.medical_file,
  "medicine": LdIcons.medicine,
  "meetup": LdIcons.meetup,
  "mic": LdIcons.mic,
  "microscope": LdIcons.microscope,
  "mobile": LdIcons.mobile,
  "money": LdIcons.money,
  "monitor": LdIcons.monitor,
  "monkey": LdIcons.monkey,
  "navigator": LdIcons.navigator,
  "option": LdIcons.option,
  "pause": LdIcons.pause,
  "pdf": LdIcons.pdf,
  "pen": LdIcons.pen,
  "phone": LdIcons.phone,
  "pill": LdIcons.pill,
  "pipette": LdIcons.pipette,
  "pisces": LdIcons.pisces,
  "placeholder": LdIcons.placeholder,
  "plane": LdIcons.plane,
  "plant": LdIcons.plant,
  "play": LdIcons.play,
  "pound": LdIcons.pound,
  "pretzel": LdIcons.pretzel,
  "print": LdIcons.print,
  "pulse": LdIcons.pulse,
  "puzzle": LdIcons.puzzle,
  "refresh": LdIcons.refresh,
  "repost": LdIcons.repost,
  "rewind": LdIcons.rewind,
  "rocket": LdIcons.rocket,
  "san_francisco": LdIcons.san_francisco,
  "satelite": LdIcons.satelite,
  "savings": LdIcons.savings,
  "scientific_paper": LdIcons.scientific_paper,
  "scissors": LdIcons.scissors,
  "secure_conncetion": LdIcons.secure_conncetion,
  "security": LdIcons.security,
  "settings": LdIcons.settings,
  "share": LdIcons.share,
  "shield": LdIcons.shield,
  "sock": LdIcons.sock,
  "solar_power": LdIcons.solar_power,
  "star": LdIcons.star,
  "stethoscope": LdIcons.stethoscope,
  "stop": LdIcons.stop,
  "syringe": LdIcons.syringe,
  "tea_pot": LdIcons.tea_pot,
  "test_tube": LdIcons.test_tube,
  "truck": LdIcons.truck,
  "upload": LdIcons.upload,
  "user": LdIcons.user,
  "ux": LdIcons.ux,
  "virus": LdIcons.virus,
  "visibity": LdIcons.visibity,
  "vr": LdIcons.vr,
  "watch": LdIcons.watch,
  "website": LdIcons.website,
  "wi_fi": LdIcons.wi_fi,
  "world": LdIcons.world,
  "youtube": LdIcons.youtube,
  "zip": LdIcons.zip,
  "arrow_down": LdIcons.arrow_down,
  "arrow_left": LdIcons.arrow_left,
  "arrow_right": LdIcons.arrow_right,
  "arrow_up_n_down": LdIcons.arrow_up_n_down,
  "arrow_up": LdIcons.arrow_up,
  "arrow_double_left": LdIcons.arrow_double_left,
};

class IconDemo extends StatefulWidget {
  const IconDemo({super.key});

  @override
  State<IconDemo> createState() => _IconDemoState();
}

class _IconDemoState extends State<IconDemo> {
  String? _query;

  void _onChanged(String? query) {
    setState(() {
      _query = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    Iterable<MapEntry<String, IconData>> iconsFiltered = _query == null
        ? icons.entries
        : icons.entries.where((element) =>
            element.key.toLowerCase().contains(_query!.toLowerCase()));

    var theme = LdTheme.of(context);

    return ComponentPage(
      title: "Icons",
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LdInput(
            hint: "Search...",
            onChanged: _onChanged,
          ),
          ldSpacerM,
          Wrap(
            spacing: 8,
            runAlignment: WrapAlignment.spaceEvenly,
            runSpacing: 8,
            children: iconsFiltered
                .map(
                  (e) => Tooltip(
                      message: "LdIcons.${e.key}",
                      child: Container(
                        width: 90,
                        padding: const EdgeInsetsDirectional.all(2),
                        height: 90,
                        decoration: BoxDecoration(
                            color: LdTheme.of(context).surface,
                            border: Border.all(
                                width: 1.5, color: LdTheme.of(context).border),
                            borderRadius: theme.radius(LdSize.s)),
                        child: Column(
                          children: [
                            Padding(
                              padding: LdTheme.of(context).pad(size: LdSize.m),
                              child: Icon(
                                e.value,
                                size: 24,
                                color: theme.text,
                              ),
                            ),
                            LdText(
                              e.key,
                              type: LdTextType.paragraph,
                              size: LdSize.s,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
