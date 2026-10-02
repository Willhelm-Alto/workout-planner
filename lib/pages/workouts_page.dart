import 'package:flutter/material.dart';
import 'package:workout_planner/pages/edit_workout_page.dart';
import 'package:workout_planner/widgets/workout_card.dart';
import 'package:workout_planner/workout_manager.dart';

class WorkoutPage extends StatelessWidget {
  WorkoutPage({super.key});

  final manager = WorkoutManager();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, child) {
        if(manager.workouts.isEmpty) return EmptyWorkout();
        final scheme = Theme.of(context).colorScheme;
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
                        background: Container(
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: scheme.onError),
                        ),
                        key: ValueKey(e.id),
                        onDismissed: (_) async{
                          await manager.deleteWorkout(e);
                        },
                        child: WorkoutCard(workout: e),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

class EmptyWorkout extends StatelessWidget {
  const EmptyWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: scheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                "Nenhum treino salvo",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}