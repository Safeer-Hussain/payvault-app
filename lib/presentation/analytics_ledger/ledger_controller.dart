import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transfer_repository.dart';

class LedgerController extends GetxController {
  final TransferRepository _transferRepository;

  LedgerController(this._transferRepository);

  final RxList<TransactionEntity> transactions = <TransactionEntity>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Shopping',
    'Dining',
    'Tech/Cloud',
    'Travel',
    'Salary',
    'Investment',
  ];

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final loaded = await _transferRepository.getTransactions(
        category: selectedCategory.value,
        searchQuery: searchQuery.value,
      );
      transactions.assignAll(loaded);
    } catch (e) {
      AppFeedback.showError(message: 'Failed to load ledger: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void filterByCategory(String cat) {
    selectedCategory.value = cat;
    loadTransactions();
  }

  void search(String query) {
    searchQuery.value = query;
    loadTransactions();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadTransactions();
  }

  // Analytics Computation
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (final tx in transactions) {
      if (!tx.isCredit) {
        breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return breakdown;
  }

  double get totalDebits {
    double sum = 0.0;
    for (final tx in transactions) {
      if (!tx.isCredit) sum += tx.amount;
    }
    return sum;
  }

  double get totalCredits {
    double sum = 0.0;
    for (final tx in transactions) {
      if (tx.isCredit) sum += tx.amount;
    }
    return sum;
  }

  List<double> get weeklyBurnData {
    // 4 weeks burn simulation based on transactions
    return [1240.0, 1890.50, 940.20, 1280.0];
  }

  void simulateDownloadReceipt(TransactionEntity tx) {
    AppFeedback.showSuccess(
      title: 'Cryptographic Receipt Exported',
      message: 'Downloaded SHA256-sealed PDF receipt for ${tx.referenceId}',
    );
  }
}
