import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

/// A string that is either a literal or an A2UI `{"path": ...}` binding.
sealed class LdStringRef {
  const LdStringRef();

  /// Parses a GenUI string-or-binding. Returns null if [json] is null/invalid.
  static LdStringRef? tryParse(Object? json) {
    if (json == null) return null;
    if (json is String) return LdStringLiteral(json);
    final map = ldJsonMap(json);
    final path = ldJsonString(map?['path']);
    if (path != null && path.isNotEmpty) {
      return LdStringBinding(path);
    }
    return null;
  }

  static LdStringRef parse(Object? json, {required String field}) {
    final ref = tryParse(json);
    if (ref == null) {
      throw FormatException('$field must be a string or {"path": "..."}');
    }
    return ref;
  }

  /// Value to pass to genui `BoundString`.
  Object get boundValue => switch (this) {
    LdStringLiteral(:final value) => value,
    LdStringBinding(:final path) => {'path': path},
  };
}

final class LdStringLiteral extends LdStringRef {
  const LdStringLiteral(this.value);

  final String value;
}

final class LdStringBinding extends LdStringRef {
  const LdStringBinding(this.path);

  final String path;
}

/// A number that is either a literal or an A2UI `{"path": ...}` binding.
sealed class LdNumberRef {
  const LdNumberRef();

  static LdNumberRef? tryParse(Object? json) {
    if (json == null) return null;
    if (json is num) return LdNumberLiteral(json);
    final map = ldJsonMap(json);
    final path = ldJsonString(map?['path']);
    if (path != null && path.isNotEmpty) {
      return LdNumberBinding(path);
    }
    return null;
  }

  static LdNumberRef parse(Object? json, {required String field}) {
    final ref = tryParse(json);
    if (ref == null) {
      throw FormatException('$field must be a number or {"path": "..."}');
    }
    return ref;
  }

  /// Value to pass to genui `BoundNumber`.
  Object get boundValue => switch (this) {
    LdNumberLiteral(:final value) => value,
    LdNumberBinding(:final path) => {'path': path},
  };
}

final class LdNumberLiteral extends LdNumberRef {
  const LdNumberLiteral(this.value);

  final num value;
}

final class LdNumberBinding extends LdNumberRef {
  const LdNumberBinding(this.path);

  final String path;
}

/// A boolean that is either a literal or an A2UI `{"path": ...}` binding.
sealed class LdBoolRef {
  const LdBoolRef();

  static LdBoolRef? tryParse(Object? json) {
    if (json == null) return null;
    if (json is bool) return LdBoolLiteral(json);
    final map = ldJsonMap(json);
    final path = ldJsonString(map?['path']);
    if (path != null && path.isNotEmpty) {
      return LdBoolBinding(path);
    }
    return null;
  }

  /// Value to pass to genui `BoundBool`.
  Object get boundValue => switch (this) {
    LdBoolLiteral(:final value) => value,
    LdBoolBinding(:final path) => {'path': path},
  };
}

final class LdBoolLiteral extends LdBoolRef {
  const LdBoolLiteral(this.value);

  final bool value;
}

final class LdBoolBinding extends LdBoolRef {
  const LdBoolBinding(this.path);

  final String path;
}
