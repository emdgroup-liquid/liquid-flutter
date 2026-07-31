import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) {
  return LdThemeProvider(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    ldDisableAnimations = true;
  });

  tearDown(() {
    ldDisableAnimations = false;
  });

  testWidgets('LdApprovalCard approve callback fires', (tester) async {
    var approved = false;

    await tester.pumpWidget(
      _wrap(
        LdApprovalCard(
          item: const LdApprovalItem(
            id: 'a1',
            title: 'Allow shell?',
            status: LdApprovalStatus.pending,
          ),
          onApprove: () => approved = true,
        ),
      ),
    );

    await tester.tap(find.text('Approve once'));
    await tester.pump();

    expect(approved, isTrue);
  });

  testWidgets('LdApprovalCard shows Approve & allow when toolName set',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        LdApprovalCard(
          item: const LdApprovalItem(
            id: 'a1',
            title: 'Run bash?',
            toolName: 'bash',
            arguments: '{"command":"ls"}',
            status: LdApprovalStatus.pending,
          ),
          onApprove: () {},
          onDeny: () {},
          onApproveWithRule: (_) {},
        ),
      ),
    );

    expect(find.text('Approve & allow'), findsOneWidget);
    expect(find.text('Deny'), findsOneWidget);
    expect(find.text('Approve once'), findsOneWidget);
  });

  testWidgets('LdUsageCostModal shows mix, type, and tool sections',
      (tester) async {
    const totals = LdUsageTotals(
      promptTokens: 100,
      completionTokens: 50,
      totalTokens: 150,
      billedTurnCount: 1,
      estimatedCostUsd: 0.01,
      byModel: [
        LdUsageByModel(
          modelId: 'm',
          displayName: 'Model',
          promptTokens: 100,
          completionTokens: 50,
          totalTokens: 150,
          turnCount: 1,
          estimatedCostUsd: 0.01,
        ),
      ],
      byKind: [
        LdUsageByKind(
          kind: LdUsageKind.user,
          promptTokens: 40,
          completionTokens: 0,
          totalTokens: 40,
          estimatedCostUsd: 0.002,
        ),
        LdUsageByKind(
          kind: LdUsageKind.tools,
          promptTokens: 30,
          completionTokens: 0,
          totalTokens: 30,
          estimatedCostUsd: 0.001,
        ),
        LdUsageByKind(
          kind: LdUsageKind.agent,
          promptTokens: 30,
          completionTokens: 50,
          totalTokens: 80,
          estimatedCostUsd: 0.007,
        ),
      ],
      byTool: [
        LdUsageByTool(
          toolName: 'bash',
          promptTokens: 30,
          completionTokens: 0,
          totalTokens: 30,
          callCount: 2,
          estimatedCostUsd: 0.001,
        ),
      ],
    );

    await tester.pumpWidget(
      _wrap(const LdUsageCostModal(totals: totals)),
    );
    await tester.pump();

    expect(find.text('TOKEN MIX'), findsOneWidget);
    expect(find.text('BY TYPE'), findsOneWidget);
    expect(find.text('Agent'), findsOneWidget);
    expect(find.text('BY TOOL'), findsOneWidget);
    expect(find.text('bash'), findsOneWidget);
    expect(find.text('BY MODEL'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
  });

  testWidgets('LdToolAllowRuleEditor emits onChanged for wildcard',
      (tester) async {
    LdToolAllowRule? changed;
    final rule = LdToolAllowRule.wildcardAll(toolName: 'bash');

    await tester.pumpWidget(
      _wrap(
        LdToolAllowRuleEditor(
          rule: rule,
          onChanged: (next) => changed = next,
        ),
      ),
    );

    await tester.tap(find.text('Require specific arguments'));
    await tester.pump();

    expect(changed, isNotNull);
    expect(changed!.wildcard, isFalse);
    expect(changed!.toolName, 'bash');
  });

  testWidgets('LdToolAllowFieldTree shows Not allowed for optional schema gaps',
      (tester) async {
    final session = ldBuildToolAllowFieldSession(
      inputSchema: {
        'type': 'object',
        'required': ['title'],
        'properties': {
          'title': {'type': 'string'},
          'body': {'type': 'string'},
        },
      },
      arguments: {'title': 'feat'},
    );

    await tester.pumpWidget(
      _wrap(
        LdToolAllowFieldTree(
          session: session,
          onPinChanged: (_, __) {},
        ),
      ),
    );

    expect(find.text('feat'), findsOneWidget);
    expect(find.text('Not allowed'), findsOneWidget);
    expect(find.text('body:'), findsOneWidget);
  });

  test('ldStripGenuiBlocks removes fenced blocks', () {
    const raw = 'Hello\n\n```genui\n{"createSurface":{}}\n```\n\nWorld';
    expect(ldStripGenuiBlocks(raw), contains('Hello'));
    expect(ldStripGenuiBlocks(raw), contains('World'));
    expect(ldStripGenuiBlocks(raw), isNot(contains('```genui')));
  });

  testWidgets('LdComposeBar shows send when text entered', (tester) async {
    final controller = TextEditingController();
    String? sent;

    await tester.pumpWidget(
      _wrap(
        LdScaffold(
          body: LdComposeBar(
            controller: controller,
            onSend: (value) => sent = value,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(sent, 'hello');
  });

  testWidgets('LdSendFlyScope commits immediately when animations disabled',
      (tester) async {
    var committed = false;

    await tester.pumpWidget(
      _wrap(
        LdSendFlyScope(
          child: Builder(
            builder: (context) {
              return LdButton(
                onPressed: () {
                  LdSendFlyScope.of(context).dispatch(
                    const LdUserMessageItem(id: 'm1', text: 'hi'),
                    bubble: const SizedBox.shrink(),
                    onCommitted: () => committed = true,
                  );
                },
                child: const Text('Send'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Send'));
    await tester.pump();

    expect(committed, isTrue);
  });

  testWidgets('LdAgentTaskPanel hides when empty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdAgentTaskPanel(
          tasks: [],
          child: Text('conversation'),
        ),
      ),
    );
    expect(find.byType(LdAgentTaskPanel), findsOneWidget);
    expect(find.text('Tasks'), findsNothing);
    expect(find.text('conversation'), findsOneWidget);
  });

  testWidgets('LdAgentTaskPanel shows tasks in AppBarFrame', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdAgentTaskPanel(
          tasks: [
            LdAgentTask(
              id: 't1',
              label: 'Search docs',
              status: LdAgentTaskStatus.inProgress,
            ),
          ],
          child: Text('conversation'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search docs'), findsOneWidget);
    expect(find.text('conversation'), findsOneWidget);
    expect(find.byType(AppBarFrame), findsOneWidget);
  });

  testWidgets('LdConversationAppear shows child when animations disabled',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdConversationAppear(
          child: Text('agent'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('agent'), findsOneWidget);
  });

  testWidgets('LdStreamReveal shows child and grows with content',
      (tester) async {
    var text = 'Hi';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                LdStreamReveal(
                  active: true,
                  child: Text(text),
                ),
                TextButton(
                  onPressed: () => setState(() => text = 'Hi there friend'),
                  child: const Text('grow'),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Hi'), findsOneWidget);

    await tester.tap(find.text('grow'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hi there friend'), findsOneWidget);
  });

  testWidgets('LdSystemPromptCard is collapsed by default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: LdSystemPromptCard(
            item: LdSystemPromptItem(
              id: 's1',
              content: 'You are a helpful assistant.',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('System prompt'), findsOneWidget);
    expect(
      find.text('You are a helpful assistant.').hitTestable(),
      findsNothing,
    );

    await tester.tap(find.text('System prompt'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('You are a helpful assistant.').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('LdSystemPromptCard honors custom title', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdSystemPromptCard(
          item: LdSystemPromptItem(
            id: 's1',
            title: 'Developer instructions',
            content: 'Always cite sources.',
          ),
          initiallyExpanded: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Developer instructions'), findsOneWidget);
    expect(find.text('Always cite sources.'), findsOneWidget);
  });

  testWidgets('LdReasoningCard shows Thought for when done', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdReasoningCard(
          item: LdReasoningItem(
            id: 'r1',
            content:
                'line1\nline2\nline3\nline4\nlong thought that spans many lines',
            duration: Duration(seconds: 4),
          ),
          isSingleton: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Thought for 4s'), findsOneWidget);
  });

  testWidgets('LdReasoningCard shows streaming content', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: LdReasoningCard(
            item: LdReasoningItem(
              id: 'r1',
              content: 'Streaming thought text',
              isStreaming: true,
            ),
            isSingleton: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Streaming thought text'), findsOneWidget);
    expect(find.textContaining('Thought for'), findsNothing);
  });

  Widget activityItemBuilder(
    BuildContext context,
    LdConversationItem item,
    bool isSingleton,
  ) {
    return LdConversation.defaultItemBuilder(context, item, isSingleton);
  }

  testWidgets('LdAgentActivityGroup shows body while active', (tester) async {
    final group = LdConversationActivityGroup([
      const LdReasoningItem(
        id: 'r1',
        content: 'thinking hard about this problem today',
        isStreaming: true,
      ),
      const LdToolCallItem(
        id: 't1',
        name: 'search_docs',
        toolCallId: 'tc1',
        status: LdToolCallStatus.running,
        argsPreview: '{"q":"x"}',
      ),
    ]);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: LdAgentActivityGroup(
            group: group,
            isActive: true,
            itemBuilder: activityItemBuilder,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('search_docs'), findsOneWidget);
  });

  testWidgets('LdAgentActivityGroup shows summary when inactive', (tester) async {
    final group = LdConversationActivityGroup([
      const LdReasoningItem(
        id: 'r1',
        content: 'done thinking',
        duration: Duration(seconds: 3),
      ),
      const LdToolCallItem(
        id: 't1',
        name: 'search_docs',
        toolCallId: 'tc1',
        status: LdToolCallStatus.done,
      ),
    ]);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: LdAgentActivityGroup(
            group: group,
            isActive: false,
            itemBuilder: activityItemBuilder,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1 tool call · Thought 3s'), findsOneWidget);
  });

  testWidgets('LdAgentActivityGroup animates collapse when becoming inactive',
      (tester) async {
    ldDisableAnimations = false;

    final activeGroup = LdConversationActivityGroup([
      const LdReasoningItem(
        id: 'r1',
        content: 'thinking',
        isStreaming: true,
      ),
      const LdToolCallItem(
        id: 't1',
        name: 'search_docs',
        toolCallId: 'tc1',
        status: LdToolCallStatus.running,
      ),
    ]);
    final idleGroup = LdConversationActivityGroup([
      const LdReasoningItem(
        id: 'r1',
        content: 'thinking',
        duration: Duration(seconds: 2),
      ),
      const LdToolCallItem(
        id: 't1',
        name: 'search_docs',
        toolCallId: 'tc1',
        status: LdToolCallStatus.done,
      ),
    ]);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: LdAgentActivityGroup(
            group: activeGroup,
            isActive: true,
            itemBuilder: activityItemBuilder,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('search_docs'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: LdAgentActivityGroup(
            group: idleGroup,
            isActive: false,
            itemBuilder: activityItemBuilder,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1 tool call · Thought 2s'), findsOneWidget);
  });

  test('ldAgentTaskFocusIndex prefers in-progress then last pending', () {
    expect(
      ldAgentTaskFocusIndex(const [
        LdAgentTask(id: 'a', label: 'A', status: LdAgentTaskStatus.done),
        LdAgentTask(id: 'b', label: 'B', status: LdAgentTaskStatus.inProgress),
        LdAgentTask(id: 'c', label: 'C', status: LdAgentTaskStatus.pending),
      ]),
      1,
    );
    expect(
      ldAgentTaskFocusIndex(const [
        LdAgentTask(id: 'a', label: 'A', status: LdAgentTaskStatus.done),
        LdAgentTask(id: 'b', label: 'B', status: LdAgentTaskStatus.pending),
        LdAgentTask(id: 'c', label: 'C', status: LdAgentTaskStatus.pending),
      ]),
      2,
    );
    expect(
      ldAgentTaskFocusIndex(const [
        LdAgentTask(id: 'a', label: 'A', status: LdAgentTaskStatus.done),
        LdAgentTask(id: 'b', label: 'B', status: LdAgentTaskStatus.failed),
      ]),
      1,
    );
  });

  testWidgets('LdAgentTaskPanel expands and collapses task list', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LdAgentTaskPanel(
          tasks: const [
            LdAgentTask(id: 'a', label: 'Search docs', status: LdAgentTaskStatus.done),
            LdAgentTask(
              id: 'b',
              label: 'Draft reply',
              status: LdAgentTaskStatus.inProgress,
            ),
            LdAgentTask(id: 'c', label: 'Deliver', status: LdAgentTaskStatus.pending),
          ],
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Draft reply'), findsOneWidget);
    expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.chevronDown));
    await tester.pumpAndSettle();

    expect(find.text('Search docs'), findsOneWidget);
    expect(find.text('Deliver'), findsOneWidget);
    expect(find.byIcon(LucideIcons.chevronUp), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.chevronUp));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
  });

  testWidgets('LdAgentTaskPanel peeks open when tasks are added', (tester) async {
    ldDisableAnimations = false;

    await tester.pumpWidget(
      _wrap(
        const LdAgentTaskPanel(
          tasks: [],
          child: SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(
      _wrap(
        const LdAgentTaskPanel(
          tasks: [
            LdAgentTask(id: 'a', label: 'Search docs', status: LdAgentTaskStatus.done),
            LdAgentTask(
              id: 'b',
              label: 'Draft reply',
              status: LdAgentTaskStatus.inProgress,
            ),
            LdAgentTask(id: 'c', label: 'Deliver', status: LdAgentTaskStatus.pending),
          ],
          child: SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(); // post-frame peek start

    expect(find.byIcon(LucideIcons.chevronUp), findsOneWidget);
    expect(find.text('Search docs'), findsOneWidget);
    expect(find.text('Deliver'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
  });

  testWidgets('LdConversation wires approval actions into default item builder',
      (tester) async {
    LdApprovalItem? approved;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          height: 600,
          child: LdConversation(
            items: const [
              LdApprovalItem(
                id: 'ap1',
                title: 'Allow shell?',
                status: LdApprovalStatus.pending,
              ),
            ],
            approval: LdConversationApprovalActions(
              onApprove: (item) => approved = item,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Approve once'));
    await tester.pump();

    expect(approved?.id, 'ap1');
  });

  testWidgets(
    'LdConversation groupBuilder receives resolved itemBuilder',
    (tester) async {
      var itemBuilderInvoked = false;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 600,
            child: LdConversation(
              items: const [
                LdAgentMarkdownItem(id: 'a1', markdown: 'Hello from agent'),
              ],
              groupBuilder: (context, group, itemBuilder) {
                itemBuilderInvoked = true;
                return LdConversation.defaultGroupBuilder(
                  context,
                  group,
                  itemBuilder,
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(itemBuilderInvoked, isTrue);
      expect(find.text('Hello from agent'), findsOneWidget);
    },
  );
}
