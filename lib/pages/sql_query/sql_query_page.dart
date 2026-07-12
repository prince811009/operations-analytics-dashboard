import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/sales_record.dart';
import '../../theme/app_theme.dart';

class SqlQueryPage extends StatefulWidget {
  final List<SalesRecord> salesData;

  const SqlQueryPage({super.key, required this.salesData});

  @override
  State<SqlQueryPage> createState() => _SqlQueryPageState();
}

class _SqlQueryPageState extends State<SqlQueryPage> {
  final TextEditingController _queryController = TextEditingController(
    text: '''
SELECT id, month, sales
FROM sales
WHERE sales > 150000
ORDER BY sales DESC;
''',
  );

  List<Map<String, Object?>> _queryResults = [];
  String? _errorMessage;
  bool _isRunning = false;
  bool _hasRunQuery = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runQuery() async {
    final sql = _queryController.text.trim();

    if (sql.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a SQL query.';
      });
      return;
    }

    setState(() {
      _isRunning = true;
      _errorMessage = null;
    });

    try {
      final results = await DatabaseHelper.instance.runSelectQuery(sql);

      if (!mounted) return;

      setState(() {
        _queryResults = results;
        _hasRunQuery = true;
      });
    } on FormatException catch (error) {
      if (!mounted) return;

      setState(() {
        _queryResults = [];
        _hasRunQuery = true;
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _queryResults = [];
        _hasRunQuery = true;
        _errorMessage = 'Query failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  void _loadExampleQuery(String query) {
    _queryController.text = query;

    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    'SQL Query Explorer',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Run read-only SQL queries against imported sales data.',
                    style: TextStyle(fontSize: 16, color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 28),
                  _buildQueryEditor(),
                  const SizedBox(height: 20),
                  _buildExampleQueries(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildErrorMessage(),
                  _buildResultsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQueryEditor() {
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
            'SQL Editor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            minLines: 7,
            maxLines: 12,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              height: 1.5,
              color: Color(0xFFE2E8F0),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText: 'Enter a SELECT query...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isRunning ? null : _runQuery,
                icon: _isRunning
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'Running...' : 'Run Query'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '${widget.salesData.length} imported records',
                style: const TextStyle(color: AppTheme.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleQueries() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton(
          onPressed: () {
            _loadExampleQuery('''
SELECT id, month, sales
FROM sales
ORDER BY month ASC;
''');
          },
          child: const Text('All Records'),
        ),
        OutlinedButton(
          onPressed: () {
            _loadExampleQuery('''
SELECT month, sales
FROM sales
WHERE sales > 150000
ORDER BY sales DESC;
''');
          },
          child: const Text('Sales > 150,000'),
        ),
        OutlinedButton(
          onPressed: () {
            _loadExampleQuery('''
SELECT AVG(sales) AS average_sales
FROM sales;
''');
          },
          child: const Text('Average Sales'),
        ),
        OutlinedButton(
          onPressed: () {
            _loadExampleQuery('''
SELECT month, sales
FROM sales
ORDER BY sales DESC
LIMIT 3;
''');
          },
          child: const Text('Top 3 Months'),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Query Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
              ),
              if (_hasRunQuery)
                Text(
                  '${_queryResults.length} rows',
                  style: const TextStyle(color: AppTheme.mutedText),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (!_hasRunQuery)
            const _EmptyResult(message: 'Run a SELECT query to view results.')
          else if (_queryResults.isEmpty && _errorMessage == null)
            const _EmptyResult(message: 'The query returned no records.')
          else if (_queryResults.isNotEmpty)
            _buildResultTable(),
        ],
      ),
    );
  }

  Widget _buildResultTable() {
    final columns = _queryResults.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columns: columns.map((column) {
          return DataColumn(
            label: Text(
              column,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
          );
        }).toList(),
        rows: _queryResults.map((row) {
          return DataRow(
            cells: columns.map((column) {
              final value = row[column];

              return DataCell(
                Text(
                  value?.toString() ?? 'NULL',
                  style: const TextStyle(color: AppTheme.text),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  final String message;

  const _EmptyResult({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.storage_outlined,
            size: 48,
            color: AppTheme.mutedText,
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.mutedText)),
        ],
      ),
    );
  }
}
