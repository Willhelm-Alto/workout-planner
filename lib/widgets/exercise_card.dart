import 'package:flutter/material.dart';
import 'package:gym_tracker/workout.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({required this.exercise, required this.index, this.tracker, super.key});
  final Exercise exercise;
  final int index;
  final Widget? tracker;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
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
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
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
                    style: TextStyle(color: Colors.grey, fontSize: 13),
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
