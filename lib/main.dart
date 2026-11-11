import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint(
          'PayVault Unhandled Flutter Error: ${details.exceptionAsString()}',
        );
      };

      // Keep pre-runApp setup strictly minimal inside defensive try/catch
      try {
        await configureDependencies();
      } catch (e) {
        debugPrint('PayVault Dependency Initialization Warning: $e');
      }

      runApp(const PayVaultApp());
    },
    (error, stack) {
      debugPrint('PayVault Global Zone Caught Exception: $error');
    },
  );
}

class PayVaultApp extends StatelessWidget {
  const PayVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'PayVault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: const SplashView(),
      );
    });
  }
}
