import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Classes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fitness_center),
              ),
              title: Text("HIIT Training Class ${index + 1}"),
              subtitle: const Text("10:00 AM - 11:00 AM\nInstructor: John Doe"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Book"),
              ),
            ),
          );
        },
      ),
    );
  }
}
