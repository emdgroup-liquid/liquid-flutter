import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:liquid_generators/variants.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

class VariantBuilder implements Builder {
  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'variants.g.dart'),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['variants.g.dart'],
    };
  }

  String joinCamelCase(String a, String b) {
    return a + b[0].toUpperCase() + b.substring(1);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final directAssets =
        buildStep.findAssets(Glob('lib/src/*.dart', recursive: true));

    final subDirAssets =
        buildStep.findAssets(Glob('lib/src/**/*.dart', recursive: true));

    final assets = [
      ...await directAssets.toList(),
      ...await subDirAssets.toList()
    ];

    List<Class> fields = [];

    for (final input in assets) {
      try {
        final library = await buildStep.resolver.libraryFor(input);
        final classesInLibrary = LibraryReader(library).classes;

        for (final classItem in classesInLibrary) {
          if (!variants.containsKey(classItem.name)) {
            continue;
          }

          final variantsForClass = variants[classItem.name]!;

          for (final variant in variantsForClass) {
            final superAsignments = classItem.constructors.first.parameters
                .where((element) => element.isPositional)
                .map((e) => e.name)
                .join(", ");

            final optionalSuperAssignments = classItem
                .constructors.first.parameters
                .where((element) => !element.isPositional)
                .map((e) => "${e.name}: ${variant.defaults[e.name] ?? e.name}")
                .join(", ");

            fields.add(Class((classBuilder) => classBuilder
              ..extend = refer(classItem.name)
              ..constructors
                  .add(Constructor((constructorBuilder) => constructorBuilder
                    ..constant = classItem.constructors.first.isConst &&
                        !variant.requireContext
                    ..requiredParameters.addAll(classItem
                        .constructors.first.parameters
                        .where((element) => element.isPositional)
                        .map((e) =>
                            Parameter((parameterBuilder) => parameterBuilder
                              ..name = e.name
                              ..type = refer(e.type.toString())))
                        .toList())
                    ..optionalParameters.addAll(classItem
                        .constructors.first.parameters
                        .where((element) => !element.isPositional)
                        .map((e) =>
                            Parameter((parameterBuilder) => parameterBuilder
                              ..name = e.name
                              ..named = e.isNamed
                              ..defaultTo = e.defaultValueCode != null
                                  ? Code(e.defaultValueCode!)
                                  : null
                              ..required = e.isRequired
                              ..type = refer(e.type.toString())))
                        .toList())
                    ..initializers.add(Code(
                        "super($superAsignments${superAsignments.isNotEmpty ? "," : ""}$optionalSuperAssignments)"))
                    ..optionalParameters.addAll([
                      if (variant.requireContext)
                        Parameter((parameterBuilder) => parameterBuilder
                          ..name = "context"
                          ..named = true
                          ..required = true
                          ..type = refer("BuildContext"))
                    ])))
              ..name = joinCamelCase(classItem.name, variant.name)));
          }
        }
      } catch (e) {
        print('Error analyzing file ${input.path}: $e');
      }
    }

    final outputLibrary = Library(
      (libraryBuilder) => libraryBuilder
        ..body.addAll([
          const Code("import 'package:flutter/material.dart';"),
          const Code("import 'package:liquid_flutter/liquid_flutter.dart';"),
          ...fields
        ]),
    );

    final emitter = DartEmitter.scoped();
    final output = DartFormatter().format('${outputLibrary.accept(emitter)}');

    await buildStep.writeAsString(_allFileOutput(buildStep), output);
  }
}

Builder variantGenerator(BuilderOptions _) => VariantBuilder();
