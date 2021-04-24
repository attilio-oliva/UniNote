enum EditorMode {
  Selection,
  Insertion,
  Reading,
}

enum EditorSubject {
  Text,
  Image,
  Stroke,
  Attachment,
}
enum EditorToolBar {
  Text,
  Insert,
  View,
}

class EditorState {
  EditorMode mode;
  EditorSubject subject = EditorSubject.Text;
  EditorToolBar selectedToolbar = EditorToolBar.Text;
  bool toolbarVisibility = false;
  EditorState(this.mode, this.subject,
      [this.selectedToolbar, this.toolbarVisibility]);
  EditorState.from(EditorState state) {
    EditorState(
      state.mode,
      state.subject,
      state.selectedToolbar,
      state.toolbarVisibility,
    );
  }
}
