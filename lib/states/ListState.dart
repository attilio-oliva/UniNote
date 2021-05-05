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
}

class ListState {
  ListSubject subject = ListSubject.notebook;
  List<Item> itemList = [];
  String selectedItem = "";
  int? editingIndex;
  String editingContent = "";
  bool swapToNoteEditor = false;
  ListState([
    this.subject = ListSubject.notebook,
    this.selectedItem = "",
    this.itemList = const [],
  ]);
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
