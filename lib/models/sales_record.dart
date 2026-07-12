class SalesRecord {
  final String month;
  final double sales;

  const SalesRecord({required this.month, required this.sales});

  factory SalesRecord.fromCsvRow(List<dynamic> row) {
    if (row.length < 2) {
      throw const FormatException('Each CSV row must contain month and sales.');
    }

    final month = row[0].toString().trim();
    final sales = double.tryParse(row[1].toString().replaceAll(',', '').trim());

    if (month.isEmpty || sales == null) {
      throw FormatException('Invalid CSV row: $row');
    }

    return SalesRecord(month: month, sales: sales);
  }
}
