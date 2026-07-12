import '../../models/sales_record.dart';
import 'package:flutter/material.dart';

class SqlQueryPage extends StatelessWidget {
  final List<SalesRecord> salesData;

  const SqlQueryPage({
    super.key,
    required this.salesData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SQL Query",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SelectableText(
                  '''
SELECT *
FROM sales
WHERE sales > 150000
ORDER BY sales DESC;
''',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {},
                child: const Text("Run Query"),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Month")),
                      DataColumn(label: Text("Sales")),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(Text("2025-08")),
                          DataCell(Text("181000")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text("2025-07")),
                          DataCell(Text("168000")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text("2025-06")),
                          DataCell(Text("172000")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}