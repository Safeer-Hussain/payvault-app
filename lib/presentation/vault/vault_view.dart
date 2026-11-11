import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'vault_controller.dart';
import 'widgets/multi_currency_carousel.dart';
import 'widgets/quick_actions_hub.dart';
import 'widgets/cash_flow_chart.dart';
import '../adaptive_scaffold.dart';

class VaultView extends StatelessWidget {
  const VaultView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<VaultController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_vault_send_money',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text(
          'Send Wire',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () {
          final adaptiveState = context
              .findAncestorStateOfType<AdaptiveScaffoldState>();
          adaptiveState?.switchTab(2); // Switch to Transfers
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadVaultData(),
        color: colorScheme.primary,
        child: isLandscape
            ? _buildLandscapeLayout(context, colorScheme, controller)
            : _buildPortraitLayout(context, colorScheme, controller),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ColorScheme colorScheme,
    VaultController controller,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MultiCurrencyCarousel(),
          const SizedBox(height: 16),
          const QuickActionsHub(),
          const SizedBox(height: 16),
          const CashFlowChart(),
          const SizedBox(height: 20),
          _buildRecentTransactionsHeader(context, colorScheme),
          const SizedBox(height: 10),
          _buildRecentTransactionsList(colorScheme, controller),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ColorScheme colorScheme,
    VaultController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pane (Balance Carousel & Quick Actions)
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                MultiCurrencyCarousel(),
                SizedBox(height: 12),
                QuickActionsHub(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
        // Right Pane (Cash Flow Chart & Recent Transactions)
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CashFlowChart(),
                const SizedBox(height: 14),
                _buildRecentTransactionsHeader(context, colorScheme),
                const SizedBox(height: 8),
                _buildRecentTransactionsList(colorScheme, controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'RECENT LEDGER SETTLEMENTS',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final adaptiveState = context
                .findAncestorStateOfType<AdaptiveScaffoldState>();
            adaptiveState?.switchTab(4); // Switch to Ledger
          },
          child: Text(
            'View All',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList(
    ColorScheme colorScheme,
    VaultController controller,
  ) {
    return Obx(() {
      final txs = controller.recentTransactions;
      if (txs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Text(
            'No transactions recorded yet',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: txs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final tx = txs[index];
          final isCredit = tx.isCredit;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCredit
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCredit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isCredit
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.formattedShortDate} • ${tx.category}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isCredit
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
