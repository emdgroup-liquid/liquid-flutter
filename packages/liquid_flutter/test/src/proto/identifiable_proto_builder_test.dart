import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/proto/identifiable_proto_builder.dart';

void main() {
  group('transformIdentifiableProto', () {
    final emptyOverrides = <String, String>{};

    test('adds Identifiable<int> for class with int id getter', () {
      final input = r'''
import 'dart:async';

class User extends $pb.GeneratedMessage {
  $core.int get id => 0;
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(result, contains('with Identifiable<\$core.int>'));
      expect(result, contains("import 'package:liquid_flutter/liquid_flutter.dart';"));
      expect(result, isNot(contains('get id => id')));
    });

    test('adds Identifiable<String> for class with String id getter', () {
      final input = r'''
class Product extends $pb.GeneratedMessage {
  $core.String get id => '';
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(result, contains('with Identifiable<\$core.String>'));
    });

    test('uses field override and adds forwarding getter', () {
      final input = r'''
import 'dart:async';

class Product extends $pb.GeneratedMessage {
  $core.String get uuid => '';

  static Product? _defaultInstance;
}
''';

      final result =
          transformIdentifiableProto(input, {'Product': 'uuid'});
      expect(result, contains('with Identifiable<\$core.String>'));
      expect(result, contains('\$core.String get id => uuid'));
      expect(result, contains("import 'package:liquid_flutter/liquid_flutter.dart';"));
    });

    test('handles int field override with forwarding getter', () {
      final input = r'''
import 'dart:async';

class Order extends $pb.GeneratedMessage {
  $core.int get orderId => 0;

  static Order? _defaultInstance;
}
''';

      final result =
          transformIdentifiableProto(input, {'Order': 'orderId'});
      expect(result, contains('with Identifiable<\$core.int>'));
      expect(result, contains('\$core.int get id => orderId'));
    });

    test('skips class already having Identifiable', () {
      final input = r'''
class User extends $pb.GeneratedMessage with Identifiable<$core.int> {
  $core.int get id => 0;
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(result, equals(input));
    });

    test('skips class without id getter and without override', () {
      final input = r'''
class Product extends $pb.GeneratedMessage {
  $core.String get uuid => '';
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(result, equals(input));
    });

    test('does not add duplicate import', () {
      final input = r'''
import 'dart:async';
import 'package:liquid_flutter/liquid_flutter.dart';

class User extends $pb.GeneratedMessage {
  $core.int get id => 0;
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      final importCount = RegExp(r"import 'package:liquid_flutter/liquid_flutter.dart'")
          .allMatches(result)
          .length;
      expect(importCount, equals(1));
    });

    test('handles multiple classes in one file', () {
      final input = r'''
class User extends $pb.GeneratedMessage {
  $core.int get id => 0;
}

class Order extends $pb.GeneratedMessage {
  $core.String get id => '';
}

class Product extends $pb.GeneratedMessage {
  $core.String get uuid => '';

  static Product? _defaultInstance;
}
''';

      final result =
          transformIdentifiableProto(input, {'Product': 'uuid'});
      expect(result, contains('class User extends \$pb.GeneratedMessage with Identifiable<\$core.int>'));
      expect(result, contains('class Order extends \$pb.GeneratedMessage with Identifiable<\$core.String>'));
      expect(result, contains('class Product extends \$pb.GeneratedMessage with Identifiable<\$core.String>'));
      expect(result, contains('\$core.String get id => uuid'));
    });

    test('ignores non-message classes', () {
      final input = r'''
class MyService {
  $core.String get id => '';
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(result, equals(input));
    });

    test('no liquid import added when no classes modified', () {
      final input = r'''
class Product extends $pb.GeneratedMessage {
  $core.String get uuid => '';
}
''';

      final result = transformIdentifiableProto(input, emptyOverrides);
      expect(
        result,
        isNot(contains("import 'package:liquid_flutter/liquid_flutter.dart'")),
      );
    });

    test('no forwarding getter when class has get id =>', () {
      final input = r'''
import 'dart:async';

class User extends $pb.GeneratedMessage {
  $core.String get id => '';

  static User? _defaultInstance;
}
''';

      final result = transformIdentifiableProto(input, {'User': 'id'});
      expect(result, contains('with Identifiable<\$core.String>'));
      expect(result, isNot(contains('get id => id')));
    });
  });
}