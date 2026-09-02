import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum DayOfWeek {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado,
  domingo;

  String get label {
    switch (this) {
      case segunda:
        return "Segunda-feira";
      case terca:
        return "Terça-feira";
      case quarta:
        return "Quarta-quarta";
      case quinta:
        return "Quinta-feira";
      case sexta:
        return "Sexta-feira";
      case sabado:
        return "Sabádo";
      case domingo:
        return "Domingo";
    }
  }
}

class Workout {
  String id;
  String title;
  List<Exercise> exercises;
  DayOfWeek day;
  DateTime? timeOfDay;

  Workout({
    required this.id,
    required this.title,
    required this.exercises,
    required this.day,
    this.timeOfDay,
  });

  Workout.fromJson(Map<String, dynamic> data)
    : id = data["id"],
      title = data["title"],
      timeOfDay = data["timeOfDay"] != null
          ? DateTime.parse(data["timeOfDay"].toString())
          : null,
      exercises = (data["exercises"] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      day = DayOfWeek.values.byName(data["day"]);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "exercises": exercises.map((e) => e.toJson()).toList(),
      "day": day.name,
      "timeOfDay": timeOfDay,
    };
  }
}

class Exercise {
  String title;
  int repetitions;
  int set;
  int restTime;
  int? weight;
  int? duration;
  bool byTime = false;

  Exercise({
    required this.title,
    this.repetitions = 12,
    this.set = 3,
    this.restTime = 30,
    this.weight,
    this.duration,
    this.byTime = false,
  });

  Exercise.fromJson(Map<String, dynamic> data)
    : title = data["title"],
      repetitions = data["repetitions"],
      set = data["set"],
      restTime = data["restTime"],
      weight = data["weight"],
      duration = data["duration"],
      byTime = data["byTime"];

  Exercise.copy(Exercise other)
    : title = other.title,
      repetitions = other.repetitions,
      set = other.set,
      restTime = other.restTime,
      weight = other.weight,
      duration = other.duration,
      byTime = other.byTime;

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "repetitions": repetitions,
      "set": set,
      "restTime": restTime,
      "weight": weight,
      "duration": duration,
      "byTime": byTime,
    };
  }
}

class WorkoutManager extends ChangeNotifier{
  static WorkoutManager? _instance; //instância da própria classe
  
  //TODO: Mudar _workouts para Map<int, Workout> a fim de preservar a ordem dos treinos
  final List<Workout> _workouts = [];
  bool wasInitialized = false;

  WorkoutManager._(); //construtor com nome "_"

  //um factory é um tipo especial de construtor que nem sempre retorna uma nova instância, mas pode retornar uma instância já criada
  factory WorkoutManager() {
    _instance ??= WorkoutManager._();
    return _instance!;
  }

  List<Workout> get workouts => _workouts;


  //===========File functions===========//

  Future<void> printFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    File workoutFile = File("${appDir.path}/workout.json");
    String contents = workoutFile.readAsStringSync().trim();
    debugPrint(contents);
    debugPrint("WOKROUT LIST: $workouts");
  }

  Future<void> nukeEverything() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    File workoutFile = File("${appDir.path}/workout.json");
    if(workoutFile.existsSync()){
      await workoutFile.delete();
    }
  }

  Future<void> load() async {
    if (!wasInitialized) {
      Directory appDir = await getApplicationDocumentsDirectory();
      File workoutFile = File("${appDir.path}/workout.json");

      if (workoutFile.existsSync()) {
        String contents = workoutFile.readAsStringSync().trim();
        if (contents != "") {
          List<dynamic> data = jsonDecode(contents);
          for (var element in data) {
            var w = element as Map<String, dynamic>;
            _workouts.add(Workout.fromJson(w));
          }
        }
      } else {
        workoutFile.writeAsStringSync(jsonEncode(""));
      }
      wasInitialized = true;
    }
    return;
  }

  Future<void> writeWorkoutFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    File file = File("${appDir.path}/workout.json");

    file.writeAsStringSync(
      jsonEncode(_workouts.map((e) => e.toJson()).toList()),
    );
  }

  //=====================================//


  Future<void> saveWorkout(Workout w) async {
    _workouts.add(w);
    notifyListeners();
    await writeWorkoutFile();
  }

  Future<void> deleteWorkout(Workout w) async {
    _workouts.remove(w);
    notifyListeners();
    await writeWorkoutFile();
  }

  Future<void> editWorkout(Workout w) async {
    final edit = _workouts.firstWhere((e) => e.id == w.id);
    _workouts.remove(edit);

    edit.title = w.title;
    edit.day = w.day;
    edit.exercises = w.exercises;

    await saveWorkout(edit);
  }

  bool checkIfValid(Workout w) {
    bool res = true;
    for (var e in workouts) {
      if (e.day == w.day && e.id != w.id) {
        res = false;
      }
    }
    return res;
  }
}
