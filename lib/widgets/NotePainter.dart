import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
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
      canMove = !data["isTitle"] ?? true;
    }
    String content = "";
    switch (subject) {
      case EditorSubject.text:
        list.add(BlocProvider<TextComponentBloc>(
            create: (context) => TextComponentBloc(
                  ComponentState(
                    cursor,
                    defaultMaxWidth,
                    topFieldBarHeight,
                    content,
                    canMove,
                    data,
                  ),
                ),
            child: TextComponent(position: pos, text: content)));
        break;
      case EditorSubject.image:
        // TODO: Handle this case.
        break;
      case EditorSubject.stroke:
        // TODO: Handle this case.
        break;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
  }

  void onTapUp(
      BuildContext context, TapUpDetails details, EditorState editorState) {
    if (!focusNode.hasFocus) {
      bool backgroundClicked = true;
      for (BlocProvider<TextComponentBloc> item in list) {
        if (item.child is Component) {
          Component component = item.child as Component;
          if (component.bloc.hitTest(details.localPosition)) {
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
            height: 2000,
            width: 2000,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) =>
                  onTapUp(context, details, state),
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
