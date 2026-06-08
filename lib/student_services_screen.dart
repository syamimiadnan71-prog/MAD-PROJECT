import 'package:flutter/material.dart';

class StudentServicesScreen extends StatelessWidget {
  const StudentServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Services")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _serviceCard("Printing Services", "RM 0.10/page"),
          _serviceCard("Laptop Repair", "Starts at RM 30"),
        ],
      ),
    );
  }

  Widget _serviceCard(String title, String price) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(price),
        trailing: const Icon(Icons.phone),
      ),
    );
  }
}
