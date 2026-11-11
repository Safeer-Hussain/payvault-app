import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/local_database.dart';
import '../models/contact_model.dart';
import '../models/transaction_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<ContactEntity>> getContacts() async {
    final db = await AppDatabase.database;
    final maps = await db.query('contacts', orderBy: 'lastTransferDate DESC');
    return maps.map((m) => ContactModel.fromMap(m)).toList();
  }

  @override
  Future<ContactEntity> addContact({
    required String name,
    required String handle,
    required String iban,
  }) async {
    final db = await AppDatabase.database;
    final contact = ContactModel(
      id: 'cont_${_uuid.v4().substring(0, 8)}',
      name: name,
      handle: handle.startsWith('@') ? handle : '@$handle',
      avatarUrl: 'assets/images/avatar_user.png',
      iban: iban.toUpperCase(),
      lastTransferDate: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return contact;
  }

  @override
  Future<TransactionEntity> executeP2PTransfer({
    required String recipientName,
    required String recipientHandle,
    required String currency,
    required double amount,
    required String memo,
    required String biometricAuthToken,
  }) async {
    final db = await AppDatabase.database;
    late TransactionModel txModel;

    await db.transaction((txn) async {
      final walletMaps = await txn.query(
        'wallets',
        where: 'currency = ?',
        whereArgs: [currency],
        limit: 1,
      );
      if (walletMaps.isEmpty) {
        throw Exception('Vault wallet $currency not found');
      }
      final currentBal = (walletMaps.first['balance'] as num).toDouble();
      if (currentBal < amount) {
        throw Exception('Insufficient funds in $currency vault');
      }

      // Deduct balance
      await txn.update(
        'wallets',
        {'balance': currentBal - amount},
        where: 'currency = ?',
        whereArgs: [currency],
      );

      // Create transaction
      txModel = TransactionModel(
        id: 'tx_${_uuid.v4().substring(0, 8)}',
        title: 'Transfer to $recipientName',
        subtitle: memo.isNotEmpty ? memo : 'P2P Transfer to $recipientHandle',
        amount: amount,
        currency: currency,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        category: 'Shopping',
        status: 'Completed',
        type: 'debit',
        referenceId: 'P2P-${_uuid.v4().substring(0, 8).toUpperCase()}',
      );
      await txn.insert(
        'transactions',
        txModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update contact if exists
      await txn.update(
        'contacts',
        {'lastTransferDate': DateTime.now().millisecondsSinceEpoch},
        where: 'handle = ?',
        whereArgs: [recipientHandle],
      );
    });

    return txModel;
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    String? category,
    String? searchQuery,
  }) async {
    final db = await AppDatabase.database;
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty && category != 'All') {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final queryCondition =
          '(title LIKE ? OR subtitle LIKE ? OR referenceId LIKE ?)';
      final queryParam = '%${searchQuery.trim()}%';
      if (whereClause != null) {
        whereClause = '$whereClause AND $queryCondition';
      } else {
        whereClause = queryCondition;
      }
      whereArgs.addAll([queryParam, queryParam, queryParam]);
    }

    final maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }
}
