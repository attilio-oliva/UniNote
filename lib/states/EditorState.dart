import 'package:flutter/material.dart';

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
  List<Widget> selectedComponents = [];
  bool toolBarVisibility = false;
  bool subToolBarVisibility = false;
  Color backgroundColor = Colors.black;
  EditorState(this.mode, this.subject,
      [this.selectedToolbar = EditorToolBar.text,
      this.toolBarVisibility = false]);
  EditorState.from(EditorState state) {
    mode = state.mode;
    subject = state.subject;
    selectedToolbar = state.selectedToolbar;
    toolBarVisibility = state.toolBarVisibility;
    subToolBarVisibility = state.subToolBarVisibility;
    backgroundColor = state.backgroundColor;
    selectedComponents = state.selectedComponents;
  }
  String toString() {
    return "{mode: $mode, subject: $subject, selectedToolbar: $selectedToolbar, toolbarVisibility: $toolBarVisibility\n";
  }
}
