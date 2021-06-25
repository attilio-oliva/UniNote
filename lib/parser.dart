import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'globals/types.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path, cache: false);
}

String usedFileListPath = 'assets';
Future<void> createUsedFileList() async {
  File list = new File(usedFileListPath);
  list.create();
  list.writeAsString("<list>\n</list>");
}

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory!.path;
}

Future<File> _getLocalFile(String nome) async {
  File file = File(nome);

  bool exists = await file.exists();

  if (!exists) await file.create();
  return file;
}

Future<List<String>> usedFilesPaths() async {
  List<String> paths = [];
  try {
    usedFileListPath = await _localPath;
    File usedFileList = File(usedFileListPath + "/opened.xml");
    //if (!(await usedFileList.exists())) {
    //  createUsedFileList();
    //} else {
    print(usedFileList.path);
    String data = usedFileList.readAsStringSync();

    XmlDocument document = XmlDocument.parse(data);
    paths = document.root.descendants
        .where((node) => node is XmlText && node.text.trim().isNotEmpty)
        .map((e) => e.text)
        .toList();
    print("Opened files:");
    paths = paths.map((String element) {
      String newElement = "$usedFileListPath/$element";
      print("\t$newElement");
      return newElement;
    }).toList();
    //}
  } catch (e) {
    print("Exeption: $e");
    createUsedFileList();
  }
  return paths;
}

Item elementToItem(XmlElement element, [String path = ""]) {
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
  return Item(title, colorValue, key, location: path, isGroup: isGroup);
}

Future<Tree<Item>> pathsToTree(List<String> pathList) async {
  Tree<Item> tree = Tree<Item>();
  for (String path in pathList) {
    File file;
    try {
      file = await _getLocalFile(path);
    } catch (e) {
      print("Exeption: $e");
      continue;
    }
    if (await file.length() != 0) {
      XmlDocument document = XmlDocument.parse(file.readAsStringSync());
      for (final node in document.descendants.whereType<XmlText>()) {
        node.replace(XmlText(node.text.trim()));
      }
      document.normalize();
      XmlElement fileElement = document.getElement("file")!;
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
