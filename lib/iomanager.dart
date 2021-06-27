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
String fileExtension = '.xml';
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
  String template = "<list>\n</list>";
  file.writeAsString(template);
  openedFileIndex = file;
  //openedIndexDocument = XmlDocument.parse(template);
}

Future<void> createNotebookFile(String location, Item item) async {
  File file = new File(location);
  String template =
      '<notebook title="${item.title}" id="${item.key}" color="${item.colorValue}">\n</notebook>';
  file.writeAsString(template);
  //openedItemsDocument = XmlDocument.parse(template);
}

Future<void> createDocumentFile(String location, String title) async {
  File file = new File(location);
  DateTime time = DateTime.now();
  String timestamp =
      "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute}";
  String template =
      '<doc title="$title">\n<meta>\n<version app="v0.01" note="${timestamp}"/>\n</meta>\n<style>\n<background color="#FFFFFF" pattern="grid"/>\n<theme></theme>\n</style>\n<content>\n</content>\n</doc>';
  file.writeAsString(template);
  //openedDocument = XmlDocument.parse(template);
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
    if (openedFileIndex == null) {
      usedFileListPath = await _localPath;
      openedFileIndex = await getLocalFile(
          usedFileListPath + "/index.xml", DocType.indexList);
    }
    await openedFileIndex!.readAsString().then((data) {
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
        newElement += fileExtension;
        print(newElement);
        return newElement;
      }).toList();
    });
  } on Exception catch (e) {
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
      print("Exception: $e");
      continue;
    }
    if (await file.length() != 0) {
      await file.readAsString().then((data) {
        openedItemsDocument = XmlDocument.parse(data);
        for (final node
            in openedItemsDocument.descendants.whereType<XmlText>()) {
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
      });
    }
  }
  return tree;
}
