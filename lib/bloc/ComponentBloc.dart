import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/EditableDocument.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/widgets/components/StrokeComponent.dart';
import 'package:uninote/widgets/components/TextComponent.dart';
import 'package:xml/xml.dart';
import 'package:uninote/iomanager.dart';

enum ComponentEvent {
  resized,
  moved,
  contentChanged,
  selected,
  deselected,
}

class ComponentBloc extends Bloc<Map<String, dynamic>, ComponentState> {
  String fileComponentName = "component";
  ComponentBloc(ComponentState initialState) : super(initialState);

  factory ComponentBloc.load(XmlElement element) {
    String key = element.getAttribute("id")!;
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return ComponentBloc(ComponentState(
      position: position,
      width: ComponentState.defaultWidth,
      height: ComponentState.defaultHeight,
      key: key,
    ));
  }
  bool onSave() => false;

  void save() {
    bool changed = onSave();
    if (changed) {
      openedFileDocument?.writeAsString(
          openedDocument.toXmlString(pretty: true),
          flush: true);
    }
  }

  String parse() => "";
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

  @override
  void onChange(Change<ComponentState> change) {
    super.onChange(change);
    //print(state.toString());
    save();
  }

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
        if (state.canMove && state.isSelected) {
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
                width: TextComponent.maxWidthTitle,
                canMove: false,
                key: "title")
            : initialState) {
    fileComponentName =
        (initialState.data["isTitle"] ?? false) ? "title" : "text";
  }

  factory TextComponentBloc.load(XmlElement element) {
    String key = element.getAttribute("id")!;
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
      key: key,
    ));
  }
  @override
  bool onSave() {
    bool changed = false;
    if (fileComponentName == "title") {
      if (state.content != openedDocument.firstChild?.getAttribute("title")) {
        openedDocument.firstChild?.setAttribute("title", state.content);
        changed = true;
      }
    } else {
      try {
        XmlElement element = openedDocument
            .findAllElements(fileComponentName)
            .firstWhere(
                (element) => (element.getAttribute("id") ?? "") == state.key);
        double x = double.parse(element.getAttribute("x")!);
        double y = double.parse(element.getAttribute("y")!);
        Offset position = Offset(x, y);
        if (state.content != element.getAttribute("data")) {
          element.setAttribute("data", state.content);
          changed = true;
        }

        if (state.position != position) {
          element.setAttribute("x", state.position.dx.toStringAsFixed(2));
          element.setAttribute("y", state.position.dy.toStringAsFixed(2));
          changed = true;
        }
      } on StateError {
        Map<String, String> bindings = {
          "id": state.key,
          "x": state.position.dx.toStringAsFixed(2),
          "y": state.position.dy.toStringAsFixed(2),
          "data": state.content,
        };

        openedDocument = EditableDocument().addElement(
          openedDocument,
          parent: XmlElement(XmlName("content")),
          name: fileComponentName,
          bindings: bindings,
        );

        changed = true;
      }
    }
    return changed;
  }

  @override
  ComponentState onContentChange(Map<String, dynamic> event) {
    Map<String, dynamic> map = Map<String, dynamic>.from(state.data);
    if (!map.containsKey("mode")) {
      map["mode"] = event["mode"];
    } else {
      String lastMode = map["mode"];
      if (event.containsKey("mode")) {
        if (lastMode != event["mode"]) {
          map["mode"] = event["mode"];
        }
      }
    }
    return state.copyWith(data: map);
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
  ImageComponentBloc(ComponentState initialState) : super(initialState) {
    fileComponentName = "image";
  }
  factory ImageComponentBloc.load(XmlElement element) {
    String key = element.getAttribute("id")!;
    String location = element.getAttribute("location") ?? "";
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    double width = double.parse(element.getAttribute("width")!);
    double height = double.parse(element.getAttribute("height")!);
    Offset position = Offset(x, y);
    return ImageComponentBloc(ComponentState(
      content: location,
      position: position,
      width: width,
      height: height,
      isSelected: false,
      key: key,
    ));
  }
  @override
  bool onSave() {
    bool changed = false;
    try {
      XmlElement element = openedDocument
          .findAllElements(fileComponentName)
          .firstWhere((element) => (element.getAttribute("id")) == state.key);
      double x = double.parse(element.getAttribute("x")!);
      double y = double.parse(element.getAttribute("y")!);
      double width = double.parse(element.getAttribute("width")!);
      double height = double.parse(element.getAttribute("height")!);
      Offset position = Offset(x, y);
      if (state.content != element.getAttribute("data")) {
        element.setAttribute("location", state.content);
        changed = true;
      }
      if (state.width != width) {
        element.setAttribute("width", state.width.toStringAsFixed(2));
        changed = true;
      }
      if (state.height != height) {
        element.setAttribute("height", state.height.toStringAsFixed(2));
        changed = true;
      }
      if (state.position != position) {
        element.setAttribute("x", state.position.dx.toStringAsFixed(2));
        element.setAttribute("y", state.position.dy.toStringAsFixed(2));
        changed = true;
      }
    } on StateError {
      Map<String, String> bindings = {
        "id": state.key,
        "x": state.position.dx.toStringAsFixed(2),
        "y": state.position.dy.toStringAsFixed(2),
        "width": state.width.toStringAsFixed(2),
        "height": state.height.toStringAsFixed(2),
        "location": state.content,
      };

      openedDocument = EditableDocument().addElement(
        openedDocument,
        parent: XmlElement(XmlName("content")),
        name: fileComponentName,
        bindings: bindings,
      );

      changed = true;
    }
    return changed;
  }
}

class StrokeComponentBloc extends ComponentBloc {
  static List<Offset> editingStrokeData = [];
  static StrokeComponentBloc? editingBloc;
  bool flag = false;
  StrokeComponentBloc(ComponentState initialState)
      : super(!(initialState.data["isEditing"] ?? false)
            ? recalculateConstraints(
                    initialState, initialState.data["points"] ?? [])
                .copyWith(isSelected: false)
            : initialState.copyWith(isSelected: false)) {
    fileComponentName = "stroke";
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
    List<Offset> points = stringToPoints(svgData);
    String key = element.getAttribute("id")!;
    double x = double.parse(element.getAttribute("x")!);
    double y = double.parse(element.getAttribute("y")!);
    Offset position = Offset(x, y);
    return StrokeComponentBloc(ComponentState(
      content: "*",
      data: {"points": points},
      position: position,
      width: double.infinity,
      height: double.infinity,
      key: key,
    ));
  }
  @override
  void onChange(Change<ComponentState> change) {
    super.onChange(change);
    //print(state.toString());
    if ((change.nextState.data["isEditing"] ?? false) !=
        (change.currentState.data["isEditing"] ?? false)) {
      flag = true;
    }
  }

  @override
  void save() {
    if (flag) {
      super.save();
    }
  }

  static List<Offset> stringToPoints(String data) {
    return data.trimRight().split(" ").map((element) {
      List<String> pair = element.split(",");
      double x = double.parse(pair.first);
      double y = double.parse(pair.last);
      return Offset(x, y);
    }).toList();
  }

  String pointsToString(List<Offset> points) {
    SvgPolyline path = SvgPolyline();
    for (int i = 0; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    return path.toString();
  }

  @override
  bool onSave() {
    bool changed = false;
    bool pointsChanged = false;
    try {
      XmlElement element = openedDocument
          .findAllElements(fileComponentName)
          .firstWhere(
              (element) => (element.getAttribute("id") ?? "") == state.key);
      double x = double.parse(element.getAttribute("x")!);
      double y = double.parse(element.getAttribute("y")!);
      Offset position = Offset(x, y);

      List<Offset> statePoints = state.data["points"] ?? [];
      XmlElement svgElement = element.findAllElements("polyline").first;
      List<Offset> points =
          stringToPoints(svgElement.getAttribute("points") ?? "");
      if (statePoints.length != points.length) {
        pointsChanged = true;
      } else {
        for (int index = 0; index < statePoints.length; index++) {
          if (statePoints[index] != points[index]) {
            pointsChanged = true;
            break;
          }
        }
      }
      if (pointsChanged) {
        svgElement.setAttribute("points", pointsToString(statePoints));
        changed = true;
      }

      if (state.position != position) {
        element.setAttribute("x", state.position.dx.toStringAsFixed(2));
        element.setAttribute("y", state.position.dy.toStringAsFixed(2));
        changed = true;
      }
    } on StateError {
      Map<String, String> bindings = {
        "id": state.key,
        "x": state.position.dx.toStringAsFixed(2),
        "y": state.position.dy.toStringAsFixed(2),
      };
      Map<String, Map<String, String>> childrenBindings = {
        "polyline": {
          "points": pointsToString(state.data["points"]),
        },
      };
      openedDocument = EditableDocument().addElement(openedDocument,
          parent: XmlElement(XmlName("content")),
          name: fileComponentName,
          bindings: bindings,
          childrenBindings: childrenBindings);

      changed = true;
    }
    return changed;
  }

  static ComponentState recalculateConstraints(
      ComponentState state, List<Offset> points) {
    List<double> xPos = points.map((e) => e.dx).toList();
    List<double> yPos = points.map((e) => e.dy).toList();
    if (xPos.isEmpty || yPos.isEmpty) {
      return state;
    }
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
        //TODO:fix scale to one direction for strokes
        Offset newPoint =
            point.scale(width / state.width, height / state.height);
        newData["points"].add(newPoint);
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
      Map<String, dynamic> newData = state.copyWith().data;
      newData.remove("isEditing");
      newState.copyWith(data: newData);
    }
    return newState;
  }
}
