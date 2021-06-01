import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';

enum EditorMode {
  selection,
  insertion,
  readOnly,
}

enum EditorSubject {
  text,
  image,
  stroke,
  attachment,
}
enum EditorToolBar {
  text,
  insert,
  view,
}

class EditorState {
  EditorMode mode = EditorMode.insertion;
  EditorSubject subject = EditorSubject.text;
  EditorToolBar selectedToolbar = EditorToolBar.text;
  List<Widget> componentList = [];
  List<Widget> selectedComponents = [];
  bool toolBarVisibility = false;
  bool subToolBarVisibility = false;
  bool paletteVisibility = false;
  bool gridModifierVisibility = false;
  Map<String, dynamic> theme = {
    "backgroundColor": Colors.black,
    "gridColor": Colors.blue,
    "gridSize": 25.0,
  };
  EditorState(this.mode, this.subject,
      [this.selectedToolbar = EditorToolBar.text,
      this.toolBarVisibility = false]);
  EditorState.from(EditorState state) {
    mode = state.mode;
    subject = state.subject;
    selectedToolbar = state.selectedToolbar;
    toolBarVisibility = state.toolBarVisibility;
    subToolBarVisibility = state.subToolBarVisibility;
    paletteVisibility = state.paletteVisibility;
    gridModifierVisibility = state.gridModifierVisibility;
    theme = state.theme;
    componentList = state.componentList;
    selectedComponents = state.selectedComponents;
  }

  String toString() {
    String result = "{\n";
    result += "\tmode: $mode,\n";
    result += "\tsubject: $subject,\n";
    result += "\tselectedToolbar: $selectedToolbar,\n";
    result += "\ttoolbarVisibility: $toolBarVisibility,\n";
    result += "\tcomponentList: ${componentList},\n";
    result += "\tselectedComponents: ${selectedComponents},\n";
    result += "}\n";
    return result;
  }
}
