import 'package:flutter/material.dart';
import 'package:gym_tracker/workout.dart';

class NewExercise extends StatefulWidget {
  const NewExercise({
    required this.onDelete,
    required this.exercise,
    required this.nameValidator,
    required this.setValidator,
    required this.repValidator,
    required this.restValidator,
    super.key,
  });
  final Function onDelete;
  final Function(String? value) nameValidator;
  final Function(String? value) setValidator;
  final Function(String? value) repValidator;
  final Function(String? value) restValidator;
  final Exercise exercise;
  @override
  State<NewExercise> createState() => _NewExerciseState();
}

class _NewExerciseState extends State<NewExercise> {
  bool isDuration = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.exercise.title,
              onChanged: (value) => widget.exercise.title = value,
              validator: (value) => widget.nameValidator(value),
              style: TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                label: Text(
                  "Nome do Exercício",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              spacing: 8,
              children: [
                isDuration ? Expanded(
                  child: TextFormField(
                    initialValue: 10.toString(),
                    onChanged: (value) {
                      if (value != "") {
                        widget.exercise.set = int.parse(value);
                      }
                    },
                    validator: (value) => widget.setValidator(value),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      label: Text('Duration'),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ) :
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exercise.set.toString(),
                    onChanged: (value) {
                      if (value != "") {
                        widget.exercise.set = int.parse(value);
                      }
                    },
                    validator: (value) => widget.setValidator(value),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      label: Text('Set'),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exercise.repetitions.toString(),
                    onChanged: (value) {
                      if (value != "") {
                        widget.exercise.repetitions = int.parse(value);
                      }
                    },
                    validator: (value) => widget.repValidator(value),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      label: Text('Rep'),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exercise.restTime.toString(),
                    onChanged: (value) {
                      if (value != "") {
                        widget.exercise.restTime = int.parse(value);
                      }
                    },
                    validator: (value) => widget.restValidator(value),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      label: Text('Rest'),
                      labelStyle: TextStyle(color: Colors.grey),
                      suffixText: "(s)",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: isDuration,
                  onChanged: (value) => setState(() => isDuration = value),
                  activeTrackColor: Colors.blue
                ),
                Text("Por Duração", style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                  color: isDuration ? Colors.blue.shade700 : Colors.grey
                )),
                Spacer(),
                IconButton(
                  color: Colors.red,
                  onPressed: () => widget.onDelete(),
                  icon: Icon(Icons.delete, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
