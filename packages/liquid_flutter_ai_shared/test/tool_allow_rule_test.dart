import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:test/test.dart';

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

    test('field wildcard allows key to be absent', () {
      const rule = LdToolAllowRule(
        toolName: 'pr',
        argumentPattern: {
          'title': 'feat',
          'body': ldToolAllowWildcard,
        },
      );
      // Broader than the current call: optional body allowed as Any.
      expect(rule.matches('pr', {'title': 'feat'}), isTrue);
      expect(rule.matches('pr', {'title': 'feat', 'body': 'x'}), isTrue);
      expect(rule.matches('pr', {'title': 'other'}), isFalse);
    });

    test('wildcard inside OR list allows key to be absent', () {
      const rule = LdToolAllowRule(
        toolName: 'bash',
        argumentPattern: {
          'cwd': [ldToolAllowWildcard],
        },
      );
      expect(rule.matches('bash', {}), isTrue);
      expect(rule.matches('bash', {'cwd': '/anywhere'}), isTrue);
    });
    test('exact array value matches wrapped list arg', () {
      const rule = LdToolAllowRule(
        toolName: 'pr',
        argumentPattern: {
          'labels': [
            ['ui', 'ai'],
          ],
        },
      );
      expect(rule.matches('pr', {'labels': ['ui', 'ai']}), isTrue);
      expect(rule.matches('pr', {'labels': ['ui']}), isFalse);
      expect(rule.matches('pr', {'labels': 'ui'}), isFalse);
    });

    test('OR of arrays matches nested list alternatives', () {
      const rule = LdToolAllowRule(
        toolName: 'pr',
        argumentPattern: {
          'labels': [
            ['ui'],
            ['ui', 'ai'],
          ],
        },
      );
      expect(rule.matches('pr', {'labels': ['ui']}), isTrue);
      expect(rule.matches('pr', {'labels': ['ui', 'ai']}), isTrue);
      expect(rule.matches('pr', {'labels': ['docs']}), isFalse);
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

  group('LdToolAllowRule.fromFieldPins', () {
    test('omits notAllowed paths', () {
      final rule = LdToolAllowRule.fromFieldPins(
        'pr',
        {
          'title': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.exact,
            values: ['feat'],
          ),
          'body': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.notAllowed,
          ),
        },
      );
      expect(rule.argumentPattern['title'], 'feat');
      expect(rule.argumentPattern.containsKey('body'), isFalse);
    });

    test('notAllowed parent excludes children', () {
      final rule = LdToolAllowRule.fromFieldPins(
        'pr',
        {
          'repo': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.notAllowed,
          ),
          'repo.owner': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.exact,
            values: ['mtrust'],
          ),
        },
        objectPaths: {'repo'},
      );
      expect(rule.argumentPattern.containsKey('repo'), isFalse);
    });

    test('multi-value exact emits list', () {
      final rule = LdToolAllowRule.fromFieldPins(
        'bash',
        {
          'cwd': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.exact,
            values: ['/app', '/tmp'],
          ),
        },
      );
      expect(rule.argumentPattern['cwd'], ['/app', '/tmp']);
    });

    test('array pin emits wrapped OR list', () {
      final rule = LdToolAllowRule.fromFieldPins(
        'pr',
        {
          'labels': LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.exact,
            values: [
              ['ui', 'ai'],
              ['docs'],
            ],
          ),
        },
      );
      expect(rule.argumentPattern['labels'], [
        ['ui', 'ai'],
        ['docs'],
      ]);
      expect(rule.matches('pr', {'labels': ['docs']}), isTrue);
      expect(rule.matches('pr', {'labels': ['ui', 'ai']}), isTrue);
      expect(rule.matches('pr', {'labels': 'ui'}), isFalse);
    });

    test('inclusive matcher rejects later extra key', () {
      final rule = LdToolAllowRule.fromFieldPins(
        'pr',
        {
          'title': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.exact,
            values: ['feat'],
          ),
          'body': const LdToolAllowFieldPin(
            mode: LdToolAllowPinMode.notAllowed,
          ),
        },
      );
      expect(rule.matches('pr', {'title': 'feat'}), isTrue);
      expect(
        rule.matches('pr', {'title': 'feat', 'body': 'hello'}),
        isFalse,
      );
    });
  });

  group('ldBuildToolAllowFieldSession', () {
    const schema = {
      'type': 'object',
      'required': ['title'],
      'properties': {
        'title': {'type': 'string'},
        'body': {'type': 'string'},
        'draft': {'type': 'boolean'},
        'repo': {
          'type': 'object',
          'properties': {
            'owner': {'type': 'string'},
            'visibility': {
              'type': 'string',
              'enum': ['public', 'private'],
            },
          },
        },
      },
    };

    test('defaults optional absent to notAllowed', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: {'title': 'feat'},
      );
      expect(session.pins['title']?.mode, LdToolAllowPinMode.exact);
      expect(session.pins['title']?.values, ['feat']);
      expect(session.pins['body']?.mode, LdToolAllowPinMode.notAllowed);
      expect(session.pins['draft']?.mode, LdToolAllowPinMode.notAllowed);
    });

    test('seed ∪ call unions leaf values', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: {'title': 'feat-b'},
        seedRule: const LdToolAllowRule(
          toolName: 'pr',
          argumentPattern: {
            'title': ['feat-a'],
          },
        ),
      );
      expect(session.pins['title']?.mode, LdToolAllowPinMode.exact);
      expect(
        session.pins['title']?.values,
        containsAll(['feat-a', 'feat-b']),
      );
    });

    test('picker toRule: Any on absent optional still matches call', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: {'title': 'feat'},
      );
      final withBodyAny = session.copyWithPins({
        ...session.pins,
        'body': const LdToolAllowFieldPin(mode: LdToolAllowPinMode.wildcard),
      });
      final rule = withBodyAny.toRule('pr');
      expect(rule.argumentPattern['body'], ldToolAllowWildcard);
      expect(rule.matches('pr', {'title': 'feat'}), isTrue);
    });

    test('picker toRule: Fixed on absent optional includes null', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: {'title': 'feat'},
      );
      final withBodyFixed = session.copyWithPins({
        ...session.pins,
        'body': const LdToolAllowFieldPin(
          mode: LdToolAllowPinMode.exact,
          values: ['hello'],
        ),
      });
      final rule = withBodyFixed.toRule('pr');
      expect(rule.argumentPattern['body'], containsAll([null, 'hello']));
      expect(rule.matches('pr', {'title': 'feat'}), isTrue);
      expect(
        rule.matches('pr', {'title': 'feat', 'body': 'hello'}),
        isTrue,
      );
    });

    test('editor toRule: does not invent null without call context', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: null,
        seedRule: const LdToolAllowRule(
          toolName: 'pr',
          argumentPattern: {'title': 'feat'},
        ),
      );
      final withBodyFixed = session.copyWithPins({
        ...session.pins,
        'body': const LdToolAllowFieldPin(
          mode: LdToolAllowPinMode.exact,
          values: ['hello'],
        ),
      });
      final rule = withBodyFixed.toRule('pr');
      expect(rule.argumentPattern['body'], 'hello');
    });

    test('schema enum options available on meta', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: schema,
        arguments: {
          'title': 'x',
          'repo': {'visibility': 'private'},
        },
      );
      expect(
        session.schemaMeta['repo.visibility']?.enumOptions,
        ['public', 'private'],
      );
    });

    test('invalid schema falls back to map walk', () {
      final session = ldBuildToolAllowFieldSession(
        inputSchema: {
          'properties': {
            'command': {'type': 'string'},
            'cwd': {'type': 'string'},
          },
        },
        arguments: {'command': 'ls'},
      );
      expect(session.pins.containsKey('command'), isTrue);
      expect(session.pins['cwd']?.mode, LdToolAllowPinMode.notAllowed);
    });
  });

  group('ldParseToolInputSchema', () {
    test('parses nested object properties', () {
      final meta = ldParseToolInputSchema({
        'type': 'object',
        'properties': {
          'repo': {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
            },
          },
        },
      });
      expect(meta['repo']?.isObject, isTrue);
      expect(meta['repo.owner']?.kind, LdToolAllowValueKind.string);
    });

    test('schema array items expose itemKind', () {
      final meta = ldParseToolInputSchema({
        'type': 'object',
        'properties': {
          'labels': {
            'type': 'array',
            'items': {
              'type': 'string',
              'enum': ['ui', 'ai', 'docs'],
            },
          },
        },
      });
      expect(meta['labels']?.kind, LdToolAllowValueKind.array);
      expect(meta['labels']?.itemKind, LdToolAllowValueKind.string);
      expect(meta['labels']?.enumOptions, ['ui', 'ai', 'docs']);
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
