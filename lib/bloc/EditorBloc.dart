import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/states/EditorState.dart';

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
  EditorBloc(EditorState initialState) : super(initialState);
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
          print(event['type']);
          switch (event['type']) {
            //TODO: implement all tools
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
        //TODO: implement feature
        yield EditorState.from(state);
        break;
    }
    subToolBar(state);
  }
}
