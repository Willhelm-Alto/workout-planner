import 'package:flutter/material.dart';
import 'package:workout_planner/workout_manager.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({required this.exercise, required this.index, this.tracker, this.customBorder, super.key});
  final Exercise exercise;
  final int index;
  final Widget? tracker;
  final BorderSide? customBorder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // null falls through to cardTheme; only an explicit override builds a shape
      shape: customBorder == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: customBorder!,
            ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    exercise.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    _summary(exercise),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
            ?tracker
          ],
        ),
      ),
    );
  }
}

String _summary(Exercise exercise) {
  return [
    exercise.byTime ? "${exercise.duration}s" : "${exercise.set} × ${exercise.repetitions}" ,
    "${exercise.restTime}s descanso",
    if (exercise.weight != null) "${exercise.weight} kg",
  ].join("  ·  ");
}
