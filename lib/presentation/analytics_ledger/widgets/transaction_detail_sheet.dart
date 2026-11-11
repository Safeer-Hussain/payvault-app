import 'package:flutter/material.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../ledger_controller.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionEntity transaction;
  final LedgerController controller;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCredit = transaction.isCredit;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ledger Settlement Audit',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
            const SizedBox(height: 18),

            // Amount Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                    style: TextStyle(
                      color: isCredit
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'Hardware Enclave Verified • ${transaction.status}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildDetailRow(colorScheme, 'Title', transaction.title),
                  const Divider(height: 16),
                  _buildDetailRow(
                    colorScheme,
                    'Description',
                    transaction.subtitle,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    colorScheme,
                    'Category',
                    transaction.category,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    colorScheme,
                    'Timestamp',
                    transaction.formattedDate,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    colorScheme,
                    'Reference ID',
                    transaction.referenceId,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Download Receipt Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text(
                  'Download Cryptographic Receipt (PDF)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.simulateDownloadReceipt(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ColorScheme colorScheme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
