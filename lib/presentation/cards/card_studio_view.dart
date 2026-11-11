import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'card_studio_controller.dart';
import 'widgets/frosted_card_widget.dart';
import 'widgets/card_security_controls.dart';
import 'widgets/new_card_modal.dart';

class CardStudioView extends StatelessWidget {
  const CardStudioView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<CardStudioController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_card_new_virtual',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'New Card',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: colorScheme.surface,
            builder: (context) => const NewCardModal(),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCards(),
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
    CardStudioController controller,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final cards = controller.cards;
        if (cards.isEmpty) {
          return Center(
            child: Text(
              'No virtual cards provisioned',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          );
        }

        final currentIndex = controller.selectedCardIndex.value;
        final current = controller.currentCard!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Carousel Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE ENCLAVE CARDS (${cards.length})',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    current.nickname,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card Widget
            FrostedCardWidget(
              card: current,
              isRevealed: controller.isRevealed.value,
              onRevealTap: () => controller.toggleRevealSensitiveDetails(),
            ),
            const SizedBox(height: 12),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (idx) {
                final isSelected = idx == currentIndex;
                return GestureDetector(
                  onTap: () => controller.selectCard(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Security Controls
            const CardSecurityControls(),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ColorScheme colorScheme,
    CardStudioController controller,
  ) {
    return Obx(() {
      final cards = controller.cards;
      if (cards.isEmpty) {
        return const SizedBox.shrink();
      }
      final current = controller.currentCard!;
      final currentIndex = controller.selectedCardIndex.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane: Card Visual & Selector
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          current.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Card ${currentIndex + 1} of ${cards.length}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FrostedCardWidget(
                    card: current,
                    isRevealed: controller.isRevealed.value,
                    onRevealTap: () =>
                        controller.toggleRevealSensitiveDetails(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cards.length, (idx) {
                      final isSelected = idx == currentIndex;
                      return GestureDetector(
                        onTap: () => controller.selectCard(idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Right Pane: Security Controls
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [CardSecurityControls(), SizedBox(height: 80)],
              ),
            ),
          ),
        ],
      );
    });
  }
}
