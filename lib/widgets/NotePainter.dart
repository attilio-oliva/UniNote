import 'package:flutter/material.dart';
import 'package:uninote/widgets/components/TextComponent.dart';

class Painter extends StatefulWidget {
  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  Offset cursor = Offset(0, 0);
  List<Widget> list = [];
  _PainterState() {
    list.add(TextComponent(
      position: cursor,
      text: "Title",
    ));
  }
  void onTapUp(BuildContext context, TapUpDetails details) {
    setState(() {
      cursor = details.localPosition;
      list.add(TextComponent(position: cursor));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) => onTapUp(context, details),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: list,
      ),
    );
  }
}

/*
class NotePainter extends CustomPainter {
  List<CustomPainter> list = [];

  NotePainter() {
    addComponent(TextPrintable());
  }

  void addComponent(CustomPainter component) {
    list.add(component);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (CustomPainter component in list) {
      component.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(NotePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(NotePainter oldDelegate) => false;
}
*/
