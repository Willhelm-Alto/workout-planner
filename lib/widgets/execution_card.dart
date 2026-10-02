import 'package:flutter/material.dart';

class ExecutionCard extends StatelessWidget {
  const ExecutionCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
        child: child,
      ),
    );
  }
}