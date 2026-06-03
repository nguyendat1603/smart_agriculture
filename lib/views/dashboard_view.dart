import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giám Sát Cây Trồng"),
        backgroundColor: Colors.green,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        children: [
          _buildSensorCard("Nhiệt độ (DHT22)", "28.5 °C", Colors.orange),
          _buildSensorCard("Độ ẩm khí (DHT22)", "65 %", Colors.blue),
          _buildSensorCard("Độ ẩm Đất", "45 %", Colors.brown),
          _buildSensorCard("Trạng thái Mưa", "Không mưa", Colors.teal),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
