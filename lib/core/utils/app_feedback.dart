import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppFeedback {
  static void showSuccess({
    required String message,
    String title = 'Operation Successful',
  }) {
    if (Get.testMode || Get.key.currentState == null) return;
    try {
      final context = Get.context;
      final colorScheme = context != null
          ? Theme.of(context).colorScheme
          : null;
      final bg =
          colorScheme?.surfaceContainerHighest ?? const Color(0xFF192231);
      final fg = colorScheme?.onSurface ?? const Color(0xFFF8FAFC);
      final accent = colorScheme?.primary ?? const Color(0xFF10B981);

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: bg,
        colorText: fg,
        icon: Icon(Icons.check_circle_rounded, color: accent, size: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 14,
        borderWidth: 1,
        borderColor: accent.withValues(alpha: 0.35),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  static void showWarning({
    required String message,
    String title = 'Attention Required',
  }) {
    if (Get.testMode || Get.key.currentState == null) return;
    try {
      final context = Get.context;
      final colorScheme = context != null
          ? Theme.of(context).colorScheme
          : null;
      final bg =
          colorScheme?.surfaceContainerHighest ?? const Color(0xFF192231);
      final fg = colorScheme?.onSurface ?? const Color(0xFFF8FAFC);

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: bg,
        colorText: fg,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFF59E0B),
          size: 24,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 14,
        borderWidth: 1,
        borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  static void showError({
    required String message,
    String title = 'Action Failed',
  }) {
    if (Get.testMode || Get.key.currentState == null) return;
    try {
      final context = Get.context;
      final colorScheme = context != null
          ? Theme.of(context).colorScheme
          : null;
      final bg =
          colorScheme?.surfaceContainerHighest ?? const Color(0xFF192231);
      final fg = colorScheme?.onSurface ?? const Color(0xFFF8FAFC);
      final err = colorScheme?.error ?? const Color(0xFFEF4444);

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: bg,
        colorText: fg,
        icon: Icon(Icons.error_outline_rounded, color: err, size: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 14,
        borderWidth: 1,
        borderColor: err.withValues(alpha: 0.35),
        duration: const Duration(seconds: 4),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  static void showInfo({
    required String message,
    String title = 'Vault Notification',
  }) {
    if (Get.testMode || Get.key.currentState == null) return;
    try {
      final context = Get.context;
      final colorScheme = context != null
          ? Theme.of(context).colorScheme
          : null;
      final bg =
          colorScheme?.surfaceContainerHighest ?? const Color(0xFF192231);
      final fg = colorScheme?.onSurface ?? const Color(0xFFF8FAFC);
      final tertiary = colorScheme?.tertiary ?? const Color(0xFF06B6D4);

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: bg,
        colorText: fg,
        icon: Icon(Icons.info_outline_rounded, color: tertiary, size: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 14,
        borderWidth: 1,
        borderColor: tertiary.withValues(alpha: 0.35),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }
}
