mixin Identifiable<I> {
  I get id;
  String get idString => id.toString();
}
