import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

void main() {
  group('ldPrettyPrintJsonish', () {
    test('pretty-prints compact JSON objects', () {
      expect(
        ldPrettyPrintJsonish('{"q":"full query","n":2}'),
        '{\n  "q": "full query",\n  "n": 2\n}',
      );
    });

    test('pretty-prints JSON arrays', () {
      expect(
        ldPrettyPrintJsonish('[1,{"a":true}]'),
        '[\n  1,\n  {\n    "a": true\n  }\n]',
      );
    });

    test('leaves non-JSON text unchanged', () {
      expect(ldPrettyPrintJsonish('found 3 docs'), 'found 3 docs');
      expect(ldPrettyPrintJsonish('{not json'), '{not json');
      expect(ldPrettyPrintJsonish('"just a string"'), '"just a string"');
      expect(ldPrettyPrintJsonish('42'), '42');
    });

    test('preserves empty and whitespace-only input', () {
      expect(ldPrettyPrintJsonish(''), '');
      expect(ldPrettyPrintJsonish('   '), '   ');
    });

    test('trims before decode but keeps pretty output without outer padding', () {
      expect(
        ldPrettyPrintJsonish('  {"a":1}  '),
        '{\n  "a": 1\n}',
      );
    });
  });
}
