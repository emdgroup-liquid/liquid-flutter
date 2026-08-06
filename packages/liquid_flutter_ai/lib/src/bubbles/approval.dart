import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_rule_picker.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// Approval request with deny / approve / approve-and-allow actions.
class LdApprovalCard extends StatelessWidget {
  final LdApprovalItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final ValueChanged<LdToolAllowRulePickerResult>? onApproveWithRule;
  final WidgetBuilder? trailingBuilder;

  /// Existing rule to extend in the allow-rule picker (same tool).
  final LdToolAllowRule? seedRule;

  /// When false, hides the "Approve & allow" button even if [item.toolName] is set.
  final bool showAllowRule;

  const LdApprovalCard({
    super.key,
    required this.item,
    this.onApprove,
    this.onDeny,
    this.onApproveWithRule,
    this.trailingBuilder,
    this.seedRule,
    this.showAllowRule = true,
  });

  bool get _canAllowRule =>
      showAllowRule &&
      onApproveWithRule != null &&
      (item.toolName?.isNotEmpty ?? false);

  Future<void> _approveAndAllow(BuildContext context) async {
    final result = await ldShowToolAllowRulePicker(
      context,
      toolName: item.toolName!,
      arguments: item.arguments,
      inputSchema: item.inputSchema,
      seedRule: seedRule,
    );
    if (!context.mounted) {
      return;
    }
    if (result == null || !result.approved) {
      return;
    }
    onApproveWithRule!(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final hasDescription = item.description?.isNotEmpty ?? false;

    return LdCard(
      padding: theme.pad(size: LdSize.m),
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: switch (item.status) {
                  LdApprovalStatus.pending => LdIndicator.info(
                    key: const Key('request_pending'),
                  ),
                  LdApprovalStatus.approved => LdIndicator.success(
                    key: const Key('request_approved'),
                  ),
                  LdApprovalStatus.denied => LdIndicator.error(
                    key: const Key('request_denied'),
                  ),
                },
              ),
              ldHSpacerS,
              Expanded(
                child: LdAutoSpace(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  defaultSpacing: LdSize.xs,
                  children: [
                    LdText.l(item.title),
                    if (hasDescription)
                      LdText.p(
                        item.description!,
                        size: LdSize.s,
                        color: theme.textMuted,
                      ),
                    switch (item.status) {
                      LdApprovalStatus.pending => _buildPendingActions(
                        context,
                        theme,
                      ),
                      LdApprovalStatus.approved => LdText.l('Request Approved'),
                      LdApprovalStatus.denied => LdText.l('Request Denied'),
                    },
                    if (trailingBuilder != null) trailingBuilder!(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(BuildContext context, LdTheme theme) {
    return LdAutoSpace(
      children: [
        Row(
          children: [
            LdButton.outline(
              onPressed: () async => onDeny?.call(),
              disabled: onDeny == null,
              child: const Text('Deny'),
            ),
            if (_canAllowRule)
              LdButton(
                mode: LdButtonMode.vague,
                onPressed: () async => _approveAndAllow(context),
                child: const Text('Approve & allow'),
              ),
            LdButton(
              onPressed: () async => onApprove?.call(),
              disabled: onApprove == null,
              child: const Text('Approve once'),
            ),
          ],
        ).spaceS(),
      ],
    );
  }
}
