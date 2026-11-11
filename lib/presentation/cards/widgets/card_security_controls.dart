import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../card_studio_controller.dart';

class CardSecurityControls extends StatelessWidget {
  const CardSecurityControls({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<CardStudioController>();

    return Obx(() {
      final card = controller.currentCard;
      if (card == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Quick Security Toggles (Freeze / Unmask)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: card.isFrozen
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: card.isFrozen
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: card.isFrozen
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  icon: Icon(
                    card.isFrozen
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      card.isFrozen ? 'Unfreeze Card' : 'Freeze Card',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onPressed: () => controller.toggleFreezeCurrentCard(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  icon: Icon(
                    controller.isRevealed.value
                        ? Icons.visibility_off_rounded
                        : Icons.fingerprint_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      controller.isRevealed.value
                          ? 'Mask Details'
                          : 'Tap to Reveal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onPressed: () => controller.toggleRevealSensitiveDetails(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Monthly Spend Limit Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'MONTHLY SPEND CAP',
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
                    const SizedBox(width: 8),
                    Text(
                      '\$${card.spendLimit.toStringAsFixed(0)} USD',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  min: 500,
                  max: 10000,
                  divisions: 19,
                  value: card.spendLimit.clamp(500.0, 10000.0),
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.surfaceContainerHighest,
                  onChanged: (val) => controller.updateCurrentSpendLimit(val),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Spent: \$${card.currentMonthSpent.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Remaining: \$${(card.spendLimit - card.currentMonthSpent).clamp(0.0, 10000.0).toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Online & ATM Withdrawal Controls
          Material(
            color: colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.language_rounded,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      'Online E-Commerce Transactions',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Authorize web payment gateways and in-app checkouts',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    value: card.isOnlineAllowed,
                    activeThumbColor: colorScheme.primary,
                    onChanged: (val) => controller.toggleOnlineControls(val),
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.local_atm_rounded,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      'ATM & International Cash Dispense',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Allow physical ATM biometric terminal withdrawals',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    value: card.isAtmAllowed,
                    activeThumbColor: colorScheme.primary,
                    onChanged: (val) => controller.toggleAtmControls(val),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
