import 'dart:ui';

import 'package:uninote/bloc/ComponentBloc.dart';

class Component {
  ComponentBloc bloc;
  /*
  Offset position;
  double width;
  double heigth;

  bool hitTest(Offset point) {
    if (position.dx <= point.dx && point.dx <= position.dx + width) {
      if (position.dy <= point.dy && point.dy <= position.dy + heigth) {
        return true;
      }
    }
    return false;
  }
  */
  String parse() {
    return "<component/>";
  }
}
