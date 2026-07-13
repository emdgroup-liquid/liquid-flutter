import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags `condition ? Wrapper(child: x) : x` patterns where `LdWrapConditional`
/// should be used instead. The Liquid Flutter design system provides
/// `LdWrapConditional` for conditionally wrapping a widget with a parent.
final class LdWrapConditionalMissed extends LdLintRule {
  LdWrapConditionalMissed()
    : super(
        name: 'ld_wrap_conditional_missed',
        description:
            'Use LdWrapConditional instead of ternary operators with '
            'conditionally wrapped child widgets.',
      );

  static const _code = LintCode(
    'ld_wrap_conditional_missed',
    'Use LdWrapConditional instead of a ternary for conditional wrapping.',
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
  final LdWrapConditionalMissed rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    final thenExpr = node.thenExpression;
    final elseExpr = node.elseExpression;

    if (thenExpr is InstanceCreationExpression) {
      final argList = thenExpr.argumentList;

      final childArg = argList.arguments
          .whereType<NamedExpression>()
          .where((a) => a.name.label.name == 'child')
          .cast<NamedExpression?>()
          .firstOrNull;

      if (childArg != null &&
          _isReferenceToSameSimpleVar(childArg.expression, elseExpr)) {
        rule.reportAtNode(node);
      }
    }
  }

  bool _isReferenceToSameSimpleVar(Expression a, Expression b) {
    if (a is SimpleIdentifier && b is SimpleIdentifier) {
      return a.name == b.name;
    }
    return false;
  }
}