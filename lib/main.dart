import 'package:flutter/material.dart';
import 'widgets/ListSelection.dart';
import 'widgets/EditCanvas.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color primaryColor = Color(0xff2b2b2b);
  final Color primaryVariantColor = Colors.black;
  final Color secondaryColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNote',
      theme: ThemeData(
        primaryColor: primaryColor,
        accentColor: Colors.pink,
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: secondaryColor)),
        iconTheme: IconThemeData(color: secondaryColor),
        bottomAppBarColor: primaryColor,
        scaffoldBackgroundColor: primaryVariantColor,
        textTheme: Typography.whiteMountainView,
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: secondaryColor,
          ),
          actionsIconTheme: IconThemeData(color: secondaryColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      //home: ListSelection(title: 'Select notebook'),
      home: EditCanvas(),
    );
  }
}
