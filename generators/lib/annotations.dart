class Variants {
  final List<Variant> variants;

  const Variants(this.variants);
}

class Variant {
  final String name;
  final Map<String, String> defaults;

  const Variant(this.name, {required this.defaults});
}

class ContextConfigurable {
  const ContextConfigurable();
}
