// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:liquid_flutter/documentation.dart';

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}

extension CollectionElementExtension on CollectionElement {
  Map<String, dynamic> get properties {
    final map = <String, dynamic>{};
    for (var element in childEntities) {
      if (element is ArgumentList) {
        for (var arg in element.arguments) {
          if (arg is NamedExpression) {
            map[arg.name.label.name] = _extractValue(arg.expression);
          }
        }
      }
    }
    return map;
  }

  T get<T>(String name) {
    final property = properties[name];
    if ((T == List<String>) && property is ListLiteral) {
      return property.elements
          .map((e) => (e as StringLiteral).stringValue ?? '')
          .toList() as T;
    }
    return property as T;
  }

  dynamic _extractValue(Expression expr) {
    if (expr is SimpleStringLiteral) {
      return expr.value;
    } else if (expr is BooleanLiteral) {
      return expr.value;
    }
    return expr;
  }
}

/// Parse a `LdDocComponent` from a `MethodInvocation` AST node.
LdDocComponent parseLdDocComponent(MethodInvocation expr) {
  // Extract the component data
  final name = expr.get<String>('name');
  final isNullSafe = expr.get<bool?>('isNullSafe') ?? false;
  final description = expr.get<String>('description');
  final methods = expr.get<List<String>>('methods');

  // Parse constructors
  final constructors = <LdDocConstructor>[];
  final constructorsArg = expr.get<ListLiteral>('constructors');
  for (final constructor in constructorsArg.elements) {
    final signature = <LdDocParameter>[];
    final params = constructor.get<ListLiteral?>('signature');
    for (CollectionElement param in params?.elements ?? []) {
      signature.add(LdDocParameter(
        name: param.get<String>('name'),
        type: param.get<String>('type'),
        description: param.get<String>('description'),
        named: param.get<bool?>('named') ?? false,
        required: param.get<bool?>('required') ?? false,
      ));
    }
    constructors.add(LdDocConstructor(
      name: constructor.get<String>('name'),
      signature: signature,
      features: [],
    ));
  }

  // Parse properties
  final properties = <LdDocProperty>[];
  final propertiesArg = expr.get<ListLiteral>('properties');
  for (final property in propertiesArg.elements) {
    properties.add(LdDocProperty(
      name: property.get<String>('name'),
      type: property.get<String>('type'),
      description: property.get<String>('description'),
      features: property.get<List<String>>('features'),
    ));
  }

  return LdDocComponent(
    name: name,
    isNullSafe: isNullSafe,
    description: description,
    constructors: constructors,
    properties: properties,
    methods: methods,
  );
}

/// Load the content of a file from a URI and extract the LdDocComponents from
/// it by parsing the AST.
Future<List<LdDocComponent>> extractLdDocComponents(Uri uri) async {
  String content;
  if (uri.scheme == 'https') {
    final response = HttpClient().getUrl(uri);
    content = await response.then((value) => value.close()).then((value) {
      return value.transform(const Utf8Decoder()).join();
    });
  } else {
    final file = File(uri.toFilePath());
    content = file.readAsStringSync();
  }
  final unit = parseString(content: content).unit;

  final components = <LdDocComponent>[];

  // find "const ldDocComponents = [...]" in the file
  unit.declarations.whereType<TopLevelVariableDeclaration>().forEach((decl) {
    final variable = decl.variables.variables.first;
    if (variable.name.toString() == 'ldDocComponents') {
      final initializer = variable.initializer;
      if (initializer is ListLiteral) {
        for (var element in initializer.elements) {
          if (element is MethodInvocation) {
            final name = element.methodName.name;
            if (name == 'LdDocComponent') {
              final component = parseLdDocComponent(element);
              components.add(component);
            }
          }
        }
      }
    }
  });

  return components;
}

enum ApiChangeType {
  patch,
  minor,
  major,
}

extension VersionChangeTypeExtension on ApiChangeType {
  ApiChangeType atLeast(ApiChangeType other) {
    return index >= other.index ? this : other;
  }

  ApiChangeType atMost(ApiChangeType other) {
    return index <= other.index ? this : other;
  }
}

class ApiChange {
  final String component;
  final String description;
  final ApiChangeType type;

  ApiChange({
    required this.component,
    required this.description,
    required this.type,
  });

  ApiChange atMost(ApiChangeType other) {
    return ApiChange(
      component: component,
      description: description,
      type: type.atMost(other),
    );
  }
}

extension LdConstructorNameString on LdDocConstructor {
  String get nameString => "constructor '${name.isEmpty ? 'default' : name}'";
}

extension LdParameterNameString on LdDocParameter {
  String get nameString => "parameter '$name'";
  String get typeString => "type '$type'";
}

extension LdPropertyNameString on LdDocProperty {
  String get nameString => "property '$name'";
  String get typeString => "type '$type'";
}

List<ApiChange> compareLdDocConstructors(
  LdDocConstructor oldConstructor,
  LdDocConstructor newConstructor, {
  required String componentName,
}) {
  final changes = <ApiChange>[];
  final atMostChangeType =
      componentName.startsWith('_') ? ApiChangeType.minor : ApiChangeType.major;

  for (var i = 0; i < oldConstructor.signature.length; i++) {
    final oldParam = oldConstructor.signature[i];
    final newParam = newConstructor.signature
        .firstWhereOrNull((element) => element.name == oldParam.name);
    if (newParam == null) {
      changes.add(ApiChange(
        component: componentName,
        description:
            "${oldParam.nameString} was removed in ${newConstructor.nameString}",
        type: ApiChangeType.major.atMost(atMostChangeType),
      ));
      continue;
    }
    if (!oldParam.required && newParam.required) {
      changes.add(ApiChange(
        component: componentName,
        description:
            "${oldParam.nameString} became required in ${newConstructor.nameString}",
        type: ApiChangeType.minor,
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
    final oldParam = oldConstructor.signature
        .firstWhereOrNull((element) => element.name == newParam.name);
    if (oldParam == null) {
      changes.add(ApiChange(
        component: componentName,
        description:
            "${newParam.required ? "Required" : "Optional"} ${newParam.nameString} was added in ${newConstructor.nameString}",
        type: newParam.required ? ApiChangeType.major : ApiChangeType.minor,
      ));
    }
  }

  return changes;
}

List<ApiChange> compareLdDocPropertyLists(
  List<LdDocProperty> oldProperties,
  List<LdDocProperty> newProperties, {
  required String componentName,
}) {
  final changes = <ApiChange>[];
  final atMostChangeType =
      componentName.startsWith('_') ? ApiChangeType.minor : ApiChangeType.major;

  for (var i = 0; i < oldProperties.length; i++) {
    final newProperty = newProperties
        .firstWhereOrNull((element) => element.name == oldProperties[i].name);
    if (newProperty == null) {
      changes.add(ApiChange(
        component: componentName,
        description: "${oldProperties[i].nameString} was removed",
        type: ApiChangeType.major.atMost(atMostChangeType),
      ));
      continue;
    }
    if (oldProperties[i].type != newProperty.type) {
      changes.add(ApiChange(
        component: componentName,
        description:
            "${oldProperties[i].nameString} type changed from ${oldProperties[i].typeString} to ${newProperty.typeString}",
        type: ApiChangeType.major.atMost(atMostChangeType),
      ));
    }
  }

  for (var i = 0; i < newProperties.length; i++) {
    final oldProperty = oldProperties
        .firstWhereOrNull((element) => element.name == newProperties[i].name);
    if (oldProperty == null) {
      changes.add(ApiChange(
        component: componentName,
        description: "${newProperties[i].nameString} was added",
        type: ApiChangeType.minor,
      ));
    }
  }

  return changes;
}

List<ApiChange> compareLdDocComponents(
    LdDocComponent oldComponent, LdDocComponent newComponent) {
  final changes = <ApiChange>[];

  /// For components starting with an underscore, we consider changes to be at
  /// most minor, as they are private to the library and should not be used
  /// outside of it.
  final atMostChangeType = oldComponent.name.startsWith('_')
      ? ApiChangeType.minor
      : ApiChangeType.major;

  if (oldComponent.isNullSafe && !newComponent.isNullSafe) {
    changes.add(ApiChange(
      component: oldComponent.name,
      description: "Component became null-unsafe",
      type: ApiChangeType.major.atMost(atMostChangeType),
    ));
  }

  for (var constructor in oldComponent.constructors) {
    final otherConstructor = newComponent.constructors
        .firstWhereOrNull((element) => element.name == constructor.name);
    if (otherConstructor == null) {
      changes.add(ApiChange(
        component: oldComponent.name,
        description: "${constructor.nameString} was removed",
        type: ApiChangeType.major.atMost(atMostChangeType),
      ));
      continue;
    }
    changes.addAll(compareLdDocConstructors(
      constructor,
      otherConstructor,
      componentName: oldComponent.name,
    ));
  }

  for (var constructor in newComponent.constructors) {
    final otherConstructor = oldComponent.constructors
        .firstWhereOrNull((element) => element.name == constructor.name);
    if (otherConstructor == null) {
      changes.add(ApiChange(
        component: oldComponent.name,
        description: "${constructor.nameString} was added",
        type: ApiChangeType.minor,
      ));
    }
  }

  final oldMethods = oldComponent.methods.toSet();
  final newMethods = newComponent.methods.toSet();
  for (var method in oldMethods.difference(newMethods)) {
    final privateMethod = method.startsWith('_');
    changes.add(ApiChange(
      component: oldComponent.name,
      description: "method '$method' was removed",
      type: ApiChangeType.major.atMost(
        privateMethod ? ApiChangeType.minor : atMostChangeType,
      ),
    ));
  }
  for (var method in newMethods.difference(oldMethods)) {
    changes.add(ApiChange(
      component: oldComponent.name,
      description: "method '$method' was added",
      type: ApiChangeType.minor,
    ));
  }

  changes.addAll(
    compareLdDocPropertyLists(
      oldComponent.properties,
      newComponent.properties,
      componentName: oldComponent.name,
    ).map((change) => change.atMost(atMostChangeType)),
  );

  return changes;
}

List<ApiChange> compareDocComponentLists(
    List<LdDocComponent> oldComponents, List<LdDocComponent> newComponents) {
  final changes = <ApiChange>[];

  for (var i = 0; i < oldComponents.length; i++) {
    final newComponent = newComponents
        .firstWhereOrNull((element) => element.name == oldComponents[i].name);
    if (newComponent == null) {
      changes.add(ApiChange(
        component: oldComponents[i].name,
        description: "component was removed",
        type: ApiChangeType.major,
      ));
      continue;
    }
    changes.addAll(compareLdDocComponents(oldComponents[i], newComponent));
  }

  for (var i = 0; i < newComponents.length; i++) {
    final oldComponent = oldComponents
        .firstWhereOrNull((element) => element.name == newComponents[i].name);
    if (oldComponent == null) {
      changes.add(ApiChange(
        component: newComponents[i].name,
        description: "component was added",
        type: ApiChangeType.minor,
      ));
    }
  }
  return changes;
}

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    print(
        'Usage: dart documentation_comparator.dart <localFile> <remoteFile> [options]');
    print(
        'Example: dart documentation_comparator.dart ../../lib/documentation.dart https://raw.githubusercontent.com/emdgroup-liquid/liquid-flutter/refs/heads/main/lib/documentation.dart');
    print('Options:');
    print('  --help, -h: Show this help message');
    print('  --verbose, -v: Print detailed information about the changes');
    return;
  }

  final verbose = args.contains('--verbose') || args.contains('-v');

  final positionalArgs =
      args.where((element) => !element.startsWith('-')).toList();
  final localFileUri = Uri.parse(
      positionalArgs.elementAtOrNull(0) ?? '../lib/documentation.dart');
  final remoteFileUri = Uri.parse(positionalArgs.elementAtOrNull(1) ??
      'https://raw.githubusercontent.com/emdgroup-liquid/liquid-flutter/refs/heads/main/lib/documentation.dart');

  final localComponents = await extractLdDocComponents(localFileUri);
  final remoteComponents = await extractLdDocComponents(remoteFileUri);
  final apiChanges =
      compareDocComponentLists(remoteComponents, localComponents);

  // print api changes
  var result = ApiChangeType.minor;
  for (var change in apiChanges) {
    result = result.atLeast(change.type);
    if (verbose) {
      print(
        "[${change.type.name}] change in '${change.component}': ${change.description}",
      );
    }
  }
  print(verbose ? 'Final result: ${result.name}' : result.name);
}
