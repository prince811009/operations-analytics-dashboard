import 'package:flutter/material.dart';

import '../../models/sales_record.dart';
import '../../theme/app_theme.dart';

class ReportPage extends StatelessWidget {
  final List<SalesRecord> salesData;

  const ReportPage({
    super.key,
    required this.salesData,
  });

  double get _totalSales {
    return salesData.fold<double>(
      0,
      (sum, record) => sum + record.sales,
    );
  }

  double get _averageSales {
    if (salesData.isEmpty) return 0;
    return _totalSales / salesData.length;
  }

  SalesRecord? get _bestMonth {
    if (salesData.isEmpty) return null;

    return salesData.reduce(
      (first, second) =>
          first.sales >= second.sales ? first : second,
    );
  }

  SalesRecord? get _worstMonth {
    if (salesData.isEmpty) return null;

    return salesData.reduce(
      (first, second) =>
          first.sales <= second.sales ? first : second,
    );
  }

  double get _growthRate {
    if (salesData.length < 2) return 0;

    final previousSales =
        salesData[salesData.length - 2].sales;
    final latestSales = salesData.last.sales;

    if (previousSales == 0) return 0;

    return ((latestSales - previousSales) / previousSales) * 100;
  }

  double get _forecastSales {
    if (salesData.isEmpty) return 0;

    if (salesData.length == 1) {
      return salesData.first.sales;
    }

    final recentRecords = salesData.length >= 3
        ? salesData.sublist(salesData.length - 3)
        : salesData;

    final recentAverage = recentRecords.fold<double>(
          0,
          (sum, record) => sum + record.sales,
        ) /
        recentRecords.length;

    return recentAverage * 1.05;
  }

  String _formatNumber(double value) {
    final text = value.round().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < text.length; index++) {
      final positionFromEnd = text.length - index;

      buffer.write(text[index]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  String get _recommendation {
    if (salesData.isEmpty) {
      return 'Upload a CSV file to generate a management report.';
    }

    if (_growthRate > 5) {
      return 'The latest sales results indicate strong growth. '
          'Consider increasing inventory preparation and reviewing '
          'operational capacity for projected demand.';
    }

    if (_growthRate < -5) {
      return 'The latest sales results indicate a decline. '
          'Review demand changes, process bottlenecks, and recent '
          'operational decisions.';
    }

    return 'Sales performance is relatively stable. '
        'Continue monitoring monthly results and maintain current '
        'operational capacity.';
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
                  if (salesData.isEmpty)
                    const _EmptyReport()
                  else ...[
                    _buildKpiSection(),
                    const SizedBox(height: 24),
                    isCompact
                        ? Column(
                            children: [
                              _buildPerformanceCard(),
                              const SizedBox(height: 24),
                              _buildRecommendationCard(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildPerformanceCard(),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child:
                                    _buildRecommendationCard(),
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    _buildMonthlyTable(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Report',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppTheme.text,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Review operational performance, trends, and recommendations.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSection() {
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

        final growthText =
            '${_growthRate >= 0 ? '+' : ''}'
            '${_growthRate.toStringAsFixed(1)}%';

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _ReportKpiCard(
              width: cardWidth,
              title: 'Total Sales',
              value: _formatNumber(_totalSales),
              icon: Icons.payments_outlined,
            ),
            _ReportKpiCard(
              width: cardWidth,
              title: 'Average Sales',
              value: _formatNumber(_averageSales),
              icon: Icons.analytics_outlined,
            ),
            _ReportKpiCard(
              width: cardWidth,
              title: 'Forecast',
              value: _formatNumber(_forecastSales),
              icon: Icons.auto_graph,
            ),
            _ReportKpiCard(
              width: cardWidth,
              title: 'Latest Growth',
              value: growthText,
              icon: _growthRate >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceCard() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Summary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 24),
          _buildPerformanceItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFF16A34A),
            backgroundColor: const Color(0xFFECFDF3),
            title: 'Best Month',
            month: _bestMonth!.month,
            value: _formatNumber(_bestMonth!.sales),
          ),
          const Divider(height: 34),
          _buildPerformanceItem(
            icon: Icons.trending_down,
            iconColor: const Color(0xFFDC2626),
            backgroundColor: const Color(0xFFFEF2F2),
            title: 'Worst Month',
            month: _worstMonth!.month,
            value: _formatNumber(_worstMonth!.sales),
          ),
          const Divider(height: 34),
          _buildPerformanceItem(
            icon: Icons.calendar_month_outlined,
            iconColor: AppTheme.primary,
            backgroundColor: const Color(0xFFEFF6FF),
            title: 'Latest Period',
            month: salesData.last.month,
            value: _formatNumber(salesData.last.sales),
          ),
          const Divider(height: 34),
          _buildPerformanceItem(
            icon: Icons.dataset_outlined,
            iconColor: const Color(0xFF7C3AED),
            backgroundColor: const Color(0xFFEDE9FE),
            title: 'Source Records',
            month: 'Imported rows',
            value: salesData.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String month,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                month,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.text,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF7C3AED),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Management Recommendation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _recommendation,
            style: const TextStyle(
              height: 1.65,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 22),
          const _ActionItem(
            text: 'Review KPI changes each month',
          ),
          const SizedBox(height: 13),
          const _ActionItem(
            text: 'Compare actual results with forecasts',
          ),
          const SizedBox(height: 13),
          const _ActionItem(
            text: 'Use SQL queries for detailed investigation',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTable() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Performance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Month',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sales',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Change',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              rows: salesData.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;

                var changeText = '--';
                var change = 0.0;

                if (index > 0) {
                  final previous = salesData[index - 1].sales;

                  if (previous != 0) {
                    change =
                        ((record.sales - previous) / previous) *
                            100;

                    changeText =
                        '${change >= 0 ? '+' : ''}'
                        '${change.toStringAsFixed(1)}%';
                  }
                }

                return DataRow(
                  cells: [
                    DataCell(Text(record.month)),
                    DataCell(
                      Text(_formatNumber(record.sales)),
                    ),
                    DataCell(
                      Text(
                        changeText,
                        style: TextStyle(
                          color: change > 0
                              ? const Color(0xFF16A34A)
                              : change < 0
                                  ? const Color(0xFFDC2626)
                                  : AppTheme.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Widget child;

  const _ReportCard({
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

class _ReportKpiCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;

  const _ReportKpiCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _ReportCard(
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

class _ActionItem extends StatelessWidget {
  final String text;

  const _ActionItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
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
              color: AppTheme.text,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 58,
            color: AppTheme.mutedText,
          ),
          SizedBox(height: 18),
          Text(
            'No report data available',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Upload a CSV file from the Dashboard first.',
            style: TextStyle(
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}