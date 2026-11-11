import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_feedback.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/repositories/vault_repository.dart';
import '../vault/vault_controller.dart';
import '../cards/card_studio_controller.dart';
import '../analytics_ledger/ledger_controller.dart';

class DebugController extends GetxController {
  final SharedPreferences _prefs;
  final VaultRepository _vaultRepository;

  DebugController(this._prefs, this._vaultRepository);

  final RxBool biometricBypass = false.obs;
  final RxInt simulatedLatency = 450.obs;
  final RxBool force503 = false.obs;

  @override
  void onInit() {
    super.onInit();
    biometricBypass.value =
        _prefs.getBool(AppConstants.keyBiometricBypass) ?? false;
    simulatedLatency.value =
        _prefs.getInt(AppConstants.keySimulatedLatency) ?? 450;
    force503.value = _prefs.getBool(AppConstants.keySimulate503) ?? false;
  }

  Future<void> toggleBiometricBypass(bool value) async {
    biometricBypass.value = value;
    await _prefs.setBool(AppConstants.keyBiometricBypass, value);
    if (value) {
      AppFeedback.showWarning(
        title: 'Recruiter Bypass Engaged',
        message: 'Biometric hardware requirement bypassed for automated testing and review',
      );
    } else {
      AppFeedback.showInfo(
        title: 'Hardware Biometrics Enforced',
        message: 'Hardware KeyStore prompt required for all operations',
      );
    }
    update();
  }

  Future<void> setSimulatedLatency(int ms) async {
    simulatedLatency.value = ms;
    await _prefs.setInt(AppConstants.keySimulatedLatency, ms);
    update();
  }

  Future<void> toggleForce503(bool value) async {
    force503.value = value;
    await _prefs.setBool(AppConstants.keySimulate503, value);
    if (value) {
      AppFeedback.showWarning(
        title: 'Simulated 503 Outage Enabled',
        message: 'Network client will simulate HTTP 503 Server Unavailable on requests',
      );
    } else {
      AppFeedback.showSuccess(
        title: 'Network Restored',
        message: 'Mock network client operating with 100% availability',
      );
    }
    update();
  }

  Future<void> injectWireDeposit(double amount, String currency) async {
    try {
      await _vaultRepository.injectMockDeposit(
        currency: currency,
        amount: amount,
      );
      if (Get.isRegistered<VaultController>()) {
        await Get.find<VaultController>().loadVaultData();
      }
      if (Get.isRegistered<LedgerController>()) {
        await Get.find<LedgerController>().loadTransactions();
      }
      AppFeedback.showSuccess(
        title: 'Inbound Wire Injected',
        message:
            'Simulated institutional settlement of +$amount $currency credited to SQLite vault',
      );
    } catch (e) {
      AppFeedback.showError(message: 'Failed to inject wire: $e');
    }
  }

  Future<void> resetAllData() async {
    try {
      await AppDatabase.resetDatabase();
      if (Get.isRegistered<VaultController>()) {
        await Get.find<VaultController>().loadVaultData();
      }
      if (Get.isRegistered<CardStudioController>()) {
        await Get.find<CardStudioController>().loadCards();
      }
      if (Get.isRegistered<LedgerController>()) {
        await Get.find<LedgerController>().loadTransactions();
      }
      AppFeedback.showSuccess(
        title: 'Database Re-seeded',
        message: 'All vaults, cards, and transaction ledgers restored to factory initial state',
      );
    } catch (e) {
      AppFeedback.showError(message: 'Database reset error: $e');
    }
  }
}
