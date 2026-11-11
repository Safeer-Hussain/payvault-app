import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/platform/biometric_bridge.dart';
import '../../core/utils/app_feedback.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/vault_repository.dart';

class SplitParticipant {
  final ContactEntity contact;
  double customAmount;
  bool isSelected;

  SplitParticipant({
    required this.contact,
    required this.customAmount,
    this.isSelected = true,
  });
}

class TransferController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TransferRepository _transferRepository;
  final VaultRepository _vaultRepository;
  final BiometricBridge _biometricBridge;
  final Uuid _uuid = const Uuid();

  TransferController(
    this._transferRepository,
    this._vaultRepository,
    this._biometricBridge,
  );

  TabController? _tabController;
  TabController get tabController => _tabController!;
  set tabController(TabController val) => _tabController = val;

  final RxList<ContactEntity> contacts = <ContactEntity>[].obs;
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingTransfer = false.obs;

  // P2P Form State
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final RxString selectedCurrency = 'USD'.obs;
  final Rx<ContactEntity?> selectedContact = Rx<ContactEntity?>(null);

  // Split Bill State
  final TextEditingController billTotalController = TextEditingController(
    text: '300.00',
  );
  final RxList<SplitParticipant> splitParticipants = <SplitParticipant>[].obs;
  final RxBool isEqualSplit = true.obs;

  // Contactless QR State
  final RxString generatedQrPayload = ''.obs;
  final RxBool isSimulatingScan = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadData();
    generateDynamicMerchantQr();
  }

  @override
  void onClose() {
    _tabController?.dispose();
    recipientController.dispose();
    amountController.dispose();
    memoController.dispose();
    billTotalController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final loadedContacts = await _transferRepository.getContacts();
      final loadedWallets = await _vaultRepository.getWallets();
      contacts.assignAll(loadedContacts);
      wallets.assignAll(loadedWallets);

      // Initialize split participants
      splitParticipants.assignAll(
        loadedContacts
            .take(4)
            .map((c) => SplitParticipant(contact: c, customAmount: 75.0)),
      );
      recalculateSplit();
    } catch (e) {
      AppFeedback.showError(message: 'Failed to load transfer data: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void selectQuickPayee(ContactEntity contact) {
    selectedContact.value = contact;
    recipientController.text = contact.handle;
    update();
  }

  Future<bool> executeP2PTransfer() async {
    final recipient = recipientController.text.trim();
    final amountText = amountController.text.trim();
    final memo = memoController.text.trim();

    if (recipient.isEmpty) {
      AppFeedback.showError(
        message: 'Please specify a recipient handle, IBAN, or email',
      );
      return false;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppFeedback.showError(
        message: 'Enter a valid transfer amount greater than 0',
      );
      return false;
    }

    final wallet = wallets.firstWhereOrNull(
      (w) => w.currency == selectedCurrency.value,
    );
    if (wallet == null) {
      AppFeedback.showError(message: 'Selected currency vault unavailable');
      return false;
    }

    if (wallet.balance < amount) {
      AppFeedback.showError(
        message:
            'Insufficient balance in ${selectedCurrency.value} vault (Current: ${wallet.balance.toStringAsFixed(2)})',
      );
      return false;
    }

    isProcessingTransfer.value = true;
    try {
      // Hardware Biometric Verification
      final authResult = await _biometricBridge.authenticate(
        title: 'Authorize P2P Settlement',
        reason:
            'Authorize transfer of $amount ${selectedCurrency.value} to $recipient',
      );

      if (!authResult.authenticated) {
        AppFeedback.showError(
          message: 'Biometric authorization failed or cancelled',
        );
        return false;
      }

      await _transferRepository.executeP2PTransfer(
        recipientName: selectedContact.value?.name ?? recipient,
        recipientHandle: recipient,
        currency: selectedCurrency.value,
        amount: amount,
        memo: memo,
        biometricAuthToken: authResult.token,
      );

      await loadData();
      amountController.clear();
      memoController.clear();
      recipientController.clear();
      selectedContact.value = null;

      AppFeedback.showSuccess(
        title: 'Settlement Dispatched',
        message:
            'Successfully wired $amount ${selectedCurrency.value} to $recipient via KeyStore cryptogram',
      );
      return true;
    } catch (e) {
      AppFeedback.showError(message: 'Transfer failed: $e');
      return false;
    } finally {
      isProcessingTransfer.value = false;
      update();
    }
  }

  // QR Logic
  void generateDynamicMerchantQr() {
    final payload = {
      'merchant': 'PayVault Enterprise Merchant',
      'vaultId': 'PV-${_uuid.v4().substring(0, 8).toUpperCase()}',
      'currency': selectedCurrency.value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'enclaveSignature':
          'SIG-${_uuid.v4().replaceAll('-', '').substring(0, 24)}',
    };
    generatedQrPayload.value = jsonEncode(payload);
    update();
  }

  Future<void> simulateQrPaymentScan() async {
    isSimulatingScan.value = true;
    update();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final authResult = await _biometricBridge.authenticate(
      title: 'Contactless Merchant Settlement',
      reason: 'Authorize instant NFC/QR settlement for \$125.00 USD',
    );

    isSimulatingScan.value = false;
    update();

    if (authResult.authenticated) {
      AppFeedback.showSuccess(
        title: 'Contactless Payment Approved',
        message: 'Paid \$125.00 USD to verified merchant via Enclave Token',
      );
    } else {
      AppFeedback.showError(message: 'Payment verification failed');
    }
  }

  // Split-Bill Logic
  void toggleEqualSplit(bool equal) {
    isEqualSplit.value = equal;
    recalculateSplit();
  }

  void recalculateSplit() {
    final total = double.tryParse(billTotalController.text.trim()) ?? 0.0;
    final activeCount =
        splitParticipants.where((p) => p.isSelected).length + 1; // +1 for self
    if (activeCount == 0 || total <= 0) return;

    if (isEqualSplit.value) {
      final perPerson = total / activeCount;
      for (final p in splitParticipants) {
        if (p.isSelected) {
          p.customAmount = perPerson;
        }
      }
    }
    update();
  }

  void toggleParticipant(int index, bool selected) {
    splitParticipants[index].isSelected = selected;
    recalculateSplit();
  }

  void triggerSplitPaymentRequests() {
    final total = double.tryParse(billTotalController.text.trim()) ?? 0.0;
    if (total <= 0) {
      AppFeedback.showError(message: 'Please enter a valid bill total');
      return;
    }

    final selectedCount = splitParticipants.where((p) => p.isSelected).length;
    if (selectedCount == 0) {
      AppFeedback.showError(
        message: 'Select at least one participant to split bill',
      );
      return;
    }

    AppFeedback.showSuccess(
      title: 'Payment Requests Sent',
      message:
          'Dispatched dynamic payment links to $selectedCount participants with automated Ledger reminders',
    );
  }
}
