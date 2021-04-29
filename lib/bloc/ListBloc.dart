import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'dart:convert';

final String defaultKey = 0xFFFFFF.toString();
const defaultNoteBookName = "Notebook";
const defaultSectionName = "Section";
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

String _getHashedKey(String title) {
  String salt = math.Random().nextInt(0xFFFF).toString();
  List<int> plainText = utf8.encode(title + salt);
  return sha1.convert(plainText).toString();
}

int count(ListState state, String defaultName) {
  return state.itemList
      .where((item) => item.title.indexOf(defaultName) != -1)
      .toList()
      .length;
}

class ListBloc extends Bloc<Map<String, dynamic>, ListState> {
  ListBloc(ListState initialState) : super(initialState);

  //TODO: use a list of presets instead
  int getRandomColour() {
    return math.Random().nextInt(0xFFFFFF);
  }

  @override
  Stream<ListState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event['key']) {
      case ListEvent.itemSelected:
        if (state.subject == ListSubject.notebook) {
          yield ListState(ListSubject.section, event['data']);
        } else if (state.subject == ListSubject.section) {
          yield ListState(ListSubject.note, event['data']);
        } else if (state.subject == ListSubject.note) {
          state.swapToNoteEditor = true;
          yield ListState.from(state);
        }
        break;
      case ListEvent.itemAdded:
        String defaultName = defaultNoteBookName;
        if (state.subject == ListSubject.section) {
          defaultName = defaultSectionName;
        } else if (state.subject == ListSubject.note) {
          defaultName = defaultNoteName;
        }
        Item newItem = Item(defaultName + count(state, defaultName).toString(),
            getRandomColour(), defaultKey);
        state.itemList.add(newItem);
        state.editingIndex = state.itemList.length - 1;
        yield ListState.from(state);
        break;
      case ListEvent.editRequested:
        int index = event['index'];
        String title = event['data'];
        if (title != "") {
          String defaultName = defaultNoteBookName;
          if (state.subject == ListSubject.section) {
            defaultName = defaultSectionName;
          } else if (state.subject == ListSubject.note) {
            defaultName = defaultNoteName;
          }
          state.itemList[index].title =
              defaultName + (count(state, defaultName)).toString();
        }
        state.editingIndex = null;
        if (state.itemList[index].key == defaultKey) {
          state.itemList[index].key = _getHashedKey(title);
        }
        yield ListState.from(state);
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
