import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/network_client.dart';
import '../platform/biometric_bridge.dart';
import '../theme/theme_controller.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../data/repositories/ai_advisor_repository_impl.dart';
import '../../domain/repositories/vault_repository.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/ai_advisor_repository.dart';
import '../../presentation/vault/vault_controller.dart';
import '../../presentation/cards/card_studio_controller.dart';
import '../../presentation/transfers/transfer_controller.dart';
import '../../presentation/ai_advisor/ai_advisor_controller.dart';
import '../../presentation/analytics_ledger/ledger_controller.dart';
import '../../presentation/settings_debug/debug_controller.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 2. Core Bridges & Network
  final biometricBridge = BiometricBridge(prefs);
  getIt.registerSingleton<BiometricBridge>(biometricBridge);

  final networkClient = NetworkClient(prefs);
  getIt.registerSingleton<NetworkClient>(networkClient);

  // 3. Repositories
  final vaultRepo = VaultRepositoryImpl();
  final cardRepo = CardRepositoryImpl();
  final transferRepo = TransferRepositoryImpl();
  final aiRepo = AiAdvisorRepositoryImpl();

  getIt.registerSingleton<VaultRepository>(vaultRepo);
  getIt.registerSingleton<CardRepository>(cardRepo);
  getIt.registerSingleton<TransferRepository>(transferRepo);
  getIt.registerSingleton<AiAdvisorRepository>(aiRepo);

  // 4. Controllers
  final themeController = Get.put(ThemeController(prefs), permanent: true);
  getIt.registerSingleton<ThemeController>(themeController);

  final vaultController = Get.put(VaultController(vaultRepo), permanent: true);
  getIt.registerSingleton<VaultController>(vaultController);

  final cardController = Get.put(
    CardStudioController(cardRepo, biometricBridge),
    permanent: true,
  );
  getIt.registerSingleton<CardStudioController>(cardController);

  final transferController = Get.put(
    TransferController(transferRepo, vaultRepo, biometricBridge),
    permanent: true,
  );
  getIt.registerSingleton<TransferController>(transferController);

  final aiController = Get.put(
    AiAdvisorController(aiRepo, vaultRepo, transferRepo),
    permanent: true,
  );
  getIt.registerSingleton<AiAdvisorController>(aiController);

  final ledgerController = Get.put(
    LedgerController(transferRepo),
    permanent: true,
  );
  getIt.registerSingleton<LedgerController>(ledgerController);

  final debugController = Get.put(
    DebugController(prefs, vaultRepo),
    permanent: true,
  );
  getIt.registerSingleton<DebugController>(debugController);
}
