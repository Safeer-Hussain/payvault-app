abstract final class AppConstants {
  static const String appName = 'PayVault';
  static const String appTagline =
      'Enterprise FinTech Neo-Bank & Digital Vault';
  static const String appVersion = 'v1.4.0-PROD';
  static const String biometricChannelName =
      'com.safeer.payvault/biometric_vault';
  static const String databaseName = 'payvault_ledger.db';
  static const int databaseVersion = 1;

  // KeyStore / Storage keys
  static const String keyThemeMode = 'pv_theme_mode';
  static const String keyBiometricBypass = 'pv_debug_biometric_bypass';
  static const String keySimulatedLatency = 'pv_debug_simulated_latency';
  static const String keySimulate503 = 'pv_debug_force_503';
  static const String keyDatabaseSeeded = 'pv_db_seeded_v1';
}
