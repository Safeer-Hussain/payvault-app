import '../../domain/entities/virtual_card_entity.dart';

class VirtualCardModel extends VirtualCardEntity {
  const VirtualCardModel({
    required super.id,
    required super.cardHolder,
    required super.pan,
    required super.expiryDate,
    required super.cvv,
    required super.skinType,
    required super.isFrozen,
    required super.spendLimit,
    required super.currentMonthSpent,
    required super.isBurner,
    required super.isOnlineAllowed,
    required super.isAtmAllowed,
    required super.nickname,
  });

  factory VirtualCardModel.fromMap(Map<String, dynamic> map) {
    return VirtualCardModel(
      id: map['id'] as String,
      cardHolder: map['cardHolder'] as String,
      pan: map['pan'] as String,
      expiryDate: map['expiryDate'] as String,
      cvv: map['cvv'] as String,
      skinType: map['skinType'] as String,
      isFrozen: (map['isFrozen'] as int) == 1,
      spendLimit: (map['spendLimit'] as num).toDouble(),
      currentMonthSpent: (map['currentMonthSpent'] as num).toDouble(),
      isBurner: (map['isBurner'] as int) == 1,
      isOnlineAllowed: (map['isOnlineAllowed'] as int) == 1,
      isAtmAllowed: (map['isAtmAllowed'] as int) == 1,
      nickname: map['nickname'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardHolder': cardHolder,
      'pan': pan,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'skinType': skinType,
      'isFrozen': isFrozen ? 1 : 0,
      'spendLimit': spendLimit,
      'currentMonthSpent': currentMonthSpent,
      'isBurner': isBurner ? 1 : 0,
      'isOnlineAllowed': isOnlineAllowed ? 1 : 0,
      'isAtmAllowed': isAtmAllowed ? 1 : 0,
      'nickname': nickname,
    };
  }

  factory VirtualCardModel.fromEntity(VirtualCardEntity entity) {
    return VirtualCardModel(
      id: entity.id,
      cardHolder: entity.cardHolder,
      pan: entity.pan,
      expiryDate: entity.expiryDate,
      cvv: entity.cvv,
      skinType: entity.skinType,
      isFrozen: entity.isFrozen,
      spendLimit: entity.spendLimit,
      currentMonthSpent: entity.currentMonthSpent,
      isBurner: entity.isBurner,
      isOnlineAllowed: entity.isOnlineAllowed,
      isAtmAllowed: entity.isAtmAllowed,
      nickname: entity.nickname,
    );
  }
}
