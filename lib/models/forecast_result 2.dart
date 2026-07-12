class ForecastResult {
  final String model;
  final String forecastMonth;
  final double forecastSales;
  final double latestSales;
  final double growthRatePercent;
  final String trend;
  final double mae;
  final double rmse;
  final String recommendation;
  final List<ForecastHistoryItem> historical;

  const ForecastResult({
    required this.model,
    required this.forecastMonth,
    required this.forecastSales,
    required this.latestSales,
    required this.growthRatePercent,
    required this.trend,
    required this.mae,
    required this.rmse,
    required this.recommendation,
    required this.historical,
  });

  factory ForecastResult.fromJson(Map<String, dynamic> json) {
    return ForecastResult(
      model: json['model']?.toString() ?? 'Unknown',
      forecastMonth: json['forecast_month']?.toString() ?? 'Next Period',
      forecastSales: (json['forecast_sales'] as num?)?.toDouble() ?? 0,
      latestSales: (json['latest_sales'] as num?)?.toDouble() ?? 0,
      growthRatePercent: (json['growth_rate_percent'] as num?)?.toDouble() ?? 0,
      trend: json['trend']?.toString() ?? 'unknown',
      mae: (json['mae'] as num?)?.toDouble() ?? 0,
      rmse: (json['rmse'] as num?)?.toDouble() ?? 0,
      recommendation:
          json['recommendation']?.toString() ?? 'No recommendation.',
      historical: (json['historical'] as List<dynamic>? ?? [])
          .map(
            (item) => ForecastHistoryItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class ForecastHistoryItem {
  final String month;
  final double sales;

  const ForecastHistoryItem({required this.month, required this.sales});

  factory ForecastHistoryItem.fromJson(Map<String, dynamic> json) {
    return ForecastHistoryItem(
      month: json['month']?.toString() ?? '',
      sales: (json['sales'] as num?)?.toDouble() ?? 0,
    );
  }
}
