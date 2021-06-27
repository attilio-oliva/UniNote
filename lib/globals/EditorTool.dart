enum EditorTool {
  closing,
  selectionMode,
  textInsert,
  textSize,
  textColor,
  imageInsert,
  strokeInsert,
  lockInsertion,
  backgroundPalette,
  grid,
  changedColor,
  changedGridSize,
  markdown,
  latex,
  plainText
}

extension editorToolExtension on EditorTool {
  bool get isSubTool {
    switch (this) {
      case EditorTool.changedColor:
      case EditorTool.changedGridSize:
        return true;
      default:
        return false;
    }
  }
}
