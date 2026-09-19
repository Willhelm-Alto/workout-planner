import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_planner/widgets/execution_card.dart';
import 'package:workout_planner/widgets/execution_chip.dart';
import 'package:workout_planner/workout_manager.dart';

class ExecutionPage extends StatefulWidget {
  const ExecutionPage({required this.workout, super.key});
  final Workout workout;

  @override
  State<ExecutionPage> createState() => _ExecutionPageState();
}

class _ExecutionPageState extends State<ExecutionPage> {
  List<Exercise> doneExercisesList = [];
  Exercise get current => widget.workout.exercises[currentIndex];

  Timer? ticker;
  Timer? timer;

  bool isTimer = false;
  bool workoutStarted = false;
  bool isEditingNote = false;
  bool isWorkoutDone = false;

  int secondsLeft = 0;
  int currentSet = 1;
  int currentIndex = 0;

  final weightController = TextEditingController();
  final noteController = TextEditingController();
  final stopwatch = Stopwatch();
  final manager = WorkoutManager();

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
    setWeightController();
    setNoteController();
  }

  @override
  void dispose() {
    ticker?.cancel();
    timer?.cancel();
    noteController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void setWeightController() => current.weight != null
      ? weightController.text = current.weight.toString()
      : weightController.text = "-";

  void setNoteController() => current.observation != null
      ? noteController.text = current.observation!
      : noteController.text = "";

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

    if (isTimer) {
      timer?.cancel();
      setState(() => finishTimer());
      return;
    }

    setState(() {
      isTimer = true;
      secondsLeft = current.restTime;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          secondsLeft--;
          if (secondsLeft == 0) {
            timer.cancel();
            finishTimer();
          }
        });
      });
    });
  }

  void finishTimer() {
    timer = null;
    isTimer = false;
    currentSet++;
    if (currentSet > current.set) {
      setState(() {
        currentSet = 1;
        doneExercisesList.add(current);
        if (doneExercisesList.length < widget.workout.exercises.length) {
          currentIndex++;
          setWeightController();
          setNoteController();
        } else {
          ticker?.cancel();
          stopwatch.stop();
          isWorkoutDone = true;
        }
      });
    }
  }

  void goToExercise(int index) {
    if (index < 0 || index >= widget.workout.exercises.length) return;
    timer?.cancel();
    setState(() {
      timer = null;
      isTimer = false;
      currentIndex = index;
      currentSet = 1;
      isEditingNote = false;
      setNoteController();
      setWeightController();
    });
  }

  Future<void> saveWeight() async {
    FocusScope.of(context).unfocus();
    final text = weightController.text;
    int? newWeight = text.isEmpty ? null : int.parse(text);
    if (newWeight != current.weight) {
      setState(() => current.weight = newWeight);
      await manager.editWorkout(widget.workout);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Weight Saved"), duration: Duration(seconds: 1)),
      );
      }
    }
  }

  Future<void> saveNote() async {
    FocusScope.of(context).unfocus();
    final newNote = noteController.text;
    isEditingNote = false;
    if (newNote != current.observation) {
      setState(() => current.observation = newNote);
      await manager.editWorkout(widget.workout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Note Saved"), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isWorkoutDone ? true : false,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              executionBody(),
              AnimatedSlide(
                offset: isWorkoutDone ? Offset.zero : Offset(0, 1),
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: finishedBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget finishedBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 16,
          children: [
            Spacer(flex: 2),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: Colors.blue.shade700,
              ),
            ),
            Text(
              "Workout Complete!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text(widget.workout.title, style: TextStyle(fontSize: 15)),
            Text("Total time: $stopwatchStr"),
            Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget executionBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExecutionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        "Exercise ${currentIndex + 1} of ${widget.workout.exercises.length}",
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.blue,
                          value:
                              doneExercisesList.length /
                              widget.workout.exercises.length,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  current.title.toUpperCase(),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ExecutionChip(text: '${current.repetitions} reps'),
                    ExecutionChip(text: '${current.set} sets'),
                    ExecutionChip(text: '${current.restTime}s rest'),
                  ],
                ),
                ExecutionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Set $currentSet of ${current.set}"),
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
                              color: done ? Colors.blue : Colors.transparent,
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
                ExecutionCard(
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
                              onSubmitted: (_) => saveWeight(),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: false,
                                signed: false,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                suffixText: "kg",
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => saveWeight(),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                _buildNoteField(),
              ],
            ),
          ),
        ),
        _buildMainButton(),
      ],
    );
  }

  Widget _buildNoteField() {
    final isNoteEmpty = noteController.text.isEmpty;
    return ExecutionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          if (!isNoteEmpty)
            Row(
              spacing: 6,
              children: [
                Icon(Icons.list_alt, size: 16),
                Expanded(child: Text("Note")),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      setState(() => isEditingNote = !isEditingNote),
                  icon: Icon(Icons.edit, size: 16),
                ),
              ],
            ),
          if (isNoteEmpty)
            InkWell(
              onTap: () => setState(() => isEditingNote = true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.blue),
                    Text(
                      "Add Note",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isNoteEmpty || isEditingNote)
            TextField(
              controller: noteController,
              readOnly: !isEditingNote,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                enabledBorder: isEditingNote
                    ? OutlineInputBorder()
                    : InputBorder.none,
                focusedBorder: isEditingNote ? null : InputBorder.none,
              ),
            ),
          if (isEditingNote)
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    setNoteController();
                    isEditingNote = false;
                  }),
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () => saveNote(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        ],
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: currentIndex > 0
                ? () => goToExercise(currentIndex - 1)
                : null,
            icon: Icon(Icons.arrow_left, size: 50, color: Colors.grey.shade600),
          ),
          SizedBox(
            width: 108,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isTimer)
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: secondsLeft / current.restTime,
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
                      : isTimer
                      ? Text(
                          "$secondsLeft",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Icon(Icons.check),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: currentIndex < widget.workout.exercises.length - 1
                ? () => goToExercise(currentIndex + 1)
                : null,
            icon: Icon(
              Icons.arrow_right,
              size: 50,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
