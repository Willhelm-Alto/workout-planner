import 'package:flutter/material.dart';
import 'package:workout_planner/pages/edit_workout_page.dart';
import 'package:workout_planner/workout_manager.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
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
                    side: BorderSide.none,
                    backgroundColor: Colors.blue.shade50,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "${workout.exercises.length} exercises",
                    style: TextStyle(color: Colors.grey),
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
