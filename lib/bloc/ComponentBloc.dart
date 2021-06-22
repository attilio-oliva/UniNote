import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/widgets/components/TextComponent.dart';
import 'package:xml/xml.dart';

enum ComponentEvent {
  resized,
  moved,
  contentChanged,
  selected,
  deselected,
}

class ComponentBloc extends Bloc<Map<String, dynamic>, ComponentState> {
  ComponentBloc(ComponentState initialState) : super(initialState);

  factory ComponentBloc.load(XmlElement element) {
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return ComponentBloc(ComponentState(
      position: position,
      width: ComponentState.defaultWidth,
      height: ComponentState.defaultHeight,
    ));
  }

  String parse() {
    return "";
  }

  ComponentState onContentChange(Map<String, dynamic> event) => state;
  ComponentState onMove(Offset position) => state;
  ComponentState onResize(double width, double height) => state;

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

/*
  @override
  void onTransition(
      Transition<Map<String, dynamic>, ComponentState> transition) {
    print(state.toString());
    super.onTransition(transition);
  }
*/
  @override
  Stream<ComponentState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event["key"]) {
      case ComponentEvent.resized:
        ComponentState newState = onResize(event["width"], event["height"]);
        if (newState.width != state.width || newState.height != state.height) {
          yield newState;
        } else {
          yield state.resize(event["width"], event["height"]);
        }
        break;
      case ComponentEvent.moved:
        if (state.canMove) {
          Offset position = state.position;
          if (event["absolute"] != null) {
            position = event["absolute"];
          } else if (event["data"] is Offset) {
            position += event["data"];
          }
          ComponentState newState = onMove(position);
          yield newState.move(position);
        } else {
          yield state;
        }
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
  TextComponentBloc(ComponentState initialState)
      : super((initialState.data["isTitle"] ?? false)
            ? initialState.copyWith(
                width: TextComponent.maxWidthTitle, canMove: false)
            : initialState);

  factory TextComponentBloc.load(XmlElement element) {
    String text = element.getAttribute("data") ?? "";
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return TextComponentBloc(ComponentState(
      content: text,
      position: position,
      width: TextComponent.defaultMaxWidth,
      height: TextComponent.defaultHeight + TextComponent.topFieldBarHeight,
      isSelected: false,
    ));
  }
  /*
  TextComponentBloc.load(XmlElement element)
      : super(ComponentState(
          content: element.getAttribute("data") ?? "",
          position: Offset(double.parse(element.getAttribute("x")!),
              double.parse(element.getAttribute("y")!)),
          width: TextComponent.defaultMaxWidth,
          height: TextComponent.defaultHeight + TextComponent.topFieldBarHeight,
          isSelected: false,
        ));
  */
  //@override
  //void onContentChange(Map<String, dynamic> event) {
  //  state.data["isTitle"] = ;
  //  state.data["isEditing"] = ;
  //}
}

class ImageComponentBloc extends ComponentBloc {
  ImageComponentBloc(ComponentState initialState) : super(initialState);
  factory ImageComponentBloc.load(XmlElement element) {
    String location = element.getAttribute("location") ?? "";
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return ImageComponentBloc(ComponentState(
      content: location,
      position: position,
      width: ComponentState.defaultWidth,
      height: ComponentState.defaultHeight,
      isSelected: false,
    ));
  }
}

class StrokeComponentBloc extends ComponentBloc {
  static List<Offset> editingStrokeData = [];
  static StrokeComponentBloc? editingBloc;

  StrokeComponentBloc(ComponentState initialState)
      : super(!(initialState.data["isEditing"] ?? false)
            ? recalculateConstraints(initialState, initialState.data["points"])
                .copyWith(isSelected: false)
            : initialState.copyWith(isSelected: false)) {
    if (state.data["isEditing"] ?? false) {
      if (state.data.containsKey("points")) {
        editingStrokeData = state.data["points"];
        editingBloc = this;
      }
    }
  }
  factory StrokeComponentBloc.load(XmlElement element) {
    String svgData =
        element.findElements("polyline").first.getAttribute("points") ?? "";
    List<Offset> points = svgData.split(" ").map((element) {
      List<String> pair = element.split(",");
      double x = double.parse(pair.first);
      double y = double.parse(pair.last);
      return Offset(x, y);
    }).toList();
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return StrokeComponentBloc(ComponentState(
      content: "*",
      data: {"points": points},
      position: position,
      width: double.infinity,
      height: double.infinity,
    ));
  }

  static ComponentState recalculateConstraints(
      ComponentState state, List<Offset> points) {
    List<double> xPos = points.map((e) => e.dx).toList();
    List<double> yPos = points.map((e) => e.dy).toList();
    xPos.sort();
    yPos.sort();
    double xMin = xPos.first;
    double xMax = xPos.last;
    double yMin = yPos.first;
    double yMax = yPos.last;
    Offset newPosition = Offset(xMin, yMin);
    double newWidth = (xMax - xMin).clamp(5, double.infinity);
    double newHeight = (yMax - yMin).clamp(5, double.infinity);

    return state.copyWith(
      position: newPosition,
      width: newWidth,
      height: newHeight,
    );
  }

  @override
  ComponentState onResize(double width, double height) {
    ComponentState newState = state;
    if (state.data.containsKey("points")) {
      Map<String, dynamic> newData = state.copyWith().data;
      List<Offset> pointList = state.data["points"];
      newData["points"] = <Offset>[];
      for (Offset point in pointList) {
        newData["points"]
            .add(point.scale(width / state.width, height / state.height));
      }

      List<Offset> points = newData["points"];
      newState = recalculateConstraints(state, points).copyWith(
        data: newData,
      );
    }
    return newState;
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
          newState = recalculateConstraints(state, points).copyWith(
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
