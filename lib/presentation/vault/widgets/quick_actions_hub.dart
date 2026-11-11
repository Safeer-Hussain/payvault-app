import 'package:flutter/material.dart';

import 'currency_exchange_modal.dart';
import '../../adaptive_scaffold.dart';

class QuickActionsHub extends StatelessWidget {
  const QuickActionsHub({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final actions = [
      {
        'label': 'Send Wire',
        'icon': Icons.send_rounded,
        'onTap': () {
          final adaptiveState = context
              .findAncestorStateOfType<AdaptiveScaffoldState>();
          adaptiveState?.switchTab(2); // Transfer tab
        },
      },
      {
        'label': 'Receive / QR',
        'icon': Icons.qr_code_2_rounded,
        'onTap': () {
          final adaptiveState = context
              .findAncestorStateOfType<AdaptiveScaffoldState>();
          adaptiveState?.switchTab(2); // Transfer tab
        },
      },
      {
        'label': 'Exchange',
        'icon': Icons.currency_exchange_rounded,
        'onTap': () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: colorScheme.surface,
            builder: (context) => const CurrencyExchangeModal(),
          );
        },
      },
      {
        'label': 'Analytics',
        'icon': Icons.insights_rounded,
        'onTap': () {
          final adaptiveState = context
              .findAncestorStateOfType<AdaptiveScaffoldState>();
          adaptiveState?.switchTab(4); // Analytics tab
        },
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: item['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
