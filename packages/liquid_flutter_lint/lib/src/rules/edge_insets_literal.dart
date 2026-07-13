import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags `EdgeInsets.all(x)`, `EdgeInsets.only(...)`, `EdgeInsets.symmetric(...)`
/// and suggests using `.padM()`, `.padS()`, `.padL()` etc. extension methods
/// from Liquid Flutter's design system instead.
final class EdgeInsetsLiteral extends LdLintRule {
  EdgeInsetsLiteral()
    : super(
        name: 'edge_insets_literal',
        description:
            'Use Liquid Flutter padding extensions (.padM(), .padS(), etc.) '
            'instead of EdgeInsets literal constructors.',
      );

  static const _code = LintCode(
    'edge_insets_literal',
    'Use a Liquid Flutter padding extension (e.g., .padM()) instead of EdgeInsets.',
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
  final EdgeInsetsLiteral rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.toString();
    if (typeName != 'EdgeInsets') return;
    final constructorStr = node.constructorName.name?.name ?? '';

    if (constructorStr == 'all' ||
        constructorStr == 'only' ||
        constructorStr == 'symmetric' ||
        constructorStr == 'fromLTRB') {
      rule.reportAtNode(node);
    }
  }
}