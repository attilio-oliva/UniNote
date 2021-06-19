import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/globals/EditorTool.dart';

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
  String noteLocation = "";
  EditorMode mode = EditorMode.insertion;
  EditorSubject subject = EditorSubject.text;
  EditorToolBar selectedToolbar = EditorToolBar.text;
  List<Widget> componentList = [];
  List<Widget> selectedComponents = [];
  bool toolBarVisibility = false;
  bool subToolBarVisibility = false;
  bool paletteVisibility = false;
  bool gridModifierVisibility = false;
  EditorTool? lastPressedTool;
  Map<String, dynamic> theme = {
    "backgroundColor": Colors.black,
    "gridColor": Colors.blue.shade800,
    "gridSize": 25.0,
  };
  EditorState({
    this.noteLocation = "",
    this.mode = EditorMode.insertion,
    this.subject = EditorSubject.text,
    this.selectedToolbar = EditorToolBar.text,
    this.toolBarVisibility = false,
    this.subToolBarVisibility = false,
    this.paletteVisibility = false,
    this.gridModifierVisibility = false,
    this.lastPressedTool = EditorTool.closing,
    List<Widget>? componentList,
    List<Widget>? selectedComponents,
  }) {
    this.componentList = componentList ?? [];
    this.selectedComponents = selectedComponents ?? [];
  }
  EditorState.from(EditorState state) {
    noteLocation = state.noteLocation;
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
    lastPressedTool = state.lastPressedTool;
  }
  EditorState copyWith(
    String? noteLocation,
    EditorMode? mode,
    EditorSubject? subject,
    EditorToolBar? selectedToolbar,
    List<Widget>? componentList,
    List<Widget>? selectedComponents,
    bool? toolBarVisibility,
    bool? subToolBarVisibility,
    bool? paletteVisibility,
    bool? gridModifierVisibility,
  ) {
    return EditorState(
      noteLocation: noteLocation ?? this.noteLocation,
      mode: mode ?? this.mode,
      subject: subject ?? this.subject,
      selectedToolbar: selectedToolbar ?? this.selectedToolbar,
      componentList: componentList ?? this.componentList,
      selectedComponents: selectedComponents ?? this.selectedComponents,
      toolBarVisibility: toolBarVisibility ?? this.toolBarVisibility,
      subToolBarVisibility: subToolBarVisibility ?? this.subToolBarVisibility,
      paletteVisibility: paletteVisibility ?? this.paletteVisibility,
      gridModifierVisibility:
          gridModifierVisibility ?? this.gridModifierVisibility,
    );
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
