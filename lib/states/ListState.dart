import 'package:uninote/globals/types.dart';

enum ListSubject { notebook, note }

extension ListSubjectExtension on ListSubject {
  String get name {
    switch (this) {
      case ListSubject.notebook:
        return 'notebook';
      case ListSubject.note:
        return 'note';
      default:
        return null;
    }
  }
}

class ListState {
  ListSubject subject = ListSubject.notebook;
  List<Item> itemList = List.empty(growable: true);
  String selectedItem = "";
  bool swapToEditCanvas = false;
  ListState([ListSubject subject, String selectedNote, List<Item> itemList]) {
    this.subject = subject ?? this.subject;
    this.itemList = itemList ?? this.itemList;
    this.selectedItem = selectedNote ?? this.selectedItem;
  }
  ListState.from(ListState state) {
    this.subject = state?.subject;
    this.itemList = state?.itemList;
    this.selectedItem = state?.selectedItem;
    this.swapToEditCanvas = state?.swapToEditCanvas;
  }
  ListState.fromList(List<Item> itemList) {
    this.itemList = itemList ?? this.itemList;
  }
}
