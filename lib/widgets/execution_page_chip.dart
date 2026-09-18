import 'package:flutter/material.dart';

class ExecutionChip extends StatelessWidget {
  const ExecutionChip({super.key, required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.blue.shade50,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      label: Text(text),
    );
  }
}