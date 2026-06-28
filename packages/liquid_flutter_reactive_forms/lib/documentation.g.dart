class DocComponent {
  const DocComponent({
    required this.name,
    required this.isNullSafe,
    required this.description,
    required this.constructors,
    required this.properties,
    required this.methods,
  });

  final String name;
  final bool isNullSafe;
  final String description;
  final List<DocConstructor> constructors;
  final List<DocProperty> properties;
  final List<String> methods;
}

class DocProperty {
  const DocProperty({
    required this.name,
    required this.type,
    required this.description,
    required this.features,
  });

  final String name;
  final String type;
  final String description;
  final List<String> features;
}

class DocConstructor {
  const DocConstructor({
    required this.name,
    required this.signature,
    required this.features,
  });

  final String name;
  final List<DocParameter> signature;
  final List<String> features;
}

class DocParameter {
  const DocParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.named,
    required this.required,
  });

  final String name;
  final String description;
  final String type;
  final bool named;
  final bool required;
}

const docComponents = <DocComponent>[];
