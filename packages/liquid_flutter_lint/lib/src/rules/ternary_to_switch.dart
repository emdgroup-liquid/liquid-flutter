import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags deeply nested ternary operators (2+ levels) used in widget trees
/// where a `switch` expression would be more readable.
final class TernaryToSwitch extends LdLintRule {
  TernaryToSwitch()
    : super(
        name: 'ternary_to_switch',
        description:
            'Prefer switch expressions over nested ternary operators for '
            'multi-branch conditions.',
      );

  static const _code = LintCode(
    'ternary_to_switch',
    'Prefer a switch expression over nested ternary operators.',
  );

  @override
  LintCode get diagnosticCode => _code;

  @override
  bool get canUseParsedResult => true;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addConditionalExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final TernaryToSwitch rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (_containsNestedTernary(node)) {
      rule.reportAtNode(node);
    }
  }

  bool _containsNestedTernary(ConditionalExpression node) {
    final finder = _NestedTernaryFinder();
    node.thenExpression.accept(finder);
    if (finder.found) return true;
    node.elseExpression.accept(finder);
    return finder.found;
  }
}

class _NestedTernaryFinder extends SimpleAstVisitor<void> {
  bool found = false;

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    found = true;
  }
}