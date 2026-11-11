import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pay_vault/presentation/transfers/transfer_controller.dart';

import '../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransferRepository fakeTransferRepo;
  late FakeVaultRepository fakeVaultRepo;
  late FakeBiometricBridge fakeBiometricBridge;
  late TransferController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeTransferRepo = FakeTransferRepository();
    fakeVaultRepo = FakeVaultRepository();
    fakeBiometricBridge = FakeBiometricBridge(prefs);

    controller = TransferController(
      fakeTransferRepo,
      fakeVaultRepo,
      fakeBiometricBridge,
    );
  });

  tearDown(() {
    controller.onClose();
  });

  group('TransferController Unit Tests', () {
    test('Loads contacts and wallets correctly', () async {
      await controller.loadData();
      expect(controller.contacts.length, equals(2));
      expect(controller.wallets.length, equals(3));
    });

    test('Selects quick payee and populates recipient controller', () async {
      await controller.loadData();
      final contact = controller.contacts.first;
      controller.selectQuickPayee(contact);

      expect(controller.selectedContact.value?.id, equals(contact.id));
      expect(controller.recipientController.text, equals(contact.handle));
    });

    test(
      'Executes P2P transfer with biometric verification and wallet deduction',
      () async {
        await controller.loadData();
        controller.recipientController.text = '@sophia.v';
        controller.amountController.text = '250.00';
        controller.selectedCurrency.value = 'USD';
        controller.memoController.text = 'Consulting retainer';

        final success = await controller.executeP2PTransfer();
        expect(success, isTrue);
        expect(fakeTransferRepo.mockTransactions.length, equals(1));
        expect(fakeTransferRepo.mockTransactions.first.amount, equals(250.0));
      },
    );

    test(
      'Recalculates equal bill split across active participants and self',
      () async {
        await controller.loadData();
        controller.billTotalController.text = '300.00';
        controller.recalculateSplit();

        // 2 contacts + 1 self = 3 people -> 300 / 3 = 100.0 each
        final active = controller.splitParticipants.where((p) => p.isSelected);
        for (final p in active) {
          expect(p.customAmount, equals(100.0));
        }
      },
    );

    test('Generates dynamic merchant contactless QR payload with cryptographic signature', () {
      controller.generateDynamicMerchantQr();
      expect(controller.generatedQrPayload.value.isNotEmpty, isTrue);

      final decoded = jsonDecode(
        controller.generatedQrPayload.value,
      ) as Map<String, dynamic>;
      expect(decoded['merchant'], equals('PayVault Enterprise Merchant'));
      expect(decoded.containsKey('enclaveSignature'), isTrue);
    });
  });
}
