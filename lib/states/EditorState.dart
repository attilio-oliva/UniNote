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
  EditorMode mode;
  EditorSubject subject;
  EditorToolBar selectedToolbar;
  bool toolBarVisibility;
  EditorState(this.mode, this.subject,
      [this.selectedToolbar = EditorToolBar.text,
      this.toolBarVisibility = false]);
  EditorState.from(EditorState state) {
    mode = state.mode;
    subject = state.subject;
    selectedToolbar = state.selectedToolbar;
    toolBarVisibility = state.toolBarVisibility;
  }
  String toString() {
    print(
        "{Mode: $mode, Subject: $subject, SelectedToolbar: $selectedToolbar, toolbarVisibility: $toolBarVisibility\n");
  }
}
