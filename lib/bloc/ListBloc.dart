import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markdown/markdown.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';
import 'dart:math' as math;

const defaultNoteBookName = "Notebook";
const defaultNoteName = "Note";

enum ListEvent { itemSelected, itemAdded, editRequested }

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc(ListState initialState) : super(initialState);

  //TODO: use a list of presets instead
  int getRandomColour() {
    return math.Random().nextInt(0xFFFFFF);
  }

  @override
  Stream<ListState> mapEventToState(ListEvent event) async* {
    switch (event) {
      case ListEvent.itemSelected:
        if (state.subject == ListSubject.notebook) {
          yield ListState(ListSubject.note, null, null);
        } else if (state.subject == ListSubject.note) {
          state.swapToEditCanvas = true;
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
        break;
    }
  }
}
