import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/local_database.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

class VaultRepositoryImpl implements VaultRepository {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<WalletEntity>> getWallets() async {
    final db = await AppDatabase.database;
    final maps = await db.query('wallets', orderBy: 'id ASC');
    return maps.map((m) => WalletModel.fromMap(m)).toList();
  }

  @override
  Future<WalletEntity?> getWalletByCurrency(String currency) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'wallets',
      where: 'currency = ?',
      whereArgs: [currency],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateWalletBalance(String currency, double newBalance) async {
    final db = await AppDatabase.database;
    await db.update(
      'wallets',
      {'balance': newBalance},
      where: 'currency = ?',
      whereArgs: [currency],
    );
  }

  @override
  Future<void> executeCurrencyExchange({
    required String sourceCurrency,
    required String targetCurrency,
    required double sourceAmount,
    required double targetAmount,
    required double feeAmount,
  }) async {
    final db = await AppDatabase.database;
    await db.transaction((txn) async {
      // 1. Deduct from source wallet
      final sourceMaps = await txn.query(
        'wallets',
        where: 'currency = ?',
        whereArgs: [sourceCurrency],
        limit: 1,
      );
      if (sourceMaps.isEmpty) throw Exception('Source wallet not found');
      final currentSourceBal = (sourceMaps.first['balance'] as num).toDouble();
      if (currentSourceBal < (sourceAmount + feeAmount)) {
        throw Exception('Insufficient funds in $sourceCurrency vault');
      }
      final newSourceBal = currentSourceBal - (sourceAmount + feeAmount);
      await txn.update(
        'wallets',
        {'balance': newSourceBal},
        where: 'currency = ?',
        whereArgs: [sourceCurrency],
      );

      // 2. Add to target wallet
      final targetMaps = await txn.query(
        'wallets',
        where: 'currency = ?',
        whereArgs: [targetCurrency],
        limit: 1,
      );
      if (targetMaps.isEmpty) throw Exception('Target wallet not found');
      final currentTargetBal = (targetMaps.first['balance'] as num).toDouble();
      final newTargetBal = currentTargetBal + targetAmount;
      await txn.update(
        'wallets',
        {'balance': newTargetBal},
        where: 'currency = ?',
        whereArgs: [targetCurrency],
      );

      // 3. Record transaction in ledger
      final txMap = {
        'id': 'tx_${_uuid.v4().substring(0, 8)}',
        'title': 'Currency Swap: $sourceCurrency to $targetCurrency',
        'subtitle':
            'Converted $sourceAmount $sourceCurrency at 0.1% FX fee ($feeAmount $sourceCurrency)',
        'amount': targetAmount,
        'currency': targetCurrency,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'category': 'Investment',
        'status': 'Completed',
        'type': 'credit',
        'referenceId': 'FX-${_uuid.v4().substring(0, 8).toUpperCase()}',
      };
      await txn.insert(
        'transactions',
        txMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions({
    int limit = 10,
  }) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  @override
  Future<void> injectMockDeposit({
    required String currency,
    required double amount,
  }) async {
    final db = await AppDatabase.database;
    await db.transaction((txn) async {
      final maps = await txn.query(
        'wallets',
        where: 'currency = ?',
        whereArgs: [currency],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        final currentBal = (maps.first['balance'] as num).toDouble();
        await txn.update(
          'wallets',
          {'balance': currentBal + amount},
          where: 'currency = ?',
          whereArgs: [currency],
        );

        final txMap = {
          'id': 'tx_${_uuid.v4().substring(0, 8)}',
          'title': 'Recruiter Inbound Wire Deposit',
          'subtitle': 'Simulated Institutional Treasury Settlement',
          'amount': amount,
          'currency': currency,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'category': 'Salary',
          'status': 'Completed',
          'type': 'credit',
          'referenceId': 'WIRE-${_uuid.v4().substring(0, 8).toUpperCase()}',
        };
        await txn.insert(
          'transactions',
          txMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
