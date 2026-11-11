import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../card_studio_controller.dart';

class NewCardModal extends StatefulWidget {
  const NewCardModal({super.key});

  @override
  State<NewCardModal> createState() => _NewCardModalState();
}

class _NewCardModalState extends State<NewCardModal> {
  final CardStudioController controller = Get.find<CardStudioController>();
  String? _nicknameError;

  final List<Map<String, String>> skinOptions = [
    {'id': 'titanium_black', 'name': 'Titanium Black'},
    {'id': 'platinum_cyber', 'name': 'Platinum Cyber'},
    {'id': 'emerald_eco', 'name': 'Emerald Eco'},
    {'id': 'rose_gold_luxe', 'name': 'Rose Gold Luxe'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
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
                        Icons.add_card_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mint Virtual Card',
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

              // Nickname Input
              Text(
                'CARD NICKNAME / PURPOSE',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nicknameController,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. AWS Production Fleet, Uber Business',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  errorText: _nicknameError,
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
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
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (val.trim().isNotEmpty && _nicknameError != null) {
                    setState(() {
                      _nicknameError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 18),

              // Skin Selector
              Text(
                'ENCLAVE MATERIAL & SKIN',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final current = controller.selectedSkin.value;
                return Row(
                  children: skinOptions.map((skin) {
                    final isSel = skin['id'] == current;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () =>
                              controller.selectedSkin.value = skin['id']!,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: isSel ? 1.6 : 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              skin['name']!.split(' ').first,
                              maxLines: 1,
                              style: TextStyle(
                                color: isSel
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 18),

              // Spending Cap
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MONTHLY LIMIT',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '\$${controller.newCardLimit.value.toStringAsFixed(0)} USD',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      min: 500,
                      max: 10000,
                      divisions: 19,
                      value: controller.newCardLimit.value,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.surfaceContainerHighest,
                      onChanged: (val) => controller.newCardLimit.value = val,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Burner Card Toggle
              Obx(
                () => Material(
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.flash_on_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        'Single-Use Burner Shield',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically self-destructs after single transaction',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      value: controller.isNewCardBurner.value,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) =>
                          controller.isNewCardBurner.value = val,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mint Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (controller.nicknameController.text.trim().isEmpty) {
                      setState(() {
                        _nicknameError = 'Please enter a card nickname';
                      });
                      return;
                    }
                    final navigator = Navigator.of(context);
                    final ok = await controller.createNewVirtualCard();
                    if (ok && mounted) {
                      navigator.pop();
                    }
                  },
                  child: const Text(
                    'Mint Hardware Enclave Card',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
