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

  ListSubject fromDepth(int depth) {
    switch (depth) {
      case 1:
        return ListSubject.notebook;
      case 2:
        return ListSubject.section;
      case 3:
        return ListSubject.note;
      default:
        return ListSubject.notebook;
    }
  }
}

class ListState {
  final ListSubject subject;
  final String? selectedNote;
  final int? editingIndex;
  late final String selectedItem;
  late final String editingContent;
  late final bool isMarking;
  late final List<Node<Item>> itemList;
  late final List<Node<Item>> markedItems;
  ListState({
    this.subject = ListSubject.notebook,
    this.selectedItem = "",
    this.selectedNote,
    this.editingIndex,
    this.editingContent = "",
    this.isMarking = false,
    List<Node<Item>>? markedItems,
    List<Node<Item>>? itemList,
  }) {
    if (markedItems != null) {
      this.markedItems = markedItems;
    } else {
      this.markedItems = [];
    }
    if (itemList != null) {
      this.itemList = itemList;
    } else {
      this.itemList = [];
    }
  }
  ListState copyWith({
    ListSubject? subject,
    List<Node<Item>>? itemList,
    String? selectedItem,
    String? selectedNote,
    int? editingIndex,
    String? editingContent,
    bool? isMarking,
    List<Node<Item>>? markedItems,
  }) {
    return ListState(
      subject: subject ?? this.subject,
      itemList: itemList ?? this.itemList,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedNote: selectedNote ?? this.selectedNote,
      editingIndex: editingIndex ?? this.editingIndex,
      editingContent: editingContent ?? this.editingContent,
      isMarking: isMarking ?? this.isMarking,
      markedItems: markedItems ?? this.markedItems,
    );
  }

  ListState stopEditing() {
    return ListState(
      subject: this.subject,
      itemList: this.itemList,
      selectedItem: this.selectedItem,
      selectedNote: this.selectedNote,
      editingIndex: null,
      editingContent: "",
      isMarking: this.isMarking,
      markedItems: this.markedItems,
    );
  }

  String toString() {
    String result = "{";
    result += " subject: " + subject.name;
    result += ", items: " + itemList.toString();
    result += ", selectedItem: " + selectedItem;
    result += ", editingIndex: " + editingIndex.toString();
    result += ", editingContent: " + editingContent;
    result += ", selectedNote: " + selectedNote.toString();
    result += "}";
    return result;
  }
}
