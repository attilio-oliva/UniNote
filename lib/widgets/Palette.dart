import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/globals/colors.dart' as globals;
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/globals/EditorTool.dart';

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
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        width: 140,
        height: 30,
        decoration: BoxDecoration(
          color: globals.primaryColor,
          border: Border(
            right: BorderSide(color: Colors.black),
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
                    "data": Colors.amber,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      (state.lastPressedTool == EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] == Colors.amber)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.amber)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: (state.lastPressedTool ==
                            EditorTool.backgroundPalette)
                        ? (state.theme["backgroundColor"] == Colors.amber)
                            ? Border.all(width: 2, color: globals.primaryColor)
                            : Border.all(width: 0)
                        : (state.theme["gridColor"] == Colors.amber)
                            ? Border.all(width: 2, color: globals.primaryColor)
                            : Border.all(width: 0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
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
                  shape: BoxShape.circle,
                  border:
                      (state.lastPressedTool == EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] == Colors.black)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.black)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: (state.lastPressedTool ==
                              EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] == Colors.black)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.black)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)),
                ),
              ),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.pink.shade900,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: (state.lastPressedTool ==
                          EditorTool.backgroundPalette)
                      ? (state.theme["backgroundColor"] == Colors.pink.shade900)
                          ? Border.all(width: 2, color: Colors.white)
                          : Border.all(width: 0)
                      : (state.theme["gridColor"] == Colors.pink.shade900)
                          ? Border.all(width: 2, color: Colors.white)
                          : Border.all(width: 0),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.pink.shade900,
                      shape: BoxShape.circle,
                      border: (state.lastPressedTool ==
                              EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] ==
                                  Colors.pink.shade900)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.pink.shade900)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)),
                ),
              ),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.blue.shade800,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: (state.lastPressedTool ==
                          EditorTool.backgroundPalette)
                      ? (state.theme["backgroundColor"] == Colors.blue.shade800)
                          ? Border.all(width: 2, color: Colors.white)
                          : Border.all(width: 0)
                      : (state.theme["gridColor"] == Colors.blue.shade800)
                          ? Border.all(width: 2, color: Colors.white)
                          : Border.all(width: 0),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      shape: BoxShape.circle,
                      border: (state.lastPressedTool ==
                              EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] ==
                                  Colors.blue.shade800)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.blue.shade800)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)),
                ),
              ),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                editorBloc.add(
                  {
                    "key": EditorEvent.toolButtonPressed,
                    "type": EditorTool.changedColor,
                    "data": Colors.grey,
                  },
                );
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      (state.lastPressedTool == EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] == Colors.grey)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.grey)
                              ? Border.all(width: 2, color: Colors.white)
                              : Border.all(width: 0),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      border: (state.lastPressedTool ==
                              EditorTool.backgroundPalette)
                          ? (state.theme["backgroundColor"] == Colors.grey)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)
                          : (state.theme["gridColor"] == Colors.grey)
                              ? Border.all(
                                  width: 2, color: globals.primaryColor)
                              : Border.all(width: 0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
