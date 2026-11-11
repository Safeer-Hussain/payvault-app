import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/ai_advisor_repository.dart';
import '../datasources/local_database.dart';
import '../models/ai_message_model.dart';

class AiAdvisorRepositoryImpl implements AiAdvisorRepository {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<AiMessageModel>> getChatHistory() async {
    final db = await AppDatabase.database;
    final maps = await db.query('ai_messages', orderBy: 'timestamp ASC');
    return maps.map((m) => AiMessageModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveMessage(AiMessageModel message) async {
    final db = await AppDatabase.database;
    await db.insert(
      'ai_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Stream<String> streamAiAdvice({
    required String prompt,
    required double totalNetWorthUsd,
    required double monthlyBurnRate,
    required String topCategory,
  }) async* {
    String responseText;

    if (prompt.contains('Audit My Unnecessary Subscriptions') ||
        prompt.toLowerCase().contains('subscription')) {
      responseText =
          'Audit Completed: Detected 4 recurring enterprise and consumer cloud subscriptions totaling \$786.50/mo. '
          'Recommendation: Consolidate AWS compute instances to reserved reservations (-32% cost), '
          'and pause idle entertainment licenses. Projected annual capital recapture: \$3,450.00.';
    } else if (prompt.contains('How Much Can I Save This Month?') ||
        prompt.toLowerCase().contains('save')) {
      final potentialSavings = (monthlyBurnRate * 0.22).toStringAsFixed(2);
      responseText =
          'Liquidity Analysis: Based on your current 30-day cash flow, non-essential operational expenditure in $topCategory '
          'represents 34% of outflows. You can conservatively allocate \$$potentialSavings into the High-Yield Treasury Vault '
          'at 5.15% APY without impacting core operational runway.';
    } else if (prompt.contains('Analyze Currency Exchange Opportunities') ||
        prompt.toLowerCase().contains('currency') ||
        prompt.toLowerCase().contains('exchange')) {
      responseText =
          'FX Intelligence Matrix: USD/EUR is currently hovering near mid-market resistance at 1.087. '
          'The European Central Bank rate policy suggests potential EUR consolidation. '
          'Arbitrage Opportunity: Converting 15% of surplus USD holdings into EUR and GBP vaults lock in 0.1% transaction spread '
          'and hedge foreign vendor invoice exposure across the coming quarter.';
    } else if (prompt.contains('Simulate \$10,000 Portfolio Growth') ||
        prompt.toLowerCase().contains('portfolio')) {
      responseText =
          'Deterministic 3-Tier Allocation Simulation for \$10,000.00 Capital Deployment:\n'
          '• Tier 1 (45% - \$4,500): Short-Term US Treasury Bills (5.20% APY) -> Expected 1-Yr Return: \$234.00.\n'
          '• Tier 2 (35% - \$3,500): Global Equity Index ETF (8.40% Historical CAGR) -> Expected 1-Yr Return: \$294.00.\n'
          '• Tier 3 (20% - \$2,000): Multi-Currency FX Vault Arbitrage (4.10% Yield) -> Expected 1-Yr Return: \$82.00.\n'
          'Combined 12-Month Projected Value: \$10,610.00 (+6.10% net risk-adjusted yield).';
    } else {
      responseText =
          'Executive Financial Advisory: Your total net worth across all 5 active currency vaults stands at '
          '\$${totalNetWorthUsd.toStringAsFixed(2)}. Monthly outflow burn is running at \$${monthlyBurnRate.toStringAsFixed(2)}, '
          'with primary expenditure concentrated in $topCategory. Your capital reserve ratio remains exceptionally strong at 18.2x monthly baseline.';
    }

    final words = responseText.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }

  @override
  Future<void> clearHistory() async {
    final db = await AppDatabase.database;
    await db.execute('DELETE FROM ai_messages');
    final welcome = AiMessageModel(
      id: 'ai_msg_${_uuid.v4().substring(0, 8)}',
      text: 'AI Financial Copilot history reset. Ledger intelligence loaded. Ready for your analysis queries.',
      isUser: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      category: 'General',
    );
    await db.insert('ai_messages', welcome.toMap());
  }
}
