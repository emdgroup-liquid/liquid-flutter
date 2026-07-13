import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags `Provider`, `ListenableProvider`, `ChangeNotifierProvider` instances
/// that are created inside `if/else` conditional branches. Providers should
/// always be mounted unconditionally in the widget tree to avoid losing state
/// when conditions change.
final class ConditionallyMountedProvider extends LdLintRule {
  ConditionallyMountedProvider()
    : super(
        name: 'conditionally_mounted_provider',
        description:
            'Providers should not be mounted conditionally inside if/else '
            'branches; mount them unconditionally in the widget tree.',
      );

  static const _code = LintCode(
    'conditionally_mounted_provider',
    'Mount Provider unconditionally; conditional mounting loses state.',
  );

  static const _providerTypeNames = <String>{
    'Provider',
    'ListenableProvider',
    'ChangeNotifierProvider',
    'MultiProvider',
  };

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
  final ConditionallyMountedProvider rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.toString();
    if (!ConditionallyMountedProvider._providerTypeNames.contains(typeName)) {
      return;
    }

    var current = node.parent;
    while (current != null) {
      if (current is IfStatement ||
          current is ConditionalExpression ||
          current is SwitchStatement ||
          current is SwitchExpression) {
        rule.reportAtNode(node);
        return;
      }
      if (current is MethodDeclaration ||
          current is FunctionDeclaration ||
          current is FunctionExpression) {
        return;
      }
      current = current.parent;
    }
  }
}