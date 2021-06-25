import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:uninote/globals/colors.dart' as globalColors;
import 'package:uninote/iomanager.dart';
import 'package:uninote/states/ListState.dart';

import 'bloc/ListBloc.dart';
import 'frames/ListSelection.dart';
import 'globals/types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
      print(statuses[
          Permission.storage]); // it should print PermissionStatus.granted
    }
  }
  runApp(MyApp(await pathsToTree(await usedFilesPaths())));
}

class MyApp extends StatelessWidget {
  final Tree<Item> fileTree;
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
      /*
      home: BlocProvider<EditorBloc>(
        create: (context) => EditorBloc(
          EditorState(
            mode: EditorMode.insertion,
            subject: EditorSubject.text,
          ),
        ),
        child: NoteEditor(),
      ),
      */
      home: BlocProvider<ListBloc>(
        create: (context) => ListBloc(ListState(), fileTree),
        child: ListSelection(title: 'notebook'),
      ),
    );
  }
}
