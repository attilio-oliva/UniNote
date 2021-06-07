import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

import 'Component.dart';

const double imageDefaultMaxWidth = 300;
const double imageDefaultMaxHeight = 300;
const double imageDefaultMinWidth = 100;
const double imageDefaultMinHeight = 100;
const Offset imageDefaultPosition = Offset(0, 0);
const String imageDefaultLocation =
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Eilat_Dolphin_Reef_%283%29.jpg/500px-Eilat_Dolphin_Reef_%283%29.jpg";

class ImageComponent extends StatefulWidget with Component {
  final Offset position;
  final double width;
  final double height;
  final String location;
  final ComponentBloc bloc;
  ImageComponent({
    this.position = imageDefaultPosition,
    this.width = imageDefaultMaxWidth,
    this.height = imageDefaultMaxWidth,
    this.location = imageDefaultLocation,
    required this.bloc,
  });

  State<ImageComponent> createState() =>
      _ImageState(position, width, height, location);

  @override
  bool hitTest(Offset point) {
    return bloc.hitTest(point);
  }

  @override
  String parse() {
    // TODO: implement parse
    throw UnimplementedError();
  }
}

class _ImageState extends State<ImageComponent> {
  late Offset position;
  late double maxWidth;
  late double maxHeigth;
  late String location;
  late double width;
  late double height;
  bool isSelected = true;

  _ImageState(this.position, this.width, this.height, this.location);

  Widget getImageWidget(String location) {
    location = (location == "") ? imageDefaultLocation : location;
    return Image.network(
      location,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComponentBloc, ComponentState>(
      bloc: widget.bloc,
      listener: (context, state) {},
      builder: (context, state) => Visibility(
        visible: state.isSelected,
        replacement: Positioned(
          left: state.position.dx,
          top: state.position.dy,
          width: state.width,
          height: state.height,
          child: Container(
            //padding: EdgeInsets.all(editOffset + editBorderWidth),
            width: state.width,
            height: state.height,
            child: getImageWidget(state.content),
          ),
        ),
        child: ResizableWidget(
          child: getImageWidget(state.content),
          position: state.position,
          width: state.width,
          height: state.height,
          bloc: widget.bloc,
        ),
      ),
    );
  }
}
