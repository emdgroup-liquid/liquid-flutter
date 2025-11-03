import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

LdModalRoute ldMonkeyDetailModal<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdMonkey<T, IdType> route,
) {
  return LdModalRoute(
    context: context,
    pageBuilder: (context) => LdMonkeyDetailPageContent(route: route, selection: route.state.selectedItems),
  );
}
