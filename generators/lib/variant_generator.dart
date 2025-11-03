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

  bool _hasContextConfigurableAnnotation(ParameterElement parameter) {
    for (final annotation in parameter.metadata) {
      try {
        final reader = ConstantReader(annotation.computeConstantValue());
        if (reader.objectValue.type?.element?.name == 'ContextConfigurable') {
          return true;
        }
      } catch (e) {
        // Ignore errors when reading annotation
      }
    }
    return false;
  }

  /// Checks if a type string represents a nullable type
  bool _isNullableType(String typeString) {
    return typeString.trim().endsWith('?');
  }

  /// Makes a type string nullable by appending '?' if not already nullable
  String _makeNullableType(String typeString) {
    if (_isNullableType(typeString)) {
      return typeString;
    }
    return '$typeString?';
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

    // Detect context-configurable parameters
    final contextConfigurableParams = <ParameterElement>[];
    for (final param in optionalParams) {
      if (_hasContextConfigurableAnnotation(param)) {
        contextConfigurableParams.add(param);
      }
    }

    // Get all fields from the class (excluding inherited fields from StatelessWidget/StatefulWidget)
    final fields =
        classItem.fields.where((f) => !f.isStatic && f.isFinal).toList();

    final generatedItems = <Spec>[];

    // Generate config class and provider if there are context-configurable parameters
    if (contextConfigurableParams.isNotEmpty) {
      final configClassName = '${publicClassName}Config';
      final configClass = _generateConfigClass(
          configClassName, contextConfigurableParams, optionalParams);
      final providerClass = _generateProviderClass(
          configClassName, publicClassName, contextConfigurableParams);
      generatedItems.addAll([configClass, providerClass]);
    }

    final componentClass = Class((builder) {
      builder.name = publicClassName;
      builder.extend = const Reference("StatelessWidget");

      // 1. Generate final fields
      for (final field in fields) {
        // Find matching parameter to check if it's context-configurable
        ParameterElement? matchingParam;
        try {
          matchingParam =
              optionalParams.firstWhere((p) => p.name == field.name);
        } catch (_) {
          try {
            matchingParam =
                positionalParams.firstWhere((p) => p.name == field.name);
          } catch (_) {
            matchingParam = null;
          }
        }

        final isContextConfigurable = matchingParam != null &&
            _hasContextConfigurableAnnotation(matchingParam);
        final hasDefaultValue = matchingParam?.defaultValueCode != null;

        // Make field nullable if it's context-configurable with a default value
        final fieldType = isContextConfigurable && hasDefaultValue
            ? _makeNullableType(field.type.toString())
            : field.type.toString();

        builder.fields.add(Field((fb) => fb
          ..name = field.name
          ..type = refer(fieldType)
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
          optionalParams.map((p) {
            final isContextConfigurable = contextConfigurableParams.contains(p);
            final hasDefaultValue = p.defaultValueCode != null;

            // For context-configurable params with defaults, skip the default
            // and make the type nullable so context config can be checked
            final shouldSkipDefault = isContextConfigurable && hasDefaultValue;
            final paramType = shouldSkipDefault
                ? _makeNullableType(p.type.toString())
                : p.type.toString();

            return Parameter((pb) => pb
              ..name = p.name
              ..toThis = p.name != "key"
              ..toSuper = p.name == "key"
              ..named = p.isNamed
              ..required = p.isRequired
              //..type = refer(paramType)
              ..defaultTo = shouldSkipDefault
                  ? null
                  : (p.defaultValueCode != null
                      ? Code(p.defaultValueCode!)
                      : null));
          }),
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
              optionalParams.map((p) {
                final isContextConfigurable =
                    contextConfigurableParams.contains(p);
                final hasDefaultValue = p.defaultValueCode != null;

                // For context-configurable params with defaults, skip the default
                // and make the type nullable so context config can be checked
                final shouldSkipDefault =
                    isContextConfigurable && hasDefaultValue;
                final paramType = shouldSkipDefault
                    ? _makeNullableType(p.type.toString())
                    : p.type.toString();

                return Parameter((pb) => pb
                  ..name = p.name
                  ..named = p.isNamed
                  ..required = p.isRequired
                  ..type = refer(paramType)
                  ..defaultTo = shouldSkipDefault
                      ? null
                      : (p.defaultValueCode != null
                          ? Code(p.defaultValueCode!)
                          : null));
              }),
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
              optionalParams.map((p) {
                final isContextConfigurable =
                    contextConfigurableParams.contains(p);
                final hasDefaultValue = p.defaultValueCode != null;

                // For context-configurable params with defaults, skip the default
                // and make the type nullable so context config can be checked
                final shouldSkipDefault =
                    isContextConfigurable && hasDefaultValue;
                final paramType = shouldSkipDefault
                    ? _makeNullableType(p.type.toString())
                    : p.type.toString();

                return Parameter((pb) => pb
                  ..name = p.name
                  ..named = p.isNamed
                  ..required = p.isRequired
                  ..type = refer(paramType)
                  ..defaultTo = shouldSkipDefault
                      ? null
                      : (p.defaultValueCode != null
                          ? Code(p.defaultValueCode!)
                          : null));
              }),
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

        // Get config class name if there are context-configurable parameters
        final configClassName = contextConfigurableParams.isNotEmpty
            ? '${publicClassName}Config'
            : null;

        // Build the method body as a block of statements
        final bodyStatements = <Code>[];

        // If there are context-configurable parameters, read the provider once
        if (configClassName != null) {
          bodyStatements.add(
            Code(
                'final config = Provider.of<$configClassName?>(context, listen: false);'),
          );
        }

        for (final param in optionalParams.where((p) => p.name != 'key')) {
          final isContextConfigurable =
              contextConfigurableParams.contains(param);
          if (isContextConfigurable && configClassName != null) {
            // Generate: param ?? config?.param ?? default
            final providerAccess = refer('config').nullSafeProperty(param.name);

            if (param.defaultValueCode != null) {
              namedArgs[param.name] = refer(param.name)
                  .ifNullThen(providerAccess)
                  .ifNullThen(CodeExpression(Code(param.defaultValueCode!)));
            } else {
              namedArgs[param.name] =
                  refer(param.name).ifNullThen(providerAccess);
            }
          } else {
            namedArgs[param.name] = refer(param.name);
          }
        }

        // Add the return statement
        bodyStatements.add(
          refer(privateWidgetName)
              .newInstance(positionalArgs, namedArgs)
              .returned
              .statement,
        );

        mb.body = Block.of(bodyStatements);
      }));
    });

    generatedItems.add(componentClass);
    return generatedItems;
  }

  Class _generateConfigClass(
    String configClassName,
    List<ParameterElement> contextConfigurableParams,
    List<ParameterElement> allOptionalParams,
  ) {
    return Class((builder) {
      builder.name = configClassName;

      // Generate fields for each context-configurable parameter
      // All fields must be nullable so we can detect when they weren't provided
      for (final param in contextConfigurableParams) {
        final nullableType = _makeNullableType(param.type.toString());
        builder.fields.add(Field((fb) => fb
          ..name = param.name
          ..type = refer(nullableType)
          ..modifier = FieldModifier.final$));
      }

      // Generate constructor
      builder.constructors.add(Constructor((cb) {
        cb.constant = true;
        for (final param in contextConfigurableParams) {
          cb.optionalParameters.add(Parameter((pb) => pb
            ..name = param.name
            ..named = true
            ..required = false
            ..toThis = true
            // No defaults - fields should be null if not provided
            ..defaultTo = null));
        }
      }));
    });
  }

  Class _generateProviderClass(
    String configClassName,
    String publicClassName,
    List<ParameterElement> contextConfigurableParams,
  ) {
    return Class((builder) {
      builder.name = '${publicClassName}ConfigProvider';
      builder.extend = const Reference('StatelessWidget');

      // Field for config
      builder.fields.add(Field((fb) => fb
        ..name = 'config'
        ..type = refer(configClassName)
        ..modifier = FieldModifier.final$));

      // Field for child
      builder.fields.add(Field((fb) => fb
        ..name = 'child'
        ..type = const Reference('Widget')
        ..modifier = FieldModifier.final$));

      // Constructor
      builder.constructors.add(Constructor((cb) {
        cb.constant = true;
        cb.requiredParameters.add(Parameter((pb) => pb
          ..name = 'config'
          ..toThis = true));
        cb.requiredParameters.add(Parameter((pb) => pb
          ..name = 'child'
          ..toThis = true));
        cb.optionalParameters.add(Parameter((pb) => pb
          ..name = 'key'
          ..named = true
          ..toSuper = true
          ..required = false));
      }));

      // Build method
      builder.methods.add(Method((mb) {
        mb.annotations.add(refer('override'));
        mb.name = 'build';
        mb.returns = const Reference('Widget');
        mb.requiredParameters.add(Parameter((pb) => pb
          ..name = 'context'
          ..type = const Reference('BuildContext')));

        // Build method body: check for parent config and merge
        final bodyStatements = <Code>[];

        // Read parent config
        bodyStatements.add(
          Code(
              'final parentConfig = Provider.of<$configClassName?>(context, listen: false);'),
        );

        // Generate merge arguments for each context-configurable parameter
        final mergeArgs = <String>[];
        for (final param in contextConfigurableParams) {
          mergeArgs.add(
              '${param.name}: config.${param.name} ?? parentConfig.${param.name}');
        }

        // Determine merged config
        if (mergeArgs.isNotEmpty) {
          bodyStatements.add(
            Code('final mergedConfig = parentConfig != null ? $configClassName('
                '${mergeArgs.join(',\n        ')}'
                ') : config;'),
          );
        } else {
          bodyStatements.add(
            Code('final mergedConfig = config;'),
          );
        }

        // Provide merged config
        bodyStatements.add(
          Code('return Provider<$configClassName>.value('
              'value: mergedConfig, '
              'child: child,'
              ');'),
        );

        mb.body = Block.of(bodyStatements);
      }));
    });
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
