// Local models for `.api_guard/*.json` snapshots produced by the
// `mtrust_api_guard` CLI. Kept in-tree so the example app does not need the
// `mtrust_api_guard` package as a workspace dependency (that package pulls
// `analyzer ^13`, which conflicts with Flutter-pinned `test` / generators).

enum DocComponentType {
  classType,
  functionType,
  mixinType,
  enumType,
  typedefType,
  extensionType,
  metaType,
}

DocComponentType _docComponentTypeFromJson(Object? value) {
  return switch (value) {
    'function' => DocComponentType.functionType,
    'mixin' => DocComponentType.mixinType,
    'enum' => DocComponentType.enumType,
    'typedef' => DocComponentType.typedefType,
    'extension' => DocComponentType.extensionType,
    'meta' => DocComponentType.metaType,
    _ => DocComponentType.classType,
  };
}

class DocType {
  const DocType({
    required this.name,
    this.superTypes = const [],
    this.isNullable = false,
  });

  final String name;
  final List<String> superTypes;
  final bool isNullable;

  factory DocType.fromJson(Map<String, dynamic> json) {
    return DocType(
      name: json['name'] as String,
      superTypes: (json['superTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isNullable: json['isNullable'] as bool? ?? false,
    );
  }

  @override
  String toString() => name;
}

class DocComponent {
  const DocComponent({
    required this.name,
    required this.description,
    required this.constructors,
    required this.properties,
    required this.methods,
    this.filePath,
    this.entryPoint,
    this.type = DocComponentType.classType,
    this.aliasedType,
    this.annotations = const [],
    this.superClasses = const [],
    this.superClassPackages = const [],
    this.interfaces = const [],
    this.mixins = const [],
    this.typeParameters = const [],
  });

  final String? filePath;
  final String? entryPoint;
  final String name;
  final String description;
  final List<DocConstructor> constructors;
  final List<DocProperty> properties;
  final List<DocMethod> methods;
  final DocComponentType type;
  final String? aliasedType;
  final List<String> annotations;
  final List<String> superClasses;
  final List<String> superClassPackages;
  final List<String> interfaces;
  final List<String> mixins;
  final List<String> typeParameters;

  factory DocComponent.fromJson(Map<String, dynamic> json) {
    return DocComponent(
      name: json['name'] as String,
      description: json['description'] as String,
      constructors: (json['constructors'] as List<dynamic>)
          .map((e) => DocConstructor.fromJson(e as Map<String, dynamic>))
          .toList(),
      properties: (json['properties'] as List<dynamic>)
          .map((e) => DocProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      methods: (json['methods'] as List<dynamic>)
          .map((e) => DocMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
      filePath: json['filePath'] as String?,
      entryPoint: json['entryPoint'] as String?,
      type: _docComponentTypeFromJson(json['type']),
      aliasedType: json['aliasedType'] as String?,
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      superClasses: (json['superClasses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      superClassPackages: (json['superClassPackages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interfaces: (json['interfaces'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mixins: (json['mixins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      typeParameters: (json['typeParameters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

class DocProperty {
  const DocProperty({
    required this.name,
    required this.type,
    required this.description,
    required this.features,
    this.annotations = const [],
  });

  final String name;
  final DocType type;
  final String description;
  final List<String> features;
  final List<String> annotations;

  factory DocProperty.fromJson(Map<String, dynamic> json) {
    return DocProperty(
      name: json['name'] as String,
      type: DocType.fromJson(json['type'] as Map<String, dynamic>),
      description: json['description'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

class DocConstructor {
  const DocConstructor({
    required this.name,
    required this.signature,
    required this.features,
    this.annotations = const [],
  });

  final String name;
  final List<DocParameter> signature;
  final List<String> features;
  final List<String> annotations;

  factory DocConstructor.fromJson(Map<String, dynamic> json) {
    return DocConstructor(
      name: json['name'] as String,
      signature: (json['signature'] as List<dynamic>)
          .map((e) => DocParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

class DocParameter {
  const DocParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.named,
    required this.required,
    this.defaultValue,
    this.annotations = const [],
  });

  final String name;
  final String description;
  final DocType type;
  final bool named;
  final bool required;
  final String? defaultValue;
  final List<String> annotations;

  factory DocParameter.fromJson(Map<String, dynamic> json) {
    return DocParameter(
      name: json['name'] as String,
      type: DocType.fromJson(json['type'] as Map<String, dynamic>),
      description: json['description'] as String,
      named: json['named'] as bool,
      required: json['required'] as bool,
      defaultValue: json['defaultValue'] as String?,
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

class DocMethod {
  const DocMethod({
    required this.name,
    required this.returnType,
    required this.signature,
    required this.features,
    required this.description,
    this.annotations = const [],
    this.typeParameters = const [],
  });

  final String name;
  final DocType returnType;
  final List<DocParameter> signature;
  final List<String> features;
  final String description;
  final List<String> annotations;
  final List<String> typeParameters;

  factory DocMethod.fromJson(Map<String, dynamic> json) {
    return DocMethod(
      name: json['name'] as String,
      returnType: DocType.fromJson(json['returnType'] as Map<String, dynamic>),
      signature: (json['signature'] as List<dynamic>)
          .map((e) => DocParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String,
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      typeParameters: (json['typeParameters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}
