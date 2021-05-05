import 'dart:ui';

abstract class Component {
  bool hitTest(Offset point);
  String parse();
}
