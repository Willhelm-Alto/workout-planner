import 'package:flutter/material.dart';
import 'package:workout_planner/pages/edit_workout_page.dart';
import 'package:workout_planner/workout_manager.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditWorkout(workout: workout),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(15),
          child: Column(
            spacing: 4,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(workout.day.label),
                    labelStyle: TextStyle(fontSize: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "${workout.exercises.length} ${workout.exercises.length == 1 ? 'exercício' : 'exercícios'}",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
