import 'package:flutter/material.dart';
import 'dart:math';

class CircularProgressBar extends StatelessWidget {

  CircularProgressBar({
    @required this.progress,
    @required this.progressColor,
    @required this.backgroundColor,
    this.strokeWidth = 5.0,
  });

  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressBarPainter(
          progress, progressColor, backgroundColor, strokeWidth,
      ),
    );
  }
}

class _CircularProgressBarPainter extends CustomPainter {
  _CircularProgressBarPainter(
      this.progress,
      this.progressColor,
      this.backgroundColor,
      this.strokeWidth,
  );

  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset center = size.center(Offset.zero);
    double radius = size.width / 2.0;

    canvas.drawCircle(center, radius, paint);
    paint.color = progressColor;

    double startAngle = -pi*0.5; //starts from bottom
    double progressRadians = progress * 2 * pi; //progress is clockwise
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressRadians,
        false,
        paint
    );
  }

  @override
  bool shouldRepaint(_CircularProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}