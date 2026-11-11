// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final iconsDir = Directory('assets/icons');
  final imagesDir = Directory('assets/images');
  if (!iconsDir.existsSync()) iconsDir.createSync(recursive: true);
  if (!imagesDir.existsSync()) imagesDir.createSync(recursive: true);

  // 1. Convert app icon from subagent output
  final subagentIcon = File(
    r'C:\Users\safee\.gemini\antigravity\brain\af9cd494-7434-4274-9f5b-404c6df7064a\payvault_app_icon_v3_1794422824924.jpg',
  );
  if (subagentIcon.existsSync()) {
    final bytes = subagentIcon.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final pngBytes = img.encodePng(decoded);
      File('assets/icons/app_icon.png').writeAsBytesSync(pngBytes);
      print('App icon saved to assets/icons/app_icon.png');
    }
  } else {
    // Generate high-res default fallback icon
    final icon = img.Image(width: 512, height: 512);
    img.fill(icon, color: img.ColorRgb8(10, 14, 20));
    // Draw gold accent
    for (int y = 200; y < 312; y++) {
      for (int x = 200; x < 312; x++) {
        icon.setPixelRgb(x, y, 229, 193, 88);
      }
    }
    File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(icon));
  }

  // 2. Generate Card Textures (Titanium Black, Platinum Cyber, Emerald Eco, Rose Gold Luxe)
  final cardSkins = <String, List<img.ColorRgb8>>{
    'card_titanium_black.png': [
      img.ColorRgb8(18, 22, 28),
      img.ColorRgb8(36, 44, 56),
      img.ColorRgb8(229, 193, 88), // gold accent
    ],
    'card_platinum_cyber.png': [
      img.ColorRgb8(35, 45, 65),
      img.ColorRgb8(65, 85, 120),
      img.ColorRgb8(100, 210, 255), // cyan accent
    ],
    'card_emerald_eco.png': [
      img.ColorRgb8(10, 36, 25),
      img.ColorRgb8(20, 70, 48),
      img.ColorRgb8(52, 211, 153), // emerald accent
    ],
    'card_rose_gold_luxe.png': [
      img.ColorRgb8(45, 25, 30),
      img.ColorRgb8(80, 45, 55),
      img.ColorRgb8(244, 164, 164), // rose gold accent
    ],
  };

  cardSkins.forEach((fileName, colors) {
    final image = img.Image(width: 600, height: 380);
    final c1 = colors[0];
    final c2 = colors[1];
    final c3 = colors[2];

    for (int y = 0; y < 380; y++) {
      final t = y / 380.0;
      final r = (c1.r + (c2.r - c1.r) * t).round();
      final g = (c1.g + (c2.g - c1.g) * t).round();
      final b = (c1.b + (c2.b - c1.b) * t).round();

      for (int x = 0; x < 600; x++) {
        // subtle diagonal gradient and micro-grid pattern
        final d = (x + y) / 980.0;
        final fr = (r + (c3.r - r) * (d * 0.25)).clamp(0, 255).round();
        final fg = (g + (c3.g - g) * (d * 0.25)).clamp(0, 255).round();
        final fb = (b + (c3.b - b) * (d * 0.25)).clamp(0, 255).round();
        image.setPixelRgb(x, y, fr, fg, fb);
      }
    }
    File('assets/images/$fileName').writeAsBytesSync(img.encodePng(image));
  });

  // 3. Currency Flags (USD, EUR, GBP, PKR, AED)
  final flagColors = <String, List<img.ColorRgb8>>{
    'flag_usd.png': [img.ColorRgb8(10, 34, 64), img.ColorRgb8(180, 20, 30)],
    'flag_eur.png': [img.ColorRgb8(0, 51, 153), img.ColorRgb8(255, 204, 0)],
    'flag_gbp.png': [img.ColorRgb8(1, 33, 105), img.ColorRgb8(200, 16, 46)],
    'flag_pkr.png': [img.ColorRgb8(1, 65, 28), img.ColorRgb8(245, 245, 245)],
    'flag_aed.png': [img.ColorRgb8(0, 115, 47), img.ColorRgb8(200, 10, 10)],
  };

  flagColors.forEach((fileName, colors) {
    final flag = img.Image(width: 96, height: 64);
    final c1 = colors[0];
    final c2 = colors[1];
    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 96; x++) {
        final col = x < 48 ? c1 : c2;
        flag.setPixelRgb(x, y, col.r.toInt(), col.g.toInt(), col.b.toInt());
      }
    }
    File('assets/images/$fileName').writeAsBytesSync(img.encodePng(flag));
  });

  // 4. Merchant Avatars & User Avatar
  final avatars = <String, img.ColorRgb8>{
    'merchant_aws.png': img.ColorRgb8(255, 153, 0),
    'merchant_apple.png': img.ColorRgb8(150, 150, 155),
    'merchant_uber.png': img.ColorRgb8(30, 30, 30),
    'merchant_starbucks.png': img.ColorRgb8(0, 112, 74),
    'merchant_airbnb.png': img.ColorRgb8(255, 90, 95),
    'avatar_user.png': img.ColorRgb8(229, 193, 88),
  };

  avatars.forEach((fileName, col) {
    final imgAvatar = img.Image(width: 96, height: 96);
    img.fill(imgAvatar, color: img.ColorRgb8(22, 28, 36));
    // Center circle
    for (int y = 0; y < 96; y++) {
      for (int x = 0; x < 96; x++) {
        final dx = x - 48;
        final dy = y - 48;
        if (dx * dx + dy * dy <= 38 * 38) {
          imgAvatar.setPixelRgb(x, y, col.r.toInt(), col.g.toInt(), col.b.toInt());
        }
      }
    }
    File('assets/images/$fileName').writeAsBytesSync(img.encodePng(imgAvatar));
  });

  print('All PayVault luxury assets generated successfully.');
}
