import 'package:flutter/material.dart';
import 'package:workout_planner/pages/home_page.dart';
import 'package:workout_planner/pages/workouts_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      title: 'Workout Tracker',
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // static final List<Widget> _pages = [const HomePage(), WorkoutPage()];
  // int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // title: Text("Workout Planner"),
          toolbarHeight: 10,
          centerTitle: true,
          bottom: TabBar(
            dividerHeight: 0,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            indicatorPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            tabs: [
              Tab(
                icon: Icon(Icons.home, color: Colors.white),
                // child: Text("Home", style: TextStyle(color: Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.fitness_center, color: Colors.white),
                // child: Text("Workouts", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [HomePage(), WorkoutPage()]),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Workout Planner"),
    //     centerTitle: true,
    //   ),
    //   body: _pages.elementAt(_pageIndex),
    //   bottomNavigationBar: BottomNavigationBar(
    //     selectedItemColor: Colors.blue,
    //     onTap: (value) => setState(() => _pageIndex = value),
    //     currentIndex: _pageIndex,
    //     items: [
    //       BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
    //       BottomNavigationBarItem(
    //         label: "Workout",
    //         icon: Icon(Icons.fitness_center),
    //       ),
    //     ],
    //   ),
    //   floatingActionButton: _pageIndex == 1 ? IconButton(
    //       style: IconButton.styleFrom(side: BorderSide(color: Colors.blue)),
    //       onPressed: () => Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => EditWorkout()),
    //       ),
    //       icon: Icon(Icons.add, color: Colors.blue),
    //     ) : null,
    //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    // );
  }
}
