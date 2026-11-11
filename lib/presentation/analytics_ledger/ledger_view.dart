import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ledger_controller.dart';
import 'widgets/spending_doughnut_chart.dart';
import 'widgets/weekly_burn_chart.dart';
import 'widgets/transaction_detail_sheet.dart';

class LedgerView extends StatelessWidget {
  const LedgerView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<LedgerController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => controller.loadTransactions(),
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
    LedgerController controller,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchAndFilters(colorScheme, controller),
          const SizedBox(height: 14),
          Obx(() {
            final _ = controller.transactions.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SpendingDoughnutChart(
                  categoryBreakdown: controller.categoryBreakdown,
                ),
                const SizedBox(height: 14),
                WeeklyBurnChart(weeklyBurn: controller.weeklyBurnData),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text(
            'TRANSACTION AUDIT RECORDS',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildTransactionList(context, colorScheme, controller),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ColorScheme colorScheme,
    LedgerController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pane: Spending & Weekly Charts
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  final _ = controller.transactions.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SpendingDoughnutChart(
                        categoryBreakdown: controller.categoryBreakdown,
                      ),
                      const SizedBox(height: 12),
                      WeeklyBurnChart(weeklyBurn: controller.weeklyBurnData),
                    ],
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        // Right Pane: Search, Category Filter & Transactions
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchAndFilters(colorScheme, controller),
                const SizedBox(height: 12),
                _buildTransactionList(context, colorScheme, controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
    ColorScheme colorScheme,
    LedgerController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        TextField(
          controller: controller.searchController,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search by merchant, memo, or reference ID...',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              onPressed: () => controller.clearSearch(),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
          onChanged: (val) => controller.search(val),
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              return Obx(() {
                final isSelected = controller.selectedCategory.value == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainer,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  onSelected: (val) => controller.filterByCategory(cat),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    ColorScheme colorScheme,
    LedgerController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final txs = controller.transactions;
      if (txs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(28),
          alignment: Alignment.center,
          child: Text(
            'No matching ledger settlements found',
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

          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: colorScheme.surface,
                builder: (context) => TransactionDetailSheet(
                  transaction: tx,
                  controller: controller,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCredit
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCredit
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
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
                          '${tx.formattedDate} • ${tx.category}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      Text(
                        tx.status,
                        style: TextStyle(
                          color: isCredit
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
