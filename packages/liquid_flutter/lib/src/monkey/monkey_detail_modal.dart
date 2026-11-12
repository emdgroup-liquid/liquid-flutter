import 'package:material_ui/material_ui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

LdModalRoute ldMonkeyDetailModal<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  Widget detailPage,
) {
  return LdModalRoute(
    context: context,
    pageBuilder: (context) {
      return detailPage;
    },
  );
}
