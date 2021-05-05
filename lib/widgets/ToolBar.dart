import 'package:flutter/material.dart';
import 'package:uninote/globals/colors.dart';

class ToolBar extends StatefulWidget {
  final List<Widget> children;
  ToolBar({this.children = const <Widget>[]});
  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  _ToolBarState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
          left: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      height: 40,
      child: Row(
        children: widget.children,
      ),
    );
  }
}
