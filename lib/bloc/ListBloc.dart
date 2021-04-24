import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';
import 'dart:math' as math;

const defaultNoteBookName = "Notebook";
const defaultNoteName = "Note";

enum ListEvent {
  itemSelected,
  itemAdded,
  editRequested,
  importRemoteResource,
  importLocalResource
}

class ListEventData {
  final ListEvent key;
  final dynamic data;
  ListEventData(this.key, [this.data]);
}

class ListBloc extends Bloc<ListEventData, ListState> {
  ListBloc(ListState initialState) : super(initialState);

  //TODO: use a list of presets instead
  int getRandomColour() {
    return math.Random().nextInt(0xFFFFFF);
  }

  @override
  Stream<ListState> mapEventToState(ListEventData event) async* {
    switch (event.key) {
      case ListEvent.itemSelected:
        if (state.subject == ListSubject.notebook) {
          yield ListState(ListSubject.note, event.data);
        } else if (state.subject == ListSubject.note) {
          state.swapToNoteEditor = true;
          yield ListState.from(state);
        }
        break;
      case ListEvent.itemAdded:
        String defaultName = defaultNoteBookName;
        if (state.subject == ListSubject.note) {
          defaultName = defaultNoteName;
        }
        int count = state.itemList
            .where((item) => item.title.contains(defaultName))
            .toList()
            .length;
        Item newItem = Item(defaultName + count.toString(), getRandomColour());
        state.itemList.add(newItem);
        yield ListState.from(state);
        break;
      case ListEvent.editRequested:
        // TODO: Handle this case.
        break;
      case ListEvent.importLocalResource:
        // TODO: Handle this case.
        break;
      case ListEvent.importRemoteResource:
        // TODO: Handle this case.
        break;
    }
  }
}
