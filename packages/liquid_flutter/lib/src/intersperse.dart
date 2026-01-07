Iterable<T> intersperseIterable<T>(T element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;
  if (iterator.moveNext()) {
    yield iterator.current;
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

extension IntersperseIterable<T> on Iterable<T> {
  Iterable<T> intersperse(T element) {
    return intersperseIterable(element, this);
  }
}
