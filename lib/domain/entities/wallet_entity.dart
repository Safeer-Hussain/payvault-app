class WalletEntity {
  final String id;
  final String currency;
  final double balance;
  final String symbol;
  final String flagPath;
  final double exchangeRateToUsd;

  const WalletEntity({
    required this.id,
    required this.currency,
    required this.balance,
    required this.symbol,
    required this.flagPath,
    required this.exchangeRateToUsd,
  });

  double get balanceInUsd => balance * exchangeRateToUsd;

  WalletEntity copyWith({
    String? id,
    String? currency,
    double? balance,
    String? symbol,
    String? flagPath,
    double? exchangeRateToUsd,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      symbol: symbol ?? this.symbol,
      flagPath: flagPath ?? this.flagPath,
      exchangeRateToUsd: exchangeRateToUsd ?? this.exchangeRateToUsd,
    );
  }
}
