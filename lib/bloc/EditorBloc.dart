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
}

class EditorEventData {
  final EditorEvent key;
  final dynamic data;
  EditorEventData(this.key, [this.data]);
}

class EditorBloc extends Bloc<EditorEventData, EditorState> {
  EditorBloc(EditorState initialState) : super(initialState);
  @override
  Stream<EditorState> mapEventToState(EditorEventData event) async* {
    switch (event.key) {
      case EditorEvent.appBarButtonPressed:
        if (event.data is EditorToolBar) {
          if (state.toolBarVisibility == true &&
              event.data == state.selectedToolbar) {
            state.toolBarVisibility = false;
          } else {
            state.selectedToolbar = event.data;
            state.toolBarVisibility = true;
          }
        }
        yield EditorState.from(state);
        break;
      case EditorEvent.toolButtonPressed:
        if (event.data is EditorTool) {
          switch (event.data) {
            //TODO: implement all tools
            case EditorTool.textInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.text;
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
  }
}
