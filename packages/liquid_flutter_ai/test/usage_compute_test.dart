import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

void main() {
  group('ldComputeUsage', () {
    test('sums usage and estimates cost', () {
      final pricing = ldModelPricingLookup([
        const LdModelPricing(
          modelId: 'openai/gpt-4o-mini',
          displayName: 'GPT-4o Mini',
          promptPricePerToken: 0.000001,
          completionPricePerToken: 0.000002,
        ),
      ]);

      final totals = ldComputeUsage(
        records: const [
          LdTokenUsageRecord(
            modelId: 'openai/gpt-4o-mini',
            promptTokens: 1000,
            completionTokens: 200,
            totalTokens: 1200,
            kind: LdUsageKind.agent,
          ),
          LdTokenUsageRecord(
            modelId: 'gpt-4o-mini',
            promptTokens: 500,
            completionTokens: 50,
            totalTokens: 550,
            kind: LdUsageKind.agent,
          ),
        ],
        pricingByModelId: pricing,
      );

      expect(totals.promptTokens, 1500);
      expect(totals.completionTokens, 250);
      expect(totals.totalTokens, 1750);
      expect(totals.billedTurnCount, 2);
      expect(totals.byModel.length, 1);
      expect(totals.estimatedCostUsd, closeTo(0.002, 0.0001));
      expect(totals.byKind.length, 1);
      expect(totals.byKind.first.kind, LdUsageKind.agent);
      expect(totals.byKind.first.estimatedCostUsd, closeTo(0.002, 0.0001));
    });

    test('attributes token cost to user and tools', () {
      final pricing = ldModelPricingLookup([
        const LdModelPricing(
          modelId: 'm',
          displayName: 'Model',
          promptPricePerToken: 0.001,
          completionPricePerToken: 0.002,
        ),
      ]);

      final totals = ldComputeUsage(
        pricingByModelId: pricing,
        records: const [
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 10,
            totalTokens: 10,
            kind: LdUsageKind.user,
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 20,
            totalTokens: 20,
            kind: LdUsageKind.tools,
            toolName: 'bash',
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            completionTokens: 5,
            totalTokens: 5,
            kind: LdUsageKind.agent,
          ),
        ],
      );

      final byKind = {for (final k in totals.byKind) k.kind: k};
      expect(byKind[LdUsageKind.user]!.estimatedCostUsd, closeTo(0.01, 1e-9));
      expect(byKind[LdUsageKind.tools]!.estimatedCostUsd, closeTo(0.02, 1e-9));
      expect(byKind[LdUsageKind.agent]!.estimatedCostUsd, closeTo(0.01, 1e-9));
      expect(totals.estimatedCostUsd, closeTo(0.04, 1e-9));
    });

    test('aggregates by tool and sorts by tokens', () {
      final totals = ldComputeUsage(
        records: const [
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 100,
            totalTokens: 100,
            kind: LdUsageKind.tools,
            toolName: 'grep',
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 400,
            totalTokens: 400,
            kind: LdUsageKind.tools,
            toolName: 'bash',
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 50,
            totalTokens: 50,
            kind: LdUsageKind.tools,
            toolName: 'grep',
          ),
        ],
      );

      expect(totals.byTool.map((t) => t.toolName), ['bash', 'grep']);
      expect(totals.byTool.first.totalTokens, 400);
      expect(totals.byTool.first.callCount, 1);
      expect(totals.byTool.last.totalTokens, 150);
      expect(totals.byTool.last.callCount, 2);
    });

    test('ignores zero usage', () {
      final totals = ldComputeUsage(
        records: const [
          LdTokenUsageRecord(modelId: 'x'),
        ],
      );
      expect(totals.hasUsage, isFalse);
      expect(totals.byKind, isEmpty);
      expect(totals.byTool, isEmpty);
    });

    test('splits by kind', () {
      final totals = ldComputeUsage(
        records: const [
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 100,
            totalTokens: 100,
            kind: LdUsageKind.system,
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 50,
            completionTokens: 50,
            totalTokens: 100,
            kind: LdUsageKind.agent,
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            completionTokens: 40,
            totalTokens: 40,
            kind: LdUsageKind.reasoning,
          ),
          LdTokenUsageRecord(
            modelId: 'm',
            promptTokens: 20,
            totalTokens: 20,
            kind: LdUsageKind.tools,
          ),
        ],
      );

      expect(totals.byKind.map((e) => e.kind), [
        LdUsageKind.system,
        LdUsageKind.tools,
        LdUsageKind.agent,
        LdUsageKind.reasoning,
      ]);
      expect(totals.totalTokens, 260);
      expect(totals.chartKinds.map((e) => e.kind), [
        LdUsageKind.tools,
        LdUsageKind.agent,
        LdUsageKind.reasoning,
      ]);
    });
  });

  group('ldNormalizeModelId', () {
    test('strips openrouter provider prefix', () {
      expect(
        ldNormalizeModelId('openrouter:google/gemini-2.5-flash'),
        'google/gemini-2.5-flash',
      );
    });
  });

  group('ldComputeContextUsage', () {
    test('estimates tokens from sources and draft', () {
      final usage = ldComputeContextUsage(
        sources: const [
          LdContextTokenSource(text: 'hello world'),
          LdContextTokenSource(text: 'ignored', excludedFromContext: true),
        ],
        draftText: 'draft',
        contextLimit: 128000,
        lastPromptTokens: 900,
      );

      expect(usage.excludedPieceCount, 1);
      expect(usage.hasLimit, isTrue);
      expect(usage.lastPromptTokens, 900);
      expect(usage.estimatedTokens, greaterThan(0));
      expect(ldFormatContextUsageLabel(usage), contains('/'));
    });
  });

  group('formatters', () {
    test('ldFormatTokenCount', () {
      expect(ldFormatTokenCount(1234567), '1,234,567');
    });

    test('ldFormatUsd', () {
      expect(ldFormatUsd(null), '—');
      expect(ldFormatUsd(0), r'$0.00');
      expect(ldFormatUsd(0.0012), r'$0.0012');
      expect(ldFormatUsd(1.5), r'$1.50');
    });

    test('ldFormatPercent', () {
      expect(ldFormatPercent(0.52), '52%');
      expect(ldFormatPercent(0.004), '<1%');
    });
  });
}
