import '../../models/sales_record.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  final List<SalesRecord> salesData;

  const ReportPage({
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
          child: ListView(
            children: const [
              Text(
                "Management Report",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 32),

              ListTile(
                title: Text("Best Month"),
                trailing: Text("2025-08"),
              ),

              Divider(),

              ListTile(
                title: Text("Worst Month"),
                trailing: Text("2025-01"),
              ),

              Divider(),

              ListTile(
                title: Text("Average Sales"),
                trailing: Text("151,750"),
              ),

              Divider(),

              ListTile(
                title: Text("Forecast"),
                trailing: Text("195,480"),
              ),

              Divider(),

              ListTile(
                title: Text("Recommendation"),
                subtitle: Text(
                  "Sales trend is positive.\nIncrease inventory preparation.",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}