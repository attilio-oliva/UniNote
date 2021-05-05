import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/components/ImageComponent.dart';
import 'package:uninote/widgets/components/StrokeComponent.dart';
import 'package:uninote/widgets/components/TextComponent.dart';

import 'components/Component.dart';

class Painter extends StatefulWidget {
  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  Offset cursor = Offset(0, 0);
  List<Widget> list = [];
  FocusNode focusNode = FocusNode();
  _PainterState() {
    addComponent(EditorSubject.text, cursor, {"isTitle": true});
  }
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
          cursor,
          defaultMaxWidth,
          topFieldBarHeight,
          content,
          canMove,
          data,
        ));
        list.add(
          BlocProvider<TextComponentBloc>(
            create: (context) => bloc,
            child: TextComponent(
              text: content,
              bloc: bloc,
            ),
          ),
        );
        break;
      case EditorSubject.image:
        content = imageDefaultLocation;
        ComponentBloc bloc = ComponentBloc(
          ComponentState(
            cursor,
            imageDefaultMaxWidth,
            imageDefaultMaxHeight,
            content,
            canMove,
            data,
          ),
        );
        list.add(BlocProvider<ComponentBloc>(
            create: (context) => bloc,
            child: ImageComponent(
              position: cursor,
              location: content,
              bloc: bloc,
            )));
        break;
      case EditorSubject.stroke:
        StrokeComponentBloc bloc = StrokeComponentBloc(
          ComponentState(
            cursor,
            double.infinity,
            double.infinity,
            content,
            canMove,
            data,
          ),
        );
        list.add(BlocProvider<StrokeComponentBloc>(
            create: (context) => bloc,
            child: StrokeComponent(
              bloc: bloc,
            )));
        break;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
  }

  void onDragUpdate(DragUpdateDetails details, EditorState editorState) {
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
    setState(() {});
  }

  void onDragEnd(DragEndDetails details, EditorState editorState) {
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
  }

  void onTapDown(TapDownDetails details, EditorState editorState) {
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
  }

  void onDragStart(DragStartDetails details, EditorState editorState) {
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
  }

  void onTapUp(
      BuildContext context, TapUpDetails details, EditorState editorState) {
    if (!focusNode.hasFocus) {
      bool backgroundClicked = true;
      for (Widget item in list) {
        if (item is BlocProvider<ComponentBloc>) {
          if (item.child is Component) {
            Component component = item.child as Component;
            if (component.hitTest(details.localPosition)) {
              backgroundClicked = false;
              break;
            }
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
  }

  Color getBackgroundColor(BuildContext context, EditorState state) {
    //setState(() {});
    return Colors.pink;
  }

  @override
  Widget build(BuildContext context) {
    final EditorBloc editorBloc = BlocProvider.of<EditorBloc>(context);
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
            color: getBackgroundColor(context, state),
            height: 2000,
            width: 2000,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) =>
                  onTapUp(context, details, state),
              onTapDown: (details) => onTapDown(details, state),
              onPanStart: (details) => onDragStart(details, state),
              onPanUpdate: (details) => onDragUpdate(details, state),
              onPanEnd: (details) => onDragEnd(details, state),
              /*
            onTapUp: (TapUpDetails details) => editorBloc.add(EditorEventData(
                EditorEvent.canvasPressed, details.localPosition)),
            */
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: list,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
