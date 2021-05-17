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
  bool toolBarVisibility = false;
  bool subToolBarVisibility = false;
  Map<String, Color> theme = {
    "backgroundColor": Colors.black,
    "gridColor": Colors.white,
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
    theme = state.theme;
  }
  String toString() {
    return "{mode: $mode, subject: $subject, selectedToolbar: $selectedToolbar, toolbarVisibility: $toolBarVisibility\n";
  }
}
