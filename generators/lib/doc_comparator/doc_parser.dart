import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:liquid_generators/doc_items.dart';

/// Helper extension to extract properties from a `CollectionElement`.
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

  /// Helper method to extract a property from a `CollectionElement`.
  T get<T>(String name) {
    final property = properties[name];
    if ((T == List<String>) && property is ListLiteral) {
      return property.elements
          .map((e) => (e as StringLiteral).stringValue ?? '')
          .toList() as T;
    }
    return property as T;
  }

  /// Helper method to extract the value of an expression, if it is of a simple
  /// type.
  dynamic _extractValue(Expression expr) {
    if (expr is SimpleStringLiteral) {
      return expr.value;
    } else if (expr is BooleanLiteral) {
      return expr.value;
    }
    // if needed, we can add more types here
    return expr;
  }
}

/// Parse a `LdDocComponent` from a `MethodInvocation` AST node.
DocComponent parseLdDocComponent(MethodInvocation docExpr) {
  // Extract the component data
  final name = docExpr.get<String>('name');
  final isNullSafe = docExpr.get<bool?>('isNullSafe') ?? false;
  final description = docExpr.get<String>('description');
  final methods = docExpr.get<List<String>>('methods');

  // Parse constructors
  final constructors = <Constructor>[];
  final constructorsArg = docExpr.get<ListLiteral>('constructors');
  for (final constrExpr in constructorsArg.elements) {
    final signature = <Parameter>[];
    final params = constrExpr.get<ListLiteral?>('signature');
    for (CollectionElement param in params?.elements ?? []) {
      signature.add(Parameter(
        name: param.get<String>('name'),
        type: param.get<String>('type'),
        description: param.get<String>('description'),
        named: param.get<bool?>('named') ?? false,
        required: param.get<bool?>('required') ?? false,
      ));
    }
    constructors.add(Constructor(
      name: constrExpr.get<String>('name'),
      signature: signature,
      features: [],
    ));
  }

  // Parse properties
  final properties = <Property>[];
  final propertiesArg = docExpr.get<ListLiteral>('properties');
  for (final propExpr in propertiesArg.elements) {
    properties.add(Property(
      name: propExpr.get<String>('name'),
      type: propExpr.get<String>('type'),
      description: propExpr.get<String>('description'),
      features: propExpr.get<List<String>>('features'),
    ));
  }

  return DocComponent(
    name: name,
    isNullSafe: isNullSafe,
    description: description,
    constructors: constructors,
    properties: properties,
    methods: methods,
  );
}

/// Parses the content of a file containing `LdDocComponent` definitions.
List<DocComponent> parseLdDocComponentsFile(String fileContent) {
  final unit = parseString(content: fileContent).unit;
  final components = <DocComponent>[];

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
