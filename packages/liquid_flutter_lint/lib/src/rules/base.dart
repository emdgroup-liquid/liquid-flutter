import 'package:meta/meta.dart';

import 'package:analyzer/analysis_rule/analysis_rule.dart';

/// A base class for Liquid Flutter lint rules that report a single
/// diagnostic code.
@internal
abstract base class LdLintRule extends AnalysisRule {
  LdLintRule({
    required super.name,
    required super.description,
  });
}