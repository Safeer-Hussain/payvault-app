import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../domain/entities/virtual_card_entity.dart';

class FrostedCardWidget extends StatelessWidget {
  final VirtualCardEntity card;
  final bool isRevealed;
  final VoidCallback onRevealTap;

  const FrostedCardWidget({
    super.key,
    required this.card,
    required this.isRevealed,
    required this.onRevealTap,
  });

  String get _skinImagePath {
    switch (card.skinType) {
      case 'platinum_cyber':
        return 'assets/images/card_platinum_cyber.png';
      case 'emerald_eco':
        return 'assets/images/card_emerald_eco.png';
      case 'rose_gold_luxe':
        return 'assets/images/card_rose_gold_luxe.png';
      case 'titanium_black':
      default:
        return 'assets/images/card_titanium_black.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          // Background Texture Image
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              _skinImagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: colorScheme.surfaceContainerHighest);
              },
            ),
          ),

          // High-End Frosted Glass Border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.35),
                width: 1.4,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.15),
                  colorScheme.surface.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),

          // Card Elements
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Logo & Chip & Burner Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'PAYVAULT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (card.isBurner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'BURNER',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Icon(
                          Icons.contactless_rounded,
                          color: colorScheme.onSurface,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),

                // Card PAN
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isRevealed ? card.formattedPan : card.maskedPan,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isRevealed
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: onRevealTap,
                      tooltip: 'Tap to Reveal via Biometrics',
                    ),
                  ],
                ),

                // Bottom Row: Expiry, CVV & Holder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARDHOLDER',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.cardHolder.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRES',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRevealed ? card.expiryDate : '**/**',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CVV',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRevealed ? card.cvv : '***',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Instant Frozen Frost Overlay
          if (card.isFrozen)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                child: Container(
                  color: colorScheme.surface.withValues(alpha: 0.65),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.ac_unit_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CARD FROZEN • ENCLAVE LOCKED',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
