import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/forecast_result.dart';
import '../models/sales_record.dart';

class ForecastService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<ForecastResult> generateForecast(List<SalesRecord> records) async {
    if (records.length < 3) {
      throw const FormatException(
        'At least 3 records are required for forecasting.',
      );
    }

    final csvBuffer = StringBuffer('month,sales\n');

    for (final record in records) {
      csvBuffer.writeln('${record.month},${record.sales}');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/forecast'),
    );

    request.files.add(
      http.MultipartFile.fromString(
        'file',
        csvBuffer.toString(),
        filename: 'sales.csv',
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      String message = 'Forecast request failed.';

      try {
        final errorJson = jsonDecode(responseBody);

        if (errorJson is Map<String, dynamic> && errorJson['detail'] != null) {
          message = errorJson['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final jsonData = jsonDecode(responseBody);

    if (jsonData is! Map<String, dynamic>) {
      throw const FormatException('Invalid forecast response format.');
    }

    return ForecastResult.fromJson(jsonData);
  }
}
