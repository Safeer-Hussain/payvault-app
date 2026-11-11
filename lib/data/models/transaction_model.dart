import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.currency,
    required super.timestamp,
    required super.category,
    required super.status,
    required super.type,
    required super.referenceId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      timestamp: map['timestamp'] as int,
      category: map['category'] as String,
      status: map['status'] as String,
      type: map['type'] as String,
      referenceId: map['referenceId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp,
      'category': category,
      'status': status,
      'type': type,
      'referenceId': referenceId,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      amount: entity.amount,
      currency: entity.currency,
      timestamp: entity.timestamp,
      category: entity.category,
      status: entity.status,
      type: entity.type,
      referenceId: entity.referenceId,
    );
  }
}
