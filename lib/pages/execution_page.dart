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

  finishTimer() {
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
          actions: [Icon(Icons.access_alarm), Text(stopwatchStr)],
        ),
        body: Column(
          children: [
            Text(
              current.title.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${current.set}"),
                Text("${current.restTime}")
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isTimer)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _secondsLeft / current.restTime,
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    fixedSize: const Size(52, 52),
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
      ),
    );
  }
}


// body: ListView.builder(
        //   padding: const EdgeInsets.all(16),
        //   itemCount: widget.workout.exercises.length,
        //   itemBuilder: (_, i) => ExerciseCard(
        //     exercise: widget.workout.exercises[i],
        //     index: i,
        //     customBorder:
        //         current != null && current! == widget.workout.exercises[i]
        //         ? BorderSide(color: Colors.blue, width: 2)
        //         : null,
        //     tracker: Switch(
        //       value: doneExercisesList[widget.workout.exercises[i]]!,
        //       onChanged: (value) {},
        //     ),
        //   ),
        // ),
        // bottomSheet: TrackerBottomSheet(
        //   key: ValueKey(current),
        //   current: current,
        //   init: () => setState(() {
        //     current = doneExercisesList.entries
        //         .firstWhere((element) => !element.value)
        //         .key;
        //     stopwatch.start();
        //     ticker ??= Timer.periodic(Duration(seconds: 1), (_) => setState((){}));
        //   }),
        //   onFinishExercise: (e) {
        //     setState(() {
        //       doneExercisesList[e] = true;
        //       current = doneExercisesList.entries
        //           .firstWhere((element) => !element.value)
        //           .key;
        //     });
        //   },
        // ),

/*
┌──────────────────────────────────────────┐
│  ←   Treino A               ⧗ 00:12:34   │  AppBar azul (tema)
├──────────────────────────────────────────┤
│                                          │
│  Exercício 2 de 5         1 concluídos   │  cinza 13px
│  ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  barra 6px, raio total
│                                          │
│  SUPINO RETO                             │  26px w700
│                                          │
│  ╭─────────╮ ╭──────────╮ ╭────────────╮ │  chips pill
│  │ 12 reps │ │ 3 séries │ │ 30s descan.│ │  bg blue.50 / txt blue.700
│  ╰─────────╯ ╰──────────╯ ╰────────────╯ │
│                                          │
│  ┌────────────────────────────────────┐  │  card: borda grey.300
│  │  Série 2 de 3            ●  ◉  ○   │  │  ● feita ◉ atual ○ futura
│  └────────────────────────────────────┘  │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  ⚖  Carga                          │  │
│  │  ┌────────────────────┐ ┌────────┐ │  │  ← campo editável
│  │  │ 40             kg  │ │ Salvar │ │  │  botão só ativa se mudou
│  │  └────────────────────┘ └────────┘ │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ╔════════════════════════════════════╗  │  sem borda, fundo blue.50
│  ║  ▤  OBSERVAÇÃO                     ║  │  ← some se estiver vazia
│  ║     Descer devagar, 2s na negativa ║  │
│  ╚════════════════════════════════════╝  │
│                                          │
├──────────────────────────────────────────┤  borda superior grey.200
│               ╭ ─ ─ ─ ─ ─ ╮              │  anel 108px = progresso
│             ╱   ╭───────╮   ╲            │  do descanso, drenando
│            │    │  18   │    │           │  botão 92px azul sólido
│             ╲   ╰───────╯   ╱            │
│               ╰ ─ ─ ─ ─ ─ ╯              │
│        Descanso · toque para pular       │  legenda cinza 13px
└──────────────────────────────────────────┘
*/