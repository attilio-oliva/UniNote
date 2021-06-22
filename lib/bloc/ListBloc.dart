import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/parser.dart';
import 'package:uninote/states/ListState.dart';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:xml/xml.dart';

final String defaultKey = 0xFFFFFF.toString();
const defaultNoteBookName = "Notebook";
const defaultSectionName = "Section";
const defaultNoteName = "Note";
const defaultGroupName = "Group";

enum ListEvent {
  itemSelected,
  itemAdded,
  groupAdded,
  editUpdate,
  editRequested,
  importRemoteResource,
  importLocalResource,
  editorToListSwitch,
  back
}

String _getHashedKey(String title) {
  String salt = math.Random().nextInt(0xFFFF).toString();
  List<int> plainText = utf8.encode(title + salt);
  return sha1.convert(plainText).toString();
}

int count(List<Node<Item>> list, String value, [int? indexToSkip]) {
  int length = 0;
  int n = list.length;
  indexToSkip = indexToSkip ?? n;
  for (int i = 0; i < n; i++) {
    if (i != indexToSkip) {
      if (list[i].value!.title == value) {
        length++;
      }
    }
  }
  return length;
}

//TODO: handle case max attempts are reached
String getDuplicateId(List<Node<Item>> list, String value, [int? indexToSkip]) {
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
  final XmlBuilder builder = XmlBuilder();
  Tree<Item> fileSystem = Tree<Item>();
  late Node<Item> selectedNode;

  ListBloc(ListState initialState, [Tree<Item>? tree]) : super(initialState) {
    fileSystem = tree ?? Tree<Item>();
    selectedNode = fileSystem.root;
    state.itemList = selectedNode.children;
  }
  String getBaseFilePath() {
    Node<Item> node = selectedNode;
    for (int i = 0; i < selectedNode.degree - ListSubject.notebook.depth; i++) {
      node = node.parent ?? fileSystem.root;
    }
    String path = node.value!.location;
    if (path != "") {
      File file = File(path);
      return file.parent.absolute.path;
    } else {
      return "";
    }
  }

  //TODO: use a list of presets instead
  int getRandomColour() {
    return math.Random().nextInt(0xFFFFFF);
  }

  List<Node<Item>> itemListFromNode(Node<Item> node) {
    List<Node<Item>> itemList = [];
    if (state.subject == ListSubject.note) {
      itemList = fileSystem.preOrder(node);
    } else {
      itemList = node.children;
    }
    return itemList;
  }

  void listToEditor(String note) {
    state.selectedNote = note;
  }

  void editorToList() {
    state.selectedNote = null;
    state.selectedItem = selectedNode.value!.title;
    state.itemList = itemListFromNode(selectedNode);
  }

  @override
  Stream<ListState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event['key']) {
      case ListEvent.editorToListSwitch:
        editorToList();
        yield ListState.from(state);
        break;
      case ListEvent.itemSelected:
        if (event['index'] != null) {
          selectedNode = state.itemList[event['index']];
        } else if (event['data'] != null) {
          selectedNode = selectedNode.children
              .firstWhere((element) => element.value?.title == event['data']);
        }
        state.selectedItem = selectedNode.value!.title;

        if (state.subject == ListSubject.notebook) {
          state.subject = ListSubject.section;
        } else if (state.subject == ListSubject.section) {
          state.subject = ListSubject.note;
        } else if (state.subject == ListSubject.note) {
          if (selectedNode.value!.isGroup) {
            selectedNode.areChildrenVisible = !selectedNode.areChildrenVisible;
          } else {
            listToEditor(selectedNode.value!.title);
            if (selectedNode.parent!.value!.isGroup) {
              selectedNode = selectedNode.parent!;
            }
          }
          selectedNode = selectedNode.parent!;
          state.selectedItem = selectedNode.value!.title;
        }

        state.itemList = itemListFromNode(selectedNode);
        yield ListState.from(state);
        break;
      case ListEvent.itemAdded:
      case ListEvent.groupAdded:
        bool isGroupAdded = (event['key'] == ListEvent.groupAdded);
        String defaultName = defaultNoteBookName;
        if (state.subject == ListSubject.section) {
          defaultName = defaultSectionName;
        } else if (isGroupAdded) {
          defaultName = defaultGroupName;
        } else if (state.subject == ListSubject.note) {
          defaultName = defaultNoteName;
        }
        if (!isGroupAdded) {
          Item newItem = Item(
            defaultName + getDuplicateId(state.itemList, defaultName),
            getRandomColour(),
            defaultKey,
            isGroup: isGroupAdded,
          );
          fileSystem.addChild(selectedNode, newItem);
        } else {
          String title =
              defaultName + getDuplicateId(state.itemList, defaultName);
          Item newItem = Item(
            title,
            getRandomColour(),
            _getHashedKey(title),
            isGroup: isGroupAdded,
          );
          fileSystem.addChild(fileSystem.addChild(selectedNode, newItem),
              Item(defaultNoteName, newItem.colorValue, defaultKey));
        }
        if (state.subject == ListSubject.note) {
          state.itemList = fileSystem.preOrder(selectedNode);
        } else {
          state.itemList = selectedNode.children;
        }
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
          state.itemList[index].value!.title =
              title + getDuplicateId(state.itemList, title, index);
        }
        state.editingIndex = null;
        state.editingContent = "";
        if (state.itemList[index].value!.key == defaultKey) {
          state.itemList[index].value!.key = _getHashedKey(title);
        }
        yield ListState.from(state);
        break;
      case ListEvent.back:
        if (selectedNode.parent != null) //if not root
        {
          selectedNode = selectedNode.parent!;
          state.itemList = selectedNode.children;
          state.subject = state.subject.fromDepth(state.subject.depth - 1);
          state.selectedNote = null;
          if (state.subject == ListSubject.notebook) {
            state.selectedItem = defaultNoteBookName;
          } else {
            state.selectedItem = selectedNode.value!.title;
          }
          yield ListState.from(state);
        }
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
