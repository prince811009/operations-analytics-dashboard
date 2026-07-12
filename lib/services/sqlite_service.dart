import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqliteService {
  SqliteService._();

  static final SqliteService instance = SqliteService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    databaseFactory = databaseFactoryFfiWeb;

    _database = await databaseFactory.openDatabase(
      'operations_analytics.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE sales (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              month TEXT NOT NULL,
              sales REAL NOT NULL
            )
          ''');
        },
      ),
    );

    return _database!;
  }

  Future<void> replaceSalesData(
    List<Map<String, Object?>> records,
  ) async {
    final db = await database;

    await db.transaction((transaction) async {
      await transaction.delete('sales');

      final batch = transaction.batch();

      for (final record in records) {
        batch.insert('sales', record);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, Object?>>> getAllSales() async {
    final db = await database;

    return db.query(
      'sales',
      orderBy: 'month ASC',
    );
  }

  Future<List<Map<String, Object?>>> getSalesAbove(
    double minimumSales,
  ) async {
    final db = await database;

    return db.query(
      'sales',
      where: 'sales > ?',
      whereArgs: [minimumSales],
      orderBy: 'sales DESC',
    );
  }

  Future<double> getAverageSales() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT AVG(sales) AS average_sales FROM sales',
    );

    final value = result.first['average_sales'];

    return value == null ? 0 : (value as num).toDouble();
  }
}