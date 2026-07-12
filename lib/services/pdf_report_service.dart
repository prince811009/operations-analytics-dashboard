import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sales_record.dart';

class PdfReportService {
  Future<void> exportManagementReport(List<SalesRecord> salesData) async {
    if (salesData.isEmpty) {
      throw const FormatException('No sales data is available for the report.');
    }

    final document = pw.Document();

    final totalSales = salesData.fold<double>(
      0,
      (sum, record) => sum + record.sales,
    );

    final averageSales = totalSales / salesData.length;

    final bestMonth = salesData.reduce(
      (first, second) => first.sales >= second.sales ? first : second,
    );

    final worstMonth = salesData.reduce(
      (first, second) => first.sales <= second.sales ? first : second,
    );

    final growthRate = _calculateGrowthRate(salesData);
    final forecastSales = _calculateForecast(salesData);
    final recommendation = _buildRecommendation(growthRate);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Operations Analytics Platform',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.Text(
                'Management Report',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated from imported CSV data',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 18),
          pw.Text(
            'Management Report',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Operational performance summary generated from '
            '${salesData.length} imported records.',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 26),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildKpiCard(
                title: 'Total Sales',
                value: _formatNumber(totalSales),
              ),
              _buildKpiCard(
                title: 'Average Sales',
                value: _formatNumber(averageSales),
              ),
              _buildKpiCard(
                title: 'Forecast',
                value: _formatNumber(forecastSales),
              ),
              _buildKpiCard(
                title: 'Latest Growth',
                value:
                    '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
          pw.SizedBox(height: 26),
          _buildSectionTitle('Performance Summary'),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              _buildSummaryRow(
                label: 'Best Month',
                period: bestMonth.month,
                value: _formatNumber(bestMonth.sales),
                isHeader: true,
              ),
              _buildSummaryRow(
                label: 'Worst Month',
                period: worstMonth.month,
                value: _formatNumber(worstMonth.sales),
              ),
              _buildSummaryRow(
                label: 'Latest Period',
                period: salesData.last.month,
                value: _formatNumber(salesData.last.sales),
              ),
              _buildSummaryRow(
                label: 'Source Records',
                period: 'Imported rows',
                value: salesData.length.toString(),
              ),
            ],
          ),
          pw.SizedBox(height: 26),
          _buildSectionTitle('Management Recommendation'),
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blue100),
            ),
            child: pw.Text(
              recommendation,
              style: const pw.TextStyle(
                fontSize: 11,
                lineSpacing: 4,
                color: PdfColors.blueGrey900,
              ),
            ),
          ),
          pw.SizedBox(height: 26),
          _buildSectionTitle('Monthly Performance'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const ['Month', 'Sales', 'Change'],
            data: _buildMonthlyRows(salesData),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey100,
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blueGrey900,
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'operations-management-report.pdf',
      onLayout: (_) async => document.save(),
    );
  }

  pw.Widget _buildKpiCard({required String title, required String value}) {
    return pw.Container(
      width: 118,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 17,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    );
  }

  pw.TableRow _buildSummaryRow({
    required String label,
    required String period,
    required String value,
    bool isHeader = false,
  }) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: isHeader ? pw.FontWeight.bold : null,
      color: PdfColors.blueGrey900,
    );

    return pw.TableRow(
      decoration: isHeader
          ? const pw.BoxDecoration(color: PdfColors.grey100)
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(period, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: style),
        ),
      ],
    );
  }

  List<List<String>> _buildMonthlyRows(List<SalesRecord> salesData) {
    return salesData.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;

      var changeText = '--';

      if (index > 0) {
        final previous = salesData[index - 1].sales;

        if (previous != 0) {
          final change = ((record.sales - previous) / previous) * 100;

          changeText = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
        }
      }

      return [record.month, _formatNumber(record.sales), changeText];
    }).toList();
  }

  double _calculateGrowthRate(List<SalesRecord> salesData) {
    if (salesData.length < 2) return 0;

    final previous = salesData[salesData.length - 2].sales;
    final latest = salesData.last.sales;

    if (previous == 0) return 0;

    return ((latest - previous) / previous) * 100;
  }

  double _calculateForecast(List<SalesRecord> salesData) {
    if (salesData.isEmpty) return 0;

    final recentRecords = salesData.length >= 3
        ? salesData.sublist(salesData.length - 3)
        : salesData;

    final recentAverage =
        recentRecords.fold<double>(0, (sum, record) => sum + record.sales) /
        recentRecords.length;

    return recentAverage * 1.05;
  }

  String _buildRecommendation(double growthRate) {
    if (growthRate > 5) {
      return 'The latest sales results indicate strong growth. '
          'Consider increasing inventory preparation and reviewing '
          'operational capacity for projected demand.';
    }

    if (growthRate < -5) {
      return 'The latest sales results indicate a decline. '
          'Review demand changes, process bottlenecks, and recent '
          'operational decisions.';
    }

    return 'Sales performance is relatively stable. '
        'Continue monitoring monthly results and maintain current '
        'operational capacity.';
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
}
