import 'package:flutter/material.dart';

import '../models/sales_record.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/data_explorer/data_explorer_page.dart';
import '../pages/forecast/forecast_page.dart';
import '../pages/report/report_page.dart';
import '../pages/sql_query/sql_query_page.dart';
import '../services/csv_service.dart';
import '../widgets/app_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final CsvService _csvService = CsvService();

  int selectedIndex = 0;
  bool isSidebarCollapsed = false;
  bool isImporting = false;

  String? importedFileName;
  String? importError;

  List<SalesRecord> salesData = const [];

  Future<void> importCsv() async {
    setState(() {
      isImporting = true;
      importError = null;
    });

    try {
      final result = await _csvService.pickAndParseSalesCsv();

      if (result == null) {
        return;
      }

      setState(() {
        salesData = result.records;
        importedFileName = result.fileName;
      });
    } on FormatException catch (error) {
      setState(() {
        importError = error.message;
      });
    } catch (error) {
      setState(() {
        importError = 'Import failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        salesData: salesData,
        importedFileName: importedFileName,
        importError: importError,
        isImporting: isImporting,
        onImportCsv: importCsv,
      ),
      DataExplorerPage(salesData: salesData),
      SqlQueryPage(salesData: salesData),
      ForecastPage(salesData: salesData),
      ReportPage(salesData: salesData),
    ];

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: selectedIndex,
            isCollapsed: isSidebarCollapsed,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            onToggleCollapse: () {
              setState(() {
                isSidebarCollapsed = !isSidebarCollapsed;
              });
            },
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
