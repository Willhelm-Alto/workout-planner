import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_planner/workout_manager.dart';

class ExecutionPage extends StatefulWidget {
  const ExecutionPage({required this.workout, super.key});
  final Workout workout;

  @override
  State<ExecutionPage> createState() => _ExecutionPageState();
}

class _ExecutionPageState extends State<ExecutionPage> {
  Map<Exercise, bool> doneExercisesList = {};
  late Exercise current;
  final stopwatch = Stopwatch();
  Timer? ticker;
  Timer? _timer;
  bool _isTimer = false;
  int _secondsLeft = 0;
  int currentSet = 1;
  bool workoutStarted = false;
  final weightController = TextEditingController();

  String get stopwatchStr {
    final e = stopwatch.elapsed;
    final h = e.inHours.toString().padLeft(2, '0');
    final m = (e.inMinutes % 60).toString().padLeft(2, '0');
    final s = (e.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  String get seriesStr {
    return "series: ${current.set}   .   rest: ${current.restTime}s";
  }

  @override
  void initState() {
    super.initState();
    for (final e in widget.workout.exercises) {
      doneExercisesList[e] = false;
    }
    current = doneExercisesList.entries.firstWhere((e) => !e.value).key;
    current.weight != null
        ? weightController.text = current.weight.toString()
        : weightController.text = '-';
  }

  @override
  void dispose() {
    ticker?.cancel();
    _timer?.cancel();
    super.dispose();
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

  void _toggleTimer() {
    if (!workoutStarted) {
      workoutStarted = true;
      setState(() {});
      stopwatch.start();
      ticker ??= Timer.periodic(Duration(seconds: 1), (_) => setState(() {}));
      return;
    }

    if (_isTimer) {
      _timer?.cancel();
      setState(() => finishTimer());
      return;
    }

    setState(() {
      _isTimer = true;
      _secondsLeft = current.restTime;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft == 0) {
            timer.cancel();
            finishTimer();
          }
        });
      });
    });
  }

  void finishTimer() {
    _timer = null;
    _isTimer = false;
    currentSet++;
    if (currentSet > current.set) {
      setState(() {
        doneExercisesList[current] = true;
        current = doneExercisesList.entries
            .firstWhere((element) => !element.value)
            .key;
      });
    }
  }

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
        appBar: AppBar(
          title: Text(widget.workout.title),
          actions: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [Icon(Icons.timer_outlined), Text(stopwatchStr)],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            labelStyle: TextStyle(),
                            label: Text('${current.repetitions} reps'),
                          ),
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            labelStyle: TextStyle(),
                            label: Text('${current.set} sets'),
                          ),
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            labelStyle: TextStyle(),
                            label: Text('${current.restTime}s rest'),
                          ),
                        ],
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Set ${currentSet} of ${current.set}"),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 6,
                                children: List.generate(current.set, (i) {
                                  final done = i < currentSet - 1;
                                  final active = i == currentSet - 1;
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: done
                                          ? Colors.blue
                                          : Colors.transparent,
                                      border: Border.all(
                                        width: 2,
                                        color: done || active
                                            ? Colors.blue
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 16,
                          ),
                          child: Column(
                            spacing: 12,
                            children: [
                              Row(
                                spacing: 6,
                                children: [
                                  Icon(Icons.fitness_center, size: 16),
                                  Text("Weight"),
                                ],
                              ),
                              Row(
                                spacing: 12,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: weightController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                        suffixText: "kg",
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {}, //TODO: Permitir salvar o peso
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      "Save",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildObservation()
                    ],
                  ),
                ),
              ),
              _buildMainButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservation() {
    //TODO: Permitir editar observação
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: 6,
              children: [
                Icon(Icons.list_alt, size: 16),
                Expanded(child: Text("Note")),
                IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 16)),
              ],
            ),
            TextFormField(
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.fromLTRB(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isTimer)
                SizedBox(
                  width: 108,
                  height: 108,
                  child: CircularProgressIndicator(
                    value: _secondsLeft / current.restTime,
                    strokeWidth: 3,
                    backgroundColor: Colors.blue.shade50,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
              ElevatedButton(
                onPressed: _toggleTimer,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(10),
                  elevation: 0,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(92, 92),
                ),
                child: !workoutStarted
                    ? Text("START")
                    : _isTimer
                    ? Text(
                        "$_secondsLeft",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
    );
  }
}