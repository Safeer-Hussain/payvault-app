import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pay_vault/presentation/cards/card_studio_controller.dart';

import '../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCardRepository fakeCardRepo;
  late FakeBiometricBridge fakeBiometricBridge;
  late CardStudioController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeCardRepo = FakeCardRepository();
    fakeBiometricBridge = FakeBiometricBridge(prefs);
    controller = CardStudioController(fakeCardRepo, fakeBiometricBridge);
  });

  tearDown(() {
    controller.onClose();
  });

  group('CardStudioController Unit Tests', () {
    test('Loads cards and selects first card by default', () async {
      await controller.loadCards();
      expect(controller.cards.length, equals(1));
      expect(controller.currentCard?.nickname, equals('Primary Titanium'));
      expect(controller.currentCard?.isFrozen, isFalse);
    });

    test(
      'Toggles freeze and unfreeze status and updates reactive state',
      () async {
        await controller.loadCards();
        expect(controller.currentCard!.isFrozen, isFalse);

        await controller.toggleFreezeCurrentCard();
        expect(controller.currentCard!.isFrozen, isTrue);

        await controller.toggleFreezeCurrentCard();
        expect(controller.currentCard!.isFrozen, isFalse);
      },
    );

    test('Updates monthly spend cap within limits', () async {
      await controller.loadCards();
      expect(controller.currentCard!.spendLimit, equals(5000.0));

      await controller.updateCurrentSpendLimit(7500.0);
      expect(controller.currentCard!.spendLimit, equals(7500.0));
    });

    test('Mints new virtual card and appends to cards list', () async {
      await controller.loadCards();
      controller.nicknameController.text = 'AWS Infrastructure Fleet';
      controller.selectedSkin.value = 'platinum_cyber';
      controller.newCardLimit.value = 8000.0;
      controller.isNewCardBurner.value = false;

      final result = await controller.createNewVirtualCard();
      expect(result, isTrue);
      expect(controller.cards.length, equals(2));
      expect(
        controller.cards.last.nickname,
        equals('AWS Infrastructure Fleet'),
      );
      expect(controller.cards.last.skinType, equals('platinum_cyber'));
    });
  });
}
