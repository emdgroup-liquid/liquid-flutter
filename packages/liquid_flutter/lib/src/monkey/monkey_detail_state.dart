import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyDetailState<T extends Identifiable<IdType>, IdType> {
  final LdRepository<T, IdType>? repository;

  final Set<IdType> deletedItems;

  const LdMonkeyDetailState({
    this.deletedItems = const {},
    this.repository,
  });

  LdMonkeyDetailState<T, IdType> copyWith({
    LdRepository<T, IdType>? repository,
    Set<IdType>? deletedItems,
  }) {
    return LdMonkeyDetailState<T, IdType>(
      repository: repository ?? this.repository,
      deletedItems: deletedItems ?? this.deletedItems,
    );
  }
}
