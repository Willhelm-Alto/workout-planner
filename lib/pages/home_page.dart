import 'package:flutter/material.dart';
import 'package:workout_planner/pages/execution_page.dart';
import 'package:workout_planner/widgets/exercise_card.dart';
import 'package:workout_planner/workout_manager.dart';
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

  late final Future<void> _loadFuture = manager.load();

  Widget _buildWorkoutOfDay(DateTime day) {
    final scheme = Theme.of(context).colorScheme;
    final workout = _workoutForDay(day);
    if (workout == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 40, color: scheme.onSurfaceVariant),
            SizedBox(height: 12),
            Text(
              "Nenhum treino neste dia",
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
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
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        return ListenableBuilder(
          listenable: manager,
          builder: (context, child) {
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;
            final dayStyle = theme.textTheme.bodyMedium ?? const TextStyle();
            final dowStyle = theme.textTheme.labelMedium ?? const TextStyle();
            final workout = _workoutForDay(_selectedDay);
            return Column(
              children: [
                TableCalendar<Workout>(
                  calendarFormat: CalendarFormat.week,
                  locale: 'pt_BR',
                  // table_calendar's defaults hardcode their own light colors
                  // and never read ThemeData, so every style is passed here.
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: dayStyle.copyWith(color: scheme.onSurface),
                    weekendTextStyle: dayStyle.copyWith(color: scheme.onSurface),
                    holidayTextStyle: dayStyle.copyWith(color: scheme.primary),
                    outsideTextStyle:
                        dayStyle.copyWith(color: scheme.onSurfaceVariant),
                    disabledTextStyle: dayStyle.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.38),
                    ),
                    weekNumberTextStyle: dayStyle.copyWith(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                    todayTextStyle: dayStyle.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.primary, width: 1.5),
                    ),
                    selectedTextStyle: dayStyle.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    rangeHighlightColor: scheme.secondaryContainer,
                    markerDecoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle:
                        dowStyle.copyWith(color: scheme.onSurfaceVariant),
                    weekendStyle:
                        dowStyle.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    headerMargin: EdgeInsets.all(8),
                    titleTextStyle: (theme.textTheme.titleMedium ??
                            const TextStyle())
                        .copyWith(color: scheme.onSurface, fontSize: 17),
                    decoration: BoxDecoration(color: scheme.surface),
                  ),
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'Semana',
                  },
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
                      // The marker is stacked over the day cell, so on the
                      // selected day it lands on top of the primary fill.
                      final onFill = isSameDay(_selectedDay, day);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          workout.title,
                          style: TextStyle(
                            fontSize: 9,
                            color: onFill
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
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
                  child: workout == null
                      ? null
                      : TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExecutionPage(workout: workout),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
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
          },
        );
      },
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
