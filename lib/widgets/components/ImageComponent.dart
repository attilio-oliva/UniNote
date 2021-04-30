import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

import 'Component.dart';

const double imageDefaultMaxWidth = 300;
const double imageDefaultMaxHeight = 300;
const Offset imageDefaultPosition = Offset(0, 0);
const String imageDefaultLocation =
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Eilat_Dolphin_Reef_%283%29.jpg/500px-Eilat_Dolphin_Reef_%283%29.jpg";

class ImageComponent extends StatefulWidget with Component {
  final Offset position;
  final double width;
  final double height;
  final String location;
  ImageComponent(
      {this.position = imageDefaultPosition,
      this.width = imageDefaultMaxWidth,
      this.height = imageDefaultMaxWidth,
      this.location = imageDefaultLocation});

  State<ImageComponent> createState() =>
      _ImageState(position, width, height, location);
}

class _ImageState extends State<ImageComponent> {
  Offset position;
  double maxWidth;
  String location;
  double width;
  double height;
  double maxHeigth;
  bool isSelected = true;

  _ImageState(this.position, this.width, this.height, this.location);

  Widget getImageWidget() {
    return Image.network(
      location,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ComponentBloc componentBloc = BlocProvider.of<ComponentBloc>(context);
    widget.bloc = componentBloc;
    return BlocConsumer<ComponentBloc, ComponentState>(
      bloc: componentBloc,
      listener: (context, state) {},
      builder: (context, state) => Positioned(
        left: state.position.dx - ballDiameter / 2 - editBorderWidth / 2,
        top: state.position.dy - ballDiameter / 2 - editBorderWidth / 2,
        width: state.width + ballDiameter / 2 - editBorderWidth / 2,
        height: state.height + ballDiameter / 2 - editBorderWidth / 2,
        child: GestureDetector(
          onTapUp: (details) => setState(() {
            isSelected = !isSelected;
          }),
          child: Visibility(
            visible: isSelected,
            replacement: Container(
              padding: EdgeInsets.all(editOffset),
              width: state.width,
              height: state.height,
              child: getImageWidget(),
            ),
            child: ResizableWidget(
              child: getImageWidget(),
              position: position,
              width: state.width,
              height: state.height,
              bloc: componentBloc,
            ),
          ),
        ),
      ),
    );
  }
}
