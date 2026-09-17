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
    expect(find.textContaining('Agent'), findsOneWidget);
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
          onPinChanged: (_, _) {},
        ),
      ),
    );

    expect(find.text('feat'), findsOneWidget);
    expect(find.text('Not allowed'), findsOneWidget);
    expect(find.text('body:'), findsOneWidget);
  });

  Future<void> pumpAllowPicker(
    WidgetTester tester,
    void Function(LdToolAllowRulePickerResult?) onResult,
  ) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    final result = await ldShowToolAllowRulePicker(
                      context,
                      toolName: 'bash',
                      arguments: '{"command":"ls"}',
                      inputSchema: {
                        'type': 'object',
                        'properties': {
                          'command': {'type': 'string'},
                          'cwd': {'type': 'string'},
                        },
                      },
                    );
                    onResult(result);
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('LdToolAllowRulePickerSheet "Allow used" pins request args',
      (tester) async {
    LdToolAllowRulePickerResult? result;
    await pumpAllowPicker(tester, (r) => result = r);

    await tester.tap(find.text('Allow used'));
    await tester.pumpAndSettle();
    expect(result, isNull);

    await tester.tap(find.text('Approve & save rule'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.approved, isTrue);
    final rule = result!.savedRule!;
    expect(rule.wildcard, isFalse);
    expect(rule.argumentPattern, {'command': 'ls'});
    expect(rule.matches('bash', {'command': 'ls'}), isTrue);
  });

  testWidgets('LdToolAllowRulePickerSheet "Allow any arguments" saves wildcard',
      (tester) async {
    LdToolAllowRulePickerResult? result;
    await pumpAllowPicker(tester, (r) => result = r);

    await tester.tap(find.text('Allow any arguments'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(
      find.text('Any arguments allowed for this tool.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Approve & save rule'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.approved, isTrue);
    expect(result!.savedRule!.wildcard, isTrue);
    expect(result!.savedRule!.matches('bash', {'anything': 1}), isTrue);
  });

  testWidgets(
      'LdToolAllowRulePickerSheet "Allow * for used" wildcards request keys',
      (tester) async {
    LdToolAllowRulePickerResult? result;
    await pumpAllowPicker(tester, (r) => result = r);

    await tester.tap(find.text('Allow * for used'));
    await tester.pumpAndSettle();
    expect(result, isNull);

    await tester.tap(find.text('Approve & save rule'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    final rule = result!.savedRule!;
    expect(rule.wildcard, isFalse);
    expect(rule.argumentPattern, {'command': '*'});
    expect(rule.matches('bash', {'command': 'anything'}), isTrue);
    expect(rule.matches('bash', {'command': 'ls', 'cwd': '/tmp'}), isFalse);
  });

  test('ldStripGenuiBlocks removes fenced blocks', () {
    const raw = 'Hello\n\n```genui\n{"createSurface":{}}\n```\n\nWorld';
    expect(ldStripGenuiBlocks(raw), contains('Hello'));
    expect(ldStripGenuiBlocks(raw), contains('World'));
    expect(ldStripGenuiBlocks(raw), isNot(contains('```genui')));
  });

  testWidgets(
    'LdContextUsageIndicator gauge icon uses button IconTheme size',
    (tester) async {
      const usage = LdContextUsage(
        estimatedTokens: 100,
        contextLimit: 0,
      );

      await tester.pumpWidget(
        _wrap(
          LdContextUsageIndicator(
            contextUsage: usage,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      final icon = tester.widget<Icon>(find.byType(Icon));
      final iconTheme = IconTheme.of(tester.element(find.byType(Icon)));
      expect(icon.size, iconTheme.size);
      expect(icon.size, isNot(14));
    },
  );

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

  testWidgets('LdComposeBar keeps input focus after tapping send',
      (tester) async {
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

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'hello');
    await tester.pump();

    final inputFocusNode = tester.widget<TextField>(textField).focusNode;
    expect(inputFocusNode, isNotNull);
    await tester.tap(find.byKey(const ValueKey('ld-compose-send')));
    await tester.pump();

    expect(sent, 'hello');
    expect(inputFocusNode!.hasPrimaryFocus, isTrue);
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

  testWidgets('LdReasoningCard only scrolls when reasoning is a singleton',
      (tester) async {
    const content =
        'line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8';

    Finder scrollViewIn(WidgetTester tester) => find.descendant(
      of: find.byType(LdReasoningCard),
      matching: find.byType(SingleChildScrollView),
    );

    // Singleton streaming reasoning bounds to the scrolling ticker.
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: LdReasoningCard(
            item: LdReasoningItem(
              id: 'r1',
              content: content,
              isStreaming: true,
            ),
            isSingleton: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(scrollViewIn(tester), findsOneWidget);

    // Grouped (non-singleton) streaming reasoning shows full, unscrolled.
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: LdReasoningCard(
            item: LdReasoningItem(
              id: 'r2',
              content: content,
              isStreaming: true,
            ),
            isSingleton: false,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(scrollViewIn(tester), findsNothing);
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
    expect(find.byIcon(LucideIcons.chevronUp), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.chevronUp));
    await tester.pumpAndSettle();

    expect(find.text('Search docs'), findsOneWidget);
    expect(find.text('Deliver'), findsOneWidget);
    expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.chevronDown));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.chevronUp), findsOneWidget);
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

    expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
    expect(find.text('Search docs'), findsOneWidget);
    expect(find.text('Deliver'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    // Flush scroll-focus delay started while peeking.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byIcon(LucideIcons.chevronUp), findsOneWidget);
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

  testWidgets('LdConversation toolCallOverride replaces tool call card',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          height: 600,
          child: LdConversation(
            items: const [
              LdToolCallItem(
                id: 't1',
                name: 'search_docs',
                toolCallId: 'tc1',
                status: LdToolCallStatus.done,
                resultPreview: '3 docs',
              ),
              LdToolCallItem(
                id: 't2',
                name: 'show_chart',
                toolCallId: 'tc2',
                status: LdToolCallStatus.done,
                resultPreview: 'chart data',
              ),
            ],
            toolCallOverride: (item) {
              if (item.name != 'show_chart') {
                return null;
              }
              return (context) => const Text('RICH_CHART');
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('RICH_CHART'), findsOneWidget);
    expect(find.text('show_chart'), findsNothing);
    expect(find.text('search_docs'), findsOneWidget);
  });

  testWidgets('LdConversation hideBeforeIndex reveals earlier items',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          height: 600,
          child: LdConversation(
            hideBeforeIndex: 2,
            items: const [
              LdUserMessageItem(id: 'u1', text: 'Hidden user message'),
              LdAgentMarkdownItem(id: 'a1', markdown: 'Hidden agent reply'),
              LdUserMessageItem(id: 'u2', text: 'Visible user message'),
              LdAgentMarkdownItem(id: 'a2', markdown: 'Visible agent reply'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hidden user message'), findsNothing);
    expect(find.text('Hidden agent reply'), findsNothing);
    expect(find.text('Visible user message'), findsOneWidget);
    expect(find.text('Visible agent reply'), findsOneWidget);
    expect(find.text('Show 2 earlier messages'), findsOneWidget);

    await tester.tap(find.text('Show 2 earlier messages'));
    await tester.pump();

    expect(find.text('Hidden user message'), findsOneWidget);
    expect(find.text('Hidden agent reply'), findsOneWidget);
    expect(find.text('Show 2 earlier messages'), findsNothing);
  });

  testWidgets('LdConversation opens at the newest message', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          height: 600,
          child: LdConversation(
            items: [
              for (var i = 0; i < 40; i++)
                LdUserMessageItem(id: 'u$i', text: 'Message $i'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Message 39'), findsOneWidget);
    expect(find.text('Message 0'), findsNothing);
  });

  testWidgets('LdConversation follows new items while at the bottom', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    Widget build(List<LdConversationItem> items) => _wrap(
      SizedBox(
        width: 400,
        height: 600,
        child: LdConversation(scrollController: controller, items: items),
      ),
    );

    final items = <LdConversationItem>[
      for (var i = 0; i < 40; i++)
        LdUserMessageItem(id: 'u$i', text: 'Message $i'),
    ];

    await tester.pumpWidget(build(items));
    await tester.pump();
    await tester.pump();
    expect(
      controller.position.pixels,
      closeTo(controller.position.maxScrollExtent, 0.5),
    );

    await tester.pumpWidget(
      build([
        ...items,
        const LdUserMessageItem(id: 'u40', text: 'Message 40'),
      ]),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Message 40'), findsOneWidget);
    expect(
      controller.position.pixels,
      closeTo(controller.position.maxScrollExtent, 0.5),
    );
  });

  testWidgets('LdConversation follows content growth while at the bottom', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var lastHeight = 100.0;

    Widget build(double height) => _wrap(
      SizedBox(
        width: 400,
        height: 600,
        child: LdConversation(
          scrollController: controller,
          group: false,
          itemBuilder: (context, item, isSingleton) => SizedBox(
            height: item.id == 'last' ? height : 50,
            child: Text(item.id),
          ),
          items: [
            for (var i = 0; i < 20; i++)
              LdUserMessageItem(id: 'u$i', text: 'u$i'),
            const LdUserMessageItem(id: 'last', text: 'last'),
          ],
        ),
      ),
    );

    await tester.pumpWidget(build(lastHeight));
    await tester.pump();
    await tester.pump();
    expect(
      controller.position.pixels,
      closeTo(controller.position.maxScrollExtent, 0.5),
    );

    lastHeight = 300;
    await tester.pumpWidget(build(lastHeight));
    await tester.pump();
    await tester.pump();

    expect(
      controller.position.pixels,
      closeTo(controller.position.maxScrollExtent, 0.5),
    );
  });

  testWidgets('LdConversation keeps position when scrolled up', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    Widget build(List<LdConversationItem> items) => _wrap(
      SizedBox(
        width: 400,
        height: 600,
        child: LdConversation(scrollController: controller, items: items),
      ),
    );

    final items = <LdConversationItem>[
      for (var i = 0; i < 40; i++)
        LdUserMessageItem(id: 'u$i', text: 'Message $i'),
    ];

    await tester.pumpWidget(build(items));
    await tester.pump();
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pump();

    final pixelsAfterScrollUp = controller.position.pixels;
    expect(
      controller.position.maxScrollExtent - pixelsAfterScrollUp,
      greaterThan(80),
    );

    await tester.pumpWidget(
      build([
        ...items,
        const LdUserMessageItem(id: 'u40', text: 'Message 40'),
      ]),
    );
    await tester.pump();
    await tester.pump();

    expect(controller.position.pixels, closeTo(pixelsAfterScrollUp, 0.5));
    expect(find.text('Message 40'), findsNothing);
  });

  testWidgets('LdToolCallCard opens detail modal on tap', (tester) async {
    const item = LdToolCallItem(
      id: 't1',
      name: 'search_docs',
      toolCallId: 'tc1',
      status: LdToolCallStatus.done,
      argsPreview: '{"q":"x"}',
      args: '{"q":"full query"}',
      result: 'found 3 docs',
    );

    await tester.pumpWidget(
      _wrap(
        LdToolCallCard(item: item),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('search_docs'));
    await tester.pumpAndSettle();

    expect(find.text('Tool call'), findsOneWidget);
    expect(
      find.text('{\n  "q": "full query"\n}'),
      findsOneWidget,
    );
    expect(find.text('found 3 docs'), findsOneWidget);
  });

  testWidgets('LdToolCallCard onPressed overrides default modal', (tester) async {
    var pressed = false;
    const item = LdToolCallItem(
      id: 't1',
      name: 'search_docs',
      toolCallId: 'tc1',
      status: LdToolCallStatus.done,
    );

    await tester.pumpWidget(
      _wrap(
        LdToolCallCard(
          item: item,
          onPressed: () => pressed = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('search_docs'));
    await tester.pump();

    expect(pressed, isTrue);
    expect(find.text('Tool call'), findsNothing);
  });

  testWidgets('LdTurnErrorCard shows the failure, not assistant markdown',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LdTurnErrorCard(
          item: LdTurnErrorItem(
            id: 'e1',
            message:
                'OpenRouter credits are exhausted, or this request exceeds remaining credit (HTTP 402).',
            code: 'provider_payment_required',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('OpenRouter credits are exhausted'),
      findsOneWidget,
    );
    expect(find.text('Turn failed'), findsOneWidget);
    expect(find.byType(LdHint), findsOneWidget);
  });

  testWidgets('LdConversation renders LdTurnErrorItem via default builder',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          height: 600,
          child: LdConversation(
            items: const [
              LdUserMessageItem(id: 'u1', text: 'hello'),
              LdTurnErrorItem(
                id: 'e1',
                message: 'Gemini returned HTTP 400.',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Gemini returned HTTP 400.'), findsOneWidget);
    expect(find.text('Turn failed'), findsOneWidget);
    expect(find.byType(LdTurnErrorCard), findsOneWidget);
  });
}
