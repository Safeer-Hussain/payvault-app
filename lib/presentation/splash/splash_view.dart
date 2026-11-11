import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/datasources/local_database.dart';
import '../adaptive_scaffold.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _statusText = 'Initializing SQLite ledger & AES-256 KeyStore...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();

    // Defensively defer all SQLite seeding and precache calls to postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitializationSequence();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _runInitializationSequence() async {
    try {
      // Precache app icon safely after frame render
      if (mounted) {
        await precacheImage(
          const AssetImage('assets/icons/app_icon.png'),
          context,
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _statusText = 'Mounting native Biometric Enclave platform channels...';
      });

      // Warm up SQLite database
      await AppDatabase.database;

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _statusText = 'PayVault Neo-Bank Ready.';
      });

      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      Get.off(
        () => const AdaptiveScaffold(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    } catch (_) {
      // In case of error, proceed safely to main view
      if (mounted) {
        Get.off(
          () => const AdaptiveScaffold(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 400),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(scale: _scaleAnimation, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  color: colorScheme.surfaceContainer,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_balance_outlined,
                        size: 52,
                        color: colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'PAYVAULT',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ENTERPRISE DIGITAL VAULT',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusText,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
