import 'dart:ui';

const double minPosX = 10;
const double minPosY = 10;

class ComponentState {
  Offset _position = Offset(minPosX, minPosY);
  double width = 100;
  double height = 100;
  String content = "";
  Map<String, dynamic> data = {};
  bool canMove = true;

  Offset get position {
    return _position;
  }

  set position(Offset newPos) {
    if (!canMove) return;
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
      [this.content = "", this.canMove = true, this.data = const {}]) {
    this.position = position;
  }
  ComponentState.from(ComponentState state) {
    this.position = state.position;
    this.width = state.width;
    this.height = state.height;
    this.content = state.content;
    this.canMove = state.canMove;
    this.data = Map.from(state.data);
  }
}
