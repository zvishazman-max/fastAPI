import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class TimerWidget extends StatefulWidget {
  final int totalTimeInSeconds;
  final VoidCallback onTimerEnd;

  const TimerWidget({super.key, required this.totalTimeInSeconds, required this.onTimerEnd});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.totalTimeInSeconds;
    _startTimer();
  }

  // void _toggleTimer() {
  //   print('_toggleTimer');
  //   setState(() {
  //     _isPaused = !_isPaused;
  //     if (_isPaused) {
  //       _timer?.cancel();
  //     }
  //     else {
  //       _startTimer();
  //     }
  //   });
  // }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      }
      else {
        _timer?.cancel();
        widget.onTimerEnd();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingTime / widget.totalTimeInSeconds;

    Color timerColor;
    if (_remainingTime <= 10) {
      timerColor = Colors.red;
    } else if (_remainingTime <= 30) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.blue;
    }

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        SizedBox(
          width: 130, height: 130,
          child: CustomPaint(painter: TimerPainter(progress: progress, color: timerColor)),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text('$_remainingTime', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: timerColor)),
            Text('sec', style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}


class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2), -math.pi / 2, math.pi * 2, false, backgroundPaint);

    // Progress arc
    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round // Adds rounded ends
      ..style = PaintingStyle.stroke;

    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2), -math.pi / 2, math.pi * 2 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only when the progress or color changes
    final oldPainter = oldDelegate as TimerPainter;
    return oldPainter.progress != progress || oldPainter.color != color;
  }
}