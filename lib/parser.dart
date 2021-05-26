import 'dart:io';
import 'dart:ui';
import 'package:xml/xml.dart';

import 'globals/types.dart';

String usedFileListPath = 'example/opened.xml';
void createUsedFileList() {
  print(Directory.current);
  File list = new File(usedFileListPath);
  list.create();
  list.writeAsString("<list>\n</list>");
}

List<String> usedFilesPaths() {
  List<String> paths = [];
  try {
    File usedFileList = File(usedFileListPath);
    //if (!(await usedFileList.exists())) {
    //  createUsedFileList();
    //} else {
    XmlDocument document = XmlDocument.parse(usedFileList.readAsStringSync());
    paths = document.root.descendants
        .where((node) => node is XmlText && node.text.trim().isNotEmpty)
        .map((e) => e.text)
        .toList();
    print("Opened files:");
    paths.forEach((element) {
      print("\t$element");
    });
    //}
  } catch (e) {
    print(e);
    createUsedFileList();
  }
  return paths;
}

Item elementToItem(XmlElement element) {
  int colorValue = int.parse(element.attributes
      .firstWhere((element) => element.name.toString() == "color")
      .value);
  String key = element.attributes
      .firstWhere((element) => element.name.toString() == "key")
      .value;
  String title = element.attributes
      .firstWhere((element) => element.name.toString() == "title")
      .value;
  bool isGroup = (element.name.toString() == "group");
  return Item(title, colorValue, key, isGroup);
}

Tree<Item> pathsToTree(List<String> pathList) {
  Tree<Item> tree = Tree<Item>();
  for (String path in pathList) {
    File file = File(path);
    XmlDocument document = XmlDocument.parse(file.readAsStringSync());
    for (final node in document.descendants.whereType<XmlText>()) {
      node.replace(XmlText(node.text.trim()));
    }
    document.normalize();
    XmlElement fileElement = document.getElement("file")!;

    Node<Item> fileRootNode =
        tree.addChild(tree.root, elementToItem(fileElement));
    for (XmlElement section in fileElement.findAllElements("section")) {
      Node<Item> sectionNode =
          tree.addChild(fileRootNode, elementToItem(section));
      Node<Item> lastNode = sectionNode;
      for (XmlElement element in section.descendants.whereType<XmlElement>()) {
        if (element.depth == section.depth + 1) {
          lastNode = tree.addChild(sectionNode, elementToItem(element));
        } else {
          tree.addChild(lastNode, elementToItem(element));
        }
      }
    }
  }
  return tree;
}
