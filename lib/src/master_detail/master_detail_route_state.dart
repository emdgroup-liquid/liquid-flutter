import 'package:liquid_flutter/liquid_flutter.dart';

class LdMasterDetailRouteState<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final bool showSelectionControls;

  final LdRepository<T, IdType>? repository;

  final Set<IdType> selectedItems;

  final Set<IdType> deletedItems;

  const LdMasterDetailRouteState({
    required this.showSelectionControls,
    required this.selectedItems,
    this.deletedItems = const {},
    this.repository,
  });

  LdMasterDetailRouteState<T, IdType, GroupingCriterion> copyWith({
    bool? showSelectionControls,
    Set<IdType>? selectedItems,
    LdRepository<T, IdType>? repository,
    Set<IdType>? deletedItems,
  }) {
    return LdMasterDetailRouteState(
      showSelectionControls: showSelectionControls ?? this.showSelectionControls,
      selectedItems: selectedItems ?? this.selectedItems,
      repository: repository ?? this.repository,
      deletedItems: deletedItems ?? this.deletedItems,
    );
  }
}
