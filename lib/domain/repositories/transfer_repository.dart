import '../entities/contact_entity.dart';
import '../entities/transaction_entity.dart';

abstract class TransferRepository {
  Future<List<ContactEntity>> getContacts();
  Future<ContactEntity> addContact({
    required String name,
    required String handle,
    required String iban,
  });
  Future<TransactionEntity> executeP2PTransfer({
    required String recipientName,
    required String recipientHandle,
    required String currency,
    required double amount,
    required String memo,
    required String biometricAuthToken,
  });
  Future<List<TransactionEntity>> getTransactions({
    String? category,
    String? searchQuery,
  });
}
