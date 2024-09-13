import 'package:expense_tracker/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() {
    return _instance;
  }

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source TEXT,
          transactionType TEXT,
          amount REAL,
          date TEXT,
          time TEXT,  -- Add the time column
          recipient TEXT,
          bankName TEXT
        )
        ''');
        await db.execute('''
        CREATE TABLE credits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source TEXT,
          amount REAL,
          date TEXT,
          time TEXT,
          recipient TEXT,
          bankName TEXT
        )
        ''');
        await db.execute('''
        CREATE TABLE debits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source TEXT,
          amount REAL,
          date TEXT,
          time TEXT,
          recipient TEXT,
          bankName TEXT
        )
        ''');
      },
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;

    // Check for duplicates in the transactions table before inserting
    if (await isDuplicate('transactions', transaction)) {
      return -1;
    }

    // Insert into the transactions table
    await db.insert('transactions', transaction.toMap());

    // Insert into the appropriate table based on transactionType
    if (transaction.transactionType == 'credited') {
      if (!await isDuplicate('credits', transaction)) {
        await db.insert('credits', transaction.toMap()..remove('transactionType'));
      }
    } else if (transaction.transactionType == 'debited') {
      if (!await isDuplicate('debits', transaction)) {
        await db.insert('debits', transaction.toMap()..remove('transactionType'));
      }
    }

    return 1; // Return 1 to indicate successful insertion
  }

  Future<bool> isDuplicateTransaction(TransactionModel transaction) async {
    final db = await database;

    // Assuming transactions are unique based on date, time, amount, and recipient.
    var result = await db.query(
      'transactions',
      where: 'date = ? AND time = ? AND amount = ? AND recipient = ?',
      whereArgs: [transaction.date, transaction.time, transaction.amount, transaction.recipient],
    );

    return result.isNotEmpty;
  }

  Future<bool> isDuplicate(String table, TransactionModel transaction) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: 'date = ? AND time = ? AND amount = ? AND source = ? AND recipient = ?',
      whereArgs: [transaction.date, transaction.time, transaction.amount, transaction.source, transaction.recipient],
    );
    return result.isNotEmpty;
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<List<TransactionModel>> getCredits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('credits');

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<List<TransactionModel>> getDebits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debits');

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // ==================== Current Month Total
  Future<Map<String, double>> getCurrentMonthTotals() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    final endOfMonth = now.toIso8601String().split('T')[0];

    final totalCreditResult = await db.rawQuery('''
    SELECT SUM(amount) as totalCredit
    FROM transactions
    WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  ''', [startOfMonth, endOfMonth]);

    final totalDebitResult = await db.rawQuery('''
    SELECT SUM(amount) as totalDebit
    FROM transactions
    WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  ''', [startOfMonth, endOfMonth]);

    return {
      'totalCredit': totalCreditResult.isNotEmpty ? (totalCreditResult[0]['totalCredit'] as double) : 0.0,
      'totalDebit': totalDebitResult.isNotEmpty ? (totalDebitResult[0]['totalDebit'] as double) : 0.0,
    };
  }

// =================== Daily totals
  Future<Map<String, dynamic>> getDailyTotals() async {
    final db = await database;

    // Get the current date in 'YYYY-MM-DD' format
    final currentDate = DateTime.now().toIso8601String().split('T').first;

    final results = await db.rawQuery('''
    SELECT 
           SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
           SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
    FROM transactions
    WHERE date = ?
  ''', [currentDate]);

    // Extract totals from the query results and cast them to double
    final totalCredit = (results.isNotEmpty && results.first['totalCredit'] != null)
        ? (results.first['totalCredit'] as num).toDouble()  // Casting to double
        : 0.0;
    final totalDebit = (results.isNotEmpty && results.first['totalDebit'] != null)
        ? (results.first['totalDebit'] as num).toDouble()  // Casting to double
        : 0.0;

    return {
      'currentDate': currentDate,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
    };
  }

  // // =================== For Last Week
  // Future<Map<String, double>> getLastWeekTotals() async {
  //   final db = await database;
  //   final now = DateTime.now();
  //   final startOfLastWeek = DateTime(now.year, now.month, now.day - now.weekday - 6).toIso8601String().split('T')[0];
  //   final endOfLastWeek = DateTime(now.year, now.month, now.day - now.weekday).toIso8601String().split('T')[0];
  //
  //   final totalCreditResult = await db.rawQuery('''
  //   SELECT SUM(amount) as totalCredit
  //   FROM transactions
  //   WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  // ''', [startOfLastWeek, endOfLastWeek]);
  //
  //   final totalDebitResult = await db.rawQuery('''
  //   SELECT SUM(amount) as totalDebit
  //   FROM transactions
  //   WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  // ''', [startOfLastWeek, endOfLastWeek]);
  //
  //   return {
  //     'totalCredit': totalCreditResult.isNotEmpty ? (totalCreditResult[0]['totalCredit'] as double) : 0.0,
  //     'totalDebit': totalDebitResult.isNotEmpty ? (totalDebitResult[0]['totalDebit'] as double) : 0.0,
  //   };
  // }
  //
  // // ======================= For Current Week
  // Future<Map<String, double>> getCurrentWeekTotals() async {
  //   final db = await database;
  //   final now = DateTime.now();
  //   final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1).toIso8601String().split('T')[0];
  //   final endOfWeek = now.toIso8601String().split('T')[0];
  //
  //   final totalCreditResult = await db.rawQuery('''
  //   SELECT SUM(amount) as totalCredit
  //   FROM transactions
  //   WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  // ''', [startOfWeek, endOfWeek]);
  //
  //   final totalDebitResult = await db.rawQuery('''
  //   SELECT SUM(amount) as totalDebit
  //   FROM transactions
  //   WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  // ''', [startOfWeek, endOfWeek]);
  //
  //   return {
  //     'totalCredit': totalCreditResult.isNotEmpty ? (totalCreditResult[0]['totalCredit'] as double) : 0.0,
  //     'totalDebit': totalDebitResult.isNotEmpty ? (totalDebitResult[0]['totalDebit'] as double) : 0.0,
  //   };
  //
  // }

  // ======================= For Last Three Months

// =================== For Last Week

  Future<Map<String, double>> getLastWeekTotals() async {
    final db = await database;
    final now = DateTime.now();

    // Calculate the start and end of the last week
    final previousMonday = now.subtract(Duration(days: now.weekday + 6)); // Last week's Monday
    final previousSunday = now.subtract(Duration(days: now.weekday)); // Last week's Sunday

    final startOfLastWeek = previousMonday.toIso8601String().split('T')[0];
    final endOfLastWeek = previousSunday.toIso8601String().split('T')[0];

    // Debug print statements to verify date range

    final totalCreditResult = await db.rawQuery('''
    SELECT SUM(amount) as totalCredit
    FROM transactions
    WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  ''', [startOfLastWeek, endOfLastWeek]);

    final totalDebitResult = await db.rawQuery('''
    SELECT SUM(amount) as totalDebit
    FROM transactions
    WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  ''', [startOfLastWeek, endOfLastWeek]);

    return {
      'totalCredit': totalCreditResult.isNotEmpty && totalCreditResult[0]['totalCredit'] != null
          ? (totalCreditResult[0]['totalCredit'] as double)
          : 0.0,
      'totalDebit': totalDebitResult.isNotEmpty && totalDebitResult[0]['totalDebit'] != null
          ? (totalDebitResult[0]['totalDebit'] as double)
          : 0.0,
    };
  }

// ======================= For Current Week
  Future<Map<String, double>> getCurrentWeekTotals() async {
    final db = await database;
    final now = DateTime.now();

    // Calculate the start and end of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Previous Monday
    final endOfWeek = now.add(Duration(days: 7 - now.weekday)); // Coming Sunday

    final startOfWeekString = startOfWeek.toIso8601String().split('T')[0];
    final endOfWeekString = endOfWeek.toIso8601String().split('T')[0];

    final totalCreditResult = await db.rawQuery('''
    SELECT SUM(amount) as totalCredit
    FROM transactions
    WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  ''', [startOfWeekString, endOfWeekString]);

    final totalDebitResult = await db.rawQuery('''
    SELECT SUM(amount) as totalDebit
    FROM transactions
    WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  ''', [startOfWeekString, endOfWeekString]);

    return {
      'totalCredit': totalCreditResult.isNotEmpty && totalCreditResult[0]['totalCredit'] != null
          ? (totalCreditResult[0]['totalCredit'] as double)
          : 0.0,
      'totalDebit': totalDebitResult.isNotEmpty && totalDebitResult[0]['totalDebit'] != null
          ? (totalDebitResult[0]['totalDebit'] as double)
          : 0.0,
    };
  }

  Future<Map<String, double>> getLastThreeMonthsTotals() async {
    final db = await database;
    final now = DateTime.now();
    final startOfThreeMonthsAgo = DateTime(now.year, now.month - 3, now.day).toIso8601String().split('T')[0];
    final endOfCurrentMonth = now.toIso8601String().split('T')[0];

    final totalCreditResult = await db.rawQuery('''
    SELECT SUM(amount) as totalCredit
    FROM transactions
    WHERE transactionType = 'credited' AND date BETWEEN ? AND ?
  ''', [startOfThreeMonthsAgo, endOfCurrentMonth]);

    final totalDebitResult = await db.rawQuery('''
    SELECT SUM(amount) as totalDebit
    FROM transactions
    WHERE transactionType = 'debited' AND date BETWEEN ? AND ?
  ''', [startOfThreeMonthsAgo, endOfCurrentMonth]);

    return {
      'totalCredit': totalCreditResult.isNotEmpty ? (totalCreditResult[0]['totalCredit'] as double) : 0.0,
      'totalDebit': totalDebitResult.isNotEmpty ? (totalDebitResult[0]['totalDebit'] as double) : 0.0,
    };
  }

// ======================= For Current Week Daily Totals
  Future<List<Map<String, dynamic>>> getCurrentWeekDailyTotals() async {
    final db = await database;
    final now = DateTime.now();

    // Calculate the start and end of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = now.add(Duration(days: 7 - now.weekday)); // Sunday

    final startOfWeekString = startOfWeek.toIso8601String().split('T')[0];
    final endOfWeekString = endOfWeek.toIso8601String().split('T')[0];

    final results = await db.rawQuery('''
    SELECT date,
           SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
           SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
    FROM transactions
    WHERE date BETWEEN ? AND ?
    GROUP BY date
    ORDER BY date
  ''', [startOfWeekString, endOfWeekString]);

    // Convert the results to the required format
    return results.map((row) {
      return {
        'date': row['date'] as String,
        'totalCredit': (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
        'totalDebit': (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // =================== For Last Week Daily Totals
  Future<List<Map<String, dynamic>>> getLastWeekDailyTotals() async {
    final db = await database;
    final now = DateTime.now();

    // Calculate the start and end of the last week
    final previousMonday = now.subtract(Duration(days: now.weekday + 6)); // Last week's Monday
    final previousSunday = now.subtract(Duration(days: now.weekday )); // Last week's Sunday

    final startOfLastWeek = previousMonday.toIso8601String().split('T')[0];
    final endOfLastWeek = previousSunday.toIso8601String().split('T')[0];

    final results = await db.rawQuery('''
    SELECT date,
           SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
           SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
    FROM transactions
    WHERE date BETWEEN ? AND ?
    GROUP BY date
    ORDER BY date
  ''', [startOfLastWeek, endOfLastWeek]);

    // Convert the results to the required format
    return results.map((row) {
      return {
        'date': row['date'] as String,
        'totalCredit': (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
        'totalDebit': (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

// ======================= For Current Year Monthly Totals
  Future<List<Map<String, Object>>> getCurrentYearMonthlyTotals() async {
    final db = await database;
    final now = DateTime.now();
    final currentYear = now.year;

    final startOfYear = DateTime(currentYear, 1, 1).toIso8601String().split('T')[0];
    final endOfYear = DateTime(currentYear, 12, 31).toIso8601String().split('T')[0];

    final results = await db.rawQuery('''
    SELECT strftime('%Y-%m', date) as month,
           SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
           SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
    FROM transactions
    WHERE date BETWEEN ? AND ?
    GROUP BY month
    ORDER BY month
  ''', [startOfYear, endOfYear]);

    // Convert the results to the required format
    return results.map((row) {
      return {
        'month': row['month'] as String, // 'month' is a String
        'totalCredit': (row['totalCredit'] as num?)?.toDouble() ?? 0.0, // Convert totalCredit to double
        'totalDebit': (row['totalDebit'] as num?)?.toDouble() ?? 0.0, // Convert totalDebit to double
      };
    }).toList();
  }

// =================== For Previous Year Monthly Totals
  Future<List<Map<String, Object>>> getPreviousYearMonthlyTotals() async {
    final db = await database;
    final now = DateTime.now();
    final previousYear = now.year - 1;

    final startOfPreviousYear = DateTime(previousYear, 1, 1).toIso8601String().split('T')[0];
    final endOfPreviousYear = DateTime(previousYear, 12, 31).toIso8601String().split('T')[0];

    final results = await db.rawQuery('''
    SELECT strftime('%Y-%m', date) as month,
           SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
           SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
    FROM transactions
    WHERE date BETWEEN ? AND ?
    GROUP BY month
    ORDER BY month
  ''', [startOfPreviousYear, endOfPreviousYear]);

    // Convert the results to the required format
    return results.map((row) {
      return {
        'month': row['month'] as String,
        'totalCredit': (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
        'totalDebit': (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }


// Method to get transactions based on a specific bank name
  Future<List<Map<String, dynamic>>> getTransactionsByBankName(String bankName) async {
    final db = await database;

    // Query the database for transactions where the bank name matches the user input
    final results = await db.query(
      'transactions',
      where: 'bankName = ?',
      whereArgs: [bankName],
    );

    // Return the list of transactions
    return results;
  }

  Future<Map<String, double>> getTotalsByBankName(String bankName) async {
    final db = await database;

    // Query to get total credits and debits for the specified bank
    final result = await db.rawQuery('''
    SELECT 
      (SELECT IFNULL(SUM(amount), 0) FROM credits WHERE bankName = ?) AS totalCredit,
      (SELECT IFNULL(SUM(amount), 0) FROM debits WHERE bankName = ?) AS totalDebit
  ''', [bankName, bankName]);

    // Extract totals from result
    final totals = result.isNotEmpty
        ? {
      'totalCredit': (result[0]['totalCredit'] as num).toDouble(),
      'totalDebit': (result[0]['totalDebit'] as num).toDouble(),
    }
        : {'totalCredit': 0.0, 'totalDebit': 0.0};

    return totals;
  }

// Method to get transactions where the amount is greater than a specific value
  Future<List<Map<String, dynamic>>> getTransactionsByAmountGreaterThan(double amount) async {
    final db = await database;

    // Query the database for transactions where the amount is greater than the specified value
    final results = await db.query(
      'transactions',
      where: 'amount > ?',
      whereArgs: [amount],
    );

    // Return the list of transactions
    return results;
  }

  // Method to get the total overall debit and credit amounts
  Future<Map<String, double>> getTotalDebitAndCredit() async {
    final db = await database;

    // Query to get the total credit and debit amounts
    final results = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN transactionType = 'credited' THEN amount ELSE 0 END) as totalCredit,
        SUM(CASE WHEN transactionType = 'debited' THEN amount ELSE 0 END) as totalDebit
      FROM transactions
    ''');

    // Extracting the total amounts from the results
    final row = results.first;
    final totalCredit = (row['totalCredit'] as num?)?.toDouble() ?? 0.0;
    final totalDebit = (row['totalDebit'] as num?)?.toDouble() ?? 0.0;

    // Return the totals as a map
    return {
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
    };
  }
}
