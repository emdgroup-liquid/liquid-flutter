import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/edge_insets_literal.dart';
import 'src/rules/ld_text_in_component_child.dart';
import 'src/rules/ld_wrap_conditional_missed.dart';
import 'src/rules/missing_ld_autospace.dart';
import 'src/rules/manual_loading_state.dart';
import 'src/rules/conditionally_mounted_provider.dart';
import 'src/rules/ternary_to_switch.dart';

final plugin = LiquidFlutterLintPlugin();

class LiquidFlutterLintPlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(LdTextInComponentChild())
      ..registerWarningRule(EdgeInsetsLiteral())
      ..registerWarningRule(MissingLdAutoSpace())
      ..registerWarningRule(ManualLoadingState())
      ..registerWarningRule(ConditionallyMountedProvider())
      ..registerWarningRule(LdWrapConditionalMissed())
      ..registerWarningRule(TernaryToSwitch());
  }
}