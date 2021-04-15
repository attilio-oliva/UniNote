import 'package:flutter/material.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

const double defaultMaxWidth = 300;
const Offset defaultPosition = Offset(0, 0);
const String defaultLocation =
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Eilat_Dolphin_Reef_%283%29.jpg/500px-Eilat_Dolphin_Reef_%283%29.jpg";

class ImageComponent extends StatefulWidget {
  final Offset position;
  final double maxWidth;
  final String location;
  ImageComponent(
      {this.position = defaultPosition,
      this.maxWidth = defaultMaxWidth,
      this.location = defaultLocation});

  State<ImageComponent> createState() =>
      _ImageState(position, maxWidth, location);
}

class _ImageState extends State<ImageComponent> {
  Offset position;
  double maxWidth;
  String location;
  double currentWidth;
  double currentHeight;
  double maxHeigth;
  bool isSelected = true;

  _ImageState(this.position, this.maxWidth, this.location) {
    currentWidth = maxWidth;
    currentHeight = maxHeigth;
  }
  Widget CustomImageWidget() {
    return Image.network(
      location,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: defaultMaxWidth,
      height: defaultMaxWidth,
      child: GestureDetector(
        onTapUp: (details) => setState(() {
          isSelected = !isSelected;
        }),
        child: Visibility(
          visible: isSelected,
          replacement: CustomImageWidget(),
          child: ResizableWidget(
            child: CustomImageWidget(),
          ),
        ),
      ),
    );
  }
}
