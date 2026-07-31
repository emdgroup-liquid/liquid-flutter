import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

void main() {
  group('groupConversationItems', () {
    test('returns empty for empty input', () {
      expect(groupConversationItems(const []), isEmpty);
    });

    test('keeps user and markdown as singletons', () {
      final groups = groupConversationItems(const [
        LdUserMessageItem(id: 'u1', text: 'hi'),
        LdAgentMarkdownItem(id: 'a1', markdown: 'hello'),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0], isA<LdConversationSingletonGroup>());
      expect(groups[1], isA<LdConversationSingletonGroup>());
      expect((groups[0] as LdConversationSingletonGroup).item.id, 'u1');
      expect((groups[1] as LdConversationSingletonGroup).item.id, 'a1');
    });

    test('keeps system prompts as singletons outside activity groups', () {
      final groups = groupConversationItems(const [
        LdSystemPromptItem(id: 's1', content: 'Be helpful.'),
        LdReasoningItem(id: 'r1', content: 'planning'),
        LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
        ),
        LdAgentMarkdownItem(id: 'a1', markdown: 'done'),
      ]);

      expect(groups, hasLength(3));
      expect(groups[0], isA<LdConversationSingletonGroup>());
      expect(
        (groups[0] as LdConversationSingletonGroup).item,
        isA<LdSystemPromptItem>(),
      );
      expect(groups[1], isA<LdConversationActivityGroup>());
      expect(groups[2], isA<LdConversationSingletonGroup>());
    });

    test('buffers consecutive tool and reasoning into activity group', () {
      final groups = groupConversationItems([
        const LdUserMessageItem(id: 'u1', text: 'do it'),
        const LdReasoningItem(
          id: 'r1',
          content: 'thinking',
          duration: Duration(seconds: 3),
        ),
        const LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
        ),
        const LdToolCallItem(
          id: 't2',
          name: 'read',
          toolCallId: 'tc2',
          status: LdToolCallStatus.done,
        ),
        const LdAgentMarkdownItem(id: 'a1', markdown: 'done'),
      ]);

      expect(groups, hasLength(3));
      expect(groups[0], isA<LdConversationSingletonGroup>());
      expect(groups[1], isA<LdConversationActivityGroup>());
      expect(groups[2], isA<LdConversationSingletonGroup>());

      final activity = groups[1] as LdConversationActivityGroup;
      expect(activity.items, hasLength(3));
      expect(activity.toolCallCount, 2);
      expect(activity.totalReasoningDuration, const Duration(seconds: 3));
    });

    test('forces pending approval out of collapsed group', () {
      final groups = groupConversationItems(const [
        LdToolCallItem(
          id: 't1',
          name: 'shell',
          toolCallId: 'tc1',
          status: LdToolCallStatus.running,
        ),
        LdApprovalItem(
          id: 'ap1',
          title: 'Run shell?',
          status: LdApprovalStatus.pending,
        ),
        LdReasoningItem(id: 'r1', content: 'after'),
      ]);

      expect(groups, hasLength(3));
      expect(groups[0], isA<LdConversationActivityGroup>());
      expect(
        (groups[0] as LdConversationActivityGroup).items.single,
        isA<LdToolCallItem>(),
      );
      expect(
        (groups[1] as LdConversationSingletonGroup).item,
        isA<LdApprovalItem>(),
      );
      expect(groups[2], isA<LdConversationActivityGroup>());
      expect(
        (groups[2] as LdConversationActivityGroup).items.single,
        isA<LdReasoningItem>(),
      );
    });

    test('allows completed approval inside activity group', () {
      final groups = groupConversationItems(const [
        LdToolCallItem(
          id: 't1',
          name: 'shell',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
        ),
        LdApprovalItem(
          id: 'ap1',
          title: 'Run shell?',
          status: LdApprovalStatus.approved,
        ),
        LdReasoningItem(id: 'r1', content: 'ok'),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single, isA<LdConversationActivityGroup>());
      expect(
        (groups.single as LdConversationActivityGroup).items,
        hasLength(3),
      );
    });

    test('coalesces tool calls sharing toolCallId', () {
      final groups = groupConversationItems(const [
        LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.running,
        ),
        LdToolCallItem(
          id: 't1b',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
          resultPreview: 'ok',
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single, isA<LdConversationActivityGroup>());
      final item =
          (groups.single as LdConversationActivityGroup).items.single
              as LdToolCallItem;
      expect(item.id, 't1b');
      expect(item.status, LdToolCallStatus.done);
      expect(item.resultPreview, 'ok');
    });

    test('single activity item is still an activity group', () {
      final groups = groupConversationItems(const [
        LdReasoningItem(
          id: 'r1',
          content: 'solo',
          isStreaming: true,
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single, isA<LdConversationActivityGroup>());
      expect(
        (groups.single as LdConversationActivityGroup).key,
        'activity-r1',
      );
    });

    test('activity group isActive tracks tools and streaming reasoning', () {
      final idle = LdConversationActivityGroup([
        const LdReasoningItem(
          id: 'r1',
          content: 'done',
          duration: Duration(seconds: 2),
        ),
        const LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
        ),
      ]);
      expect(idle.isActive, isFalse);
      expect(idle.hasStreamingReasoning, isFalse);
      expect(idle.key, 'activity-r1');

      final streaming = LdConversationActivityGroup([
        const LdReasoningItem(
          id: 'r1',
          content: '…',
          isStreaming: true,
        ),
        const LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.done,
        ),
      ]);
      expect(streaming.isActive, isTrue);
      expect(streaming.hasStreamingReasoning, isTrue);

      final running = LdConversationActivityGroup([
        const LdToolCallItem(
          id: 't1',
          name: 'search',
          toolCallId: 'tc1',
          status: LdToolCallStatus.running,
        ),
      ]);
      expect(running.isActive, isTrue);
      expect(running.hasRunningTools, isTrue);
    });

    test('activity group key stays stable when items append', () {
      final first = LdConversationActivityGroup([
        const LdReasoningItem(id: 'r1', content: 'a', isStreaming: true),
      ]);
      final grown = LdConversationActivityGroup([
        const LdReasoningItem(id: 'r1', content: 'a', isStreaming: true),
        const LdToolCallItem(
          id: 't1',
          name: 'x',
          toolCallId: 'tc1',
          status: LdToolCallStatus.running,
        ),
      ]);
      expect(first.key, grown.key);
      expect(first.key, 'activity-r1');
    });
  });
}
