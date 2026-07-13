import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags uses of `LdText.*()` as children of Liquid Flutter components that
/// expect raw `Text()` (e.g., `LdHint`, `LdListItem`, `LdButton`, etc.).
///
/// These components handle their own text styling, so wrapping the string in
/// `LdText` is redundant and violates design system conventions.
final class LdTextInComponentChild extends LdLintRule {
  LdTextInComponentChild()
    : super(
        name: 'ld_text_in_component_child',
        description:
            'Avoid using LdText inside Liquid Flutter components that style '
            'their own text. Use plain Text() instead.',
      );

  static const _code = LintCode(
    'ld_text_in_component_child',
    "Don't use LdText inside this component; use a plain Text() instead.",
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
    registry.addArgumentList(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LdTextInComponentChild rule;

  _Visitor(this.rule);

  @override
  void visitArgumentList(ArgumentList node) {
    final parent = node.parent;
    if (parent is InstanceCreationExpression) {
      final typeName = parent.constructorName.type.toString();
      if (!typeName.startsWith('Ld') || typeName == 'LdText') return;

      for (final arg in node.arguments) {
        if (arg is NamedExpression &&
            _childParameterNames.contains(arg.name.label.name)) {
          final expr = arg.expression;
          if (expr is MethodInvocation &&
              expr.target is Identifier &&
              (expr.target as Identifier).name == 'LdText') {
            rule.reportAtNode(expr);
          }
        }
      }
    }
  }
}

const _childParameterNames = <String>{
  'child',
  'title',
  'subtitle',
  'description',
  'label',
  'hintText',
  'leading',
  'trailing',
  'prefix',
  'suffix',
  'emptyWidget',
  'header',
  'footer',
  'icon',
  'action',
};