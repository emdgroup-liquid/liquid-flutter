/// Liquid Flutter AI — conversation UI components.
library;

export 'src/models/agent_task.dart';
export 'src/models/compose_attachment.dart';
export 'src/models/conversation_item.dart';
export 'src/conversation/group_items.dart';
export 'src/conversation/conversation.dart';
export 'src/conversation/approval_actions.dart';
export 'src/conversation/appear.dart';
export 'src/compose/compose_bar.dart';
export 'package:cross_file/cross_file.dart' show XFile;
export 'src/bubbles/user_bubble.dart';
export 'src/bubbles/agent_markdown.dart';
export 'src/bubbles/stream_reveal.dart';
export 'src/bubbles/edge_fade.dart';
export 'src/bubbles/tool_call.dart';
export 'src/bubbles/tool_call_detail_modal.dart';
export 'src/bubbles/approval.dart';
export 'src/bubbles/reasoning.dart';
export 'src/bubbles/system_prompt.dart';
export 'src/bubbles/turn_error.dart';
export 'src/bubbles/agent_activity_group.dart';
export 'src/tasks/agent_task_panel.dart';
export 'src/send/send_fly_scope.dart'
    show
        LdSendFlyScope,
        LdSendFlyScopeState,
        LdSendFlyOrigin,
        LdSendFlyTarget,
        LdSendFlyMeasureKey,
        LdSendFlyPayload;

export 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
export 'src/approval/tool_allow_rule_picker.dart';
export 'src/approval/tool_allow_rule_editor.dart';
export 'src/approval/tool_allow_field_tree.dart';

export 'src/usage/usage_models.dart';
export 'src/usage/usage_compute.dart';
export 'src/usage/context_compute.dart';
export 'src/usage/usage_cost_modal.dart';
export 'src/usage/context_usage_indicator.dart';

export 'src/genui/ld_catalog.dart' show buildLdCatalog;
export 'src/genui/genui_surface_manager.dart';
export 'src/genui/genui_surface_widget.dart';
export 'src/genui/genui_surface_strip.dart';
export 'src/genui/genui_markdown.dart';
