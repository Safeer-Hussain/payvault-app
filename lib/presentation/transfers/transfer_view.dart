import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'transfer_controller.dart';
import 'widgets/p2p_transfer_tab.dart';
import 'widgets/contactless_qr_tab.dart';
import 'widgets/split_bill_tab.dart';

class TransferView extends StatelessWidget {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<TransferController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_scan_qr_pay',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
        label: const Text(
          'Scan QR Pay',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () {
          controller.tabController.animateTo(1); // Switch to QR Pay tab
          controller.simulateQrPaymentScan();
        },
      ),
      body: Column(
        children: [
          // Segmented Tab Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: TabBar(
              controller: controller.tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'P2P Transfer'),
                Tab(text: 'Contactless QR'),
                Tab(text: 'Split Bill'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: const [
                P2pTransferTab(),
                ContactlessQrTab(),
                SplitBillTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
