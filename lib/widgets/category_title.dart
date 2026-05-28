import 'package:flutter/material.dart';

class CategoryTitle extends StatelessWidget {
  final String title;
  const CategoryTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          TextButton(
            onPressed: () {},
            child: const Text("Ver todo >", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}