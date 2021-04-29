import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ComponentState.dart';

enum ComponentEvent {
  resized,
  moved,
  contentChanged,
}

class ComponentEventData {
  ComponentEvent key;
  dynamic data;
  ComponentEventData(this.key, [this.data]);
}

//TODO: add a minimum size
class ComponentBloc extends Bloc<Map<String, dynamic>, ComponentState> {
  ComponentBloc(ComponentState initialState) : super(initialState);

  void onContentChange(Map<String, dynamic> event) {}

  bool hitTest(Offset point) {
    if (state.position.dx <= point.dx &&
        point.dx <= state.position.dx + state.width) {
      if (state.position.dy <= point.dy &&
          point.dy <= state.position.dy + state.heigth) {
        return true;
      }
    }
    return false;
  }

  @override
  Stream<ComponentState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event["key"]) {
      case ComponentEvent.resized:
        if (event["data"] is Offset) {
          state.width = event["data"].dx;
          state.heigth = event["data"].dy;
        }
        yield ComponentState.from(state);
        break;
      case ComponentEvent.moved:
        if (event["data"] is Offset) {
          state.position += event["data"];
        }
        yield ComponentState.from(state);
        break;
      case ComponentEvent.contentChanged:
        state.content = event["data"];
        onContentChange(event);
        yield ComponentState.from(state);
        break;
    }
  }
}

class TextComponentBloc extends ComponentBloc {
  final double maxWidthTitle = 400;
  TextComponentBloc(ComponentState initialState) : super(initialState) {
    if (state.data != null) {
      if (state.data.containsKey("isTitle")) {
        if (state.data["isTitle"] ?? false) {
          state.width = maxWidthTitle;
        }
      }
    }
  }

  //@override
  //void onContentChange(Map<String, dynamic> event) {
  //  state.data["isTitle"] = ;
  //  state.data["isEditing"] = ;
  //}
}
