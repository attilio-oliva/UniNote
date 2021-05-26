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
  showBackgroundPalette,
  changedColor,
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
          bool prevSubToolBarVisible = state.subToolBarVisibility;
          state.subToolBarVisibility = false;
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
            case EditorTool.showBackgroundPalette:
              state.subToolBarVisibility = !prevSubToolBarVisible;
              break;
            case EditorTool.changedColor:
              state.backgroundColor = event["data"];
              state.subToolBarVisibility = true;
              break;
            case EditorTool.lockInsertion:
              if (state.mode == EditorMode.readOnly) {
                state.mode = EditorMode.insertion;
              } else {
                state.mode = EditorMode.readOnly;
              }
              break;
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
