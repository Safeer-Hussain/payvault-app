import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.currency,
    required super.balance,
    required super.symbol,
    required super.flagPath,
    required super.exchangeRateToUsd,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      currency: map['currency'] as String,
      balance: (map['balance'] as num).toDouble(),
      symbol: map['symbol'] as String,
      flagPath: map['flagPath'] as String,
      exchangeRateToUsd: (map['exchangeRateToUsd'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currency': currency,
      'balance': balance,
      'symbol': symbol,
      'flagPath': flagPath,
      'exchangeRateToUsd': exchangeRateToUsd,
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      currency: entity.currency,
      balance: entity.balance,
      symbol: entity.symbol,
      flagPath: entity.flagPath,
      exchangeRateToUsd: entity.exchangeRateToUsd,
    );
  }
}
