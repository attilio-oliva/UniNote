import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/globals/EditableDocument.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/iomanager.dart';
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
  itemReordered,
  groupAdded,
  editUpdate,
  editRequested,
  importRemoteResource,
  importLocalResource,
  editorToListSwitch,
  back,
  marking,
  delete
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

  ListBloc(ListState initialState, [Tree<Item>? tree])
      : super(initialState.copyWith(
            itemList: (tree ?? Tree<Item>()).root.children)) {
    fileSystem = tree ?? Tree<Item>();
    selectedNode = fileSystem.root;
  }

  String getBaseFilePath() {
    Node<Item> node = selectedNode;
    for (int i = 0; i < selectedNode.degree - ListSubject.notebook.depth; i++) {
      node = node.parent ?? node;
    }
    String path = node.value!.location;
    if (path != "") {
      File file = File(path);
      return file.parent.absolute.path;
    } else {
      return "";
    }
  }

  String getNotebookFilePath() {
    Node<Item> node = selectedNode;
    for (int i = 0; i < selectedNode.degree - ListSubject.notebook.depth; i++) {
      node = node.parent ?? node;
    }
    String path = node.value!.location;
    String name = node.value!.title;
    if (path != "") {
      File file = File(path + "/" + name);
      return file.parent.absolute.path;
    } else {
      return "";
    }
  }

  Node<Item> addChild(Node<Item> parentNode, Item newItem, ListState state,
      [bool isNewNode = true, String? oldKey]) {
    Node<Item> child;
    if (isNewNode) {
      child = fileSystem.addChild(parentNode, newItem);
    } else {
      //String key = oldKey ?? newItem.key;
      child = fileSystem
          .preOrder(parentNode)
          .firstWhere((element) => element.value!.key == newItem.key);
      parentNode = child.parent!;
    }
    String parentName = (parentNode.value!.isGroup)
        ? "group"
        : state.subject.fromDepth(parentNode.degree).name;
    String elementName = (newItem.isGroup) ? "group" : state.subject.name;
    openedItemsDocument = EditableDocument().addElement(
      openedItemsDocument,
      parent: XmlElement(
        XmlName(parentName),
        [
          XmlAttribute(XmlName("id"), parentNode.value!.key),
        ],
      ),
      name: elementName,
      lastKey: oldKey,
      bindings: newItem.toStringMap(),
    );
    print("$parentName, $elementName, $oldKey");
    openedFileItems?.writeAsString(
        openedItemsDocument.toXmlString(pretty: true),
        flush: true);
    return child;
  }

  //TODO: use a list of presets instead
  int getRandomColour() {
    return math.Random().nextInt(0xFFFFFF);
  }

  List<Node<Item>> itemListFromNode(Node<Item> node, ListState state) {
    List<Node<Item>> itemList = [];
    if (state.subject == ListSubject.note) {
      itemList = fileSystem.preOrder(node);
    } else {
      itemList = node.children;
    }
    return itemList;
  }

  /*void listToEditor(String note) {
    state.selectedNote = note;
  }*/

  ListState editorToList(ListState state) {
    return state.copyWith(
        selectedNote: null,
        selectedItem: selectedNode.value!.title,
        itemList: itemListFromNode(selectedNode, state));
  }

  @override
  Stream<ListState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event['key']) {
      case ListEvent.editorToListSwitch:
        yield editorToList(state);
        break;
      case ListEvent.itemReordered:
        ListState newState = state;
        if (event.containsKey("from") && event.containsKey("to")) {
          int from = event["from"];
          int to = event["to"];
          if (to > from) {
            to -= 1;
          }
          Node<Item> item = newState.itemList.removeAt(from);
          if (newState.subject == ListSubject.note) {
            int maxIndex = newState.itemList.length - 1;
            int prevIndex = (to - 1).clamp(0, maxIndex);
            int nextIndex = to.clamp(0, maxIndex);

            bool isPrevGroup = (to - 1 >= 0)
                ? newState.itemList[prevIndex].value!.isGroup
                : false;
            bool isNextInGroup =
                (newState.itemList[nextIndex].degree > ListSubject.note.depth);
            bool isInGroup = (newState.itemList[to.clamp(0, maxIndex)].degree >
                ListSubject.note.depth);
            bool wasInGroup = (item.degree > ListSubject.note.depth);
            if (item.value!.isGroup) {
              int maxIndex = selectedNode.children.length;
              from = (from - maxIndex).clamp(0, maxIndex);
              to = (to - maxIndex).clamp(0, maxIndex);
              selectedNode.children.remove(item);
              selectedNode.children.insert(to, item);
              newState = newState.copyWith(
                  itemList: fileSystem.preOrder(selectedNode));
              //state.itemList = fileSystem.preOrder(selectedNode);
            } else if (isPrevGroup ||
                isNextInGroup ||
                (wasInGroup && !isInGroup)) {
              fileSystem.removeChild(item.parent!, item.value!);
              Node<Item> newParent;
              int parentIndex;
              if (isNextInGroup) {
                newParent = newState.itemList[nextIndex].parent!;
              } else if (isPrevGroup) {
                newParent = newState.itemList[prevIndex];
              } else {
                newParent = selectedNode;
              }
              parentIndex = newState.itemList.indexOf(newParent);
              fileSystem.insertChildAt(
                newParent,
                item.value!,
                (to - parentIndex - 1).clamp(0, newParent.children.length),
              );
              newState = newState.copyWith(
                  itemList: fileSystem.preOrder(selectedNode));
              //state.itemList = fileSystem.preOrder(selectedNode);
            } else {
              List<Node<Item>> list = List<Node<Item>>.from(newState.itemList);
              list.insert(to, item);
              newState = newState.copyWith(itemList: list);
              //state.itemList.insert(to, item);
            }
          } else {
            List<Node<Item>> list = List<Node<Item>>.from(newState.itemList);
            list.insert(to, item);
            newState = newState.copyWith(itemList: list);
            //state.itemList.insert(to, item);
          }
          yield newState;
        } else {
          yield state;
        }

        break;
      case ListEvent.itemSelected:
        ListState newState = state;
        if (event['index'] != null) {
          selectedNode = newState.itemList[event['index']];
        } else if (event['data'] != null) {
          selectedNode = selectedNode.children
              .firstWhere((element) => element.value?.title == event['data']);
        }
        if (openedFileItems == null &&
            newState.subject != ListSubject.notebook) {
          openedFileItems = await getLocalFile(
              getNotebookFilePath(), DocType.notebook,
              item: selectedNode.value!);
        }
        newState = newState.copyWith(selectedItem: selectedNode.value!.title);
        //state.selectedItem = selectedNode.value!.title;

        if (newState.subject == ListSubject.notebook) {
          newState = newState.copyWith(subject: ListSubject.section);
          //state.subject = ListSubject.section;
        } else if (newState.subject == ListSubject.section) {
          newState = newState.copyWith(subject: ListSubject.note);
          //state.subject = ListSubject.note;
        } else if (newState.subject == ListSubject.note) {
          if (selectedNode.value!.isGroup) {
            selectedNode.areChildrenVisible = !selectedNode.areChildrenVisible;
          } else {
            newState =
                newState.copyWith(selectedNote: selectedNode.value!.title);
            //state.selectedNote = note;
            if (selectedNode.parent!.value!.isGroup) {
              selectedNode = selectedNode.parent!;
            }
          }
          selectedNode = selectedNode.parent!;
          newState = newState.copyWith(selectedItem: selectedNode.value!.title);
          //state.selectedItem = selectedNode.value!.title;
        }
        newState = newState.copyWith(
            itemList: itemListFromNode(selectedNode, newState));
        //state.itemList = itemListFromNode(selectedNode);
        yield newState;
        break;
      case ListEvent.itemAdded:
      case ListEvent.groupAdded:
        ListState newState = state;
        bool isGroupAdded = (event['key'] == ListEvent.groupAdded);
        String defaultName = defaultNoteBookName;
        if (newState.subject == ListSubject.section) {
          defaultName = defaultSectionName;
        } else if (isGroupAdded) {
          defaultName = defaultGroupName;
        } else if (newState.subject == ListSubject.note) {
          defaultName = defaultNoteName;
        }
        if (!isGroupAdded) {
          Item newItem = Item(
            defaultName + getDuplicateId(newState.itemList, defaultName),
            getRandomColour(),
            _getHashedKey(defaultNoteName), //defaultKey,
            isGroup: isGroupAdded,
          );
          addChild(selectedNode, newItem, newState);
        } else {
          String title =
              defaultName + getDuplicateId(newState.itemList, defaultName);
          Item newItem = Item(
            title,
            getRandomColour(),
            _getHashedKey(title),
            isGroup: isGroupAdded,
          );
          Node<Item> groupNode = addChild(selectedNode, newItem, newState);
          addChild(groupNode,
              Item(defaultNoteName, newItem.colorValue, defaultKey), newState);
        }
        if (newState.subject == ListSubject.note) {
          newState =
              newState.copyWith(itemList: fileSystem.preOrder(selectedNode));
          //state.itemList = fileSystem.preOrder(selectedNode);
        } else {
          newState = newState.copyWith(itemList: selectedNode.children);
          //state.itemList = selectedNode.children;
        }
        newState =
            newState.copyWith(editingIndex: (newState.itemList.length - 1));
        //state.editingIndex = state.itemList.length - 1;
        yield newState;
        break;
      case ListEvent.editUpdate:
        ListState newState = state;
        if (newState.editingIndex != null) {
          newState = newState.copyWith(editingContent: event["data"]);
          //state.editingContent = event["data"];
        }
        yield newState;
        break;
      case ListEvent.editRequested:
        ListState newState = state;
        int index = event['index'];
        String title = event['data'];
        List<Node<Item>> list = List<Node<Item>>.from(newState.itemList);
        String lastKey = list[index].value!.key;
        if (title != "") {
          list[index].value!.title = title + getDuplicateId(list, title, index);
        }
        newState = newState.stopEditing();
        if (list[index].value!.key == defaultKey) {
          list[index].value!.key = _getHashedKey(title);
        }
        addChild(selectedNode, list[index].value!, state, false, lastKey);
        yield newState;
        break;
      case ListEvent.back:
        ListState newState = state;
        if (selectedNode.parent != null) //if not root
        {
          selectedNode = selectedNode.parent!;
          ListSubject subject =
              newState.subject.fromDepth(newState.subject.depth - 1);
          newState = newState.copyWith(
              itemList: selectedNode.children,
              subject: subject,
              selectedNote: null);
          /*state.itemList = selectedNode.children;
                    state.subject = state.subject.fromDepth(state.subject.depth - 1);
                    state.selectedNote = null;*/
          if (newState.subject == ListSubject.notebook) {
            newState = newState.copyWith(selectedItem: defaultNoteBookName);
            //state.selectedItem = defaultNoteBookName;
          } else {
            newState =
                newState.copyWith(selectedItem: selectedNode.value!.title);
            //state.selectedItem = selectedNode.value!.title;
          }
          yield newState;
        }
        break;
      case ListEvent.marking:
        ListState newState = state;
        if (event["data"] == "buttonPressed") {
          newState = newState.copyWith(isMarking: !newState.isMarking);
          if (newState.isMarking == false) {
            List<Node<Item>> list = [];
            newState = newState.copyWith(markedItems: list);
          }
        } else {
          if (newState.isMarking == true) {
            Node<Item> item = state.itemList[event["index"]];
            List<Node<Item>> list = List<Node<Item>>.from(newState.markedItems);
            if (list.contains(item)) {
              list.remove(item);
            } else {
              list.add(item);
            }
            newState = newState.copyWith(markedItems: list);
          }
        }
        yield newState;
        break;
      case ListEvent.delete:
        ListState newState = state;
        List<Node<Item>> itemsList = List<Node<Item>>.from(newState.itemList);
        List<Node<Item>> markedList =
            List<Node<Item>>.from(newState.markedItems);
        List<Node<Item>> array = [];
        markedList.forEach((item) {
          if (itemsList.contains(item)) {
            int index = itemsList.indexOf(item);
            array.add(item);
            fileSystem.removeChild(
                itemsList[index].parent!, itemsList[index].value!);
            if (itemsList[index].value!.isGroup) {
              List<Node<Item>> list = [];
              itemsList[index].allChildren.forEach((element) {
                list.add(element);
              });
              list.forEach((element) {
                fileSystem.removeChild(itemsList[index], element.value!);
                itemsList.remove(element);
              });
              fileSystem.removeChild(
                  itemsList[index].parent!, itemsList[index].value!);
            }
            itemsList.remove(item);
          }
        });
        array.forEach((item) {
          markedList.remove(item);
        });
        newState =
            newState.copyWith(itemList: itemsList, markedItems: markedList);
        yield newState;
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
