import 'package:collection/collection.dart';
import 'package:liquid_generators/doc_comparator/api_change.dart';
import 'package:liquid_generators/doc_items.dart';

extension ParameterStringExt on Parameter {
  String get nameString => "${required ? "required " : "optional "}"
      "${named ? "named " : ""}"
      "${name.startsWith('_') ? "private " : ""}"
      "parameter '$name'";
  String get typeString => "type '$type'";
}

extension PropertyStringExt on Property {
  String get nameString => "${name.startsWith('_') ? "private " : ""}"
      "property '$name'";
  String get typeString => "type '$type'";
}

extension ConstructorStringExt on Constructor {
  String get nameString => "${name.startsWith("_") ? "private " : ""}"
      "constructor '${name.isEmpty ? 'default' : name}'";
}

extension DocComponentListApiChangesExt on List<DocComponent> {
  List<ApiChange> compareTo(List<DocComponent> newComponents) {
    final changes = <ApiChange>[];

    for (var i = 0; i < length; i++) {
      final newComponent = newComponents
          .firstWhereOrNull((element) => element.name == this[i].name);
      if (newComponent == null) {
        changes.add(ApiChange(
          component: this[i].name,
          description: "${this[i].name} was removed",
          type: ApiChangeType.major,
        ));
        continue;
      }
      changes.addAll(this[i].compareTo(newComponent));
    }

    for (var i = 0; i < newComponents.length; i++) {
      final oldComponent =
          firstWhereOrNull((element) => element.name == newComponents[i].name);
      if (oldComponent == null) {
        changes.add(ApiChange(
          component: newComponents[i].name,
          description: "${newComponents[i].name} was added",
          type: ApiChangeType.minor,
        ));
      }
    }

    return changes;
  }
}

extension DocComponentApiChangesExt on DocComponent {
  List<ApiChange> compareTo(DocComponent newComponent) {
    final changes = <ApiChange>[];

    /// For components starting with an underscore, we consider changes to be at
    /// most minor, as they are private to the library and should not be used
    /// outside of it.
    final atMostChangeType =
        name.startsWith('_') ? ApiChangeType.patch : ApiChangeType.major;

    if (isNullSafe && !newComponent.isNullSafe) {
      changes.add(ApiChange(
        component: name,
        description: "Component became null-unsafe",
        type: ApiChangeType.major.atMost(atMostChangeType),
      ));
    }

    changes.addAll(
      constructors.compareTo(newComponent.constructors, componentName: name),
    );
    changes.addAll(
      properties.compareTo(newComponent.properties, componentName: name),
    );

    return changes;
  }
}

extension ConstructorApiChangesExt on Constructor {
  /// Compares [this] constructor with [newConstructor] and returns a list of
  /// [ApiChange]s that have been detected between the two constructors.
  List<ApiChange> compareTo(
    Constructor newConstructor, {
    required String componentName,
  }) {
    final changes = <ApiChange>[];
    final atMostChangeType = componentName.startsWith('_')
        ? ApiChangeType.patch
        : ApiChangeType.major;

    for (var i = 0; i < signature.length; i++) {
      final oldParam = signature[i];
      final newParam = newConstructor.signature
          .firstWhereOrNull((element) => element.name == oldParam.name);
      if (newParam == null) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${oldParam.nameString} was removed in ${newConstructor.nameString}",
          type: ApiChangeType.major.atMost(atMostChangeType).atMost(
                oldParam.required ? ApiChangeType.major : ApiChangeType.minor,
              ),
        ));
        continue;
      }
      if (!oldParam.required && newParam.required) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${oldParam.nameString} became required in ${newConstructor.nameString}",
          type: ApiChangeType.major.atMost(atMostChangeType),
        ));
      }
      if (oldParam.named != newParam.named) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${oldParam.nameString} named changed from ${oldParam.named} to ${newParam.named} in ${newConstructor.nameString}",
          type: ApiChangeType.major.atMost(atMostChangeType),
        ));
      }
      if (oldParam.type != newParam.type) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${oldParam.nameString} type changed from ${oldParam.typeString} to ${newParam.typeString} in ${newConstructor.nameString}",
          type: ApiChangeType.major.atMost(atMostChangeType),
        ));
      }
      if (oldParam.required && !newParam.required) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${oldParam.nameString} became optional in ${newConstructor.nameString}",
          type: ApiChangeType.minor,
        ));
      }
    }

    for (var i = 0; i < newConstructor.signature.length; i++) {
      final newParam = newConstructor.signature[i];
      final oldParam = signature
          .firstWhereOrNull((element) => element.name == newParam.name);
      if (oldParam == null) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${newParam.nameString} was added in ${newConstructor.nameString}",
          type: newParam.required ? ApiChangeType.major : ApiChangeType.minor,
        ));
      }
    }

    return changes;
  }
}

extension ConstructorListApiChangesExt on List<Constructor> {
  /// Compares [this] list of constructors with [newConstructors] and returns a
  /// list of [ApiChange]s that have been detected between the two lists.
  List<ApiChange> compareTo(
    List<Constructor> newConstructors, {
    required String componentName,
  }) {
    final changes = <ApiChange>[];
    final atMostChangeType = componentName.startsWith('_')
        ? ApiChangeType.patch // changes to private comps are considered patch
        : ApiChangeType.major;

    for (var i = 0; i < length; i++) {
      final newConstructor = newConstructors
          .firstWhereOrNull((element) => element.name == this[i].name);
      if (newConstructor == null) {
        changes.add(ApiChange(
          component: componentName,
          description: "${this[i].nameString} was removed from $componentName",
          type: ApiChangeType.major.atMost(atMostChangeType),
        ));
        continue;
      }
      changes.addAll(
          this[i].compareTo(newConstructor, componentName: componentName));
    }

    for (var i = 0; i < newConstructors.length; i++) {
      final oldConstructor = firstWhereOrNull(
          (element) => element.name == newConstructors[i].name);
      if (oldConstructor == null) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${newConstructors[i].nameString} was added to $componentName",
          type: ApiChangeType.minor,
        ));
      }
    }

    return changes;
  }
}

extension PropertyListApiChangesExt on List<Property> {
  /// Compares [this] list of properties with [newProperties] and returns a list
  /// of [ApiChange]s that have been detected between the two lists.
  List<ApiChange> compareTo(
    List<Property> newProperties, {
    required String componentName,
  }) {
    final changes = <ApiChange>[];
    final componentAtMostChangeType = componentName.startsWith('_')
        ? ApiChangeType.patch // changes to private comps are considered patch
        : ApiChangeType.major;

    for (var i = 0; i < length; i++) {
      final newProperty = newProperties
          .firstWhereOrNull((element) => element.name == this[i].name);
      final propertyAtMostChangeType = this[i].name.startsWith('_')
          ? ApiChangeType.patch // changes to private props are considered patch
          : componentAtMostChangeType;
      if (newProperty == null) {
        changes.add(ApiChange(
          component: componentName,
          description: "${this[i].nameString} was removed",
          type: ApiChangeType.major.atMost(propertyAtMostChangeType),
        ));
        continue;
      }
      if (this[i].type != newProperty.type) {
        changes.add(ApiChange(
          component: componentName,
          description:
              "${this[i].nameString} type changed from ${this[i].typeString} to ${newProperty.typeString}",
          type: ApiChangeType.major.atMost(propertyAtMostChangeType),
        ));
      }
    }

    for (var i = 0; i < newProperties.length; i++) {
      final oldProperty =
          firstWhereOrNull((element) => element.name == newProperties[i].name);
      if (oldProperty == null) {
        changes.add(ApiChange(
          component: componentName,
          description: "${newProperties[i].nameString} was added",
          type: ApiChangeType.minor.atMost(newProperties[i].name.startsWith('_')
              ? ApiChangeType.patch // private new props are considered patch
              : componentAtMostChangeType),
        ));
      }
    }

    return changes;
  }
}
