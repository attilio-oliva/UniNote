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
  editUpdate,
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

int count(List<Item> list, String value, [int? indexToSkip]) {
  int length = 0;
  int n = list.length;
  indexToSkip = indexToSkip ?? n;
  for (int i = 0; i < n; i++) {
    if (i != indexToSkip) {
      if (list[i].title == value) {
        length++;
      }
    }
  }
  return length;
}

//TODO: handle case max attempts are reached
String getDuplicateId(List<Item> list, String value, [int? indexToSkip]) {
  int maxAttempts = 256;
  int id;
  String result = "";
  indexToSkip = indexToSkip ?? maxAttempts;
  for (id = 0; id < maxAttempts; id++) {
    String attempt = value + (id > 0 ? id.toString() : "");
    if (count(list, attempt, indexToSkip) == 0) {
      break;
    }
  }
  if (id > 0) {
    result = id.toString();
  }
  return result;
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
        Item newItem = Item(
            defaultName + getDuplicateId(state.itemList, defaultName),
            getRandomColour(),
            defaultKey);
        state.itemList.add(newItem);
        state.editingIndex = state.itemList.length - 1;
        yield ListState.from(state);
        break;
      case ListEvent.editUpdate:
        if (state.editingIndex != null) {
          state.editingContent = event["data"];
        }
        yield ListState.from(state);
        break;
      case ListEvent.editRequested:
        int index = event['index'];
        String title = event['data'];
        if (title != "") {
          state.itemList[index].title =
              title + getDuplicateId(state.itemList, title, index);
        }
        state.editingIndex = null;
        state.editingContent = "";
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
