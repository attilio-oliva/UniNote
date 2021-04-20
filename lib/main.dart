import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/states/ListState.dart';
import 'bloc/ListBloc.dart';
import 'frames/ListSelection.dart';
import 'package:uninote/globals/colors.dart' as globalColors;

import 'globals/types.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Item> openedNotebooks = [
    Item("University", 0xffe040fb),
    Item("Work", 0xff448aff),
    Item("Memos", 0xffeeff41),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNote',
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          color: globalColors.primaryColor,
        ),
        primaryColor: globalColors.primaryColor,
        accentColor: Colors.pink,
        highlightColor: Colors.pink,
        textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.pink),
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
      home: BlocProvider<ListBloc>(
        create: (context) => ListBloc(ListState.fromList(openedNotebooks)),
        child: ListSelection(title: 'notebook'),
      ),
      //home: EditCanvas(),
    );
  }
}
