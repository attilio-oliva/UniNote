import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/components/ImageComponent.dart';
import 'package:uninote/widgets/components/StrokeComponent.dart';
import 'package:uninote/widgets/components/TextComponent.dart';
import 'package:uninote/widgets/CustomGrid.dart';

import 'components/Component.dart';

class Painter extends StatefulWidget {
  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  Color backgroundColor = Colors.pink;
  Offset cursor = Offset(0, 0);
  List<Widget> list = [];
  FocusNode focusNode = FocusNode();
  _PainterState() {
    //addComponent(EditorSubject.text, cursor, {"isTitle": true});
  }
  /*
  void addComponent(EditorSubject subject, Offset pos,
      [Map<String, dynamic> data = const {}]) {
    bool canMove = true;
    if (data.containsKey("isTitle")) {
      canMove = !data["isTitle"]!;
    }
    String content = "";
    switch (subject) {
      case EditorSubject.text:
        TextComponentBloc bloc = TextComponentBloc(ComponentState(
          pos,
          defaultMaxWidth,
          topFieldBarHeight,
          content,
          canMove,
          data,
        ));
        list.add(
          TextComponent(
            text: content,
            bloc: bloc,
          ),
        );
        break;
      case EditorSubject.image:
        content = imageDefaultLocation;
        ComponentBloc bloc = ComponentBloc(
          ComponentState(
            pos,
            imageDefaultMaxWidth,
            imageDefaultMaxHeight,
            content,
            canMove,
            data,
          ),
        );
        list.add(
          ImageComponent(
            position: pos,
            location: content,
            bloc: bloc,
          ),
        );
        break;
      case EditorSubject.stroke:
        StrokeComponentBloc bloc = StrokeComponentBloc(
          ComponentState(
            pos,
            double.infinity,
            double.infinity,
            content,
            canMove,
            data,
          ),
        );
        list.add(
          StrokeComponent(
            bloc: bloc,
          ),
        );
        break;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
  }
*/
  void onDragUpdate(DragUpdateDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.update,
      "position": details.localPosition
    });
    /*
    EditorState editorState = editorBloc.state;
    switch (editorState.mode) {
      case EditorMode.selection:
        // TODO: Handle this case.
        break;
      case EditorMode.insertion:
        if (editorState.subject == EditorSubject.stroke) {
          StrokeComponentBloc.editingBloc?.add({
            "key": ComponentEvent.contentChanged,
            "isEditing": true,
            "newPoint": details.localPosition,
          });
        }
        break;
      case EditorMode.readOnly:
        // TODO: Handle this case.
        break;
        
    }
    */
    //setState(() {});
  }

  void onDragEnd(DragEndDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.end,
      "position": Offset(0, 0)
    });
    /*
    EditorState editorState = editorBloc.state;
    switch (editorState.mode) {
      case EditorMode.selection:
        // TODO: Handle this case.
        break;
      case EditorMode.insertion:
        StrokeComponentBloc.editingBloc?.add({
          "key": ComponentEvent.contentChanged,
          "isEditing": false,
        });
        break;
      case EditorMode.readOnly:
        // TODO: Handle this case.
        break;
    }
    */
  }

  void onTapDown(
      TapDownDetails details, EditorState editorState, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.tap,
      "inputState": InputState.start,
      "position": details.localPosition
    });
    /*
    cursor = details.localPosition;
    switch (editorState.mode) {
      case EditorMode.selection:
        // TODO: Handle this case.
        break;
      case EditorMode.insertion:
        if (editorState.subject == EditorSubject.stroke) {
          addComponent(EditorSubject.stroke, cursor, {
            "isEditing": true,
            "points": [cursor]
          });
        }
        StrokeComponentBloc.editingBloc?.add({
          "key": ComponentEvent.contentChanged,
          "isEditing": false,
        });
        break;
      case EditorMode.readOnly:
        // TODO: Handle this case.
        break;
    }
    setState(() {});
    */
  }

  void onDragStart(DragStartDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.drag,
      "inputState": InputState.start,
      "position": details.localPosition
    });
    /*
    EditorState editorState = editorBloc.state;
    cursor = details.localPosition;
    switch (editorState.mode) {
      case EditorMode.selection:
        // TODO: Handle this case.
        break;
      case EditorMode.insertion:
        if (editorState.subject == EditorSubject.stroke) {
          addComponent(EditorSubject.stroke, cursor, {
            "isEditing": true,
            "points": [cursor]
          });
        }
        break;
      case EditorMode.readOnly:
        // TODO: Handle this case.
        break;
    }
    */
  }

  void onTapUp(
      BuildContext context, TapUpDetails details, EditorBloc editorBloc) {
    editorBloc.add({
      "key": EditorEvent.canvasPressed,
      "inputType": InputType.tap,
      "inputState": InputState.end,
      "position": details.localPosition
    });
    /*
    EditorState editorState = editorBloc.state;
    if (!focusNode.hasFocus) {
      bool backgroundClicked = true;
      for (Widget item in list) {
        if (item is Component) {
          Component component = item as Component;
          if (component.hitTest(details.localPosition)) {
            backgroundClicked = false;
            break;
          }
        }
      }
      if (backgroundClicked) {
        setState(() {
          FocusScope.of(context).requestFocus(focusNode);
        });
      }
    } else {
      setState(() {
        focusNode.unfocus();
        cursor = details.localPosition;
        switch (editorState.mode) {
          case EditorMode.selection:
            // TODO: Handle this case.
            break;
          case EditorMode.insertion:
            addComponent(editorState.subject, cursor);
            break;
          case EditorMode.readOnly:
            // TODO: Handle this case.
            break;
        }
      });
    }
    */
  }

  List<Widget> background(List<Widget> list, EditorState state) {
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
              onTapDown: (details) => onTapDown(details, state, editorBloc),
              onPanStart: (details) => onDragStart(details, editorBloc),
              onPanUpdate: (details) => onDragUpdate(details, editorBloc),
              onPanEnd: (details) => onDragEnd(details, editorBloc),
              /*
              onTapUp: (TapUpDetails details) => editorBloc.add(EditorEventData(
                  EditorEvent.canvasPressed, details.localPosition)),
              */
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: background(list, state),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
