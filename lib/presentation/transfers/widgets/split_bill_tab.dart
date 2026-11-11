import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../transfer_controller.dart';

class SplitBillTab extends StatelessWidget {
  const SplitBillTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<TransferController>();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Bill Total Input Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL BILL AMOUNT',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'USD (\$)',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.billTotalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => controller.recalculateSplit(),
                ),
                const SizedBox(height: 12),

                // Equal vs Custom Toggle
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text(
                            'Equal Split',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: controller.isEqualSplit.value,
                          selectedColor: colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          side: BorderSide(
                            color: controller.isEqualSplit.value
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                          onSelected: (val) =>
                              controller.toggleEqualSplit(true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text(
                            'Custom Ratios',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: !controller.isEqualSplit.value,
                          selectedColor: colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          side: BorderSide(
                            color: !controller.isEqualSplit.value
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                          onSelected: (val) =>
                              controller.toggleEqualSplit(false),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Participants Roster Card
          Text(
            'SELECT PARTICIPANTS (2 TO 6)',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Obx(() {
            final participants = controller.splitParticipants;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = participants[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: p.isSelected
                        ? colorScheme.surfaceContainer
                        : colorScheme.surfaceContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: p.isSelected
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: p.isSelected,
                        activeColor: colorScheme.primary,
                        checkColor: colorScheme.onPrimary,
                        onChanged: (val) =>
                            controller.toggleParticipant(index, val ?? false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.contact.name,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              p.contact.handle,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${p.customAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: p.isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 20),

          // Trigger Payment Requests
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.outbox_rounded, size: 20),
              label: const Text(
                'Dispatch Split-Bill Requests',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              onPressed: () => controller.triggerSplitPaymentRequests(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
