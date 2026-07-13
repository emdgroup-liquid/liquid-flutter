import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags `Column()` widgets with 3+ children where `LdAutoSpace` should
/// be used instead. The Liquid Flutter design system prefers `LdAutoSpace`
/// which automatically applies spacing based on component types.
///
/// Excludes `Column` widgets that have explicit `spacing` set, indicating
/// the developer intentionally customized spacing.
final class MissingLdAutoSpace extends LdLintRule {
  MissingLdAutoSpace()
    : super(
        name: 'missing_ld_autospace',
        description:
            'Use LdAutoSpace instead of Column when arranging items '
            'vertically with default spacing.',
      );

  static const _code = LintCode(
    'missing_ld_autospace',
    'Use LdAutoSpace instead of Column to automatically space children.',
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
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingLdAutoSpace rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.toString();
    if (typeName != 'Column') return;

    final argList = node.argumentList;

    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'spacing') {
        return;
      }
    }

    NamedExpression? childrenArg;
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'children') {
        childrenArg = arg;
        break;
      }
    }
    if (childrenArg == null) return;

    final childrenExpr = childrenArg.expression;
    List<Expression>? childList;
    if (childrenExpr is ListLiteral) {
      childList = childrenExpr.elements.whereType<Expression>().toList();
    }

    if (childList != null && childList.length >= 3) {
      rule.reportAtNode(node);
    }
  }
}