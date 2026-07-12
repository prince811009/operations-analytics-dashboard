import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/sales_record.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kpi_card.dart';

class DashboardPage extends StatelessWidget {
  final List<SalesRecord> salesData;
  final String? importedFileName;
  final String? importError;
  final bool isImporting;
  final VoidCallback onImportCsv;

  const DashboardPage({
    super.key,
    required this.salesData,
    required this.importedFileName,
    required this.importError,
    required this.isImporting,
    required this.onImportCsv,
  });

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
                  _buildHeader(isCompact),
                  const SizedBox(height: 22),
                  _buildImportBar(),
                  const SizedBox(height: 28),
                  _buildKpiSection(constraints.maxWidth),
                  const SizedBox(height: 28),
                  isCompact
                      ? _buildCompactContent()
                      : _buildDesktopContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double get _totalSales {
    return salesData.fold<double>(
      0,
      (sum, item) => sum + item.sales,
    );
  }

  double get _averageSales {
    if (salesData.isEmpty) return 0;
    return _totalSales / salesData.length;
  }

  double get _forecastSales {
    if (salesData.isEmpty) return 0;

    if (salesData.length == 1) {
      return salesData.last.sales;
    }

    final recentRecords = salesData.length >= 3
        ? salesData.sublist(salesData.length - 3)
        : salesData;

    final recentAverage = recentRecords.fold<double>(
          0,
          (sum, item) => sum + item.sales,
        ) /
        recentRecords.length;

    return recentAverage * 1.05;
  }

  double get _growthRate {
    if (salesData.length < 2) return 0;

    final previous = salesData[salesData.length - 2].sales;
    final current = salesData.last.sales;

    if (previous == 0) return 0;

    return ((current - previous) / previous) * 100;
  }

  String _formatNumber(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < rounded.length; index++) {
      final positionFromEnd = rounded.length - index;

      buffer.write(rounded[index]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  Widget _buildImportBar() {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: isImporting ? null : onImportCsv,
          icon: isImporting
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(
            isImporting ? 'Importing...' : 'Upload CSV',
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
        if (importedFileName != null)
          Text(
            'Loaded: $importedFileName · ${salesData.length} records',
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (importError != null)
          Text(
            importError!,
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations Analytics Dashboard',
              style: TextStyle(
                fontSize: isCompact ? 27 : 34,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor operational performance and forecast trends.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 18,
                color: AppTheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Operational overview',
                style: TextStyle(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSection(double availableWidth) {
    const spacing = 18.0;

    double cardWidth;

    if (availableWidth >= 1200) {
      cardWidth = (availableWidth - spacing * 3) / 4;
    } else if (availableWidth >= 650) {
      cardWidth = (availableWidth - spacing) / 2;
    } else {
      cardWidth = availableWidth;
    }

    final growthText =
        '${_growthRate >= 0 ? '+' : ''}${_growthRate.toStringAsFixed(1)}%';

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        SizedBox(
          width: cardWidth,
          child: KpiCard(
            title: 'Total Records',
            value: salesData.length.toString(),
            icon: Icons.folder_open_outlined,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: KpiCard(
            title: 'Forecast',
            value: _formatNumber(_forecastSales),
            icon: Icons.show_chart,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: KpiCard(
            title: 'Average',
            value: _formatNumber(_averageSales),
            icon: Icons.analytics_outlined,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: KpiCard(
            title: 'Growth',
            value: growthText,
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _buildSalesTrendCard(height: 520),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildRecentRecordsCard(),
              const SizedBox(height: 24),
              _buildRecommendationCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Column(
      children: [
        _buildSalesTrendCard(height: 410),
        const SizedBox(height: 20),
        _buildRecentRecordsCard(),
        const SizedBox(height: 20),
        _buildRecommendationCard(),
      ],
    );
  }

  Widget _buildSalesTrendCard({
    required double height,
  }) {
    return _DashboardCard(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sales Trend',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                _StatusBadge(
                  label: salesData.isEmpty
                      ? 'No data'
                      : '${salesData.length} records',
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Monthly sales performance',
              style: TextStyle(
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: salesData.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.show_chart,
                      message: 'Upload a CSV file to display the sales trend.',
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        right: 12,
                      ),
                      child: LineChart(
                        _buildLineChartData(),
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final maximumSales = salesData
        .map((record) => record.sales)
        .reduce((current, next) => current > next ? current : next);

    final minimumSales = salesData
        .map((record) => record.sales)
        .reduce((current, next) => current < next ? current : next);

    final range = maximumSales - minimumSales;
    final padding = range == 0 ? maximumSales * 0.15 : range * 0.25;

    final minY = (minimumSales - padding).clamp(0, double.infinity);
    final maxY = maximumSales + padding;

    final spots = salesData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.sales,
      );
    }).toList();

    return LineChartData(
      minX: 0,
      maxX: (salesData.length - 1).toDouble(),
      minY: minY.toDouble(),
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppTheme.border,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            interval: (maxY - minY) / 5,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();

              if (index < 0 || index >= salesData.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  salesData[index].month,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.x.toInt();

              return LineTooltipItem(
                '${salesData[index].month}\n'
                '${_formatNumber(spot.y)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: AppTheme.primary,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primary,
                strokeWidth: 3,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primary.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRecordsCard() {
    final recentRecords = salesData.reversed.take(5).toList();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Records',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Latest imported operational data',
            style: TextStyle(
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 22),
          if (recentRecords.isEmpty)
            _buildEmptyState(
              icon: Icons.table_rows_outlined,
              message: 'No records available.',
            )
          else
            ...recentRecords.asMap().entries.map((entry) {
              final record = entry.value;
              final originalIndex =
                  salesData.indexWhere((item) => identical(item, record));

              var changeText = '--';

              if (originalIndex > 0) {
                final previousSales = salesData[originalIndex - 1].sales;

                if (previousSales != 0) {
                  final change =
                      ((record.sales - previousSales) / previousSales) * 100;

                  changeText =
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF16A34A),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        record.month,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(record.sales),
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          changeText,
                          style: TextStyle(
                            color: changeText.startsWith('+')
                                ? const Color(0xFF16A34A)
                                : changeText.startsWith('-')
                                    ? const Color(0xFFDC2626)
                                    : AppTheme.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final recommendation = _buildRecommendationText();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: AppTheme.primary,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 18),
          const _RecommendationItem(
            text: 'Review the latest operational data',
          ),
          const SizedBox(height: 12),
          const _RecommendationItem(
            text: 'Monitor monthly performance changes',
          ),
          const SizedBox(height: 12),
          const _RecommendationItem(
            text: 'Use forecasts as decision-support information',
          ),
        ],
      ),
    );
  }

  String _buildRecommendationText() {
    if (salesData.isEmpty) {
      return 'Upload a CSV file to generate operational recommendations.';
    }

    if (_growthRate > 5) {
      return 'Sales are showing a strong positive trend. '
          'Consider preparing inventory and operational resources '
          'to support projected demand.';
    }

    if (_growthRate < -5) {
      return 'Sales have declined compared with the previous period. '
          'Review recent changes and identify possible operational bottlenecks.';
    }

    return 'Sales performance is relatively stable. '
        'Continue monitoring monthly trends and operational efficiency.';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;

  const _DashboardCard({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;

  const _RecommendationItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              height: 1.4,
              color: AppTheme.text,
            ),
          ),
        ),
      ],
    );
  }
}