import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

import 'base.dart';

/// Flags `State` classes that declare `_isLoading`, `_error`, `_failure`,
/// or `_status` fields that track manual loading/error states instead of
/// using `LdSubmit`.
final class ManualLoadingState extends LdLintRule {
  ManualLoadingState()
    : super(
        name: 'manual_loading_state',
        description:
            'Use LdSubmit to manage loading and error states instead of '
            'manual _isLoading / _error fields.',
      );

  static const _code = LintCode(
    'manual_loading_state',
    'Use LdSubmit instead of manually tracking loading/error state.',
  );

  static const _manualStateFieldNames = <String>{
    '_isLoading',
    '_loading',
    '_error',
    '_failure',
    '_loadState',
    '_status',
    '_exception',
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
    registry.addFieldDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final ManualLoadingState rule;

  _Visitor(this.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final parent = node.parent;
    if (parent is ClassDeclaration) {
      final superclass = parent.extendsClause?.superclass;
      if (superclass != null && superclass.toString().startsWith('State<')) {
        final fields = node.fields.variables;
        for (final field in fields) {
          final name = field.name.toString();
          if (ManualLoadingState._manualStateFieldNames.contains(name)) {
            rule.reportAtNode(field);
          }
        }
      }
    }
  }
}