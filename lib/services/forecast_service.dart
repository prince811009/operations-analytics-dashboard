import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/forecast_result.dart';

class ForecastService {
  Future<ForecastResult> loadForecastResult() async {
    final jsonString = await rootBundle.loadString(
      'assets/forecast/forecast_result.json',
    );

    final jsonData = jsonDecode(jsonString);

    if (jsonData is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid forecast JSON format.',
      );
    }

    return ForecastResult.fromJson(jsonData);
  }
}