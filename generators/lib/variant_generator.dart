import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

class VariantBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      '.dart': ['.variants.g.dart'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process files in lib/src
    if (!buildStep.inputId.path.startsWith('lib/src/')) {
      return;
    }

    try {
      final library = await buildStep.resolver.libraryFor(buildStep.inputId);
      final classesInLibrary = LibraryReader(library).classes;

      for (final classItem in classesInLibrary) {
        // Check for @Variants annotation
        final variantsAnnotation = _getVariantsAnnotation(classItem);
        if (variantsAnnotation == null) {
          continue;
        }

        // Parse variants from annotation
        final variants = _parseVariants(variantsAnnotation);
        if (variants.isEmpty) {
          continue;
        }

        // Generate private helpers and public redirects (freezed pattern)
        final generatedItems = _generateExtension(classItem, variants);

        final outputLibrary = Library(
          (libraryBuilder) => libraryBuilder
            ..body.addAll([
              Code("part of '${buildStep.inputId.path.split('/').last}'; "),
              ...generatedItems,
            ]),
        );

        final emitter = DartEmitter.scoped();
        final output =
            DartFormatter().format('${outputLibrary.accept(emitter)}');

        await buildStep.writeAsString(
          buildStep.inputId.changeExtension('.variants.g.dart'),
          output,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error analyzing file ${buildStep.inputId.path}: $e');
    }
  }

  ConstantReader? _getVariantsAnnotation(ClassElement classElement) {
    for (final annotation in classElement.metadata) {
      final reader = ConstantReader(annotation.computeConstantValue());
      if (reader.objectValue.type?.element?.name == 'Variants') {
        return reader;
      }
    }
    return null;
  }

  List<_VariantData> _parseVariants(ConstantReader annotation) {
    final List<_VariantData> variants = [];

    final variantsList = annotation.read('variants').listValue;
    for (final variantConstant in variantsList) {
      final variantReader = ConstantReader(variantConstant);
      final name = variantReader.read('name').stringValue;
      final defaults = variantReader.read('defaults').mapValue;

      final Map<String, String> defaultsMap = {};
      for (final entry in defaults.entries) {
        final keyStr = entry.key?.toStringValue();
        final valueStr = entry.value?.toStringValue();
        if (keyStr != null && valueStr != null) {
          defaultsMap[keyStr] = valueStr;
        }
      }

      // Detect if context is required by checking if any default contains "context"
      final requiresContext = defaultsMap.values.any(
        (value) => value.contains('context'),
      );

      variants.add(_VariantData(
        name: name,
        requiresContext: requiresContext,
        defaults: defaultsMap,
      ));
    }

    return variants;
  }

  List<Spec> _generateExtension(
    ClassElement classItem,
    List<_VariantData> variants,
  ) {
    if (!classItem.name.endsWith("Widget")) {
      return [];
    }

    final publicClassName =
        classItem.name.substring(0, classItem.name.length - "Widget".length);
    final privateWidgetName = classItem.name;

    // Get constructor and fields from private widget
    final constructor = classItem.constructors.first;
    final positionalParams =
        constructor.parameters.where((p) => p.isPositional).toList();
    final optionalParams =
        constructor.parameters.where((p) => !p.isPositional).toList();

    // Get all fields from the class (excluding inherited fields from StatelessWidget/StatefulWidget)
    final fields =
        classItem.fields.where((f) => !f.isStatic && f.isFinal).toList();

    final componentClass = Class((builder) {
      builder.name = publicClassName;
      builder.extend = const Reference("StatelessWidget");

      // 1. Generate final fields
      for (final field in fields) {
        builder.fields.add(Field((fb) => fb
          ..name = field.name
          ..type = refer(field.type.toString())
          ..modifier = FieldModifier.final$));
      }

      // 2. Generate regular constructor
      builder.constructors.add(Constructor((cb) {
        cb.constant = true;

        // Add positional parameters using this.fieldName syntax
        cb.requiredParameters.addAll(
          positionalParams.map((p) => Parameter((pb) => pb
            ..name = p.name
            ..toThis = true)),
        );

        // Add optional parameters (named) using this.fieldName syntax
        cb.optionalParameters.addAll(
          optionalParams.map((p) => Parameter((pb) => pb
            ..name = p.name
            ..toThis = p.name != "key"
            ..toSuper = p.name == "key"
            ..named = p.isNamed
            ..required = p.isRequired
            ..defaultTo =
                p.defaultValueCode != null ? Code(p.defaultValueCode!) : null)),
        );
      }));

      // 3. Generate factory constructors for variants (or static methods for context-dependent)
      for (final variant in variants) {
        // Add Key parameter if not already present
        final hasKeyParam = optionalParams.any((p) => p.name == 'key') ||
            positionalParams.any((p) => p.name == 'key');

        if (variant.requiresContext) {
          // Generate static method that returns Widget (can return Builder)
          final staticMethod = Method((mb) {
            mb.name = variant.name;
            mb.static = true;
            mb.returns = refer('Widget');

            // Add all parameters (same as regular constructor)
            mb.requiredParameters.addAll(
              positionalParams.map((p) => Parameter((pb) => pb
                ..name = p.name
                ..type = refer(p.type.toString())
                ..required = !p.isOptional)),
            );

            mb.optionalParameters.addAll(
              optionalParams.map((p) => Parameter((pb) => pb
                ..name = p.name
                ..named = p.isNamed
                ..required = p.isRequired
                ..type = refer(p.type.toString())
                ..defaultTo = p.defaultValueCode != null
                    ? Code(p.defaultValueCode!)
                    : null)),
            );

            if (!hasKeyParam) {
              mb.optionalParameters.add(
                Parameter((pb) => pb
                  ..name = 'key'
                  ..named = true
                  ..type = refer('Key?')
                  ..required = false),
              );
            }

            // Build argument strings for code generation
            final namedArgsList = <String>[];

            // Build named arguments, applying variant defaults
            for (final param in optionalParams) {
              final defaultValue = variant.defaults[param.name];
              if (defaultValue != null) {
                // Default contains context - will be evaluated in Builder scope
                namedArgsList.add('${param.name}: $defaultValue');
              } else {
                namedArgsList.add('${param.name}: ${param.name}');
              }
            }

            // Add key if needed
            if (!hasKeyParam) {
              namedArgsList.add('key: key');
            }

            // Create the Builder that wraps the public class instantiation
            final bodyLines = <Code>[
              const Code('return Builder('),
              Code('  builder: (BuildContext context) => $publicClassName('),
            ];

            // Add positional arguments first
            for (final param in positionalParams) {
              bodyLines.add(Code('      ${param.name},'));
            }

            // Add named arguments
            for (final arg in namedArgsList) {
              bodyLines.add(Code('      $arg,'));
            }

            bodyLines.addAll([
              const Code('    ),'),
              const Code('  );'),
            ]);

            mb.body = Block.of(bodyLines);
          });

          builder.methods.add(staticMethod);
        } else {
          // Generate factory constructor for non-context variants
          final factoryConstructor = Constructor((cb) {
            cb.factory = true;
            cb.name = variant.name;

            // Add all parameters (same as regular constructor)
            cb.requiredParameters.addAll(
              positionalParams.map((p) => Parameter((pb) => pb
                ..name = p.name
                ..type = refer(p.type.toString()))),
            );

            cb.optionalParameters.addAll(
              optionalParams.map((p) => Parameter((pb) => pb
                ..name = p.name
                ..named = p.isNamed
                ..required = p.isRequired
                ..type = refer(p.type.toString())
                ..defaultTo = p.defaultValueCode != null
                    ? Code(p.defaultValueCode!)
                    : null)),
            );

            if (!hasKeyParam) {
              cb.optionalParameters.add(
                Parameter((pb) => pb
                  ..name = 'key'
                  ..named = true
                  ..toSuper = true
                  ..required = false),
              );
            }

            // Direct instantiation with literal defaults
            final positionalArgs =
                positionalParams.map((p) => refer(p.name)).toList();
            final namedArgs = <String, Expression>{};

            for (final param in optionalParams) {
              final defaultValue = variant.defaults[param.name];
              if (defaultValue != null) {
                namedArgs[param.name] = CodeExpression(Code(defaultValue));
              } else {
                namedArgs[param.name] = refer(param.name);
              }
            }

            if (!hasKeyParam) {
              namedArgs['key'] = refer('key');
            }

            cb.body = refer(publicClassName)
                .newInstance(positionalArgs, namedArgs)
                .returned
                .statement;
          });

          builder.constructors.add(factoryConstructor);
        }
      }

      // 4. Generate build method
      builder.methods.add(Method((mb) {
        mb.annotations.add(refer('override'));
        mb.name = 'build';
        mb.returns = refer('Widget');
        mb.requiredParameters.add(
          Parameter((pb) => pb
            ..name = 'context'
            ..type = refer('BuildContext')),
        );

        // Build arguments for private widget instantiation
        final positionalArgs =
            positionalParams.map((p) => refer(p.name)).toList();
        final namedArgs = <String, Expression>{};

        for (final param in optionalParams) {
          namedArgs[param.name] = refer(param.name);
        }

        // Add key if present
        final hasKeyParam = optionalParams.any((p) => p.name == 'key') ||
            positionalParams.any((p) => p.name == 'key');
        if (hasKeyParam) {
          ParameterElement keyParam;
          final keyInOptional =
              optionalParams.where((p) => p.name == 'key').toList();
          if (keyInOptional.isNotEmpty) {
            keyParam = keyInOptional.first;
          } else {
            keyParam = positionalParams.where((p) => p.name == 'key').first;
          }
          namedArgs['key'] = refer(keyParam.name);
        } else {
          namedArgs['key'] = refer('key');
        }

        mb.body = refer(privateWidgetName)
            .newInstance(positionalArgs, namedArgs)
            .returned
            .statement;
      }));
    });

    return [componentClass];
  }
}

class _VariantData {
  final String name;
  final bool requiresContext;
  final Map<String, String> defaults;

  _VariantData({
    required this.name,
    required this.requiresContext,
    required this.defaults,
  });
}

Builder variantGenerator(BuilderOptions _) => VariantBuilder();
