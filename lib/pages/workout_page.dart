import 'package:flutter/material.dart';
import 'package:gym_tracker/pages/edit_workout.dart';
import 'package:gym_tracker/workout.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final manager = WorkoutManager();

  @override
  Widget build(BuildContext context) {
    if (manager.workouts.isEmpty) {
      return EmptyWorkout();
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ...manager.workouts.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Dismissible(
                    direction: DismissDirection.startToEnd,
                    dismissThresholds: {},
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    key: ValueKey(e.id),
                    onDismissed: (direction) {
                    },
                    child: WorkoutCard(workout: e, then: () => setState((){})),
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(side: BorderSide(color: Colors.grey)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditWorkout()),
          ),
          icon: Icon(Icons.add, color: Colors.grey),
        ),
      ],
    );
  }
}

class EmptyWorkout extends StatelessWidget {
  const EmptyWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditWorkout()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "Não há nenhum treino salvo",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout, required this.then});
  final Workout workout;
  final Function then;

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
        ).then((value) => then()),
        child: Padding(
          padding: EdgeInsetsGeometry.all(15),
          child: Column(
            spacing: 4,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title.toUpperCase(),
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
                    "${workout.exercises.length} exercícios",
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
