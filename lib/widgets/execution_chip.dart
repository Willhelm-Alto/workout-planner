import 'package:flutter/material.dart';

class ExecutionChip extends StatelessWidget {
  const ExecutionChip({super.key, required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(text),
    );
  }
}