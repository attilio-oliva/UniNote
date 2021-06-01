import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/components/Component.dart';
import 'package:uninote/widgets/components/ImageComponent.dart';
import 'package:uninote/widgets/components/StrokeComponent.dart';
import 'package:uninote/widgets/components/TextComponent.dart';

import 'ComponentBloc.dart';

enum EditorEvent {
  appBarButtonPressed,
  toolButtonPressed,
  canvasPressed,
}
enum EditorTool {
  textInsert,
  textSize,
  textColor,
  imageInsert,
  strokeInsert,
  lockInsertion,
  backgroundPalette,
  grid,
  changedColor,
  changedGridSize,
}

enum InputType {
  tap,
  drag,
}
enum InputState {
  start, //equivalent to down for taps
  update,
  end //equivalent to up for taps
}

extension editorToolExtension on EditorTool {
  bool get isSubTool {
    switch (this) {
      case EditorTool.changedColor:
        return true;
      default:
        return false;
    }
  }
}

class EditorEventData {
  final EditorEvent key;
  final dynamic data;
  EditorEventData(this.key, [this.data]);
}

void subToolBar(EditorState state) {
  if (state.toolBarVisibility == false) {
    state.subToolBarVisibility = false;
  } else if (state.toolBarVisibility == true &&
      state.selectedToolbar != EditorToolBar.view) {
    state.subToolBarVisibility = false;
  }
}

class EditorBloc extends Bloc<Map<String, dynamic>, EditorState> {
  EditorTool? lastPressedTool;
  EditorBloc(EditorState initialState) : super(initialState) {
    addComponent(EditorSubject.text, Offset(0, 0), {"isTitle": true});
    //addComponent(EditorSubject.text, Offset(100, 100));
  }

  Widget? getClickedComponent(Offset position) {
    bool backgroundClicked = true;
    for (Widget item in state.componentList) {
      if (item is Component) {
        Component component = item as Component;
        if (component.hitTest(position)) {
          return item;
        }
      }
    }
  }

  void addComponent(EditorSubject subject, Offset pos,
      [Map<String, dynamic> data = const {}]) {
    bool canMove = true;
    if (data.containsKey("isTitle")) {
      canMove = !data["isTitle"]!;
    }
    String content = "";
    deselectAllComponents();
    switch (subject) {
      case EditorSubject.text:
        TextComponentBloc bloc = TextComponentBloc(ComponentState(
          position: pos,
          width: defaultMaxWidth,
          height: topFieldBarHeight,
          content: content,
          canMove: canMove,
          data: data,
        ));
        state.componentList.add(
          TextComponent(
            text: content,
            bloc: bloc,
            editorBloc: this,
          ),
        );
        break;
      case EditorSubject.image:
        content = imageDefaultLocation;
        ComponentBloc bloc = ComponentBloc(
          ComponentState(
            position: pos,
            width: imageDefaultMaxWidth,
            height: imageDefaultMaxHeight,
            content: content,
            canMove: canMove,
            data: data,
          ),
        );
        state.componentList.add(
          ImageComponent(
            position: pos,
            location: content,
            bloc: bloc,
          ),
        );
        break;
      case EditorSubject.stroke:
        StrokeComponentBloc bloc = StrokeComponentBloc(
          ComponentState(
            position: pos,
            width: double.infinity,
            height: double.infinity,
            content: content,
            canMove: canMove,
            data: data,
          ),
        );
        state.componentList.add(
          StrokeComponent(
            bloc: bloc,
          ),
        );
        break;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
  }

  void deselectAllComponents([List<Widget> excludedList = const []]) {
    List<Widget> list = state.componentList;
    list = list.toSet().difference(excludedList.toSet()).toList();

    for (Widget selected in list) {
      Component component = selected as Component;
      component.bloc.add({
        "key": ComponentEvent.deselected,
      });
    }
  }

  void selectComponents(List<Widget> list) {
    for (Widget selected in list) {
      Component component = selected as Component;
      component.bloc.add({
        "key": ComponentEvent.selected,
      });
    }
  }

/*
  @override
  void onChange(Change<EditorState> change) {
    print(change);
    super.onChange(change);
  }
*/
  @override
  Stream<EditorState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event['key']) {
      case EditorEvent.appBarButtonPressed:
        if (event['data'] is EditorToolBar) {
          if (state.toolBarVisibility == true &&
              event['data'] == state.selectedToolbar) {
            state.toolBarVisibility = false;
          } else {
            state.selectedToolbar = event['data'];
            state.toolBarVisibility = true;
          }
        }
        yield EditorState.from(state);
        break;
      case EditorEvent.toolButtonPressed:
        if (event['type'] is EditorTool) {
          EditorTool pressedTool = event['type'];
          bool prevSubToolBarVisible = state.subToolBarVisibility;
          state.subToolBarVisibility = false;
          state.paletteVisibility = false;
          state.gridModifierVisibility = false;
          switch (event['type']) {
            case EditorTool.textInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.text;
              break;
            case EditorTool.imageInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.image;
              break;
            case EditorTool.strokeInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.stroke;
              break;
            case EditorTool.backgroundPalette:
              if (lastPressedTool == EditorTool.backgroundPalette) {
                state.subToolBarVisibility = !prevSubToolBarVisible;
              } else {
                state.subToolBarVisibility = true;
                state.paletteVisibility = true;
              }
              break;
            case EditorTool.grid:
              if (lastPressedTool == EditorTool.grid) {
                state.subToolBarVisibility = !prevSubToolBarVisible;
              } else {
                state.subToolBarVisibility = true;
              }
              state.paletteVisibility = true;
              state.gridModifierVisibility = true;
              break;
            case EditorTool.changedGridSize:
              state.theme["gridSize"] = event["data"];
              state.subToolBarVisibility = true;
              state.paletteVisibility = true;
              state.gridModifierVisibility = true;
              break;
            case EditorTool.changedColor:
              if (lastPressedTool == EditorTool.backgroundPalette) {
                state.theme["backgroundColor"] = event["data"];
              } else if (lastPressedTool == EditorTool.grid ||
                  lastPressedTool == EditorTool.changedGridSize) {
                state.theme["gridColor"] = event["data"];
                state.gridModifierVisibility = true;
              }
              state.subToolBarVisibility = true;
              state.paletteVisibility = true;
              break;
            case EditorTool.lockInsertion:
              if (state.mode == EditorMode.readOnly) {
                state.mode = EditorMode.insertion;
              } else {
                state.mode = EditorMode.readOnly;
              }
              break;
          }
          if (!pressedTool.isSubTool) {
            lastPressedTool = event["type"];
          }
        }
        yield EditorState.from(state);
        break;
      case EditorEvent.canvasPressed:
        print("pressed");
        InputType inputType = event["inputType"];
        InputState inputState = event["inputState"];
        Offset position = event["position"];
        switch (inputType) {
          case InputType.tap:
            Widget? clickedComponent = getClickedComponent(position);
            bool isBackgroundClick = (clickedComponent == null);
            if (isBackgroundClick) {
              deselectAllComponents();
              state.selectedComponents = [];
              switch (state.mode) {
                case EditorMode.selection:
                  // TODO: Handle this case.
                  break;
                case EditorMode.insertion:
                  addComponent(state.subject, position);
                  break;
                case EditorMode.readOnly:
                  // TODO: Handle this case.
                  break;
              }
            } else {
              //deselect all components
              deselectAllComponents([clickedComponent]);

              state.selectedComponents = [clickedComponent];

              //select all components
              selectComponents(state.selectedComponents);
            }
            break;
          case InputType.drag:
            switch (state.mode) {
              case EditorMode.selection:
                // TODO: Handle this case.
                break;
              case EditorMode.insertion:
                if (state.subject == EditorSubject.stroke) {
                  if (inputState == InputState.start) {
                    addComponent(EditorSubject.stroke, position, {
                      "isEditing": true,
                      "points": [position]
                    });
                  } else if (inputState == InputState.update) {
                    if (state.subject == EditorSubject.stroke) {
                      StrokeComponentBloc.editingBloc?.add({
                        "key": ComponentEvent.contentChanged,
                        "isEditing": true,
                        "newPoint": position,
                      });
                    }
                  } else if (inputState == InputState.end) {
                    if (state.subject == EditorSubject.stroke) {
                      StrokeComponentBloc.editingBloc?.add({
                        "key": ComponentEvent.contentChanged,
                        "isEditing": false,
                      });
                    }
                  }
                }
                break;
              case EditorMode.readOnly:
                // TODO: Handle this case.
                break;
            }
            break;
        }
        yield EditorState.from(state);
        break;
    }
    subToolBar(state);
  }
}
