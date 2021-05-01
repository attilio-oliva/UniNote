import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/states/ComponentState.dart';

const ballDiameter = 10.0;
const double editBorderWidth = 2;
final double editOffset = ballDiameter / 2 - editBorderWidth / 2;

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final Offset position;
  final ComponentBloc bloc;
  ResizableWidget(
      {this.child,
      this.position = const Offset(0, 0),
      this.width = 200,
      this.height = 200,
      this.bloc});
  @override
  _ResizableWidgetState createState() =>
      _ResizableWidgetState(position, width, height);
}

class _ResizableWidgetState extends State<ResizableWidget> {
  double height;
  double width;
  double top = 0;
  double left = 0;
  Offset startPosition;
  void onResize() {
    widget.bloc.add({
      "key": ComponentEvent.resized,
      "width": width,
      "height": height,
    });
  }

  void onMove() {
    widget.bloc.add({
      "key": ComponentEvent.moved,
      "absolute": startPosition + Offset(left, top),
    });
  }

  _ResizableWidgetState(this.startPosition, this.width, this.height);
  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
    onResize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComponentBloc, ComponentState>(
      bloc: widget.bloc,
      builder: (context, state) => Stack(
        children: <Widget>[
          Positioned(
            left: editOffset,
            top: editOffset,
            width: state.width,
            height: state.height,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  border:
                      Border.all(width: editBorderWidth, color: Colors.white)),
              child: widget.child,
            ),
          ),
          // top left
          Positioned(
            top: 0,
            left: 0,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                //var mid = (dx + dy) / 2;
                Offset point = Offset(dx, dy);
                int sign =
                    point.direction >= 0 && point.direction <= math.pi / 2
                        ? 1
                        : -1;
                double mid = sign * (point.distance / 2);
                var newHeight = height - mid;
                var newWidth = width - mid;
                //var newHeight = height - dy;
                //var newWidth = width - dx;
                //setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top + mid;
                left = left + mid;
                //top = top + dx;
                //left = left + dy;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // top middle
          Positioned(
            top: 0,
            left: width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height - dy;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  top = top + dy;
                });
                onResize();
                onMove();
              },
            ),
          ),
          // top right
          Positioned(
            top: 0,
            left: width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                //var mid = (dx + (dy * -1)) / 2;
                Offset point = Offset(dx, dy);
                int sign =
                    point.direction >= math.pi / 2 && point.direction <= math.pi
                        ? -1
                        : 1;
                double mid = sign * (point.distance / 2);
                var newHeight = height + mid;
                var newWidth = width + mid;

                //setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                //left = left - mid;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // center right
          Positioned(
            top: height / 2 - ballDiameter / 2,
            left: width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width + dx;

                //setState(() {
                width = newWidth > 0 ? newWidth : 0;
                //});
                onResize();
              },
            ),
          ),
          // bottom right
          Positioned(
            top: height - ballDiameter / 2,
            left: width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                //var mid = (dx + dy) / 2;
                Offset point = Offset(dx, dy);
                int sign =
                    point.direction >= 0 && point.direction <= math.pi / 2
                        ? 1
                        : -1;
                double mid = sign * (point.distance / 2);

                var newHeight = height + mid;
                var newWidth = width + mid;

                //setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                //top = top - mid;
                //left = left - mid;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // bottom center
          Positioned(
            top: height - ballDiameter / 2,
            left: width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height + dy;

                //setState(() {
                height = newHeight > 0 ? newHeight : 0;
                //});
                onResize();
              },
            ),
          ),
          // bottom left
          Positioned(
            top: height - ballDiameter / 2,
            left: 0,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                //var mid = ((dx * -1) + dy) / 2;
                Offset point = Offset(dx, dy);
                int sign =
                    point.direction <= 0 && point.direction >= -math.pi / 2
                        ? -1
                        : 1;
                double mid = sign * (point.distance / 2);
                var newHeight = height + mid;
                var newWidth = width + mid;

                //setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                //top = top - mid;
                left = left - mid;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          //left center
          Positioned(
            top: height / 2 - ballDiameter / 2,
            left: 0,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width - dx;

                //setState(() {
                width = newWidth > 0 ? newWidth : 0;
                left = left + dx;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // center center
          Positioned(
            top: height / 2 - ballDiameter / 2,
            left: width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                //setState(() {
                top = top + dy;
                left = left + dx;
                //});
                onMove();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({
    Key key,
    this.onDrag,
  });

  final Function onDrag;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        padding: EdgeInsets.zero,
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }
}
