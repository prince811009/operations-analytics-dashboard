import 'package:flutter/material.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

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
                "Forecast",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              Card(
                child: ListTile(
                  title: const Text("Prediction"),
                  subtitle: const Text("Next Month"),
                  trailing: const Text(
                    "195,480",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: ListTile(
                  title: const Text("Model"),
                  subtitle: const Text("LSTM"),
                  trailing: const Text("RMSE 0.021"),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.show_chart,
                      size: 150,
                    ),
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