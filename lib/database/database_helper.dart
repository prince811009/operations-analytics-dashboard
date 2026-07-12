import 'package:sqlite3/wasm.dart';

import '../models/sales_record.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  CommonDatabase? _database;

  Future<CommonDatabase> get database async {
    if (_database != null) {
      return _database!;
    }

    final sqlite = await WasmSqlite3.loadFromUrlString('sqlite3.wasm');

    sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);

    final database = sqlite.open('/operations.db');

    database.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        sales REAL NOT NULL
      );
    ''');

    _database = database;

    return database;
  }

  Future<void> replaceSalesData(List<SalesRecord> records) async {
    final db = await database;

    db.execute('BEGIN TRANSACTION;');

    try {
      db.execute('DELETE FROM sales;');

      final statement = db.prepare(
        'INSERT INTO sales (month, sales) VALUES (?, ?);',
      );

      for (final record in records) {
        statement.execute([record.month, record.sales]);
      }

      statement.close();

      db.execute('COMMIT;');
    } catch (_) {
      db.execute('ROLLBACK;');
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> getAllSales() async {
    final db = await database;

    final result = db.select('''
      SELECT id, month, sales
      FROM sales
      ORDER BY month ASC;
      ''');

    return result.map((row) {
      return {'id': row['id'], 'month': row['month'], 'sales': row['sales']};
    }).toList();
  }

  Future<List<Map<String, Object?>>> runSelectQuery(String sql) async {
    final normalizedSql = sql.trim().toLowerCase();

    if (!normalizedSql.startsWith('select')) {
      throw const FormatException('Only SELECT queries are allowed.');
    }

    final db = await database;
    final result = db.select(sql);

    return result.map((row) {
      return {for (final column in result.columnNames) column: row[column]};
    }).toList();
  }

  Future<double> getAverageSales() async {
    final db = await database;

    final result = db.select('''
      SELECT AVG(sales) AS average_sales
      FROM sales;
      ''');

    final value = result.first['average_sales'];

    return value == null ? 0 : (value as num).toDouble();
  }

  Future<double> getTotalSales() async {
    final db = await database;

    final result = db.select('''
      SELECT SUM(sales) AS total_sales
      FROM sales;
      ''');

    final value = result.first['total_sales'];

    return value == null ? 0 : (value as num).toDouble();
  }

  Future<int> getRecordCount() async {
    final db = await database;

    final result = db.select('''
      SELECT COUNT(*) AS record_count
      FROM sales;
      ''');

    final value = result.first['record_count'];

    return value == null ? 0 : (value as num).toInt();
  }
}
