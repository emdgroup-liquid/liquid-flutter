import 'package:flutter/foundation.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_rule_picker.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// Host callbacks for pending approvals rendered by [LdConversation].
@immutable
class LdConversationApprovalActions {
  final void Function(LdApprovalItem item)? onApprove;
  final void Function(LdApprovalItem item)? onDeny;
  final void Function(
    LdApprovalItem item,
    LdToolAllowRulePickerResult result,
  )?
  onApproveWithRule;

  /// Optional existing rule to extend when opening "Approve & allow".
  final LdToolAllowRule? Function(LdApprovalItem item)? seedRuleFor;

  const LdConversationApprovalActions({
    this.onApprove,
    this.onDeny,
    this.onApproveWithRule,
    this.seedRuleFor,
  });
}
