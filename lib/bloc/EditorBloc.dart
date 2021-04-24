import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/globals/types.dart';

enum EditorEvent {
  AppBarButtonPressed,
  ToolButtonPressed,
}
enum EditorTool {
  TextInsert,
  TextSize,
  TextColor,
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
      case EditorEvent.AppBarButtonPressed:
        if (event.data is EditorToolBar) {
          if (state.toolbarVisibility == true &&
              event.data == state.selectedToolbar) {
            state.toolbarVisibility = false;
          } else {
            state.selectedToolbar = event.data;
            state.toolbarVisibility = true;
          }
        }
        yield EditorState.from(state);
        break;
      case EditorEvent.ToolButtonPressed:
        if (event.data is EditorTool) {
          switch (event.data) {
            //TODO: implement all tools
            case EditorTool.TextInsert:
              state.mode = EditorMode.Insertion;
              state.subject = EditorSubject.Text;
              break;
          }
          yield EditorState.from(state);
          break;
        }
    }
  }
}
