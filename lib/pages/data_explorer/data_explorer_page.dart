import 'package:flutter/material.dart';

class DataExplorerPage extends StatelessWidget {
  const DataExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {"month": "2025-01", "sales": "120000"},
      {"month": "2025-02", "sales": "135000"},
      {"month": "2025-03", "sales": "128000"},
      {"month": "2025-04", "sales": "150000"},
      {"month": "2025-05", "sales": "160000"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Explorer",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                decoration: InputDecoration(
                  hintText: "Search month...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text(data[index]["month"]!),
                        trailing: Text(data[index]["sales"]!),
                      );
                    },
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