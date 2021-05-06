import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/globals/colors.dart' as globals;
import 'package:uninote/states/EditorState.dart';

class Palette extends StatefulWidget {
  @override
  State<Palette> createState() => _PaletteState();
}

class _PaletteState extends State<Palette> {
  Color choosedColor = globals.primaryVariantColor;

  void colorSelected(Color itemColor) {}

  @override
  Widget build(BuildContext context) {
    final EditorBloc editorBloc = BlocProvider.of<EditorBloc>(context);
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) => Container(
        padding: EdgeInsets.only(left: 5),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        height: 30,
        decoration: BoxDecoration(
          color: globals.primaryColor,
          border: Border(
            top: BorderSide(color: Colors.black),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.yellow,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.black),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.black,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.black),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.pink,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.black),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.blue,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
