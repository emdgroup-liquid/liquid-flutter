class DocComponent {
  DocComponent({
    required this.name,
    required this.isNullSafe,
    required this.description,
    required this.constructors,
    required this.properties,
    required this.methods,
  });

  String name;

  bool isNullSafe;

  String description;

  List<Constructor> constructors;

  List<Property> properties;

  List<String> methods;
}

class Property {
  Property({
    required this.name,
    required this.type,
    required this.description,
    required this.features,
  });

  String name;

  String type;

  String description;

  List<String> features;
}

class Constructor {
  Constructor({
    required this.name,
    required this.signature,
    required this.features,
  });

  String name;

  List<Parameter> signature;

  List<String> features;
}

class Parameter {
  Parameter({
    required this.name,
    required this.type,
    required this.description,
    required this.named,
    required this.required,
  });

  String name;

  String description;

  String type;

  bool named;

  bool required;
}
