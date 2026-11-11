import 'package:pay_vault/core/platform/biometric_bridge.dart';
import 'package:pay_vault/data/models/ai_message_model.dart';
import 'package:pay_vault/domain/entities/contact_entity.dart';
import 'package:pay_vault/domain/entities/transaction_entity.dart';
import 'package:pay_vault/domain/entities/virtual_card_entity.dart';
import 'package:pay_vault/domain/entities/wallet_entity.dart';
import 'package:pay_vault/domain/repositories/ai_advisor_repository.dart';
import 'package:pay_vault/domain/repositories/card_repository.dart';
import 'package:pay_vault/domain/repositories/transfer_repository.dart';
import 'package:pay_vault/domain/repositories/vault_repository.dart';

class FakeVaultRepository implements VaultRepository {
  List<WalletEntity> mockWallets = [
    const WalletEntity(
      id: 'w_usd',
      currency: 'USD',
      balance: 10000.0,
      symbol: '\$',
      flagPath: 'assets/images/flag_usd.png',
      exchangeRateToUsd: 1.0,
    ),
    const WalletEntity(
      id: 'w_eur',
      currency: 'EUR',
      balance: 5000.0,
      symbol: '€',
      flagPath: 'assets/images/flag_eur.png',
      exchangeRateToUsd: 1.10,
    ),
    const WalletEntity(
      id: 'w_gbp',
      currency: 'GBP',
      balance: 2000.0,
      symbol: '£',
      flagPath: 'assets/images/flag_gbp.png',
      exchangeRateToUsd: 1.25,
    ),
  ];

  List<TransactionEntity> mockTransactions = [];

  @override
  Future<List<WalletEntity>> getWallets() async => List.from(mockWallets);

  @override
  Future<WalletEntity?> getWalletByCurrency(String currency) async {
    return mockWallets.where((w) => w.currency == currency).firstOrNull;
  }

  @override
  Future<void> updateWalletBalance(String currency, double newBalance) async {
    final idx = mockWallets.indexWhere((w) => w.currency == currency);
    if (idx != -1) {
      mockWallets[idx] = mockWallets[idx].copyWith(balance: newBalance);
    }
  }

  @override
  Future<void> executeCurrencyExchange({
    required String sourceCurrency,
    required String targetCurrency,
    required double sourceAmount,
    required double targetAmount,
    required double feeAmount,
  }) async {
    final srcIdx = mockWallets.indexWhere((w) => w.currency == sourceCurrency);
    final tgtIdx = mockWallets.indexWhere((w) => w.currency == targetCurrency);
    if (srcIdx == -1 || tgtIdx == -1) throw Exception('Wallet not found');

    final totalDeduction = sourceAmount + feeAmount;
    if (mockWallets[srcIdx].balance < totalDeduction) {
      throw Exception('Insufficient funds');
    }

    mockWallets[srcIdx] = mockWallets[srcIdx].copyWith(
      balance: mockWallets[srcIdx].balance - totalDeduction,
    );
    mockWallets[tgtIdx] = mockWallets[tgtIdx].copyWith(
      balance: mockWallets[tgtIdx].balance + targetAmount,
    );
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions({
    int limit = 10,
  }) async {
    return List.from(mockTransactions);
  }

  @override
  Future<void> injectMockDeposit({
    required String currency,
    required double amount,
  }) async {
    final idx = mockWallets.indexWhere((w) => w.currency == currency);
    if (idx != -1) {
      mockWallets[idx] = mockWallets[idx].copyWith(
        balance: mockWallets[idx].balance + amount,
      );
    }
  }
}

class FakeCardRepository implements CardRepository {
  List<VirtualCardEntity> mockCards = [
    const VirtualCardEntity(
      id: 'c_01',
      cardHolder: 'Safeer Hussain',
      pan: '4532891244098812',
      expiryDate: '08/29',
      cvv: '834',
      skinType: 'titanium_black',
      isFrozen: false,
      spendLimit: 5000.0,
      currentMonthSpent: 1200.0,
      isBurner: false,
      isOnlineAllowed: true,
      isAtmAllowed: true,
      nickname: 'Primary Titanium',
    ),
  ];

  @override
  Future<List<VirtualCardEntity>> getCards() async => List.from(mockCards);

  @override
  Future<VirtualCardEntity?> getCardById(String cardId) async {
    return mockCards.where((c) => c.id == cardId).firstOrNull;
  }

  @override
  Future<void> toggleCardFreeze(String cardId, bool isFrozen) async {
    final idx = mockCards.indexWhere((c) => c.id == cardId);
    if (idx != -1) {
      mockCards[idx] = mockCards[idx].copyWith(isFrozen: isFrozen);
    }
  }

  @override
  Future<void> updateSpendLimit(String cardId, double newLimit) async {
    final idx = mockCards.indexWhere((c) => c.id == cardId);
    if (idx != -1) {
      mockCards[idx] = mockCards[idx].copyWith(spendLimit: newLimit);
    }
  }

  @override
  Future<void> updateCardControls({
    required String cardId,
    required bool isOnlineAllowed,
    required bool isAtmAllowed,
  }) async {
    final idx = mockCards.indexWhere((c) => c.id == cardId);
    if (idx != -1) {
      mockCards[idx] = mockCards[idx].copyWith(
        isOnlineAllowed: isOnlineAllowed,
        isAtmAllowed: isAtmAllowed,
      );
    }
  }

  @override
  Future<VirtualCardEntity> createCard({
    required String nickname,
    required String skinType,
    required double spendLimit,
    required bool isBurner,
  }) async {
    final card = VirtualCardEntity(
      id: 'c_new_${mockCards.length + 1}',
      cardHolder: 'Safeer Hussain',
      pan: '4111222233334444',
      expiryDate: '12/30',
      cvv: '777',
      skinType: skinType,
      isFrozen: false,
      spendLimit: spendLimit,
      currentMonthSpent: 0.0,
      isBurner: isBurner,
      isOnlineAllowed: true,
      isAtmAllowed: !isBurner,
      nickname: nickname,
    );
    mockCards.add(card);
    return card;
  }
}

class FakeTransferRepository implements TransferRepository {
  List<ContactEntity> mockContacts = [
    const ContactEntity(
      id: 'cont_01',
      name: 'Sophia Vance',
      handle: '@sophia.v',
      avatarUrl: 'assets/images/avatar_user.png',
      iban: 'GB29NWBK60161331926819',
      lastTransferDate: 1700000000,
    ),
    const ContactEntity(
      id: 'cont_02',
      name: 'Liam Sterling',
      handle: '@sterling.fx',
      avatarUrl: 'assets/images/avatar_user.png',
      iban: 'US89PBUS10293847561029',
      lastTransferDate: 1700000000,
    ),
  ];

  List<TransactionEntity> mockTransactions = [];

  @override
  Future<List<ContactEntity>> getContacts() async => List.from(mockContacts);

  @override
  Future<ContactEntity> addContact({
    required String name,
    required String handle,
    required String iban,
  }) async {
    final c = ContactEntity(
      id: 'cont_${mockContacts.length + 1}',
      name: name,
      handle: handle,
      avatarUrl: 'assets/images/avatar_user.png',
      iban: iban,
      lastTransferDate: DateTime.now().millisecondsSinceEpoch,
    );
    mockContacts.add(c);
    return c;
  }

  @override
  Future<TransactionEntity> executeP2PTransfer({
    required String recipientName,
    required String recipientHandle,
    required String currency,
    required double amount,
    required String memo,
    required String biometricAuthToken,
  }) async {
    final tx = TransactionEntity(
      id: 'tx_${mockTransactions.length + 1}',
      title: 'Transfer to $recipientName',
      subtitle: memo,
      amount: amount,
      currency: currency,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      category: 'Shopping',
      status: 'Completed',
      type: 'debit',
      referenceId: 'REF-P2P-${mockTransactions.length + 1}',
    );
    mockTransactions.add(tx);
    return tx;
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    String? category,
    String? searchQuery,
  }) async {
    return List.from(mockTransactions);
  }
}

class FakeAiAdvisorRepository implements AiAdvisorRepository {
  List<AiMessageModel> mockMessages = [
    AiMessageModel(
      id: 'm_01',
      text: 'AI Copilot initialized.',
      isUser: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      category: 'General',
    ),
  ];

  @override
  Future<List<AiMessageModel>> getChatHistory() async =>
      List.from(mockMessages);

  @override
  Future<void> saveMessage(AiMessageModel message) async {
    mockMessages.add(message);
  }

  @override
  Stream<String> streamAiAdvice({
    required String prompt,
    required double totalNetWorthUsd,
    required double monthlyBurnRate,
    required String topCategory,
  }) async* {
    yield 'Advisory: ';
    yield 'Optimal ';
    yield 'portfolio ';
    yield 'allocation.';
  }

  @override
  Future<void> clearHistory() async {
    mockMessages.clear();
    mockMessages.add(
      AiMessageModel(
        id: 'm_reset',
        text: 'AI Financial Copilot history reset.',
        isUser: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        category: 'General',
      ),
    );
  }
}

class FakeBiometricBridge extends BiometricBridge {
  FakeBiometricBridge(super.prefs);

  @override
  Future<BiometricAuthResult> authenticate({
    String reason = 'Authorize PayVault Secure Transaction',
    String title = 'Biometric Vault Verification',
  }) async {
    return const BiometricAuthResult(
      authenticated: true,
      token: 'PV-SEC-ENCLAVE-TEST-TOKEN',
      timestamp: 1700000000,
      biometricType: 'FakeEnclaveBiometric',
      signature: 'TEST-SIGNATURE',
    );
  }
}
