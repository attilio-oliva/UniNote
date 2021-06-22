enum EditorTool {
  closing,
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
