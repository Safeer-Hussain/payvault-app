import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/virtual_card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local_database.dart';
import '../models/virtual_card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  @override
  Future<List<VirtualCardEntity>> getCards() async {
    final db = await AppDatabase.database;
    final maps = await db.query('cards', orderBy: 'id ASC');
    return maps.map((m) => VirtualCardModel.fromMap(m)).toList();
  }

  @override
  Future<VirtualCardEntity?> getCardById(String cardId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [cardId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VirtualCardModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> toggleCardFreeze(String cardId, bool isFrozen) async {
    final db = await AppDatabase.database;
    await db.update(
      'cards',
      {'isFrozen': isFrozen ? 1 : 0},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  @override
  Future<void> updateSpendLimit(String cardId, double newLimit) async {
    final db = await AppDatabase.database;
    await db.update(
      'cards',
      {'spendLimit': newLimit},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  @override
  Future<void> updateCardControls({
    required String cardId,
    required bool isOnlineAllowed,
    required bool isAtmAllowed,
  }) async {
    final db = await AppDatabase.database;
    await db.update(
      'cards',
      {
        'isOnlineAllowed': isOnlineAllowed ? 1 : 0,
        'isAtmAllowed': isAtmAllowed ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  @override
  Future<VirtualCardEntity> createCard({
    required String nickname,
    required String skinType,
    required double spendLimit,
    required bool isBurner,
  }) async {
    final db = await AppDatabase.database;

    // Generate valid 16-digit pseudo-PAN
    final p1 = 4000 + _random.nextInt(999);
    final p2 = 1000 + _random.nextInt(8999);
    final p3 = 1000 + _random.nextInt(8999);
    final p4 = 1000 + _random.nextInt(8999);
    final pan = '$p1$p2$p3$p4';

    final expMonth = (_random.nextInt(12) + 1).toString().padLeft(2, '0');
    final expYear = (DateTime.now().year % 100 + 4).toString();
    final expiryDate = '$expMonth/$expYear';
    final cvv = (_random.nextInt(900) + 100).toString();

    final card = VirtualCardModel(
      id: 'c_${_uuid.v4().substring(0, 8)}',
      cardHolder: 'Safeer Hussain',
      pan: pan,
      expiryDate: expiryDate,
      cvv: cvv,
      skinType: skinType,
      isFrozen: false,
      spendLimit: spendLimit,
      currentMonthSpent: 0.0,
      isBurner: isBurner,
      isOnlineAllowed: true,
      isAtmAllowed: !isBurner,
      nickname: nickname,
    );

    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return card;
  }
}
