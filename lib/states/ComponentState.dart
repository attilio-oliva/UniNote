import 'dart:ui';

import 'package:uninote/widgets/components/TextComponent.dart';

const double minPosX = 10;
const double minPosY = 10;

class ComponentState {
  Offset _position;
  double width;
  double height;
  String content = "";
  Map<String, dynamic> data = {};
  bool canMove = true;

  Offset get position {
    return _position;
  }

  set position(Offset newPos) {
    if (!canMove && position != null) return;
    double newX = newPos.dx;
    double newY = newPos.dy;
    if (minPosX > newPos.dx) {
      newX = minPosX;
    }
    if (minPosY > newPos.dy) {
      newY = minPosY;
    }
    _position = Offset(newX, newY);
  }

  ComponentState(position, this.width, this.height,
      [this.content = "", this.canMove = true, this.data]) {
    this.position = position;
  }
  ComponentState.from(ComponentState state) {
    this.position = state.position;
    this.width = state.width;
    this.height = state.height;
    this.content = state.content;
    this.canMove = state.canMove;
    this.data = state.data;
  }
}
