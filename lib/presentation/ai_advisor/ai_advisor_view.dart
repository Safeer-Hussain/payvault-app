import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_advisor_controller.dart';

class AiAdvisorView extends StatelessWidget {
  const AiAdvisorView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<AiAdvisorController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_ai_advisor_clear',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        elevation: 2,
        tooltip: 'Reset Conversation History',
        onPressed: () => controller.clearHistory(),
        child: const Icon(Icons.delete_sweep_outlined, size: 18),
      ),
      body: Column(
        children: [
          // Prompt Shortcuts Carousel
          Container(
            height: 44,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.promptShortcuts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final shortcut = controller.promptShortcuts[index];
                return ActionChip(
                  label: Text(
                    shortcut,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainer,
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => controller.submitPrompt(shortcut),
                );
              },
            ),
          ),

          // Chat Messages List
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              final isStreaming = controller.isStreaming.value;
              final streamingText = controller.streamingText.value;
              final statusIndicator = controller.statusIndicator.value;

              return ListView.builder(
                controller: controller.scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: messages.length + (isStreaming ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    final msg = messages[index];
                    return _buildMessageBubble(
                      context,
                      colorScheme,
                      msg.text,
                      msg.isUser,
                      msg.formattedTime,
                    );
                  }

                  // Active Streaming Bubble
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (statusIndicator.isNotEmpty &&
                              streamingText.isEmpty) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    statusIndicator,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (streamingText.isNotEmpty)
                            Text(
                              streamingText,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Bottom Input Bar - strictly NO MediaQuery viewInsets.bottom duplicate!
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.inputController,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask financial advisor anything...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) => controller.submitPrompt(val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.isStreaming.value
                            ? Icons.hourglass_top_rounded
                            : Icons.arrow_upward_rounded,
                        color: colorScheme.primary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                      onPressed: controller.isStreaming.value
                          ? null
                          : () => controller.submitPrompt(
                              controller.inputController.text,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ColorScheme colorScheme,
    String text,
    bool isUser,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 13,
                height: 1.45,
                fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  color: isUser
                      ? colorScheme.onPrimary.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
