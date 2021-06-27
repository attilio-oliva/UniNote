import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'globals/types.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

enum DocType {
  indexList,
  notebook,
  document,
}
String usedFileListPath = 'assets';
XmlDocument openedIndexDocument = XmlDocument.parse("");
XmlDocument openedItemsDocument = XmlDocument.parse("");
XmlDocument openedDocument = XmlDocument.parse("");
File? openedFileIndex;
File? openedFileItems;
File? openedFileDocument;
Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path, cache: false);
}

Future<void> createIndexFile(String location) async {
  File file = new File(location);
  file.writeAsString("<list>\n</list>");
}

Future<void> createNotebookFile(String location, Item item) async {
  File file = new File(location);
  file.writeAsString(
      '<notebook title="${item.title}" id="${item.key}" color=${item.colorValue}>\n</notebook>');
}

Future<void> createDocumentFile(String location, String title) async {
  File file = new File(location);
  DateTime time = DateTime.now();
  String timestamp =
      "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute}";
  file.writeAsString(
      '<doc title="$title">\n<meta>\n<version app="v0.01" note="${timestamp}"/>\n</meta>\n<style>\n<background color="#FFFFFF" pattern="grid"/>\n<theme></theme>\n</style>\n<content>\n</content>\n</doc>');
}

Future<String> get _localPath async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = (await getExternalStorageDirectory())!;
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  return directory.path;
}

Future<File> getLocalFile(String name, DocType type,
    {String? title = "", Item? item}) async {
  File file = File(name);

  bool exists = await file.exists();

  if (!exists) {
    await file.create();
    switch (type) {
      case DocType.indexList:
        await createIndexFile(file.absolute.path);
        break;
      case DocType.notebook:
        await createNotebookFile(file.absolute.path, item!);
        break;
      case DocType.document:
        await createDocumentFile(file.absolute.path, title!);
        break;
    }
  }
  return file;
}

Future<List<String>> usedFilesPaths() async {
  List<String> paths = [];
  try {
    String data = "";
    File usedFileList;
    if (openedFileIndex == null) {
      usedFileListPath = await _localPath;
      usedFileList = await getLocalFile(
          usedFileListPath + "/index.xml", DocType.indexList);
    } else {
      usedFileList = openedFileIndex!;
    }
    print(usedFileList.path);
    data = usedFileList.readAsStringSync();

    openedIndexDocument = XmlDocument.parse(data);
    paths = openedIndexDocument.root.descendants
        .where((node) => node is XmlText && node.text.trim().isNotEmpty)
        .map((e) => e.text)
        .toList();
    print("Opened files:");
    paths = paths.map((String element) {
      String newElement = element;
      // if relative path
      if (!element.startsWith("/")) {
        newElement = "$usedFileListPath/$element";
      }
      print("\t$newElement");
      return newElement;
    }).toList();
    //}
  } catch (e) {
    print("Exeption: $e");
  }
  return paths;
}

Item elementToItem(XmlElement element, [String path = ""]) {
  int colorValue = int.parse(element.attributes
      .firstWhere((element) => element.name.toString() == "color")
      .value);
  String key = element.attributes
      .firstWhere((element) => element.name.toString() == "id")
      .value;
  String title = element.attributes
      .firstWhere((element) => element.name.toString() == "title")
      .value;
  bool isGroup = (element.name.toString() == "group");
  return Item(title, colorValue, key, location: path, isGroup: isGroup);
}

Future<Tree<Item>> pathsToTree(List<String> pathList) async {
  Tree<Item> tree = Tree<Item>();
  for (String path in pathList) {
    File file;
    try {
      file = await getLocalFile(path, DocType.notebook);
    } catch (e) {
      print("Exeption: $e");
      continue;
    }
    if (await file.length() != 0) {
      openedItemsDocument = XmlDocument.parse(file.readAsStringSync());
      for (final node in openedItemsDocument.descendants.whereType<XmlText>()) {
        node.replace(XmlText(node.text.trim()));
      }
      openedItemsDocument.normalize();
      XmlElement fileElement = openedItemsDocument.getElement("notebook")!;
      Node<Item> fileRootNode =
          tree.addChild(tree.root, elementToItem(fileElement, path));
      for (XmlElement section in fileElement.findAllElements("section")) {
        Node<Item> sectionNode =
            tree.addChild(fileRootNode, elementToItem(section));
        Node<Item> lastNode = sectionNode;
        for (XmlElement element
            in section.descendants.whereType<XmlElement>()) {
          if (element.depth == section.depth + 1) {
            lastNode = tree.addChild(sectionNode, elementToItem(element));
          } else {
            tree.addChild(lastNode, elementToItem(element));
          }
        }
      }
    }
  }
  return tree;
}
