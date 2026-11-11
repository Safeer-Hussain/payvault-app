import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/platform/biometric_bridge.dart';
import '../../core/theme/theme_controller.dart';
import 'debug_controller.dart';

class RecruiterDebugDrawer extends StatelessWidget {
  const RecruiterDebugDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final debugController = Get.find<DebugController>();
    final themeController = Get.find<ThemeController>();
    final biometricBridge = Get.find<BiometricBridge>();

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recruiter Debug Hub',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Hardware Enclave & Ledger Controls',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Theme Control
                  Text(
                    'APPEARANCE & THEME',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: colorScheme.onSurface,
                      ),
                      title: Text(
                        'Obsidian Dark Mode',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        themeController.isDarkMode
                            ? 'Swiss Ivory Light Mode toggle'
                            : 'Obsidian Gold Dark Mode toggle',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      value: themeController.isDarkMode,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) => themeController.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 24),

                  // 2. Hardware Biometric Enclave
                  Text(
                    'SECURITY & BIOMETRIC ENCLAVE',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.fingerprint_rounded,
                        color: debugController.biometricBypass.value
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                      title: Text(
                        'Bypass Biometric Verification',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Simulate instant hardware approval without system biometric prompts',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      value: debugController.biometricBypass.value,
                      activeThumbColor: colorScheme.error,
                      onChanged: (val) =>
                          debugController.toggleBiometricBypass(val),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<HardwareSecurityStatus>(
                    future: biometricBridge.getHardwareSecurityStatus(),
                    builder: (context, snapshot) {
                      final status = snapshot.data;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Enclave Status: ${status?.enclaveStatus ?? 'VERIFYING'}',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Secure Element: ${status?.keyStoreSecureElement ?? 'StrongBox'}\nTamper Detected: ${status?.hardwareTamperDetected ?? false}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),

                  // 3. Network Simulation
                  Text(
                    'NETWORK SIMULATION',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Network Latency',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${debugController.simulatedLatency.value} ms',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 200,
                          max: 2000,
                          divisions: 18,
                          value: debugController.simulatedLatency.value
                              .toDouble(),
                          activeColor: colorScheme.primary,
                          inactiveColor: colorScheme.surfaceContainerHighest,
                          onChanged: (val) =>
                              debugController.setSimulatedLatency(val.toInt()),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.cloud_off_rounded,
                        color: debugController.force503.value
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                      title: Text(
                        'Force HTTP 503 Outage',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Trigger Core Ledger Maintenance exception on all network calls',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      value: debugController.force503.value,
                      activeThumbColor: colorScheme.error,
                      onChanged: (val) => debugController.toggleForce503(val),
                    ),
                  ),
                  const Divider(height: 24),

                  // 4. Ledger Wire Injection
                  Text(
                    'MOCK WIRE INJECTION',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () =>
                              debugController.injectWireDeposit(5000.0, 'USD'),
                          child: Text(
                            '+ \$5,000',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () =>
                              debugController.injectWireDeposit(15000.0, 'USD'),
                          child: Text(
                            '+ \$15,000',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () =>
                              debugController.injectWireDeposit(50000.0, 'EUR'),
                          child: Text(
                            '+ €50,000',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // 5. Database Reset
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error.withValues(
                        alpha: 0.15,
                      ),
                      foregroundColor: colorScheme.error,
                      elevation: 0,
                      side: BorderSide(
                        color: colorScheme.error.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.restore_page_outlined, size: 18),
                    label: const Text('Reset SQLite Ledger to Factory State'),
                    onPressed: () => debugController.resetAllData(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
