import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

import 'Component.dart';

class StrokeComponent extends StatefulWidget with Component {
  final StrokeComponentBloc bloc;
  StrokeComponent({required this.bloc});
  @override
  State<StatefulWidget> createState() => _StrokeState();

  @override
  bool hitTest(Offset point) {
    List<Offset> pointList = bloc.state.data["points"] ?? [];
    bool result =
        pointList.any((element) => (element - point).distanceSquared <= 100);
    return result;
  }

  @override
  String parse() {
    // TODO: implement parse
    throw UnimplementedError();
  }
}

class _StrokeState extends State<StrokeComponent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrokeComponentBloc, ComponentState>(
      bloc: widget.bloc,
      builder: (context, state) => Visibility(
        visible: state.isSelected,
        child: ResizableWidget(
          bloc: widget.bloc,
          position: state.position,
          child: CustomPaint(
            painter: _StrokePainter(
                state.data["points"] ?? [], widget.bloc, state.position),
            willChange: true,
          ),
        ),
        replacement: CustomPaint(
          painter: _StrokePainter(state.data["points"] ?? [], widget.bloc),
          willChange: true,
        ),
      ),
    );
  }
}

class SvgPolyline extends Path {
  String svgData = "";

  @override
  void moveTo(double x, double y) {
    super.moveTo(x, y);
    svgData += "${x.toStringAsFixed(2)},${y.toStringAsFixed(2)} ";
  }

  @override
  void lineTo(double x, double y) {
    super.lineTo(x, y);
    svgData += "${x.toStringAsFixed(2)},${y.toStringAsFixed(2)} ";
  }

  @override
  String toString() {
    return svgData;
  }
}

/*
class SvgPath extends Path {
  String svgData = "";

  @override
  void moveTo(double x, double y) {
    super.moveTo(x, y);
    svgData += "M${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ";
  }

  @override
  void lineTo(double x, double y) {
    super.lineTo(x, y);
    svgData += "L${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ";
  }

  @override
  String toString() {
    return svgData + "Z";
  }
}
*/
class _StrokePainter extends CustomPainter {
  final StrokeComponentBloc bloc;
  final double pointThreshold = 0;
  List<Offset> pointList = [];
  late Paint paintStyle;
  Offset origin = Offset(0, 0);

  _StrokePainter(this.pointList, this.bloc,
      [this.origin = const Offset(0, 0)]) {
    paintStyle = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..strokeWidth = 4;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //canvas.drawPoints(PointMode.polygon, pointList, paintStyle);

    //convert global to local coordinate system
    canvas.translate(-origin.dx, -origin.dy);

    if (pointList.length == 0) return;
    if (pointList.length == 1) {
      canvas.drawPoints(PointMode.points, pointList, paintStyle);
      return;
    }

    Offset last = pointList[0];
    SvgPolyline path = SvgPolyline();
    path.moveTo(last.dx, last.dy);
    for (int i = 0; i < pointList.length; i++) {
      double distance = (pointList[i] - last).distance;
      if (distance > pointThreshold) {
        last = pointList[i];
        path.lineTo(pointList[i].dx, pointList[i].dy);
      }
    }
    canvas.drawPath(path, paintStyle);

    bloc.add({
      'key': ComponentEvent.contentChanged,
      'data': path.toString(),
      'isEditing': true
    });
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) {
    bool repaint = false;
    if (old.pointList.length != pointList.length) {
      return true;
    }
    //if lists are different
    for (int index = 0; index < old.pointList.length; index++) {
      if (old.pointList[index] != pointList[index]) {
        repaint = true;
        break;
      }
    }
    return repaint;
  }
}
