import 'package:liquid_flutter/liquid_flutter.dart';

/// This class defines the keys that are provided to the router
class LdMonkeyRouteConfig<T extends Identifiable<IdType>, IdType> {
  LdMonkeyRouteConfig({
    required this.itemName,
    required this.serialiseIdType,
    required this.parseIdType,
  });

  /// A configuration to be used if your item is identifiable by a string,
  /// your identifier must not contain underscores (_) to be split correctly
  /// If your identifier contains underscores, you need to pass a
  /// custom [serialiseIdType] and [parseIdType] to the constructor.
  /// It is recommened to use a seperator that is a valid URI character without
  /// encoding.
  static LdMonkeyRouteConfig<T, String> identifiableString<T extends Identifiable<String>>({
    required String itemName,
  }) {
    return LdMonkeyRouteConfig<T, String>(
      itemName: itemName,
      serialiseIdType: (ids) => ids.join("_"),
      parseIdType: (selected) => selected.split("_").toSet(),
    );
  }

  /// A configuration to be used if your item is identifiable by an integer,
  static LdMonkeyRouteConfig<T, int> identifiableInt<T extends Identifiable<int>>({
    required String itemName,
  }) {
    return LdMonkeyRouteConfig<T, int>(
      itemName: itemName,
      serialiseIdType: (ids) => ids.join("_"),
      parseIdType: (selected) => selected.split("_").map(int.tryParse).nonNulls.toSet(),
    );
  }

  final String itemName;

  final String Function(Set<IdType> ids) serialiseIdType;
  final Set<IdType> Function(String selected) parseIdType;

  /// The path parameter name used to retrieve the viewing items
  String get viewingParamName => "viewing_$itemName";

  /// The key of the query parameter to store the selection
  String get selectionQueryKey => "selection_$itemName";

  /// The GoRoute.name for the master route
  String get masterRouteName => "$itemName-master";

  /// The GoRoute.name for the detail route
  String get detailRouteName => "$itemName-detail";

  /// The GoRoute.name for the create route
  String get createRouteName => '$itemName-create';

  /// Static path segment for the create route (literal, not a path param)
  String get createPathSegment => 'new';

  /// The key of the query parameter to store the show selection controls
  String get showSelectionControlsQueryKey => "select_$itemName";

  String filterQueryKey(String filterName) => "$filterName-$itemName";
  String get sortQueryKey => "sort-$itemName";
}
