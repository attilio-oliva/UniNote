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
}

class EditorEventData {
  final EditorEvent key;
  final dynamic data;
  EditorEventData(this.key, [this.data]);
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
