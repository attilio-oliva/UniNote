import 'package:flutter/material.dart';

const double defaultMaxWidth = 300;
const Offset defaultPosition = Offset(0, 0);

class TextComponent extends StatefulWidget {
  //Initial value parameters
  final Offset position;
  final double maxWidth;
  final String text;
  TextComponent(
      {this.position = defaultPosition,
      this.maxWidth = defaultMaxWidth,
      this.text = ""});
  @override
  State<TextComponent> createState() =>
      _TextState(position: position, maxWidth: maxWidth, text: text);
}

class _TextState extends State<TextComponent> {
  Offset position;
  double maxWidth;
  TextEditingController _controller;
  _TextState({this.position, this.maxWidth, text}) {
    _controller = TextEditingController(text: text);
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: maxWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) => onDragUpdate(details),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ),
    );
  }
}
