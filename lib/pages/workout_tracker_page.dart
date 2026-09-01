import 'package:flutter/material.dart';
import 'package:gym_tracker/widgets/bottom_sheet.dart';
import 'package:gym_tracker/widgets/exercise_card.dart';
import 'package:gym_tracker/workout.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({required this.workout, super.key});

  final Workout workout;

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  Map<Exercise, bool> doneExercisesList = {};

  @override
  void initState() {
    super.initState();
    widget.workout.exercises.forEach((e) => doneExercisesList[e] = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.workout.exercises.length,
        itemBuilder: (_, i) => ExerciseCard(
          exercise: widget.workout.exercises[i],
          index: i,
          tracker: Switch(value: false, onChanged: (value) {}),
        ),
      ),
      bottomSheet: MainBotomSheet(),
    );
  }
}
