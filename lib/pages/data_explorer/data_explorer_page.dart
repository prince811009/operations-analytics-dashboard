import 'dart:convert';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';

import '../../models/sales_record.dart';
import '../../theme/app_theme.dart';

class DataExplorerPage extends StatefulWidget {
  final List<SalesRecord> salesData;

  const DataExplorerPage({super.key, required this.salesData});

  @override
  State<DataExplorerPage> createState() => _DataExplorerPageState();
}

class _DataExplorerPageState extends State<DataExplorerPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minimumSalesController = TextEditingController();

  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    _minimumSalesController.dispose();
    super.dispose();
  }

  List<SalesRecord> get _filteredRecords {
    final keyword = _searchController.text.trim().toLowerCase();
    final minimumSales = double.tryParse(_minimumSalesController.text.trim());

    final records = widget.salesData.where((record) {
      final matchesKeyword =
          keyword.isEmpty || record.month.toLowerCase().contains(keyword);

      final matchesMinimum =
          minimumSales == null || record.sales >= minimumSales;

      return matchesKeyword && matchesMinimum;
    }).toList();

    records.sort(
      (first, second) => _sortAscending
          ? first.sales.compareTo(second.sales)
          : second.sales.compareTo(first.sales),
    );

    return records;
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

  void _exportCsv() {
    final records = _filteredRecords;

    if (records.isEmpty) {
      return;
    }

    final csvBuffer = StringBuffer('month,sales\n');

    for (final record in records) {
      csvBuffer.writeln('${record.month},${record.sales}');
    }

    final bytes = utf8.encode(csvBuffer.toString());

    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', 'filtered_sales_data.csv')
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 850;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Explorer',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Search, filter, sort, and export imported operational data.',
                    style: TextStyle(fontSize: 16, color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 28),
                  _buildFilterBar(isCompact),
                  const SizedBox(height: 24),
                  _buildSummary(records),
                  const SizedBox(height: 24),
                  _buildTable(records),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isCompact) {
    final fields = [
      SizedBox(
        width: isCompact ? double.infinity : 320,
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Search month',
            hintText: 'Example: 2025-03',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppTheme.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
          ),
        ),
      ),
      SizedBox(
        width: isCompact ? double.infinity : 250,
        child: TextField(
          controller: _minimumSalesController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Minimum sales',
            hintText: 'Example: 150000',
            prefixIcon: const Icon(Icons.filter_alt_outlined),
            filled: true,
            fillColor: AppTheme.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
          ),
        ),
      ),
      OutlinedButton.icon(
        onPressed: () {
          setState(() {
            _sortAscending = !_sortAscending;
          });
        },
        icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
        label: Text(
          _sortAscending ? 'Sales: Low to High' : 'Sales: High to Low',
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      ElevatedButton.icon(
        onPressed: _filteredRecords.isEmpty ? null : _exportCsv,
        icon: const Icon(Icons.download_outlined),
        label: const Text('Export CSV'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final field in fields) ...[field, const SizedBox(height: 12)],
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: fields,
    );
  }

  Widget _buildSummary(List<SalesRecord> records) {
    final totalSales = records.fold<double>(
      0,
      (sum, record) => sum + record.sales,
    );

    final averageSales = records.isEmpty ? 0 : totalSales / records.length;

    final maximumSales = records.isEmpty
        ? 0
        : records
              .map((record) => record.sales)
              .reduce((first, second) => first > second ? first : second);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _SummaryCard(title: 'Rows', value: records.length.toString()),
        _SummaryCard(title: 'Total Sales', value: _formatNumber(totalSales)),
        _SummaryCard(
          title: 'Average Sales',
          value: _formatNumber(averageSales.toDouble()),
        ),
        _SummaryCard(
          title: 'Maximum Sales',
          value: _formatNumber(maximumSales.toDouble()),
        ),
      ],
    );
  }

  Widget _buildTable(List<SalesRecord> records) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Imported Records',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 18),
          if (widget.salesData.isEmpty)
            const _EmptyState(message: 'Upload a CSV file to explore data.')
          else if (records.isEmpty)
            const _EmptyState(message: 'No records match the current filters.')
          else
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
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sales',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                rows: records.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text(record.month)),
                      DataCell(Text(_formatNumber(record.sales))),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.mutedText)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.table_rows_outlined,
            size: 50,
            color: AppTheme.mutedText,
          ),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppTheme.mutedText)),
        ],
      ),
    );
  }
}
