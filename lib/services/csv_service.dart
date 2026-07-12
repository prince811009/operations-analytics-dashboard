import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../models/sales_record.dart';

class CsvService {
  Future<CsvImportResult?> pickAndParseSalesCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      throw const FormatException('Unable to read the selected CSV file.');
    }

    final csvText = utf8.decode(bytes, allowMalformed: true);
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvText);

    if (rows.length < 2) {
      throw const FormatException(
        'CSV must include a header and at least one data row.',
      );
    }

    final header = rows.first
        .map((value) => value.toString().trim().toLowerCase())
        .toList();

    if (header.length < 2 ||
        header[0] != 'month' ||
        header[1] != 'sales') {
      throw const FormatException(
        'CSV columns must be: month,sales',
      );
    }

    final records = <SalesRecord>[];

    for (final row in rows.skip(1)) {
      if (row.every((value) => value.toString().trim().isEmpty)) {
        continue;
      }

      records.add(SalesRecord.fromCsvRow(row));
    }

    if (records.isEmpty) {
      throw const FormatException('No valid sales records were found.');
    }

    return CsvImportResult(
      fileName: file.name,
      records: records,
    );
  }
}

class CsvImportResult {
  final String fileName;
  final List<SalesRecord> records;

  const CsvImportResult({
    required this.fileName,
    required this.records,
  });
}