import 'package:flutter/material.dart';
import 'widgets/ListSelection.dart';
import 'widgets/EditCanvas.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNote',
      //theme: ThemeData.dark(),
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000)),
      debugShowCheckedModeBanner: false,
      //home: ListSelection(title: 'Select notebook'),
      home: SizedBox(
        width: 10,
        child: EditCanvas(),
      ),
    );
  }
}
