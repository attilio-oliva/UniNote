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
  List<Function> onPressList = List.empty(growable: true);
  String noteTarget;
  bool swapToEditCanvas = false;
  ListState(
      [ListSubject subject, List<Item> itemList, List<Function> onPressList]) {
    this.subject = subject ?? this.subject;
    this.itemList = itemList ?? this.itemList;
    this.onPressList = onPressList ?? this.onPressList;
  }
  ListState.from(ListState state) {
    this.subject = state?.subject;
    this.itemList = state?.itemList;
    this.onPressList = state?.onPressList;
    this.noteTarget = state?.noteTarget;
    this.swapToEditCanvas = state?.swapToEditCanvas;
  }
  ListState.fromList(List<Item> itemList) {
    this.itemList = itemList ?? this.itemList;
  }
}
