import '../../data/models/ai_message_model.dart';

abstract class AiAdvisorRepository {
  Future<List<AiMessageModel>> getChatHistory();
  Future<void> saveMessage(AiMessageModel message);
  Stream<String> streamAiAdvice({
    required String prompt,
    required double totalNetWorthUsd,
    required double monthlyBurnRate,
    required String topCategory,
  });
  Future<void> clearHistory();
}
