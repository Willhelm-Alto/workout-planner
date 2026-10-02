import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_planner/pages/edit_workout_page.dart';
import 'package:workout_planner/pages/home_page.dart';
import 'package:workout_planner/pages/workouts_page.dart';
import 'package:workout_planner/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await ThemeController().load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController();
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) => MaterialApp(
        title: 'Planejador de Treinos',
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,
        home: child,
      ),
      child: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static final List<Widget> _pages = [const HomePage(), WorkoutPage()];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: ThemeController().toggle,
            icon: Icon(
              ThemeController().isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: _pages.elementAt(_pageIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) => setState(() => _pageIndex = value),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(label: "Início", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: "Treinos",
            icon: Icon(Icons.fitness_center),
          ),
        ],
      ),
      floatingActionButton: _pageIndex == 1 ? IconButton(
          style: IconButton.styleFrom(side: BorderSide(color: scheme.primary)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditWorkout()),
          ),
          icon: Icon(Icons.add, color: scheme.primary),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
