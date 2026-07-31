import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

void main() {
  group('LdToolAllowRule.matches', () {
    test('wildcard rule matches any args', () {
      final rule = LdToolAllowRule.wildcardAll(toolName: 'bash');
      expect(rule.matches('bash', {}), isTrue);
      expect(rule.matches('bash', {'cmd': 'rm -rf /'}), isTrue);
      expect(rule.matches('other', {'cmd': 'x'}), isFalse);
    });

    test('empty pattern rejects any args', () {
      const rule = LdToolAllowRule(toolName: 'bash', argumentPattern: {});
      expect(rule.matches('bash', {}), isTrue);
      expect(rule.matches('bash', {'cmd': 'x'}), isFalse);
      expect(rule.matches('other', {'cmd': 'x'}), isFalse);
    });

    test('rejects extra keys not in pattern', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {'command': 'npm test'},
      );
      expect(
        rule.matches('bash', {'command': 'npm test', 'cwd': '/app'}),
        isFalse,
      );
      expect(rule.matches('bash', {'command': 'npm run build'}), isFalse);
    });

    test('exact match passes', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {'command': 'npm test'},
      );
      expect(rule.matches('bash', {'command': 'npm test'}), isTrue);
    });

    test('list value matches any element', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {
          'cwd': ['/app', '/tmp'],
        },
      );
      expect(rule.matches('bash', {'cwd': '/app'}), isTrue);
      expect(rule.matches('bash', {'cwd': '/tmp'}), isTrue);
      expect(rule.matches('bash', {'cwd': '/other'}), isFalse);
    });

    test('null in list means key may be absent', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {
          'cwd': [null, '/app'],
        },
      );
      expect(rule.matches('bash', {}), isTrue);
      expect(rule.matches('bash', {'cwd': '/app'}), isTrue);
      expect(rule.matches('bash', {'cwd': '/tmp'}), isFalse);
    });
  });

  group('ldIsToolAutoApproved', () {
    test('any matching rule wins', () {
      final rules = [
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'command': 'npm test'},
        ),
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'command': 'ls'},
        ),
      ];
      expect(
        ldIsToolAutoApproved('bash', {'command': 'ls'}, rules),
        isTrue,
      );
      expect(
        ldIsToolAutoApproved('bash', {'command': 'rm'}, rules),
        isFalse,
      );
    });
  });

  group('ldMergeToolAllowRules', () {
    test('empty list returns empty', () {
      expect(ldMergeToolAllowRules([]), isEmpty);
    });

    test('single rule returns same', () {
      final input = [
        const LdToolAllowRule(toolName: 'bash', argumentPattern: {'c': 'ls'}),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 1);
      expect(result.first.toolName, 'bash');
      expect(result.first.argumentPattern['c'], 'ls');
    });

    test('wildcard overrides', () {
      final input = [
        LdToolAllowRule.wildcardAll(toolName: 'bash'),
        const LdToolAllowRule(toolName: 'bash', argumentPattern: {'c': 'ls'}),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 1);
      expect(result.first.wildcard, isTrue);
    });

    test('deduplicates identical', () {
      final input = [
        const LdToolAllowRule(toolName: 'bash', argumentPattern: {'c': 'ls'}),
        const LdToolAllowRule(toolName: 'bash', argumentPattern: {'c': 'ls'}),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 1);
      expect(result.first.argumentPattern['c'], 'ls');
    });

    test('merges same field different values into list', () {
      final input = [
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'cwd': '/app'},
        ),
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'cwd': '/tmp'},
        ),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 1);
      expect(result.first.argumentPattern['cwd'], containsAll(['/app', '/tmp']));
    });

    test('absent field becomes null in list', () {
      final input = [
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'command': 'npm test'},
        ),
        const LdToolAllowRule(
          toolName: 'bash',
          argumentPattern: {'command': 'npm test', 'cwd': '/app'},
        ),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 1);
      expect(result.first.argumentPattern['command'], 'npm test');
      expect(result.first.argumentPattern['cwd'], containsAll([null, '/app']));
    });

    test('different tools independent', () {
      final input = [
        const LdToolAllowRule(toolName: 'bash', argumentPattern: {'c': 'ls'}),
        const LdToolAllowRule(
          toolName: 'git',
          argumentPattern: {'action': 'pull'},
        ),
      ];
      final result = ldMergeToolAllowRules(input);
      expect(result.length, 2);
    });
  });

  group('LdToolAllowRule.fromPicker', () {
    test('builds pattern from pin modes', () {
      final rule = LdToolAllowRule.fromPicker(
        'bash',
        {'command': 'npm test', 'cwd': '/app'},
        {
          'command': LdToolAllowPinMode.exact,
          'cwd': LdToolAllowPinMode.wildcard,
        },
      );
      expect(rule.toolName, 'bash');
      expect(rule.argumentPattern['command'], 'npm test');
      expect(rule.argumentPattern['cwd'], ldToolAllowWildcard);
    });

    test('wildcard parent excludes children', () {
      final rule = LdToolAllowRule.fromPicker(
        'ha',
        {
          'data': {'entity_id': 'light.k'},
        },
        {
          'data': LdToolAllowPinMode.wildcard,
          'data.entity_id': LdToolAllowPinMode.exact,
        },
      );
      expect(rule.argumentPattern['data'], ldToolAllowWildcard);
      expect(rule.argumentPattern.containsKey('data.entity_id'), isFalse);
    });
  });

  group('ldSummarizeArgumentPattern', () {
    test('empty pattern', () {
      expect(ldSummarizeArgumentPattern({}), 'no arguments');
    });

    test('wildcard field', () {
      expect(ldSummarizeArgumentPattern({'cwd': '*'}), 'cwd=*');
    });

    test('exact field', () {
      expect(
        ldSummarizeArgumentPattern({'command': 'npm test'}),
        'command=npm test',
      );
    });

    test('list OR values', () {
      final summary = ldSummarizeArgumentPattern({
        'cwd': ['/app', '/tmp'],
      });
      expect(summary, contains('cwd=/app'));
      expect(summary, contains('cwd=/tmp'));
      expect(summary, contains('OR'));
    });

    test('null in list renders as absent', () {
      final summary = ldSummarizeArgumentPattern({
        'cwd': [null, '/app'],
      });
      expect(summary, contains('(no cwd)'));
      expect(summary, contains('cwd=/app'));
      expect(summary, contains('OR'));
    });
  });

  group('JSON roundtrip', () {
    test('wildcard', () {
      final rule = LdToolAllowRule.wildcardAll(toolName: 'bash');
      final restored = LdToolAllowRule.fromJson(rule.toJson());
      expect(restored, rule);
    });

    test('pattern', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {'command': 'ls'},
      );
      expect(LdToolAllowRule.fromJson(rule.toJson()), rule);
    });
  });
}
