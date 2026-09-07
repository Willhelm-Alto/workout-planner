import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_planner/workout.dart';

class TrackerBottomSheet extends StatefulWidget {
  const TrackerBottomSheet({required this.current, required this.onTap, super.key});
  final Exercise? current;
  final Function onTap;

  @override
  State<TrackerBottomSheet> createState() => _TrackerBottomSheetState();
}

class _TrackerBottomSheetState extends State<TrackerBottomSheet> {
  bool _isTimer = false;
  int _secondsLeft = 10;
  Timer? _timer;
  int currentSet = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if(widget.current == null){
      widget.onTap();
      return;
    }

    if (_isTimer) {
      _timer?.cancel();
      setState(() {
        _timer = null;
        _isTimer = false;
      });
      return;
    }

    setState(() {
      _isTimer = true;
      _secondsLeft = 10;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft == 0) {
            timer.cancel();
            _timer = null;
            _isTimer = false;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      constraints: const BoxConstraints(maxHeight: 100),
      backgroundColor: Colors.blue,
      onClosing: () {},
      builder: (context) {
        return Column(
          children: [
            if(widget.current != null)
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.current!.title)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: Icon(Icons.arrow_left),
                ),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: widget.current == null ? Text("INICIAR") : _isTimer ? Text("$_secondsLeft") : Icon(Icons.check),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(5),
                  ),
                  child: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
