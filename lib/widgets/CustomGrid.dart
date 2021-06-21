import 'package:flutter/material.dart';

class _GridPaperPainter extends CustomPainter {
  const _GridPaperPainter({
    required this.color,
    required this.interval,
    required this.divisions,
    required this.subdivisions,
  });

  final Color color;
  final double interval;
  final int divisions;
  final int subdivisions;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 0.4;

    final double allDivisions = (divisions * subdivisions).toDouble();
    for (double x = 0.0; x <= size.width; x += interval / allDivisions) {
      canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), linePaint);
    }
    for (double y = 0.0; y <= size.height; y += interval / allDivisions) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_GridPaperPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.interval != interval ||
        oldPainter.divisions != divisions ||
        oldPainter.subdivisions != subdivisions;
  }

  @override
  bool hitTest(Offset position) => false;
}

class CustomGrid extends StatelessWidget {
  const CustomGrid({
    Key? key,
    this.color = Colors.white,
    this.interval = 100,
    this.divisions = 2,
    this.subdivisions = 5,
    this.child,
  })  : assert(divisions > 0,
            'The "divisions" property must be greater than zero.'),
        assert(subdivisions > 0,
            'The "subdivisions" property must be greater than zero.'),
        super(key: key);
  final Color color;
  final double interval;
  final int divisions;
  final int subdivisions;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GridPaperPainter(
        color: color,
        interval: interval,
        divisions: divisions,
        subdivisions: subdivisions,
      ),
      child: child,
    );
  }
}
