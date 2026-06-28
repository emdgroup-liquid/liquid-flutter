import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyDetailState<T extends Identifiable<IdType>, IdType> {
  final LdListController<T, IdType>? listController;

  final Set<IdType> deletedItems;

  const LdMonkeyDetailState({
    this.deletedItems = const {},
    this.listController,
  });

  LdMonkeyDetailState<T, IdType> copyWith({
    LdListController<T, IdType>? listController,
    Set<IdType>? deletedItems,
  }) {
    return LdMonkeyDetailState<T, IdType>(
      listController: listController ?? this.listController,
      deletedItems: deletedItems ?? this.deletedItems,
    );
  }
}
