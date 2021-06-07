import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/states/ComponentState.dart';

const ballDiameter = 10.0;
const double editBorderWidth = 2;
final double editOffset = ballDiameter / 2 - editBorderWidth / 2;
//final double editOffset = ballDiameter / 2 + editBorderWidth / 2;

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final Offset position;
  final ComponentBloc bloc;
  ResizableWidget({
    required this.child,
    required this.bloc,
    this.position = const Offset(0, 0),
    this.width = 200,
    this.height = 200,
  });
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

    height = newHeight.clamp(
        widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
    width =
        newWidth.clamp(widget.bloc.state.minWidth, widget.bloc.state.maxWidth);

    onResize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComponentBloc, ComponentState>(
      bloc: widget.bloc,
      builder: (context, state) => Stack(
        children: <Widget>[
          Positioned(
            left: state.position.dx - editBorderWidth,
            top: state.position.dy - editBorderWidth,
            width: state.width + editBorderWidth,
            height: state.height + editBorderWidth,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  border:
                      Border.all(width: editBorderWidth, color: Colors.white)),
              child: GestureDetector(
                  onPanUpdate: (details) {
                    top = top + details.delta.dy;
                    left = left + details.delta.dx;
                    onMove();
                  },
                  child: widget.child),
            ),
          ),
          // top left
          Positioned(
            top: state.position.dy - ballDiameter / 2,
            left: state.position.dx - ballDiameter / 2 - editBorderWidth / 2,
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
                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
                /*
                double factorLeft =
                    (width != widget.bloc.state.minWidth) ? mid : 0;
                double factorTop =
                    (height != widget.bloc.state.minHeight) ? mid : 0;
                */
                double factor = mid;
                if ((width <= widget.bloc.state.minWidth) ||
                    (height <= widget.bloc.state.minHeight)) {
                  factor = 0;
                }
                top = top + factor;
                left = left + factor;
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
            top: state.position.dy - ballDiameter / 2,
            left: state.position.dx + state.width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height - dy;

                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                double factor = dy;
                if (height <= widget.bloc.state.minHeight) {
                  factor = 0;
                }
                top = top + factor;

                onResize();
                onMove();
              },
            ),
          ),
          // top right
          Positioned(
            top: state.position.dy - ballDiameter / 2 - editBorderWidth / 2,
            left: state.position.dx +
                state.width -
                ballDiameter / 2 -
                editBorderWidth / 2,
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
                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
                double factor = mid;
                if ((width <= widget.bloc.state.minWidth) ||
                    (height <= widget.bloc.state.minHeight)) {
                  factor = 0;
                }
                top = top - factor;
                //left = left - mid;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // center right
          Positioned(
            top: state.position.dy + state.height / 2 - ballDiameter / 2,
            left: state.position.dx +
                state.width -
                ballDiameter / 2 -
                editBorderWidth / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width + dx;

                //setState(() {
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
                //});
                onResize();
              },
            ),
          ),
          // bottom right
          Positioned(
            top: state.position.dy +
                state.height -
                ballDiameter / 2 -
                editBorderWidth / 2,
            left: state.position.dx +
                state.width -
                ballDiameter / 2 -
                editBorderWidth / 2,
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
                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
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
            top: state.position.dy + state.height - ballDiameter / 2,
            left: state.position.dx + state.width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height + dy;

                //setState(() {
                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                //});
                onResize();
              },
            ),
          ),
          // bottom left
          Positioned(
            top: state.position.dy + state.height - ballDiameter / 2,
            left: state.position.dx - ballDiameter / 2 - editBorderWidth / 2,
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
                height = newHeight.clamp(
                    widget.bloc.state.minHeight, widget.bloc.state.maxHeight);
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
                double factor = mid;
                if ((width <= widget.bloc.state.minWidth) ||
                    (height <= widget.bloc.state.minHeight)) {
                  factor = 0;
                }
                //top = top - mid;
                left = left - factor;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          //left center
          Positioned(
            top: state.position.dy + state.height / 2 - editBorderWidth,
            left: state.position.dx - ballDiameter / 2 - editBorderWidth / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width - dx;

                //setState(() {
                width = newWidth.clamp(
                    widget.bloc.state.minWidth, widget.bloc.state.maxWidth);
                double factor = dx;
                if (width <= widget.bloc.state.minWidth) {
                  factor = 0;
                }
                left = left + factor;
                //});
                onResize();
                onMove();
              },
            ),
          ),
          // center center
          /*
          Positioned(
            top: state.position.dy + height / 2 - ballDiameter / 2,
            left: state.position.dx + width / 2 - ballDiameter / 2,
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
          */
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  final Function onDrag;
  ManipulatingBall({
    required this.onDrag,
  });
  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  late double initX;
  late double initY;

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
