import '../entities/wallet_entity.dart';
import '../entities/transaction_entity.dart';

abstract class VaultRepository {
  Future<List<WalletEntity>> getWallets();
  Future<WalletEntity?> getWalletByCurrency(String currency);
  Future<void> updateWalletBalance(String currency, double newBalance);
  Future<void> executeCurrencyExchange({
    required String sourceCurrency,
    required String targetCurrency,
    required double sourceAmount,
    required double targetAmount,
    required double feeAmount,
  });
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10});
  Future<void> injectMockDeposit({
    required String currency,
    required double amount,
  });
}
