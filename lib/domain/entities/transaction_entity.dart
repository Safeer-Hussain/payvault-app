import 'package:intl/intl.dart';

class TransactionEntity {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final int timestamp;
  final String category;
  final String status;
  final String type; // 'debit' or 'credit'
  final String referenceId;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.category,
    required this.status,
    required this.type,
    required this.referenceId,
  });

  bool get isCredit => type.toLowerCase() == 'credit';

  String get formattedDate {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy • HH:mm').format(dt);
  }

  String get formattedShortDate {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd').format(dt);
  }

  TransactionEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    String? currency,
    int? timestamp,
    String? category,
    String? status,
    String? type,
    String? referenceId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      status: status ?? this.status,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
