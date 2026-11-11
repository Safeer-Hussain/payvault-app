import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'vault/vault_view.dart';
import 'cards/card_studio_view.dart';
import 'transfers/transfer_view.dart';
import 'ai_advisor/ai_advisor_view.dart';
import 'analytics_ledger/ledger_view.dart';
import 'settings_debug/debug_drawer.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _views = const [
    VaultView(),
    CardStudioView(),
    TransferView(),
    AiAdvisorView(),
    LedgerView(),
  ];

  final List<String> _titles = const [
    'EXECUTIVE VAULT',
    'CARD STUDIO',
    'SETTLEMENT ENGINE',
    'AI FINANCIAL COPILOT',
    'TRANSACTION LEDGER',
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOffline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      if (mounted && _isOffline != isOffline) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final isOffline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    } catch (_) {}
  }

  void switchTab(int index) {
    if (index >= 0 && index < _views.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: colorScheme.surface,
        endDrawer: const RecruiterDebugDrawer(),
        appBar: _buildAppBar(context, colorScheme, isLandscape),
        body: Column(
          children: [
            // Animated Offline Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isOffline ? 32 : 0,
              color: colorScheme.error.withValues(alpha: 0.9),
              alignment: Alignment.center,
              child: _isOffline
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: colorScheme.onError,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline Mode • Serving Local SQLite Vault Ledger',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // Main View Area (Portrait: BottomBar, Landscape: Left NavigationRail)
            Expanded(
              child: isLandscape
                  ? Row(
                      children: [
                        _buildLandscapeNavRail(colorScheme),
                        VerticalDivider(
                          width: 1,
                          color: colorScheme.outlineVariant,
                        ),
                        Expanded(child: _views[_currentIndex]),
                      ],
                    )
                  : _views[_currentIndex],
            ),
          ],
        ),
        bottomNavigationBar: isLandscape
            ? null
            : _buildBottomNavBar(colorScheme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isLandscape,
  ) {
    return PreferredSize(
      preferredSize: Size.fromHeight(isLandscape ? 36 : 56),
      child: AppBar(
        toolbarHeight: isLandscape ? 36 : 56,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: GestureDetector(
          onLongPress: () {
            // Long-press opens Recruiter Debug Hub
            _scaffoldKey.currentState?.openEndDrawer();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isLandscape ? 20 : 28,
                height: isLandscape ? 20 : 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isLandscape ? 6 : 8),
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isLandscape ? 5 : 7),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.shield_outlined,
                        size: isLandscape ? 12 : 16,
                        color: colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _titles[_currentIndex],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: isLandscape ? 11 : 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (!isLandscape)
                    Text(
                      '${AppConstants.appName} • ${AppConstants.appVersion}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.terminal_rounded,
              color: colorScheme.primary,
              size: isLandscape ? 18 : 22,
            ),
            tooltip: 'Recruiter Debug Hub',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildLandscapeNavRail(ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: IntrinsicHeight(
        child: NavigationRail(
          selectedIndex: _currentIndex,
          minWidth: 56,
          labelType: NavigationRailLabelType.none,
          backgroundColor: colorScheme.surfaceContainer,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
          onDestinationSelected: (index) => switchTab(index),
          destinations: [
            NavigationRailDestination(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              selectedIcon: Icon(
                Icons.account_balance_wallet_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              label: const Text('Vault'),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.credit_card_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              selectedIcon: Icon(
                Icons.credit_card_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              label: const Text('Cards'),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.swap_horizontal_circle_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              selectedIcon: Icon(
                Icons.swap_horizontal_circle_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              label: const Text('Transfers'),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.psychology_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              selectedIcon: Icon(
                Icons.psychology_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              label: const Text('Copilot'),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              selectedIcon: Icon(
                Icons.receipt_long_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              label: const Text('Ledger'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        height: 64,
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        onDestinationSelected: (index) => switchTab(index),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.credit_card_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            selectedIcon: Icon(
              Icons.credit_card_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.swap_horizontal_circle_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            selectedIcon: Icon(
              Icons.swap_horizontal_circle_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            label: 'Transfers',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.psychology_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            selectedIcon: Icon(
              Icons.psychology_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            label: 'Copilot',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            label: 'Ledger',
          ),
        ],
      ),
    );
  }
}
