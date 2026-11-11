import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/platform/biometric_bridge.dart';
import '../../core/utils/app_feedback.dart';
import '../../domain/entities/virtual_card_entity.dart';
import '../../domain/repositories/card_repository.dart';

class CardStudioController extends GetxController {
  final CardRepository _cardRepository;
  final BiometricBridge _biometricBridge;

  CardStudioController(this._cardRepository, this._biometricBridge);

  final RxList<VirtualCardEntity> cards = <VirtualCardEntity>[].obs;
  final RxInt selectedCardIndex = 0.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool isLoading = false.obs;

  // New card modal form controllers
  final TextEditingController nicknameController = TextEditingController();
  final RxString selectedSkin = 'titanium_black'.obs;
  final RxDouble newCardLimit = 5000.0.obs;
  final RxBool isNewCardBurner = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  VirtualCardEntity? get currentCard {
    if (cards.isEmpty) return null;
    if (selectedCardIndex.value >= cards.length) {
      selectedCardIndex.value = 0;
    }
    return cards[selectedCardIndex.value];
  }

  Future<void> loadCards() async {
    isLoading.value = true;
    try {
      final loaded = await _cardRepository.getCards();
      cards.assignAll(loaded);
    } catch (e) {
      AppFeedback.showError(message: 'Failed to load card studio: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void selectCard(int index) {
    selectedCardIndex.value = index;
    isRevealed.value = false; // Reset security reveal on card change
    update();
  }

  Future<void> toggleRevealSensitiveDetails() async {
    if (isRevealed.value) {
      isRevealed.value = false;
      update();
      return;
    }

    isAuthenticating.value = true;
    try {
      final authResult = await _biometricBridge.authenticate(
        title: 'PayVault KeyStore Authorization',
        reason: 'Verify biometric identity to unmask PAN and CVV cryptogram',
      );

      if (authResult.authenticated) {
        isRevealed.value = true;
        AppFeedback.showSuccess(
          title: 'Biometric Verified',
          message:
              'Sensitive card details unmasked via Hardware KeyStore enclave',
        );
      } else {
        AppFeedback.showError(
          message: 'Biometric verification cancelled or failed',
        );
      }
    } catch (e) {
      AppFeedback.showError(message: 'Hardware Enclave error: $e');
    } finally {
      isAuthenticating.value = false;
      update();
    }
  }

  Future<void> toggleFreezeCurrentCard() async {
    final card = currentCard;
    if (card == null) return;

    final newFrozenState = !card.isFrozen;
    final updated = card.copyWith(isFrozen: newFrozenState);
    cards[selectedCardIndex.value] = updated;
    update();

    try {
      await _cardRepository.toggleCardFreeze(card.id, newFrozenState);
      if (newFrozenState) {
        AppFeedback.showWarning(
          title: 'Card Frozen',
          message:
              '${card.nickname} has been locked. All incoming contactless & online requests will be declined.',
        );
      } else {
        AppFeedback.showSuccess(
          title: 'Card Unfrozen',
          message:
              '${card.nickname} is active for global contactless and online transactions.',
        );
      }
    } catch (e) {
      cards[selectedCardIndex.value] = card; // rollback
      update();
      AppFeedback.showError(message: 'Failed to update card status: $e');
    }
  }

  Future<void> updateCurrentSpendLimit(double newLimit) async {
    final card = currentCard;
    if (card == null) return;

    final updated = card.copyWith(spendLimit: newLimit);
    cards[selectedCardIndex.value] = updated;
    update();

    try {
      await _cardRepository.updateSpendLimit(card.id, newLimit);
    } catch (e) {
      cards[selectedCardIndex.value] = card;
      update();
      AppFeedback.showError(message: 'Failed to update spend limit: $e');
    }
  }

  Future<void> toggleOnlineControls(bool enabled) async {
    final card = currentCard;
    if (card == null) return;

    final updated = card.copyWith(isOnlineAllowed: enabled);
    cards[selectedCardIndex.value] = updated;
    update();

    try {
      await _cardRepository.updateCardControls(
        cardId: card.id,
        isOnlineAllowed: enabled,
        isAtmAllowed: card.isAtmAllowed,
      );
    } catch (e) {
      cards[selectedCardIndex.value] = card;
      update();
      AppFeedback.showError(message: 'Failed to update controls: $e');
    }
  }

  Future<void> toggleAtmControls(bool enabled) async {
    final card = currentCard;
    if (card == null) return;

    final updated = card.copyWith(isAtmAllowed: enabled);
    cards[selectedCardIndex.value] = updated;
    update();

    try {
      await _cardRepository.updateCardControls(
        cardId: card.id,
        isOnlineAllowed: card.isOnlineAllowed,
        isAtmAllowed: enabled,
      );
    } catch (e) {
      cards[selectedCardIndex.value] = card;
      update();
      AppFeedback.showError(message: 'Failed to update controls: $e');
    }
  }

  Future<bool> createNewVirtualCard() async {
    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty) {
      AppFeedback.showError(message: 'Please provide a valid card nickname');
      return false;
    }

    try {
      final newCard = await _cardRepository.createCard(
        nickname: nickname,
        skinType: selectedSkin.value,
        spendLimit: newCardLimit.value,
        isBurner: isNewCardBurner.value,
      );

      cards.add(newCard);
      selectedCardIndex.value = cards.length - 1;
      nicknameController.clear();
      update();

      AppFeedback.showSuccess(
        title: 'Virtual Card Minted',
        message:
            'Successfully minted ${newCard.nickname} with Hardware Enclave cryptogram',
      );
      return true;
    } catch (e) {
      AppFeedback.showError(message: 'Failed to mint virtual card: $e');
      return false;
    }
  }
}
