import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/vault_repository.dart';

class VaultController extends GetxController {
  final VaultRepository _vaultRepository;

  VaultController(this._vaultRepository);

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxList<TransactionEntity> recentTransactions =
      <TransactionEntity>[].obs;
  final RxString selectedCurrency = 'USD'.obs;
  final RxBool isLoading = false.obs;

  // Currency Exchange State
  final RxString sourceCurrency = 'USD'.obs;
  final RxString targetCurrency = 'EUR'.obs;
  final RxDouble exchangeAmount = 1000.0.obs;
  final TextEditingController amountController = TextEditingController(
    text: '1000',
  );

  @override
  void onInit() {
    super.onInit();
    loadVaultData();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> loadVaultData() async {
    isLoading.value = true;
    try {
      final loadedWallets = await _vaultRepository.getWallets();
      final loadedTx = await _vaultRepository.getRecentTransactions(limit: 6);
      wallets.assignAll(loadedWallets);
      recentTransactions.assignAll(loadedTx);
    } catch (e) {
      AppFeedback.showError(message: 'Failed to load vault data: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  WalletEntity? get currentWallet {
    return wallets.firstWhereOrNull(
          (w) => w.currency == selectedCurrency.value,
        ) ??
        (wallets.isNotEmpty ? wallets.first : null);
  }

  double get totalNetWorthUsd {
    double total = 0.0;
    for (final w in wallets) {
      total += w.balanceInUsd;
    }
    return total;
  }

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    update();
  }

  // FX Calculation
  double get conversionRate {
    final src = wallets.firstWhereOrNull(
      (w) => w.currency == sourceCurrency.value,
    );
    final tgt = wallets.firstWhereOrNull(
      (w) => w.currency == targetCurrency.value,
    );
    if (src == null || tgt == null || tgt.exchangeRateToUsd == 0) return 1.0;
    return src.exchangeRateToUsd / tgt.exchangeRateToUsd;
  }

  double get calculatedTargetAmount {
    return exchangeAmount.value * conversionRate;
  }

  double get transparentFeeAmount {
    return exchangeAmount.value * 0.001; // 0.1% transparent spread
  }

  Future<bool> executeExchange() async {
    final src = wallets.firstWhereOrNull(
      (w) => w.currency == sourceCurrency.value,
    );
    if (src == null) {
      AppFeedback.showError(message: 'Invalid source currency selected');
      return false;
    }

    final totalDeduction = exchangeAmount.value + transparentFeeAmount;
    if (src.balance < totalDeduction) {
      AppFeedback.showError(
        message:
            'Insufficient balance in ${sourceCurrency.value} vault. Required: ${totalDeduction.toStringAsFixed(2)} ${sourceCurrency.value}',
      );
      return false;
    }

    try {
      await _vaultRepository.executeCurrencyExchange(
        sourceCurrency: sourceCurrency.value,
        targetCurrency: targetCurrency.value,
        sourceAmount: exchangeAmount.value,
        targetAmount: calculatedTargetAmount,
        feeAmount: transparentFeeAmount,
      );

      await loadVaultData();
      AppFeedback.showSuccess(
        title: 'FX Swap Executed',
        message:
            'Exchanged ${exchangeAmount.value.toStringAsFixed(2)} ${sourceCurrency.value} for ${calculatedTargetAmount.toStringAsFixed(2)} ${targetCurrency.value}',
      );
      return true;
    } catch (e) {
      AppFeedback.showError(message: 'Exchange failed: $e');
      return false;
    }
  }
}
