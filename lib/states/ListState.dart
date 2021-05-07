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
        return '';
    }
  }

  int get depth {
    switch (this) {
      case ListSubject.notebook:
        return 1;
      case ListSubject.section:
        return 2;
      case ListSubject.note:
        return 3;
      default:
        return 1;
    }
  }
}

class ListState {
  ListSubject subject = ListSubject.notebook;
  List<Node<Item>> itemList = [];
  String selectedItem = "";
  int? editingIndex;
  String editingContent = "";
  bool swapToNoteEditor = false;
  ListState([
    this.subject = ListSubject.notebook,
    this.selectedItem = "",
    List<Node<Item>>? list,
  ]) {
    if (list != null) {
      itemList = list;
    }
  }
  ListState.from(ListState state) {
    this.subject = state.subject;
    this.itemList = state.itemList;
    this.selectedItem = state.selectedItem;
    this.editingIndex = state.editingIndex;
    this.editingContent = state.editingContent;
    this.swapToNoteEditor = state.swapToNoteEditor;
  }
  ListState.fromList(this.itemList);
}
