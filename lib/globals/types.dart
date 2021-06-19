import 'dart:collection';
import 'dart:core';
import 'dart:core' as core;

class Item {
  String title;
  String key;
  int colorValue;
  bool isGroup;
  Item(this.title, this.colorValue, this.key, [this.isGroup = false]);

  @override
  String toString() {
    String result = "";
    result += "{Title: $title";
    result += ", color: $colorValue";
    result += ", isGroup: $isGroup";
    result += ", key: $key";
    result += "}";
    return result;
  }
}

class Node<E> {
  late E? value;
  late int degree;
  bool areChildrenVisible = true;
  List<Node<E>> _children = [];
  Node<E>? parent;

  set children(List<Node<E>> childrenList) {
    _children = childrenList;
  }

  List<Node<E>> get allChildren {
    return _children;
  }

  List<Node<E>> get children {
    if (areChildrenVisible) {
      return _children;
    } else {
      return [];
    }
  }

  Node(this.degree, this.value, this.parent, [List<Node<E>>? children]) {
    _children = children ?? [];
  }
  Node.root() {
    degree = 0;
  }
}

class Tree<E> {
  late Node<E> root;
  int degree = 0;
  int _size = 0;

  int get size {
    return _size;
  }

  Tree([List<E> firstLevel = const []]) {
    root = Node<E>.root();
    addChildren(root, firstLevel);
  }

  void addChildren(Node<E> parentNode, List<E> children) {
    for (E child in children) {
      addChild(parentNode, child);
    }
  }

  void insertChildAt(Node<E> parentNode, E child, int index) {
    Node<E> childNode = Node<E>(parentNode.degree + 1, child, parentNode);
    parentNode.children.insert(index, childNode);
    _size++;
  }

  Node<E> removeChildAt(Node<E> parentNode, int index) {
    _size--;
    return parentNode.children.removeAt(index);
  }

  Node<E> addChild(Node<E> parentNode, E child) {
    Node<E> childNode = Node<E>(parentNode.degree + 1, child, parentNode);
    parentNode.children.add(childNode);
    _size++;
    return childNode;
  }

  void removeChild(Node<E> parentNode, E child) {
    Node<E> childNode = Node<E>(parentNode.degree + 1, child, parentNode);
    parentNode.children.remove(childNode);
    _size--;
  }

  List<Node<E>> preOrder(Node<E> parentNode,
      [bool parentInclusion = false, bool showHiddenChildren = false]) {
    List<Node<E>> list = [];

    ListQueue<Node<E>> stack = ListQueue<Node<E>>();
    stack.addLast(parentNode);

    while (stack.isNotEmpty) {
      Node<E> top = stack.removeLast();
      for (Node<E> child in top.allChildren.reversed) {
        stack.addLast(child);
      }
      if (top != parentNode && !parentInclusion) {
        if (top.parent!.areChildrenVisible || showHiddenChildren) {
          list.add(top);
        }
      }
    }
    return list;
  }

  String toString() {
    String separator = "-" * 40;
    String result = separator + "\n";
    preOrder(root, false, true).forEach((element) {
      result += '|' * element.degree;
      result += ' ' + element.value.toString();
      result += '\n';
    });
    result += separator;
    return result;
  }
}

// Waiting for newer dart versions...
//typedef Event = Map<String, dynamic>;
