// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
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
        final output = DartFormatter(
          languageVersion: Version.parse("3.5.0"),
        ).format('${outputLibrary.accept(emitter)}');

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

  /// Returns true if the given constructor is annotated with @ContextConfigurable().
  /// When the constructor itself carries the annotation, every parameter is treated
  /// as context-configurable without needing per-parameter annotations.
  bool _constructorHasContextConfigurableAnnotation(
      ConstructorElement constructor) {
    for (final annotation in constructor.metadata) {
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

  /// Extracts type parameters from a class element and converts them to TypeReference objects
  List<TypeReference> _extractTypeParameters(ClassElement classElement) {
    final typeParams = <TypeReference>[];
    for (final typeParam in classElement.typeParameters) {
      final typeRef = TypeReference((tr) {
        tr.symbol = typeParam.name;
        if (typeParam.bound != null) {
          // Convert the bound type to a TypeReference
          final boundType = typeParam.bound!;
          tr.bound = _convertDartTypeToReference(boundType);
        }
      });
      typeParams.add(typeRef);
    }
    return typeParams;
  }

  /// Converts a DartType to a TypeReference for code_builder
  Reference _convertDartTypeToReference(DartType dartType) {
    if (dartType is TypeParameterType) {
      // It's a type parameter reference
      return refer(dartType.element.name);
    } else if (dartType is InterfaceType) {
      // It's a concrete type, possibly with type arguments
      final typeArgs = dartType.typeArguments;
      if (typeArgs.isEmpty) {
        return refer(dartType.element.name);
      } else {
        // Handle generic types like Identifiable<IdType>
        final typeRef = TypeReference((tr) {
          tr.symbol = dartType.element.name;
          tr.types.addAll(
            typeArgs.map((arg) => _convertDartTypeToReference(arg)),
          );
        });
        return typeRef;
      }
    } else {
      // Fallback: use toString representation
      return refer(dartType.toString());
    }
  }

  /// Checks if the config class needs type parameters by checking if any
  /// context-configurable parameter types reference generic type parameters
  bool _configNeedsTypeParameters(
    List<ParameterElement> contextConfigurableParams,
    List<TypeReference> typeParameters,
  ) {
    if (typeParameters.isEmpty) {
      return false;
    }

    // Get the names of all type parameters
    final typeParamNames = typeParameters.map((tp) => tp.symbol).toSet();

    // Check if any parameter type references a generic type parameter
    for (final param in contextConfigurableParams) {
      final typeString = param.type.toString();
      // Check if the type string contains any of the type parameter names
      // This is a simple check - we look for the type parameter name as a word
      for (final typeParamName in typeParamNames) {
        // Use regex to match whole words to avoid false positives
        final regex = RegExp(r'\b' + RegExp.escape(typeParamName) + r'\b');
        if (regex.hasMatch(typeString)) {
          return true;
        }
      }
    }

    return false;
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

    final publicClassName = classItem.name
        .substring(0, classItem.name.length - "Widget".length)
        .removePrefix("_");

    final privateWidgetName = classItem.name;

    // Extract type parameters from the class
    final typeParameters = _extractTypeParameters(classItem);

    // Get constructor and fields from private widget
    final constructor = classItem.constructors.first;
    final positionalParams =
        constructor.parameters.where((p) => p.isPositional).toList();
    final optionalParams = constructor.parameters
        .where((p) => !p.isPositional)
        .where((p) => p.name != 'key')
        .toList();

    // Detect context-configurable parameters.
    // If the constructor itself is annotated with @ContextConfigurable(), treat
    // all optional parameters as context-configurable without requiring
    // per-parameter annotations.
    final constructorIsConfigurable =
        _constructorHasContextConfigurableAnnotation(constructor);
    final contextConfigurableParams = <ParameterElement>[];
    for (final param in optionalParams) {
      if (constructorIsConfigurable ||
          _hasContextConfigurableAnnotation(param)) {
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
      // Check if config class needs type parameters
      final configNeedsTypeParams = _configNeedsTypeParameters(
        contextConfigurableParams,
        typeParameters,
      );
      final configClass = _generateConfigClass(
        configClassName,
        contextConfigurableParams,
        optionalParams,
        configNeedsTypeParams ? typeParameters : [],
      );
      final providerClass = _generateProviderClass(
        configClassName,
        publicClassName,
        contextConfigurableParams,
        configNeedsTypeParams ? typeParameters : [],
      );
      generatedItems.addAll([configClass, providerClass]);
    }

    final componentClass = Class((builder) {
      builder.name = publicClassName;
      builder.extend = const Reference("StatelessWidget");
      // Add type parameters if the class has them
      if (typeParameters.isNotEmpty) {
        builder.types.addAll(typeParameters);
      }

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
            contextConfigurableParams.contains(matchingParam);

        String fieldType;

        if (isContextConfigurable) {
          fieldType = _makeNullableType(field.type.toString());
        } else {
          fieldType = field.type.toString();
        }

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

            return Parameter((pb) => pb
              ..name = p.name
              ..toThis = p.name != "key"
              ..toSuper = p.name == "key"
              ..named = p.isNamed
              ..required = !isContextConfigurable && p.isRequired
              //..type = refer(paramType)
              ..defaultTo = shouldSkipDefault
                  ? null
                  : (p.defaultValueCode != null
                      ? Code(p.defaultValueCode!)
                      : null));
          }),
        );

        cb.optionalParameters.add(
          Parameter(
            (pb) => pb
              ..name = 'key'
              ..named = true
              ..toSuper = true
              ..required = false,
          ),
        );
      }));

      // 3. Generate .fromConfig factory constructor if there are context-configurable params
      if (contextConfigurableParams.isNotEmpty) {
        final configClassName = '${publicClassName}Config';
        final fromConfigConstructor = Constructor((cb) {
          cb.factory = true;
          cb.name = 'fromConfig';

          // Add config as required named parameter
          final configType = typeParameters.isNotEmpty
              ? TypeReference((tr) {
                  tr.symbol = configClassName;
                  tr.types.addAll(
                    typeParameters.map((tp) => refer(tp.symbol)),
                  );
                })
              : refer(configClassName);
          cb.optionalParameters.add(Parameter((pb) => pb
            ..name = 'config'
            ..named = true
            ..required = true
            ..type = configType));

          cb.requiredParameters.addAll(
            positionalParams.map((p) => Parameter((pb) => pb
              ..name = p.name
              ..type = refer(p.type.toString()))),
          );

          cb.optionalParameters.addAll(
            optionalParams
                .where((p) => !contextConfigurableParams.contains(p))
                .map((p) => Parameter((pb) => pb
                  ..name = p.name
                  ..named = p.isNamed
                  ..required = p.isRequired
                  ..type = refer(p.type.toString())
                  ..defaultTo = p.defaultValueCode != null
                      ? Code(p.defaultValueCode!)
                      : null)),
          );

          cb.optionalParameters.add(
            Parameter((pb) => pb
              ..name = 'key'
              ..named = true
              ..type = refer('Key?')
              ..toSuper = false
              ..required = false),
          );

          // Build instantiation: positional params pass through,
          // configurable params come from config, non-configurable pass through
          final positionalArgs =
              positionalParams.map((p) => refer(p.name)).toList();
          final namedArgs = _buildOrderedWidgetNamedArgs(
            optionalParams: optionalParams,
            variant: null,
          );

          // Override configurable params to read from config
          for (final param in contextConfigurableParams) {
            namedArgs[param.name] =
                refer('config').property(param.name);
          }

          // Create reference with type parameters if needed
          final classReference = typeParameters.isNotEmpty
              ? TypeReference((tr) {
                  tr.symbol = publicClassName;
                  tr.types.addAll(
                    typeParameters.map((tp) => refer(tp.symbol)),
                  );
                })
              : refer(publicClassName);

          cb.body = classReference
              .newInstance(positionalArgs, namedArgs)
              .returned
              .statement;
        });

        builder.constructors.add(fromConfigConstructor);
      }

      // 4. Generate factory constructors for variants (or static methods for context-dependent)
      for (final variant in variants) {
        if (variant.requiresContext) {
          // Generate static method that returns Widget (can return Builder)
          final staticMethod = Method((mb) {
            mb.name = variant.name;
            mb.static = true;
            mb.returns = refer('Widget');
            // Add type parameters if the class has them
            if (typeParameters.isNotEmpty) {
              mb.types.addAll(typeParameters);
            }

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

            mb.optionalParameters.add(
              Parameter((pb) => pb
                ..name = 'key'
                ..named = true
                ..type = refer('Key?')
                ..required = false),
            );

            // Build argument strings for code generation
            final namedArgsList = _buildOrderedWidgetNamedArgLines(
              optionalParams: optionalParams,
              variant: variant,
            );

            // Create the Builder that wraps the public class instantiation
            // Build type arguments string if needed
            final typeArgsString = typeParameters.isNotEmpty
                ? '<${typeParameters.map((tp) => tp.symbol).join(', ')}>'
                : '';
            final bodyLines = <Code>[
              const Code('return Builder('),
              Code(
                  '  builder: (BuildContext context) => $publicClassName$typeArgsString('),
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
          // Note: Type parameters belong to the class, not the constructor
          // The class reference will include them when instantiating
          final factoryConstructor = Constructor((cb) {
            cb.factory = true;
            cb.name = variant.name;

            // Add all parameters (same as regular constructor), but skip
            // positional params that are fully covered by variant defaults.
            cb.requiredParameters.addAll(
              positionalParams
                  .where((p) => !variant.defaults.containsKey(p.name))
                  .map((p) => Parameter((pb) => pb
                    ..name = p.name
                    ..type = refer(p.type.toString()))),
            );

            cb.optionalParameters.addAll(
              optionalParams
                  .where((p) => !variant.defaults.containsKey(p.name))
                  .map((p) {
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

            cb.optionalParameters.add(
              Parameter(
                (pb) => pb
                  ..name = 'key'
                  ..named = true
                  ..type = refer('Key?')
                  ..toSuper = false
                  ..required = false,
              ),
            );

            // Direct instantiation with literal defaults
            final positionalArgs =
                positionalParams.map((p) => refer(p.name)).toList();
            final namedArgs = _buildOrderedWidgetNamedArgs(
              optionalParams: optionalParams,
              variant: variant,
            );

            // Create reference with type parameters if needed
            // When using type parameters as type arguments, we only use the names, not the bounds
            final classReference = typeParameters.isNotEmpty
                ? TypeReference((tr) {
                    tr.symbol = publicClassName;
                    // Add just the type parameter names as type arguments (bounds are only in declarations)
                    tr.types.addAll(
                      typeParameters.map((tp) => refer(tp.symbol)),
                    );
                  })
                : refer(publicClassName);

            cb.body = classReference
                .newInstance(positionalArgs, namedArgs)
                .returned
                .statement;
          });

          builder.constructors.add(factoryConstructor);
        }
      }

      // 5. Generate build method
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
          // Check if config needs type parameters
          final configNeedsTypeParams = _configNeedsTypeParameters(
            contextConfigurableParams,
            typeParameters,
          );
          final typeArgsString =
              configNeedsTypeParams && typeParameters.isNotEmpty
                  ? '<${typeParameters.map((tp) => tp.symbol).join(', ')}>'
                  : '';
          bodyStatements.add(
            Code(
                'final config = Provider.of<$configClassName$typeArgsString?>(context, listen: true);'),
          );
        }

        for (final param in optionalParams) {
          if (param.name == 'child') {
            continue;
          }
          final isContextConfigurable =
              contextConfigurableParams.contains(param);
          if (isContextConfigurable && configClassName != null) {
            // Generate: param ?? config?.param ?? default

            if (param.defaultValueCode == null && param.isRequired) {
              if (param.defaultValueCode == null) {
                bodyStatements.add(Code(
                    'assert(config?.${param.name} != null || ${param.name} != null, "Parameter ${param.name} is required and it was neither provided nor directly passed");'));
              }
            }

            if (param.defaultValueCode != null) {
              final providerAccessSafe =
                  refer('config').nullSafeProperty(param.name);

              namedArgs[param.name] = refer(param.name)
                  .ifNullThen(providerAccessSafe)
                  .ifNullThen(CodeExpression(Code(param.defaultValueCode!)));
            } else {
              late Expression providerAccess;
              if (param.isRequired) {
                providerAccess = refer('config')
                    .nullChecked
                    .property(param.name)
                    .nullChecked;
              } else {
                providerAccess = refer('config').nullSafeProperty(param.name);
              }
              namedArgs[param.name] =
                  refer(param.name).ifNullThen(providerAccess);
            }
          } else {
            namedArgs[param.name] = refer(param.name);
          }
        }

        final childParam = optionalParams
            .where((param) => param.name == 'child')
            .cast<ParameterElement?>()
            .firstOrNull;
        if (childParam != null) {
          final param = childParam;
          final isContextConfigurable =
              contextConfigurableParams.contains(param);
          if (isContextConfigurable && configClassName != null) {
            if (param.defaultValueCode == null && param.isRequired) {
              bodyStatements.add(Code(
                  'assert(config?.${param.name} != null || ${param.name} != null, "Parameter ${param.name} is required and it was neither provided nor directly passed");'));
            }

            if (param.defaultValueCode != null) {
              final providerAccessSafe =
                  refer('config').nullSafeProperty(param.name);

              namedArgs[param.name] = refer(param.name)
                  .ifNullThen(providerAccessSafe)
                  .ifNullThen(CodeExpression(Code(param.defaultValueCode!)));
            } else {
              late Expression providerAccess;
              if (param.isRequired) {
                providerAccess = refer('config')
                    .nullChecked
                    .property(param.name)
                    .nullChecked;
              } else {
                providerAccess = refer('config').nullSafeProperty(param.name);
              }
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
    List<TypeReference> typeParameters,
  ) {
    return Class((builder) {
      builder.name = configClassName;
      // Add type parameters if needed
      if (typeParameters.isNotEmpty) {
        builder.types.addAll(typeParameters);
      }

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

      // Generate copyWith method
      builder.methods.add(Method((mb) {
        mb.name = 'copyWith';
        mb.returns = _configTypeReference(configClassName, typeParameters);

        for (final param in contextConfigurableParams) {
          mb.optionalParameters.add(Parameter((pb) => pb
            ..name = param.name
            ..named = true
            ..required = false
            ..type = refer(_makeNullableType(param.type.toString()))));
        }

        final namedArgs = <String, Expression>{};
        for (final param in contextConfigurableParams) {
          namedArgs[param.name] = refer(param.name)
              .ifNullThen(refer('this').property(param.name));
        }

        mb.body = _configTypeReference(configClassName, typeParameters)
            .newInstance(const [], namedArgs)
            .returned
            .statement;
      }));

      // Generate merge method
      builder.methods.add(Method((mb) {
        mb.name = 'merge';
        mb.returns = _configTypeReference(configClassName, typeParameters);

        mb.requiredParameters.add(Parameter((pb) => pb
          ..name = 'other'
          ..type = _configNullableTypeReference(configClassName, typeParameters)));

        final bodyStatements = <Code>[];
        bodyStatements.add(const Code('if (other == null) return this;'));

        final namedArgs = <String, Expression>{};
        for (final param in contextConfigurableParams) {
          namedArgs[param.name] = refer('other')
              .property(param.name)
              .ifNullThen(refer('this').property(param.name));
        }

        bodyStatements.add(
          _configTypeReference(configClassName, typeParameters)
              .newInstance(const [], namedArgs)
              .returned
              .statement,
        );

        mb.body = Block.of(bodyStatements);
      }));
    });
  }

  Class _generateProviderClass(
    String configClassName,
    String publicClassName,
    List<ParameterElement> contextConfigurableParams,
    List<TypeReference> typeParameters,
  ) {
    return Class((builder) {
      builder.name = '${publicClassName}ConfigProvider';
      builder.extend = const Reference('StatelessWidget');
      // Add type parameters if needed
      if (typeParameters.isNotEmpty) {
        builder.types.addAll(typeParameters);
      }

      // Field for config
      // When using type parameters as type arguments, we only use the names, not the bounds
      final configType = typeParameters.isNotEmpty
          ? TypeReference((tr) {
              tr.symbol = configClassName;
              // Add just the type parameter names as type arguments (bounds are only in declarations)
              tr.types.addAll(
                typeParameters.map((tp) => refer(tp.symbol)),
              );
            })
          : refer(configClassName);
      builder.fields.add(Field((fb) => fb
        ..name = 'config'
        ..type = configType
        ..modifier = FieldModifier.final$));

      // Field for child
      builder.fields.add(Field((fb) => fb
        ..name = 'child'
        ..type = const Reference('Widget')
        ..modifier = FieldModifier.final$));

      // When true, skip merging with an ancestor config provider.
      builder.fields.add(Field((fb) => fb
        ..name = 'ignoreParent'
        ..type = const Reference('bool')
        ..modifier = FieldModifier.final$));

      // Constructor
      builder.constructors.add(Constructor((cb) {
        cb.constant = true;
        cb.optionalParameters.addAll([
          Parameter((pb) => pb
            ..name = 'config'
            ..toThis = true
            ..named = true
            ..required = true),
          Parameter((pb) => pb
            ..name = 'child'
            ..toThis = true
            ..named = true
            ..required = true),
          Parameter((pb) => pb
            ..name = 'ignoreParent'
            ..toThis = true
            ..named = true
            ..required = false
            ..defaultTo = const Code('false')),
          Parameter((pb) => pb
            ..name = 'key'
            ..named = true
            ..toSuper = true
            ..required = false),
        ]);
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

        // Build type arguments string if needed
        final typeArgsString = typeParameters.isNotEmpty
            ? '<${typeParameters.map((tp) => tp.symbol).join(', ')}>'
            : '';

        bodyStatements.add(
          Code('if (ignoreParent) {'
              'return Provider<$configClassName$typeArgsString>.value('
              'value: config, '
              'child: child,'
              ');'
              '}'),
        );

        // Read parent config
        bodyStatements.add(
          Code(
              'final parentConfig = Provider.of<$configClassName$typeArgsString?>(context, listen: true);'),
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
            Code(
                'final mergedConfig = parentConfig != null ? $configClassName$typeArgsString('
                '${mergeArgs.join(',\n        ')}'
                ') : config;'),
          );
        } else {
          bodyStatements.add(
            const Code('final mergedConfig = config;'),
          );
        }

        // Provide merged config
        bodyStatements.add(
          Code('return Provider<$configClassName$typeArgsString>.value('
              'value: mergedConfig, '
              'child: child,'
              ');'),
        );

        mb.body = Block.of(bodyStatements);
      }));
    });
  }

  /// Builds a TypeReference for the config class, with type arguments if it has
  /// type parameters (e.g. `LdListConfig<T, IdType>`).
  TypeReference _configTypeReference(
    String configClassName,
    List<TypeReference> typeParameters,
  ) {
    if (typeParameters.isEmpty) {
      return TypeReference((tr) => tr.symbol = configClassName);
    }
    return TypeReference((tr) {
      tr.symbol = configClassName;
      tr.types.addAll(typeParameters.map((tp) => refer(tp.symbol)));
    });
  }

  /// Builds a nullable TypeReference for the config class, using a string-based
  /// approach to ensure the `?` suffix is emitted correctly even with generic
  /// type arguments.
  Reference _configNullableTypeReference(
    String configClassName,
    List<TypeReference> typeParameters,
  ) {
    final typeArgs = typeParameters.isNotEmpty
        ? '<${typeParameters.map((tp) => tp.symbol).join(', ')}>'
        : '';
    return refer('$configClassName$typeArgs?');
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

bool _isDeferredWidgetNamedArg(String name) => name == 'child' || name == 'key';

String _namedArgExpression(ParameterElement param, _VariantData? variant) {
  final defaultValue = variant?.defaults[param.name];
  if (defaultValue != null) {
    return '${param.name}: $defaultValue';
  }
  return '${param.name}: ${param.name}';
}

Map<String, Expression> _buildOrderedWidgetNamedArgs({
  required List<ParameterElement> optionalParams,
  required _VariantData? variant,
}) {
  final namedArgs = <String, Expression>{};

  for (final param in optionalParams) {
    if (_isDeferredWidgetNamedArg(param.name)) {
      continue;
    }
    final defaultValue = variant?.defaults[param.name];
    if (defaultValue != null) {
      namedArgs[param.name] = CodeExpression(Code(defaultValue));
    } else {
      namedArgs[param.name] = refer(param.name);
    }
  }

  namedArgs['key'] = refer('key');

  for (final param in optionalParams.where((param) => param.name == 'child')) {
    final defaultValue = variant?.defaults[param.name];
    if (defaultValue != null) {
      namedArgs[param.name] = CodeExpression(Code(defaultValue));
    } else {
      namedArgs[param.name] = refer(param.name);
    }
  }

  return namedArgs;
}

List<String> _buildOrderedWidgetNamedArgLines({
  required List<ParameterElement> optionalParams,
  required _VariantData variant,
}) {
  final namedArgsList = <String>[];

  for (final param in optionalParams) {
    if (_isDeferredWidgetNamedArg(param.name)) {
      continue;
    }
    namedArgsList.add(_namedArgExpression(param, variant));
  }

  namedArgsList.add('key: key');

  for (final param in optionalParams.where((param) => param.name == 'child')) {
    namedArgsList.add(_namedArgExpression(param, variant));
  }

  return namedArgsList;
}

Builder variantGenerator(BuilderOptions _) => VariantBuilder();

extension on String {
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }
}
