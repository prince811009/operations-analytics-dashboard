import 'package:flutter/material.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/app_sidebar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Operations Analytics Dashboard",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Good Morning, Joanne 👋",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: const [
                        Expanded(
                          child: KpiCard(
                            title: "Total Records",
                            value: "12,580",
                            icon: Icons.folder_open,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: KpiCard(
                            title: "Forecast",
                            value: "195,480",
                            icon: Icons.show_chart,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: KpiCard(
                            title: "Average",
                            value: "151,750",
                            icon: Icons.analytics,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: KpiCard(
                            title: "Growth",
                            value: "+8.2%",
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(24),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xffE2E8F0),
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sales Trend",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Expanded(
                                    child: Center(
                                      child: Icon(
                                        Icons.show_chart,
                                        size: 120,
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xffE2E8F0),
                                      ),
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: const [
                                        Text(
                                          "Recent Records",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 20),

                                        ListTile(
                                          dense: true,
                                          leading: Icon(Icons.check_circle,
                                              color: Colors.green),
                                          title: Text("2025-08"),
                                          trailing: Text("181,000"),
                                        ),

                                        ListTile(
                                          dense: true,
                                          leading: Icon(Icons.check_circle,
                                              color: Colors.green),
                                          title: Text("2025-07"),
                                          trailing: Text("168,000"),
                                        ),

                                        ListTile(
                                          dense: true,
                                          leading: Icon(Icons.check_circle,
                                              color: Colors.green),
                                          title: Text("2025-06"),
                                          trailing: Text("172,000"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xffE2E8F0),
                                      ),
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: const [
                                        Text(
                                          "AI Recommendation",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 20),

                                        Text(
                                          "Sales show a positive trend over recent months.\n\n"
                                          "Recommended actions:\n\n"
                                          "• Prepare inventory\n"
                                          "• Increase staffing\n"
                                          "• Monitor growth weekly",
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}