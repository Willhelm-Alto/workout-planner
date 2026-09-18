import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_planner/workout_manager.dart';

class TrackerBottomSheet extends StatefulWidget {
  const TrackerBottomSheet({
    required this.current,
    required this.init,
    required this.onFinishExercise,
    super.key,
  });
  final Exercise? current;
  final Function init;
  final Function(Exercise e) onFinishExercise;

  @override
  State<TrackerBottomSheet> createState() => _TrackerBottomSheetState();
}

class _TrackerBottomSheetState extends State<TrackerBottomSheet> {
  bool _isTimer = false;
  int _secondsLeft = 0;
  int currentSet = 1;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (widget.current == null) {
      widget.init();
      return;
    }

    if (_isTimer) {
      _timer?.cancel();
      setState(() => finishTimer());
      return;
    }

    setState(() {
      _isTimer = true;
      _secondsLeft = widget.current!.restTime;
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
    if(currentSet > widget.current!.set){
      widget.onFinishExercise(widget.current!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    return BottomSheet(
      backgroundColor: Colors.blue.shade600,
      onClosing: () {},
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (current != null) ...[
                  Text(
                    current.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    current.byTime
                        ? "${current.duration}s"
                        : "$currentSet/${current.set}",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //TODO: Implementar os botões para pular os exercícios
                    IconButton(
                      onPressed: () {},
                      color: Colors.white,
                      icon: Icon(Icons.arrow_left),
                    ),
                    SizedBox(width: 24),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isTimer)
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: _secondsLeft / current!.restTime,
                                strokeWidth: 3,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
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
                            child: current == null
                                ? const Text(
                                    "INICIAR",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
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
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_right),
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
