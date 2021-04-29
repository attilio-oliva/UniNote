import 'package:uninote/globals/types.dart';

enum ListSubject { notebook, section, note }

extension ListSubjectExtension on ListSubject {
  String get name {
    switch (this) {
      case ListSubject.notebook:
        return 'notebook';
      case ListSubject.section:
        return 'section';
      case ListSubject.note:
        return 'note';
      default:
        return "";
    }
  }
}

class ListState {
  ListSubject subject = ListSubject.notebook;
  List<Item> itemList = List.empty(growable: true);
  String selectedItem = "";
  int editingIndex;
  bool swapToNoteEditor = false;
  ListState([ListSubject subject, String selectedNote, List<Item> itemList]) {
    this.subject = subject ?? this.subject;
    this.itemList = itemList ?? this.itemList;
    this.selectedItem = selectedNote ?? this.selectedItem;
  }
  ListState.from(ListState state) {
    this.subject = state?.subject;
    this.itemList = state?.itemList;
    this.selectedItem = state?.selectedItem;
    this.editingIndex = state.editingIndex;
    this.swapToNoteEditor = state?.swapToNoteEditor;
  }
  ListState.fromList(List<Item> itemList) {
    this.itemList = itemList ?? this.itemList;
  }
}
