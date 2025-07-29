import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyDetailState<T extends Identifiable<IdType>, IdType, GroupingCriterion> {
  final bool showSelectionControls;

  final LdRepository<T, IdType>? repository;

  final Set<IdType> selectedItems;

  final Set<IdType> deletedItems;

  const LdMonkeyDetailState({
    required this.showSelectionControls,
    required this.selectedItems,
    this.deletedItems = const {},
    this.repository,
  });

  LdMonkeyDetailState<T, IdType, GroupingCriterion> copyWith({
    bool? showSelectionControls,
    Set<IdType>? selectedItems,
    LdRepository<T, IdType>? repository,
    Set<IdType>? deletedItems,
  }) {
    return LdMonkeyDetailState(
      showSelectionControls: showSelectionControls ?? this.showSelectionControls,
      selectedItems: selectedItems ?? this.selectedItems,
      repository: repository ?? this.repository,
      deletedItems: deletedItems ?? this.deletedItems,
    );
  }
}
