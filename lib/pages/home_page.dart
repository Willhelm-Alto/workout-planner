import 'package:flutter/material.dart';
import 'package:gym_tracker/pages/workout_tracker_page.dart';
import 'package:gym_tracker/widgets/exercise_card.dart';
import 'package:gym_tracker/workout.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final DateTime _today = DateUtils.dateOnly(DateTime.now());
  late DateTime _selectedDay = _today;
  WorkoutManager manager = WorkoutManager();

  Widget _buildWorkoutOfDay(DateTime day) {
    final workout = _workoutForDay(day);
    if (workout == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text("Nenhum treino neste dia", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    final count = workout.exercises.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                workout.title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              Text(
                "$count ${count == 1 ? 'exercício' : 'exercícios'}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: count == 0
              ? const Center(
                  child: Text(
                    "Nenhum exercício neste treino",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: count,
                  itemBuilder: (_, i) =>
                      ExerciseCard(exercise: workout.exercises[i], index: i),
                ),
        ),
      ],
    );
  }

  Workout? _workoutForDay(DateTime day) {
    final dayOfWeek = DayOfWeek.values[day.weekday - 1];
    for (final workout in manager.workouts) {
      if (workout.day == dayOfWeek) return workout;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final workout = _workoutForDay(_selectedDay);
    return FutureBuilder(
      future: manager.load(),
      builder: (context, snapshot) {
        if(snapshot.connectionState != ConnectionState.done){
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            TableCalendar<Workout>(
              calendarFormat: CalendarFormat.week,
              headerStyle: HeaderStyle(titleCentered: true),
              availableCalendarFormats: const {CalendarFormat.week: 'Semana'},
              startingDayOfWeek: StartingDayOfWeek.monday,
              focusedDay: _today,
              firstDay: getFirstDayOfWeek(_today),
              lastDay: getLastDayOfWeek(_today),
              rowHeight: 70,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() => _selectedDay = selectedDay);
                }
              },
              calendarBuilders: CalendarBuilders<Workout>(
                markerBuilder: (context, day, _) {
                  final workout = _workoutForDay(day);
                  if (workout == null) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      workout.title,
                      style: const TextStyle(fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildWorkoutOfDay(_selectedDay)),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: workout == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackerPage(workout: workout),
                        ),
                      ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "INICIAR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

DateTime getFirstDayOfWeek(DateTime date) {
  final day = DateUtils.dateOnly(date);
  return day.subtract(Duration(days: day.weekday - 1));
}

DateTime getLastDayOfWeek(DateTime date) {
  return getFirstDayOfWeek(date).add(const Duration(days: 6));
}
