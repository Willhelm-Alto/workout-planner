import 'package:flutter/material.dart';
import 'package:workout_planner/widgets/new_exercise.dart';
import 'package:workout_planner/workout.dart';
import 'package:uuid/uuid.dart';

class EditWorkout extends StatefulWidget {
  const EditWorkout({this.workout, super.key});
  final Workout? workout;

  @override
  EditWorkoutState createState() => EditWorkoutState();
}

class EditWorkoutState extends State<EditWorkout> {
  final WorkoutManager _manager = WorkoutManager();

  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();

  List<Exercise> exercises = [];
  DayOfWeek _selectedDayOfWeek = DayOfWeek.segunda;

  bool isNew = false;
  bool showTimeField = false;

  @override
  void initState() {
    super.initState();
    widget.workout == null ? isNew = true : isNew = false;
    if (!isNew) {
      _workoutNameController.text = widget.workout!.title;
      _selectedDayOfWeek = widget.workout!.day;
      exercises.addAll(widget.workout!.exercises.map(Exercise.copy));
    }
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? "Novo Treino" : "Editar Treino")),
      body: Form(
        key: _formKey,
        child: ReorderableListView(
          padding: EdgeInsets.all(16),
          autoScrollerVelocityScalar: 20,
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            setState((){
              final e = exercises.removeAt(oldIndex);
              exercises.insert(newIndex, e);
            });
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
                builder: (context, _) {
                  final curve = Curves.easeInOut.transform(animation.value);
                  return Material(
                    color: Colors.transparent,
                    child: Transform.scale(
                      scale: 1 + 0.03 * curve,
                      child: Opacity(
                        opacity: 1 - 0.1 * curve, 
                        child: child,
                      ),
                    ),
                  );
               }
            );
          },
          header: Column(
            children: [
              TextFormField(
                controller: _workoutNameController,
                style: TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  label: Text("Nome do Treino"),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (value) {
                  if (value == null || value == "") {
                    return "Preencha o nome do treino";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField(
                items: DayOfWeek.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.label,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                    .toList(),
                initialValue: _selectedDayOfWeek,
                decoration: InputDecoration(
                  label: Text("Dia da Semana"),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  _selectedDayOfWeek = value!;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(),
                      ),
                    ),
                    Text("Exercícios", style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          footer:IconButton(
              style: IconButton.styleFrom(side: BorderSide(color: Colors.grey)),
              onPressed: () =>
                  setState(() => exercises.add(Exercise(title: ""))),
              icon: Icon(Icons.add, color: Colors.grey),
            ),
          children: [
            for(final (i, e) in exercises.indexed)
              NewExercise(
                key: ValueKey(e),
                index: i,
                exercise: e,
                onDelete: () => setState(() {
                  exercises.remove(e);
                }),
                fieldValidator: (value) {
                  if (value == null || value == "") {
                    return "Campo vazio";
                  }
                  return null;
                },
              ),
            
          ]
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 56,
          child: TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var workout = Workout(
                  id: isNew ? Uuid().v4() : widget.workout!.id,
                  title: _workoutNameController.text.toUpperCase(),
                  exercises: exercises,
                  day: _selectedDayOfWeek,
                );
                if (!_manager.checkIfValid(workout)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Já existe um treino nesse dia")),
                  );
                  return;
                }
                if (isNew) {
                  await _manager.saveWorkout(workout);
                } else {
                  await _manager.editWorkout(workout);
                }
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SALVAR",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}