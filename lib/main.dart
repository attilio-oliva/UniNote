import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uninote/parser.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/states/ListState.dart';
import 'package:xml/xml.dart';
import 'bloc/EditorBloc.dart';
import 'bloc/ListBloc.dart';
import 'frames/ListSelection.dart';
import 'package:uninote/globals/colors.dart' as globalColors;

import 'frames/NoteEditor.dart';
import 'globals/types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  print(appDocPath);
  runApp(MyApp(pathsToTree(usedFilesPaths())));
}

class MyApp extends StatelessWidget {
  Tree<Item> fileTree;
  MyApp(this.fileTree);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNote',
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          color: globalColors.primaryColor,
        ),
        primaryColor: globalColors.primaryColor,
        accentColor: Colors.amber.shade800,
        //highlightColor: Colors.pink,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.pinkAccent.shade400,
          cursorColor: Colors.white,
          //selectionColor: Colors.orange.shade800,
          //selectionColor: Colors.grey.shade700,
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: globalColors.secondaryColor)),
        iconTheme: IconThemeData(color: globalColors.secondaryColor),
        bottomAppBarTheme: BottomAppBarTheme(
            color: globalColors.primaryColor,
            elevation: 0,
            shape: const CircularNotchedRectangle()),
        scaffoldBackgroundColor: globalColors.primaryVariantColor,
        textTheme: Typography.whiteMountainView,
        appBarTheme: AppBarTheme(
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: globalColors.secondaryColor,
          ),
          actionsIconTheme: IconThemeData(color: globalColors.secondaryColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      //home: BlocProvider<EditorBloc>(
      //  create: (context) => EditorBloc(
      //    EditorState(
      //      EditorMode.insertion,
      //      EditorSubject.text,
      //    ),
      //  ),
      //  child: NoteEditor(),
      //),
      home: BlocProvider<ListBloc>(
        create: (context) => ListBloc(ListState(), fileTree),
        child: ListSelection(title: 'notebook'),
      ),
    );
  }
}
