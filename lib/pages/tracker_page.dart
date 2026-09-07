import 'package:flutter/material.dart';
import 'package:workout_planner/widgets/tracker_bottom_sheet.dart';
import 'package:workout_planner/widgets/exercise_card.dart';
import 'package:workout_planner/workout.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({required this.workout, super.key});

  final Workout workout;

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  Map<Exercise, bool> doneExercisesList = {};
  Exercise? current;

  @override
  void initState() {
    super.initState();
    for (final e in widget.workout.exercises) {
      doneExercisesList[e] = false;
    }
  }

  Future<bool> closeConfirmationDialog() async {
    final res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sair do treino?"),
        content: Text("Tem certeza que deseja cancelar o treino?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sim'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  //TODO: TERMINAR A FUNCIONALIDADE DESSA PÁGINA
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldClose = await closeConfirmationDialog();
        if (context.mounted && shouldClose) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.workout.title)),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.workout.exercises.length,
          itemBuilder: (_, i) => ExerciseCard(
            exercise: widget.workout.exercises[i],
            index: i,
            customBorder:
                current != null && current! == widget.workout.exercises[i]
                ? BorderSide(color: Colors.blue, width: 2)
                : null,
            tracker: Switch(value: false, onChanged: (value) {}),
          ),
        ),
        bottomSheet: TrackerBottomSheet(
          current: current,
          onTap: () => setState(
            () => current = doneExercisesList.entries
                .firstWhere((element) => !element.value)
                .key,
          ),
        ),
      ),
    );
  }
}
