import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/app_constants.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await seedInitialData(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE wallets (
        id TEXT PRIMARY KEY,
        currency TEXT NOT NULL UNIQUE,
        balance REAL NOT NULL,
        symbol TEXT NOT NULL,
        flagPath TEXT NOT NULL,
        exchangeRateToUsd REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        cardHolder TEXT NOT NULL,
        pan TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        cvv TEXT NOT NULL,
        skinType TEXT NOT NULL,
        isFrozen INTEGER NOT NULL,
        spendLimit REAL NOT NULL,
        currentMonthSpent REAL NOT NULL,
        isBurner INTEGER NOT NULL,
        isOnlineAllowed INTEGER NOT NULL,
        isAtmAllowed INTEGER NOT NULL,
        nickname TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        type TEXT NOT NULL,
        referenceId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        handle TEXT NOT NULL,
        avatarUrl TEXT NOT NULL,
        iban TEXT NOT NULL,
        lastTransferDate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ai_messages (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  static Future<void> seedInitialData(Database db) async {
    // 1. Wallets
    final wallets = [
      {
        'id': 'w_usd',
        'currency': 'USD',
        'balance': 84250.00,
        'symbol': '\$',
        'flagPath': 'assets/images/flag_usd.png',
        'exchangeRateToUsd': 1.0,
      },
      {
        'id': 'w_eur',
        'currency': 'EUR',
        'balance': 32180.00,
        'symbol': '€',
        'flagPath': 'assets/images/flag_eur.png',
        'exchangeRateToUsd': 1.087,
      },
      {
        'id': 'w_gbp',
        'currency': 'GBP',
        'balance': 19450.00,
        'symbol': '£',
        'flagPath': 'assets/images/flag_gbp.png',
        'exchangeRateToUsd': 1.265,
      },
      {
        'id': 'w_pkr',
        'currency': 'PKR',
        'balance': 1250000.00,
        'symbol': 'Rs',
        'flagPath': 'assets/images/flag_pkr.png',
        'exchangeRateToUsd': 0.00359,
      },
      {
        'id': 'w_aed',
        'currency': 'AED',
        'balance': 45800.00,
        'symbol': 'AED',
        'flagPath': 'assets/images/flag_aed.png',
        'exchangeRateToUsd': 0.272,
      },
    ];

    for (final w in wallets) {
      await db.insert(
        'wallets',
        w,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 2. Cards
    final cards = [
      {
        'id': 'c_titanium_01',
        'cardHolder': 'Safeer Hussain',
        'pan': '4532891244098812',
        'expiryDate': '08/29',
        'cvv': '834',
        'skinType': 'titanium_black',
        'isFrozen': 0,
        'spendLimit': 8500.0,
        'currentMonthSpent': 2340.50,
        'isBurner': 0,
        'isOnlineAllowed': 1,
        'isAtmAllowed': 1,
        'nickname': 'Executive Titanium Vault',
      },
      {
        'id': 'c_platinum_02',
        'cardHolder': 'Safeer Hussain',
        'pan': '4111762390881254',
        'expiryDate': '11/28',
        'cvv': '192',
        'skinType': 'platinum_cyber',
        'isFrozen': 0,
        'spendLimit': 5000.0,
        'currentMonthSpent': 1120.00,
        'isBurner': 0,
        'isOnlineAllowed': 1,
        'isAtmAllowed': 0,
        'nickname': 'Cyber Cloud Ops',
      },
      {
        'id': 'c_emerald_03',
        'cardHolder': 'Safeer Hussain',
        'pan': '4916223400194821',
        'expiryDate': '04/27',
        'cvv': '507',
        'skinType': 'emerald_eco',
        'isFrozen': 1,
        'spendLimit': 2500.0,
        'currentMonthSpent': 450.00,
        'isBurner': 1,
        'isOnlineAllowed': 1,
        'isAtmAllowed': 0,
        'nickname': 'Disposable Burner Shield',
      },
    ];

    for (final c in cards) {
      await db.insert('cards', c, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Contacts
    final contacts = [
      {
        'id': 'cont_01',
        'name': 'Sophia Vance',
        'handle': '@sophia.v',
        'avatarUrl': 'assets/images/avatar_user.png',
        'iban': 'GB29NWBK60161331926819',
        'lastTransferDate': DateTime.now()
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch,
      },
      {
        'id': 'cont_02',
        'name': 'Liam Sterling',
        'handle': '@sterling.fx',
        'avatarUrl': 'assets/images/avatar_user.png',
        'iban': 'US89PBUS10293847561029',
        'lastTransferDate': DateTime.now()
            .subtract(const Duration(days: 4))
            .millisecondsSinceEpoch,
      },
      {
        'id': 'cont_03',
        'name': 'Olivia Chen',
        'handle': '@olivia.chen',
        'avatarUrl': 'assets/images/avatar_user.png',
        'iban': 'DE89370400440532013000',
        'lastTransferDate': DateTime.now()
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch,
      },
      {
        'id': 'cont_04',
        'name': 'Ethan Ward',
        'handle': '@ethan.ward',
        'avatarUrl': 'assets/images/avatar_user.png',
        'iban': 'AE07033123456789012345',
        'lastTransferDate': DateTime.now()
            .subtract(const Duration(days: 12))
            .millisecondsSinceEpoch,
      },
      {
        'id': 'cont_05',
        'name': 'Maya Patel',
        'handle': '@maya.patel',
        'avatarUrl': 'assets/images/avatar_user.png',
        'iban': 'PK36SCBL0000001123456702',
        'lastTransferDate': DateTime.now()
            .subtract(const Duration(days: 15))
            .millisecondsSinceEpoch,
      },
    ];

    for (final cnt in contacts) {
      await db.insert(
        'contacts',
        cnt,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 4. Transactions
    final now = DateTime.now();
    final transactions = [
      {
        'id': 'tx_01',
        'title': 'Amazon Web Services',
        'subtitle': 'Cloud Compute & GPU Cluster Infrastructure',
        'amount': 428.50,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(hours: 3))
            .millisecondsSinceEpoch,
        'category': 'Tech/Cloud',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-AWS-9021',
      },
      {
        'id': 'tx_02',
        'title': 'Inbound Executive Wire',
        'subtitle': 'Treasury Dividend Distribution Q4',
        'amount': 14500.00,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 1, hours: 2))
            .millisecondsSinceEpoch,
        'category': 'Salary',
        'status': 'Completed',
        'type': 'credit',
        'referenceId': 'REF-DIV-8820',
      },
      {
        'id': 'tx_03',
        'title': 'Apple Infinite Loop Store',
        'subtitle': 'Hardware Workstation Accessories',
        'amount': 349.00,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch,
        'category': 'Shopping',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-APL-4412',
      },
      {
        'id': 'tx_04',
        'title': 'Starbucks Reserve Roastery',
        'subtitle': 'Executive Client Catering',
        'amount': 38.75,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 3))
            .millisecondsSinceEpoch,
        'category': 'Dining',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-SBUX-1092',
      },
      {
        'id': 'tx_05',
        'title': 'Uber Premium Black',
        'subtitle': 'Airport Executive Chauffeur Transit',
        'amount': 92.40,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 5))
            .millisecondsSinceEpoch,
        'category': 'Travel',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-UBR-7741',
      },
      {
        'id': 'tx_06',
        'title': 'Vanguard Total Stock Index',
        'subtitle': 'Automated Treasury Allocation',
        'amount': 3200.00,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch,
        'category': 'Investment',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-VANG-6601',
      },
      {
        'id': 'tx_07',
        'title': 'Airbnb Luxury Retreat',
        'subtitle': 'Leadership Summit Accommodations',
        'amount': 1250.00,
        'currency': 'USD',
        'timestamp': now
            .subtract(const Duration(days: 11))
            .millisecondsSinceEpoch,
        'category': 'Travel',
        'status': 'Completed',
        'type': 'debit',
        'referenceId': 'REF-ABNB-3392',
      },
    ];

    for (final tx in transactions) {
      await db.insert(
        'transactions',
        tx,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 5. AI Messages
    final welcomeAi = {
      'id': 'ai_msg_01',
      'text': 'Welcome to PayVault Financial Intelligence. I have synthesized your 30-day liquidity profile across 5 multi-currency vaults. Your burn rate is 18.4% below quarterly allocation, and your yield optimization score stands at 94.2/100. Select a financial inquiry shortcut below or query your ledger.',
      'isUser': 0,
      'timestamp': now
          .subtract(const Duration(minutes: 10))
          .millisecondsSinceEpoch,
      'category': 'General',
    };
    await db.insert(
      'ai_messages',
      welcomeAi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DELETE FROM wallets');
    await db.execute('DELETE FROM cards');
    await db.execute('DELETE FROM transactions');
    await db.execute('DELETE FROM contacts');
    await db.execute('DELETE FROM ai_messages');
    await seedInitialData(db);
  }
}
