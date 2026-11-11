import 'package:flutter_test/flutter_test.dart';
import 'package:pay_vault/presentation/vault/vault_controller.dart';

import '../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVaultRepository fakeVaultRepo;
  late VaultController controller;

  setUp(() {
    fakeVaultRepo = FakeVaultRepository();
    controller = VaultController(fakeVaultRepo);
  });

  tearDown(() {
    controller.onClose();
  });

  group('VaultController Unit Tests', () {
    test('Calculates total liquid net worth in USD accurately across multi-currency vaults', () async {
      await controller.loadVaultData();

      // USD: 10000 * 1.0 = 10000
      // EUR: 5000 * 1.10 = 5500
      // GBP: 2000 * 1.25 = 2500
      // Total = 18000.0 USD
      expect(controller.totalNetWorthUsd, equals(18000.0));
      expect(controller.wallets.length, equals(3));
    });

    test('Switches active selected currency vault', () async {
      await controller.loadVaultData();
      expect(controller.selectedCurrency.value, equals('USD'));

      controller.selectCurrency('EUR');
      expect(controller.selectedCurrency.value, equals('EUR'));
      expect(controller.currentWallet?.currency, equals('EUR'));
    });

    test(
      'Calculates transparent 0.1% FX spread fee and target amount',
      () async {
        await controller.loadVaultData();
        controller.sourceCurrency.value = 'USD';
        controller.targetCurrency.value = 'EUR';
        controller.exchangeAmount.value = 1000.0;

        // Fee: 1000 * 0.001 = 1.0
        expect(controller.transparentFeeAmount, equals(1.0));

        // Conversion rate: 1.0 / 1.10
        final expectedTarget = 1000.0 * (1.0 / 1.10);
        expect(
          controller.calculatedTargetAmount,
          closeTo(expectedTarget, 0.01),
        );
      },
    );

    test('Executes FX swap deducting source vault balance and crediting target vault', () async {
      await controller.loadVaultData();
      controller.sourceCurrency.value = 'USD';
      controller.targetCurrency.value = 'EUR';
      controller.exchangeAmount.value = 1000.0;

      final success = await controller.executeExchange();
      expect(success, isTrue);

      final usdWallet = controller.wallets.firstWhere(
        (w) => w.currency == 'USD',
      );
      // 10000 - 1000 - 1.0 fee = 8999.0
      expect(usdWallet.balance, equals(8999.0));

      final eurWallet = controller.wallets.firstWhere(
        (w) => w.currency == 'EUR',
      );
      expect(eurWallet.balance, greaterThan(5000.0));
    });
  });
}
