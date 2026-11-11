class VirtualCardEntity {
  final String id;
  final String cardHolder;
  final String pan;
  final String expiryDate;
  final String cvv;
  final String skinType;
  final bool isFrozen;
  final double spendLimit;
  final double currentMonthSpent;
  final bool isBurner;
  final bool isOnlineAllowed;
  final bool isAtmAllowed;
  final String nickname;

  const VirtualCardEntity({
    required this.id,
    required this.cardHolder,
    required this.pan,
    required this.expiryDate,
    required this.cvv,
    required this.skinType,
    required this.isFrozen,
    required this.spendLimit,
    required this.currentMonthSpent,
    required this.isBurner,
    required this.isOnlineAllowed,
    required this.isAtmAllowed,
    required this.nickname,
  });

  String get maskedPan {
    if (pan.length >= 4) {
      final last4 = pan.substring(pan.length - 4);
      return '**** **** **** $last4';
    }
    return '**** **** **** ****';
  }

  String get formattedPan {
    final cleaned = pan.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  double get utilizationRatio =>
      spendLimit > 0 ? (currentMonthSpent / spendLimit).clamp(0.0, 1.0) : 0.0;

  VirtualCardEntity copyWith({
    String? id,
    String? cardHolder,
    String? pan,
    String? expiryDate,
    String? cvv,
    String? skinType,
    bool? isFrozen,
    double? spendLimit,
    double? currentMonthSpent,
    bool? isBurner,
    bool? isOnlineAllowed,
    bool? isAtmAllowed,
    String? nickname,
  }) {
    return VirtualCardEntity(
      id: id ?? this.id,
      cardHolder: cardHolder ?? this.cardHolder,
      pan: pan ?? this.pan,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      skinType: skinType ?? this.skinType,
      isFrozen: isFrozen ?? this.isFrozen,
      spendLimit: spendLimit ?? this.spendLimit,
      currentMonthSpent: currentMonthSpent ?? this.currentMonthSpent,
      isBurner: isBurner ?? this.isBurner,
      isOnlineAllowed: isOnlineAllowed ?? this.isOnlineAllowed,
      isAtmAllowed: isAtmAllowed ?? this.isAtmAllowed,
      nickname: nickname ?? this.nickname,
    );
  }
}
