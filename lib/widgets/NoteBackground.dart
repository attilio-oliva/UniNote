import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/CustomGrid.dart';

class Painter extends StatefulWidget {
  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  Color backgroundColor = Colors.pink;
  Offset cursor = Offset(0, 0);
  List<Widget> list = [];
  FocusNode focusNode = FocusNode();

  void onDragUpdate(DragUpdateDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.update,
      "position": details.localPosition
    });
  }

  void onDragEnd(DragEndDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.end,
      "position": Offset(0, 0)
    });
  }

  void onTapDown(TapDownDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.tap,
      "inputState": InputState.start,
      "position": details.localPosition
    });
  }

  void onDragStart(DragStartDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.start,
      "position": details.localPosition
    });
  }

  void onTapUp(
      BuildContext context, TapUpDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.tap,
      "inputState": InputState.end,
      "position": details.localPosition
    });
  }

  List<Widget> getBackgroundWidgets(List<Widget> list, EditorState state) {
    List<Widget> result = List<Widget>.from(list);
    result.insert(
      0,
      CustomGrid(
        color: state.theme["gridColor"] ?? Colors.white,
        interval: state.theme["gridSize"],
        divisions: 1,
        subdivisions: 1,
        child: Container(
          height: 2000,
          width: 2000,
        ),
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final EditorBloc editorBloc = BlocProvider.of<EditorBloc>(context);
    list = editorBloc.state.componentList;
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) => SingleChildScrollView(
        physics: editorBloc.state.mode == EditorMode.readOnly
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        child: SingleChildScrollView(
          physics: editorBloc.state.mode == EditorMode.readOnly
              ? AlwaysScrollableScrollPhysics()
              : NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Container(
            color: state.theme["backgroundColor"] ?? Colors.black,
            height: 2000,
            width: 2000,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) =>
                  onTapUp(context, details, editorBloc),
              onTapDown: (details) => onTapDown(details, editorBloc),
              onPanStart: (details) => onDragStart(details, editorBloc),
              onPanUpdate: (details) => onDragUpdate(details, editorBloc),
              onPanEnd: (details) => onDragEnd(details, editorBloc),
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: getBackgroundWidgets(list, state),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
