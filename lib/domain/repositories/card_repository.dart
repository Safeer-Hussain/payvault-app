import '../entities/virtual_card_entity.dart';

abstract class CardRepository {
  Future<List<VirtualCardEntity>> getCards();
  Future<VirtualCardEntity?> getCardById(String cardId);
  Future<void> toggleCardFreeze(String cardId, bool isFrozen);
  Future<void> updateSpendLimit(String cardId, double newLimit);
  Future<void> updateCardControls({
    required String cardId,
    required bool isOnlineAllowed,
    required bool isAtmAllowed,
  });
  Future<VirtualCardEntity> createCard({
    required String nickname,
    required String skinType,
    required double spendLimit,
    required bool isBurner,
  });
}
