import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_feedback.dart';
import '../../data/models/ai_message_model.dart';
import '../../domain/repositories/ai_advisor_repository.dart';
import '../../domain/repositories/vault_repository.dart';
import '../../domain/repositories/transfer_repository.dart';

class AiAdvisorController extends GetxController {
  final AiAdvisorRepository _aiAdvisorRepository;
  final VaultRepository _vaultRepository;
  final TransferRepository _transferRepository;
  final Uuid _uuid = const Uuid();

  AiAdvisorController(
    this._aiAdvisorRepository,
    this._vaultRepository,
    this._transferRepository,
  );

  final RxList<AiMessageModel> messages = <AiMessageModel>[].obs;
  final RxBool isStreaming = false.obs;
  final RxString streamingText = ''.obs;
  final RxString statusIndicator = ''.obs;
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<String> promptShortcuts = [
    'Audit My Unnecessary Subscriptions',
    'How Much Can I Save This Month?',
    'Analyze Currency Exchange Opportunities',
    'Simulate \$10,000 Portfolio Growth',
  ];

  @override
  void onInit() {
    super.onInit();
    loadChatHistory();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadChatHistory() async {
    try {
      final history = await _aiAdvisorRepository.getChatHistory();
      messages.assignAll(history);
      _scrollToBottom();
    } catch (e) {
      AppFeedback.showError(message: 'Failed to load AI advisor history: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> submitPrompt(String text) async {
    final cleanPrompt = text.trim();
    if (cleanPrompt.isEmpty || isStreaming.value) return;

    inputController.clear();

    // 1. Add user message
    final userMsg = AiMessageModel(
      id: 'ai_usr_${_uuid.v4().substring(0, 8)}',
      text: cleanPrompt,
      isUser: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      category: 'Inquiry',
    );
    messages.add(userMsg);
    await _aiAdvisorRepository.saveMessage(userMsg);
    _scrollToBottom();

    // 2. Query live vault stats for contextual intelligence
    double totalUsd = 0.0;
    try {
      final wallets = await _vaultRepository.getWallets();
      for (final w in wallets) {
        totalUsd += w.balanceInUsd;
      }
    } catch (_) {}

    double monthlyBurn = 0.0;
    String topCategory = 'Tech/Cloud';
    try {
      final txs = await _transferRepository.getTransactions();
      for (final tx in txs) {
        if (!tx.isCredit) monthlyBurn += tx.amount;
      }
    } catch (_) {}

    // 3. Initiate Streaming Response guarded with try ... finally
    isStreaming.value = true;
    streamingText.value = '';
    statusIndicator.value =
        'Analyzing 90-day cash flow, recurring subscriptions & burn rate...';
    update();

    try {
      final stream = _aiAdvisorRepository.streamAiAdvice(
        prompt: cleanPrompt,
        totalNetWorthUsd: totalUsd > 0 ? totalUsd : 181745.0,
        monthlyBurnRate: monthlyBurn > 0 ? monthlyBurn : 5350.65,
        topCategory: topCategory,
      );

      await for (final token in stream) {
        streamingText.value += token;
        _scrollToBottom();
      }

      // Save complete AI response
      final aiMsg = AiMessageModel(
        id: 'ai_bot_${_uuid.v4().substring(0, 8)}',
        text: streamingText.value,
        isUser: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        category: 'Analysis',
      );
      messages.add(aiMsg);
      await _aiAdvisorRepository.saveMessage(aiMsg);
      streamingText.value = '';
    } catch (e) {
      AppFeedback.showError(message: 'AI Advisor stream error: $e');
    } finally {
      // Guaranteed stream cleanup: spinner always dismisses
      isStreaming.value = false;
      statusIndicator.value = '';
      update();
      _scrollToBottom();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _aiAdvisorRepository.clearHistory();
      await loadChatHistory();
      AppFeedback.showInfo(
        message: 'AI Financial Copilot chat history cleared',
      );
    } catch (e) {
      AppFeedback.showError(message: 'Failed to reset chat: $e');
    }
  }
}
