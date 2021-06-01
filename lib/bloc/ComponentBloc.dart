import 'dart:ui';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ComponentState.dart';

enum ComponentEvent {
  resized,
  moved,
  contentChanged,
  selected,
  deselected,
}

class ComponentEventData {
  ComponentEvent key;
  dynamic data;
  ComponentEventData(this.key, [this.data]);
}

//TODO: add a minimum size
class ComponentBloc extends Bloc<Map<String, dynamic>, ComponentState> {
  ComponentBloc(ComponentState initialState) : super(initialState);

  ComponentState onContentChange(Map<String, dynamic> event) => state;
  ComponentState onMove(Offset position) => state;

  bool hitTest(Offset point) {
    if (state.position.dx <= point.dx &&
        point.dx <= state.position.dx + state.width) {
      if (state.position.dy <= point.dy &&
          point.dy <= state.position.dy + state.height) {
        return true;
      }
    }
    return false;
  }

  @override
  void onTransition(
      Transition<Map<String, dynamic>, ComponentState> transition) {
    super.onTransition(transition);
  }

  @override
  Stream<ComponentState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event["key"]) {
      case ComponentEvent.resized:
        yield state.scale(event["width"], event["height"]);
        break;
      case ComponentEvent.moved:
        Offset position = state.position;
        if (event["absolute"] != null) {
          position = event["absolute"];
        } else if (event["data"] is Offset) {
          position += event["data"];
        }
        ComponentState newState = onMove(position);
        yield newState.move(position);
        break;
      case ComponentEvent.deselected:
        yield state.deselect();
        break;
      case ComponentEvent.selected:
        if (state.isSelected) {
          yield state.deselect();
        } else {
          yield state.select();
        }
        break;
      case ComponentEvent.contentChanged:
        //state.content = event["data"];
        ComponentState newState = onContentChange(event);
        yield newState.copyWith(content: event["data"]);
        break;
    }
  }
}

class TextComponentBloc extends ComponentBloc {
  static double maxWidthTitle = 400;
  TextComponentBloc(ComponentState initialState)
      : super((initialState.data["isTitle"] ?? false)
            ? initialState.copyWith(width: maxWidthTitle)
            : initialState);

  //@override
  //void onContentChange(Map<String, dynamic> event) {
  //  state.data["isTitle"] = ;
  //  state.data["isEditing"] = ;
  //}
}

class StrokeComponentBloc extends ComponentBloc {
  static List<Offset> editingStrokeData = [];
  static StrokeComponentBloc? editingBloc;

  StrokeComponentBloc(ComponentState initialState)
      : super(initialState.copyWith(
            isSelected: false, minHeight: 0, minWidth: 0)) {
    if (state.data["isEditing"] ?? false) {
      if (state.data.containsKey("points")) {
        editingStrokeData = state.data["points"];
        editingBloc = this;
      }
    }
  }
  @override
  ComponentState onMove(Offset position) {
    ComponentState newState = state;
    if (state.data.containsKey("points")) {
      Map<String, dynamic> newData = state.copyWith().data;
      List<Offset> pointList = state.data["points"];
      newData["points"] = <Offset>[];
      for (Offset point in pointList) {
        newData["points"].add(point.translate(
            position.dx - state.position.dx, position.dy - state.position.dy));
      }
      newState = state.copyWith(data: newData);
    }
    return newState;
  }

  @override
  ComponentState onContentChange(Map<String, dynamic> event) {
    bool isEditing = state.data["isEditing"] ?? false;
    bool shouldBeEditing = event["isEditing"] ?? false;
    ComponentState newState = state;
    if (isEditing) {
      if (state.data.containsKey("points")) {
        if (event.containsKey("newPoint")) {
          //Add new point
          Map<String, dynamic> newData = {};
          List<Offset> points = state.data["points"];
          points.add(event["newPoint"]);
          editingStrokeData = state.data["points"];
          editingBloc = this;
          newData = state.copyWith().data;
          newData["points"] = points;

          //Recalculate position of the component
          List<double> xPos = points.map((e) => e.dx).toList();
          List<double> yPos = points.map((e) => e.dy).toList();
          xPos.sort();
          yPos.sort();
          double xMin = xPos.first;
          double xMax = xPos.last;
          double yMin = yPos.first;
          double yMax = yPos.last;
          Offset newPosition = Offset(xMin, yMin);
          double newWidth = (xMax - xMin) + 5;
          double newHeight = (yMax - yMin) + 5;

          newState = state.copyWith(
            position: newPosition,
            width: newWidth,
            height: newHeight,
            data: newData,
          );
        }
      }
    }
    if (!shouldBeEditing && isEditing && editingBloc == this) {
      editingStrokeData = [];
      editingBloc = null;
    }
    return newState;
  }
}
