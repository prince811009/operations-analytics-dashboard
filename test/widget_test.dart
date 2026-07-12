import 'package:flutter_test/flutter_test.dart';
import 'package:sales_analytics_dashboard/models/sales_record.dart';

void main() {
  group('SalesRecord', () {
    test('creates a record from a valid CSV row', () {
      final record = SalesRecord.fromCsvRow(['2025-01', '120000']);

      expect(record.month, '2025-01');
      expect(record.sales, 120000);
    });

    test('supports sales values containing commas', () {
      final record = SalesRecord.fromCsvRow(['2025-02', '135,000']);

      expect(record.month, '2025-02');
      expect(record.sales, 135000);
    });

    test('throws FormatException for an invalid row', () {
      expect(
        () => SalesRecord.fromCsvRow(['2025-03']),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
