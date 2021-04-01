import 'package:flutter/material.dart';
import 'widgets/ListSelection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNote',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: ListSelection(title: 'Select notebook'),
    );
  }
}
