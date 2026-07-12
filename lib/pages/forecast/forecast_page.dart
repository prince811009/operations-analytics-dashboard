import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/forecast_result.dart';
import '../../models/sales_record.dart';
import '../../services/forecast_service.dart';
import '../../theme/app_theme.dart';

class ForecastPage extends StatefulWidget {
  final List<SalesRecord> salesData;

  const ForecastPage({
    super.key,
    required this.salesData,
  });

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final ForecastService _forecastService = ForecastService();

  ForecastResult? _forecastResult;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.salesData.length >= 3) {
      _loadForecast();
    }
  }

  @override
  void didUpdateWidget(covariant ForecastPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.salesData != widget.salesData &&
        widget.salesData.isNotEmpty) {
      _loadForecast();
    }
  }

  Future<void> _loadForecast() async {
    if (widget.salesData.length < 3) {
      setState(() {
        _forecastResult = null;
        _errorMessage =
            'Upload at least 3 sales records before generating a forecast.';
        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _forecastService.generateForecast(
        widget.salesData,
      );

      if (!mounted) return;

      setState(() {
        _forecastResult = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _forecastResult = null;
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatNumber(double value) {
    final text = value.round().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < text.length; index++) {
      final positionFromEnd = text.length - index;

      buffer.write(text[index]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 900;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  if (widget.salesData.length < 3)
                    _buildNoDataCard()
                  else if (_isLoading)
                    _buildLoadingCard()
                  else if (_errorMessage != null)
                    _buildErrorCard()
                  else if (_forecastResult != null)
                    _buildForecastContent(
                      _forecastResult!,
                      isCompact,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      spacing: 20,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forecast Analytics',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Generate forecasting results from imported sales data.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ||
                  widget.salesData.length < 3
              ? null
              : _loadForecast,
          icon: _isLoading
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(
            _isLoading
                ? 'Generating...'
                : 'Regenerate Forecast',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastContent(
    ForecastResult result,
    bool isCompact,
  ) {
    return Column(
      children: [
        _buildKpiSection(result),
        const SizedBox(height: 24),
        if (isCompact)
          Column(
            children: [
              _buildChartCard(result),
              const SizedBox(height: 24),
              _buildModelCard(result),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildChartCard(result),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildModelCard(result),
              ),
            ],
          ),
        const SizedBox(height: 24),
        _buildRecommendationCard(result),
      ],
    );
  }

  Widget _buildKpiSection(ForecastResult result) {
    final growthText =
        '${result.growthRatePercent >= 0 ? '+' : ''}'
        '${result.growthRatePercent.toStringAsFixed(2)}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 18.0;

        double cardWidth;

        if (constraints.maxWidth >= 1100) {
          cardWidth =
              (constraints.maxWidth - spacing * 3) / 4;
        } else if (constraints.maxWidth >= 620) {
          cardWidth =
              (constraints.maxWidth - spacing) / 2;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _ForecastKpiCard(
              width: cardWidth,
              title: 'Next Forecast',
              value: _formatNumber(result.forecastSales),
              icon: Icons.auto_graph,
            ),
            _ForecastKpiCard(
              width: cardWidth,
              title: 'Latest Sales',
              value: _formatNumber(result.latestSales),
              icon: Icons.payments_outlined,
            ),
            _ForecastKpiCard(
              width: cardWidth,
              title: 'Projected Growth',
              value: growthText,
              icon: result.growthRatePercent >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
            ),
            _ForecastKpiCard(
              width: cardWidth,
              title: 'Trend',
              value: result.trend.toUpperCase(),
              icon: Icons.insights_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(ForecastResult result) {
    return _ForecastCard(
      child: SizedBox(
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historical and Forecast Trend',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'The final point represents the predicted next period.',
              style: TextStyle(
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: result.historical.isEmpty
                  ? const Center(
                      child: Text(
                        'No forecast chart data available.',
                        style: TextStyle(
                          color: AppTheme.mutedText,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        right: 12,
                      ),
                      child: LineChart(
                        _buildChartData(result),
                        duration:
                            const Duration(milliseconds: 300),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData(
    ForecastResult result,
  ) {
    final values = [
      ...result.historical.map(
        (item) => item.sales,
      ),
      result.forecastSales,
    ];

    final minValue = values.reduce(
      (current, next) =>
          current < next ? current : next,
    );

    final maxValue = values.reduce(
      (current, next) =>
          current > next ? current : next,
    );

    final range = maxValue - minValue;
    final padding =
        range == 0 ? maxValue * 0.15 : range * 0.25;

    final minY =
        (minValue - padding).clamp(0, double.infinity);
    final maxY = maxValue + padding;
    final interval =
        maxY == minY ? 1.0 : (maxY - minY) / 5;

    final historicalSpots = result.historical
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.sales,
          ),
        )
        .toList();

    final forecastIndex =
        result.historical.length.toDouble();

    final forecastSpots = [
      if (result.historical.isNotEmpty)
        FlSpot(
          forecastIndex - 1,
          result.historical.last.sales,
        ),
      FlSpot(
        forecastIndex,
        result.forecastSales,
      ),
    ];

    return LineChartData(
      minX: 0,
      maxX: forecastIndex,
      minY: minY.toDouble(),
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) {
          return const FlLine(
            color: AppTheme.border,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 58,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toStringAsFixed(0)}K',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedText,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();

              if (index ==
                  result.historical.length) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Forecast',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                );
              }

              if (index < 0 ||
                  index >= result.historical.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  result.historical[index].month,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: historicalSpots,
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 4,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primary.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        LineChartBarData(
          spots: forecastSpots,
          isCurved: false,
          color: const Color(0xFF7C3AED),
          barWidth: 4,
          dashArray: [8, 6],
          dotData: FlDotData(
            show: true,
            getDotPainter: (
              spot,
              percent,
              barData,
              index,
            ) {
              return FlDotCirclePainter(
                radius: 5,
                color: const Color(0xFF7C3AED),
                strokeWidth: 3,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(ForecastResult result) {
    return _ForecastCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Model Details',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            'Model',
            result.model,
          ),
          const Divider(height: 32),
          _buildDetailRow(
            'Forecast Period',
            result.forecastMonth,
          ),
          const Divider(height: 32),
          _buildDetailRow(
            'MAE',
            result.mae.toStringAsFixed(2),
          ),
          const Divider(height: 32),
          _buildDetailRow(
            'RMSE',
            result.rmse.toStringAsFixed(2),
          ),
          const Divider(height: 32),
          _buildDetailRow(
            'Source Records',
            result.historical.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.mutedText,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    ForecastResult result,
  ) {
    return _ForecastCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forecast Recommendation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.recommendation,
                  style: const TextStyle(
                    height: 1.6,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const SizedBox(
      height: 360,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text(
              'Generating forecast...',
              style: TextStyle(
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return _ForecastCard(
      child: SizedBox(
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file_outlined,
              size: 58,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 18),
            const Text(
              'No forecast data available',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload a CSV file containing at least 3 sales records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF991B1B),
              ),
            ),
          ),
          TextButton(
            onPressed: _loadForecast,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final Widget child;

  const _ForecastCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _ForecastKpiCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;

  const _ForecastKpiCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _ForecastCard(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}