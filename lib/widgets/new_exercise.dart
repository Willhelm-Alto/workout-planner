import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_planner/workout_manager.dart';

class NewExercise extends StatefulWidget {
  const NewExercise({
    required this.onDelete,
    required this.exercise,
    required this.fieldValidator,
    required this.index,
    super.key,
  });
  final int index;
  final Function onDelete;
  final Function(String? value) fieldValidator;
  final Exercise exercise;
  @override
  State<NewExercise> createState() => _NewExerciseState();
}

class _NewExerciseState extends State<NewExercise> {
  final durationController = TextEditingController();
  final setController = TextEditingController();
  final weightController = TextEditingController();
  final observationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setController.text = widget.exercise.set.toString();
    widget.exercise.duration ??= 10;
    durationController.text = widget.exercise.duration.toString();
    widget.exercise.weight != null
        ? weightController.text = widget.exercise.weight.toString()
        : weightController.text = "-";
    if (widget.exercise.observation != null) {
      observationController.text = widget.exercise.observation!;
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    setController.dispose();
    weightController.dispose();
    observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ReorderableDragStartListener(
                    index: widget.index,
                    child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: widget.exercise.title,
              onChanged: (value) => widget.exercise.title = value,
              validator: (value) => widget.fieldValidator(value),
              style: TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                label: Text(
                  "Nome do exercício",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: [
                Row(
                  spacing: 8,
                  children: [
                    widget.exercise.byTime
                        ? Expanded(
                            child: TextFormField(
                              controller: durationController,
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null) {
                                  widget.exercise.duration = parsed;
                                }
                              },
                              validator: (value) =>
                                  widget.fieldValidator(value),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                label: Text('Duração'),
                                suffixText: "(s)",
                              ),
                            ),
                          )
                        : Expanded(
                            child: TextFormField(
                              controller: setController,
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null) {
                                  widget.exercise.set = parsed;
                                }
                              },
                              validator: (value) =>
                                  widget.fieldValidator(value),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                label: Text('Set'),
                              ),
                            ),
                          ),
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.exercise.repetitions.toString(),
                        enabled: !widget.exercise.byTime,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            widget.exercise.repetitions = parsed;
                          }
                        },
                        validator: (value) => widget.fieldValidator(value),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          label: Text('Rep'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.exercise.restTime.toString(),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            widget.exercise.restTime = parsed;
                          }
                        },
                        validator: (value) => widget.fieldValidator(value),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          label: Text('Descanso'),
                          suffixText: "(s)",
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: weightController,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            widget.exercise.weight = parsed;
                          }
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          label: Text('Carga'),
                          suffixText: "(kg)",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: observationController,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) => widget.exercise.observation = value,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      label: Text('Obs.'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: widget.exercise.byTime,
                  onChanged: (value) =>
                      setState(() => widget.exercise.byTime = value),
                ),
                Text(
                  "Por duração",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.exercise.byTime
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
                Spacer(),
                IconButton(
                  color: scheme.error,
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
