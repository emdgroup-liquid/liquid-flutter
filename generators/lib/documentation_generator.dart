import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';
import 'doc_items.dart' as out;

import 'package:path/path.dart' as p;
import 'dart:async';

Class buildDataClass(String name, Map<String, String> properties) {
  return Class(
    (classBuilder) => classBuilder
      ..name = name
      ..fields.addAll(
        properties.entries
            .map<Field>((field) => Field((fieldBuilder) => fieldBuilder
              ..name = field.key
              ..modifier = FieldModifier.final$
              ..type = refer(field.value)))
            .toList(),
      )
      ..constructors.add(Constructor(
        (constructorBuilder) => constructorBuilder
          ..optionalParameters.addAll(properties.entries
              .map<Parameter>(
                  (field) => Parameter((parameterBuilder) => parameterBuilder
                    ..name = field.key
                    ..named = true
                    ..required = true
                    ..toThis = true))
              .toList())
          ..constant = true,
      )),
  );
}

class ListAllClassesBuilder implements Builder {
  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'documentation.dart'),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['documentation.dart'],
    };
  }

  /// Build the classes that are used in the documentation

  String buildLibraryTypes() {
    final library = Library((b) => b.body.addAll([
          buildDataClass("LdDocComponent", {
            "name": "String",
            "isNullSafe": "bool",
            "description": "String",
            "constructors": "List<LdDocConstructor>",
            "properties": "List<LdDocProperty>",
            "methods": "List<String>",
          }),
          buildDataClass("LdDocProperty", {
            "name": "String",
            "type": "String",
            "description": "String",
            "features": "List<String>",
          }),
          buildDataClass("LdDocConstructor", {
            "name": "String",
            "signature": "List<LdDocParameter>",
            "features": "List<String>",
          }),
          buildDataClass("LdDocParameter", {
            "name": "String",
            "type": "String",
            "description": "String",
            "named": "bool",
            "required": "bool",
          }),
        ]));
    final emitter = DartEmitter.scoped();
    return DartFormatter().format('${library.accept(emitter)}');
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    List<out.DocComponent> classes = [];

    // Persist the version number

    final json = jsonDecode(File("package.json").readAsStringSync());

    final version = json["version"] as String;

    final versionFile = File("lib/src/version.dart");

    versionFile.writeAsStringSync(
      "/// Version of the library \n"
      "const ldVersion = \"$version\";",
    );

    final directAssets =
        buildStep.findAssets(Glob('lib/src/*.dart', recursive: true));

    final subDirAssets =
        buildStep.findAssets(Glob('lib/src/**/*.dart', recursive: true));

    final assets = [
      ...await directAssets.toList(),
      ...await subDirAssets.toList()
    ];

    for (final input in assets) {
      final library = await buildStep.resolver.libraryFor(input);
      final classesInLibrary = LibraryReader(library).classes;

      for (final classItem in classesInLibrary) {
        classes.add(out.DocComponent(
          name: classItem.name,
          isNullSafe: true,
          description:
              classItem.documentationComment?.replaceAll("///", "") ?? "",
          constructors: classItem.constructors
              .map((e) => out.Constructor(
                    name: e.name.toString(),
                    signature: e.parameters
                        .map((param) => out.Parameter(
                              description: param.documentationComment ?? "",
                              name: param.name.toString(),
                              type: param.type.toString(),
                              named: param.isNamed,
                              required: param.isRequired,
                            ))
                        .toList(),
                    features: [
                      if (e.isConst) "const",
                      if (e.isFactory) "factory",
                      if (e.isExternal) "external",
                    ],
                  ))
              .toList(),
          properties: classItem.fields
              .map((e) => out.Property(
                    name: e.name.toString(),
                    type: e.type.toString(),
                    description: e.documentationComment ?? "",
                    features: [
                      if (e.isStatic) "static",
                      if (e.isCovariant) "covariant",
                      if (e.isFinal) "final",
                      if (e.isConst) "const",
                      if (e.isLate) "late",
                    ],
                  ))
              .toList(),
          methods: classItem.methods.map((e) => e.name.toString()).toList(),
        ));
      }
    }

    final outputLibrary = Library((libraryBuilder) {
      libraryBuilder.body.add(Field((field) => field
        ..name = "ldDocComponents"
        ..modifier = FieldModifier.constant
        ..assignment = literalList([
          for (final classItem in classes)
            refer("LdDocComponent").newInstance([], {
              "name": literalString(classItem.name),
              "isNullSafe": literalBool(classItem.isNullSafe),
              "description": literalString(classItem.description),
              "properties": literalList(classItem.properties
                  .map((e) => refer("LdDocProperty").newInstance([], {
                        "name": literalString(e.name),
                        "type": literalString(e.type),
                        "description": literalString(e.description),
                        "features": literalList(
                            e.features.map((e) => literalString(e)).toList()),
                      }))
                  .toList()),
              "constructors": literalList(classItem.constructors
                  .map((e) => refer("LdDocConstructor").newInstance([], {
                        "name": literalString(e.name),
                        "signature": literalList(e.signature
                            .map((e) => refer("LdDocParameter").newInstance(
                                  [],
                                  {
                                    "name": literalString(e.name),
                                    "type": literalString(e.type),
                                    "description": literalString(e.description),
                                    "named": literalBool(e.named),
                                    "required": literalBool(e.required),
                                  },
                                ))
                            .toList()),
                        "features": literalList(
                            e.features.map((e) => literalString(e)).toList()),
                      }))
                  .toList()),
              "methods": literalList(
                  classItem.methods.map((e) => literalString(e)).toList()),
            })
        ]).code));
    });

    final emitter = DartEmitter.scoped();
    final output = DartFormatter().format('${outputLibrary.accept(emitter)}');

    await buildStep.writeAsString(
        _allFileOutput(buildStep), buildLibraryTypes() + "\n" + output);
  }
}

Builder docGenerator(BuilderOptions _) => ListAllClassesBuilder();
