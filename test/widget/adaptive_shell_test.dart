import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pay_vault/core/theme/app_theme.dart';
import 'package:pay_vault/core/theme/theme_controller.dart';
import 'package:pay_vault/presentation/adaptive_scaffold.dart';
import 'package:pay_vault/presentation/vault/vault_controller.dart';
import 'package:pay_vault/presentation/cards/card_studio_controller.dart';
import 'package:pay_vault/presentation/transfers/transfer_controller.dart';
import 'package:pay_vault/presentation/ai_advisor/ai_advisor_controller.dart';
import 'package:pay_vault/presentation/analytics_ledger/ledger_controller.dart';
import 'package:pay_vault/presentation/settings_debug/debug_controller.dart';
import 'package:pay_vault/presentation/vault/widgets/cash_flow_chart.dart';
import 'package:pay_vault/presentation/analytics_ledger/widgets/weekly_burn_chart.dart';

import '../helpers/mock_repositories.dart';

void main() {
  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final fakeVault = FakeVaultRepository();
    final fakeCard = FakeCardRepository();
    final fakeTransfer = FakeTransferRepository();
    final fakeAi = FakeAiAdvisorRepository();
    final fakeBiometric = FakeBiometricBridge(prefs);

    Get.put(ThemeController(prefs), permanent: true);
    Get.put(VaultController(fakeVault), permanent: true);
    Get.put(CardStudioController(fakeCard, fakeBiometric), permanent: true);
    Get.put(
      TransferController(fakeTransfer, fakeVault, fakeBiometric),
      permanent: true,
    );
    Get.put(
      AiAdvisorController(fakeAi, fakeVault, fakeTransfer),
      permanent: true,
    );
    Get.put(LedgerController(fakeTransfer), permanent: true);
    Get.put(DebugController(prefs, fakeVault), permanent: true);
    Get.put(fakeBiometric, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  group('AdaptiveScaffold & Multi-Tab Widget Tests', () {
    testWidgets(
      'Zero duplicate Hero tag exceptions across the multi-tab shell',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.darkTheme,
            home: const AdaptiveScaffold(),
          ),
        );
        await tester.pumpAndSettle();

        // Find initial Scaffold and verify Vault view is displayed
        expect(find.byType(AdaptiveScaffold), findsOneWidget);
        expect(find.text('EXECUTIVE VAULT'), findsOneWidget);

        // Verify FAB has unique tag and renders
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        // Switch to Card Studio tab (index 1)
        await tester.tap(find.byIcon(Icons.credit_card_outlined));
        await tester.pumpAndSettle();
        expect(find.text('CARD STUDIO'), findsOneWidget);

        // Switch to Transfers tab (index 2)
        await tester.tap(find.byIcon(Icons.swap_horizontal_circle_outlined));
        await tester.pumpAndSettle();
        expect(find.text('SETTLEMENT ENGINE'), findsOneWidget);

        // Switch to Copilot tab (index 3)
        await tester.tap(find.byIcon(Icons.psychology_outlined));
        await tester.pumpAndSettle();
        expect(find.text('AI FINANCIAL COPILOT'), findsOneWidget);

        // Switch to Ledger tab (index 4)
        await tester.tap(find.byIcon(Icons.receipt_long_outlined));
        await tester.pumpAndSettle();
        expect(find.text('TRANSACTION LEDGER'), findsOneWidget);

        // Verify no duplicate Hero tag exceptions occurred
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Zero RenderFlex overflow errors on an 800x360 landscape viewport',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.darkTheme,
            home: const AdaptiveScaffold(),
          ),
        );
        await tester.pumpAndSettle();

        // In landscape, NavigationRail should be active
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        // Verify no RenderFlex overflow
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Full-width charts render cleanly without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  CashFlowChart(),
                  SizedBox(height: 16),
                  WeeklyBurnChart(weeklyBurn: [1000, 1500, 800, 1200]),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashFlowChart), findsOneWidget);
      expect(find.byType(WeeklyBurnChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'ThemeController switches between dark and light themes smoothly',
      (tester) async {
        final themeController = Get.find<ThemeController>();
        expect(themeController.isDarkMode, isTrue);

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            home: const AdaptiveScaffold(),
          ),
        );
        await tester.pumpAndSettle();

        await themeController.toggleTheme();
        expect(themeController.isDarkMode, isFalse);

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
