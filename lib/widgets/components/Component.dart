import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

abstract class Component {
  bool hitTest(Offset point);
  String parse();
}
/*
class ComponentWidget extends StatelessWidget {
  static const double defaultMinWidth = 20;
  static const double defaultMinHeight = 20;
  static const double defaultMaxWidth = double.maxFinite;
  static const double defaultMaxHeight = double.maxFinite;
  static const double defaultWidth = 200;
  static const double defaultHeight = 200;
  static const Offset defaultPosition = Offset(0, 0);
  Widget child;
  EditorBloc editorBloc;
  ComponentBloc componentBloc;
  Offset position;
  bool isSelected;
  bool isEditable;
  bool horizontalOnlyResizable;
  double minWidth;
  double minHeight = 20;
  double maxWidth = double.maxFinite;
  double maxHeight = double.maxFinite;
  double width = 200;
  double height = 200;

  ComponentWidget({
    required this.child,
    required this.editorBloc,
    required this.componentBloc,
    this.isSelected = true,
    this.isEditable = true,
    this.horizontalOnlyResizable = false,
    this.position = defaultPosition,
    this.minWidth = defaultMinWidth,
    this.minHeight = defaultMinHeight,
    this.maxWidth = defaultMaxWidth,
    this.maxHeight = defaultMaxHeight,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      bloc: editorBloc,
      builder: (context, state) => Visibility(
        visible: state.selectedComponents.contains(child),
        child: ResizableWidget(
          child: child,
          bloc: componentBloc,
        ),
      ),
    );
  }
}
*/
