import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/ResizableWidget.dart';

abstract class Component {
  late ComponentBloc bloc;

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
  final Widget child;
  final ComponentBloc bloc;
  final Offset position;
  final bool isSelected;
  final bool isEditable;
  final bool horizontalOnlyResizable;
  double minWidth = 20;
  double minHeight = 20;
  double maxWidth = double.maxFinite;
  double maxHeight = double.maxFinite;
  double padding = 0;

  ComponentWidget(
      {required this.child,
      required this.bloc,
      this.isSelected = true,
      this.isEditable = true,
      this.horizontalOnlyResizable = false,
      this.position = defaultPosition,
      this.minWidth = defaultMinWidth,
      this.minHeight = defaultMinHeight,
      this.maxWidth = defaultMaxWidth,
      this.maxHeight = defaultMaxHeight,
      this.padding = 0});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComponentBloc, ComponentState>(
      listener: (context, state) => print(state.isSelected),
      bloc: bloc,
      builder: (context, state) => Visibility(
        visible: state.isSelected,
        child: ResizableWidget(
          child: child,
          bloc: bloc,
          width: state.width + padding,
          height: state.height + padding,
        ),
        replacement: child,
      ),
    );
  }
}
*/
