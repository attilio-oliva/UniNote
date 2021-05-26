import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/frames/ListSelection.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/NotePainter.dart';
import 'package:uninote/widgets/Palette.dart';
import 'package:uninote/widgets/ToolBar.dart';
import 'package:uninote/globals/colors.dart' as globals;

import '../parser.dart';

enum AppBarButton {
  insert,
  textStyle,
  view,
}

extension appBarButtonExtension on AppBarButton {
  String get name {
    switch (this) {
      case AppBarButton.insert:
        return 'insert';
      case AppBarButton.textStyle:
        return 'textStyle';
      case AppBarButton.view:
        return 'view';
      default:
        return '';
    }
  }
}

class NoteEditor extends StatefulWidget {
  late ListBloc listBloc;
  NoteEditor([ListBloc? listBloc]) {
    if (listBloc != null) {
      this.listBloc = listBloc;
    } else {
      Tree<Item> tree = pathsToTree(usedFilesPaths());
      listBloc = ListBloc(ListState(), tree);
    }
  }
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  List options = ['Settings1', 'Settings2', 'Settings3'];
  late double maxHeight;
  late double maxWidth;
  late double maxListWidth;
  late double minListWidth;
  late double hideTreshold;
  late double defaultListWidth;
  late double listWidth;
  double listDividerWidth = 10;
  double subToolBarHeight = 30;
  bool isFirstBuild = true;
  bool isListVisible = false;
  bool shouldListBeVisible = false;
  Future<bool> _onWillPop(ListBloc listBloc) async {
    listBloc.add({"key": ListEvent.editorToListSwitch});
    return true;
  }

  void updateSize() {
    setState(() {
      maxHeight =
          MediaQuery.of(context).size.height - AppBar().preferredSize.height;
      maxWidth = MediaQuery.of(context).size.width;
      maxListWidth = maxWidth * 0.60;
      minListWidth = maxWidth * 0.25;
      hideTreshold = minListWidth * 0.4;
      defaultListWidth = maxWidth * 0.45;
      if (isFirstBuild) {
        listWidth = defaultListWidth;
        isFirstBuild = false;
      }
      if (!isListVisible) {
        listWidth = 0;
      }
    });
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (details.globalPosition.dx <= minListWidth) {
      if (details.globalPosition.dx <= hideTreshold) {
        shouldListBeVisible = false;
      }
    } else {
      shouldListBeVisible = true;
      isListVisible = true;
      setState(() {
        if (details.globalPosition.dx >= maxListWidth) {
          listWidth = maxListWidth;
        } else {
          listWidth = details.globalPosition.dx;
        }
      });
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (!shouldListBeVisible) {
      setState(() {
        isListVisible = false;
        listWidth = defaultListWidth;
      });
    }
  }

  List<Widget> getToolBarContent(EditorBloc bloc) {
    EditorToolBar button = bloc.state.selectedToolbar;
    List<Widget> list = List<Widget>.empty(growable: true);
    if (button == EditorToolBar.insert) {
      list.add(
          //Related to issue https://github.com/flutter/flutter/issues/30658
          Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.text_fields),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.textInsert
          }),
        ),
      ));
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.image_sharp),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.imageInsert,
          }),
        ),
      ));
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.format_paint_sharp),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.strokeInsert,
          }),
        ),
      ));
    } else if (button == EditorToolBar.text) {
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.pages_outlined),
          onPressed: () {},
        ),
      ));
    } else if (button == EditorToolBar.view) {
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.palette_outlined),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.backgroundPalette,
          }),
        ),
      ));
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: (bloc.state.mode == EditorMode.readOnly)
              ? Icon(Icons.lock_sharp)
              : Icon(Icons.lock_open),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.lockInsertion,
          }),
        ),
      ));
      list.add(Material(
        color: globals.primaryColor,
        child: IconButton(
          icon: Icon(Icons.grid_on_sharp),
          onPressed: () => bloc.add({
            "key": EditorEvent.toolButtonPressed,
            "type": EditorTool.grid,
          }),
        ),
      ));
    }
    return list;
  }

  List<Widget> getSubToolBarContent(EditorBloc bloc) {
    List<Widget> list = List<Widget>.empty(growable: true);
    if (bloc.state.paletteVisibility) {
      list.add(Palette());
    }
    if (bloc.state.gridModifierVisibility) {
      list.add(
        Container(
          height: subToolBarHeight,
          decoration: BoxDecoration(
            color: globals.primaryColor,
            border: Border(
              right: BorderSide(color: Colors.black),
            ),
          ),
          child: Row(
            children: [
              Container(
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.crop_square_sharp, size: 20),
                  onPressed: () {
                    bloc.add(
                      {
                        "key": EditorEvent.toolButtonPressed,
                        "type": EditorTool.changedGridSize,
                        "data": 40.0,
                      },
                    );
                  },
                ),
              ),
              Container(
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.crop_square_sharp, size: 15),
                  onPressed: () {
                    bloc.add(
                      {
                        "key": EditorEvent.toolButtonPressed,
                        "type": EditorTool.changedGridSize,
                        "data": 25.0,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final EditorBloc editorBloc = BlocProvider.of<EditorBloc>(context);
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    updateSize();
    return BlocConsumer<EditorBloc, EditorState>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leadingWidth: 40,
          elevation: 5,
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  isListVisible = !isListVisible;
                  shouldListBeVisible = isListVisible;
                  listWidth = defaultListWidth;
                });
              },
            );
          }),
          title: Row(
            children: [
              Spacer(),
              Flexible(
                flex: 4,
                child: IconButton(
                  padding: EdgeInsets.only(left: 5),
                  icon: Icon(Icons.undo),
                  onPressed: () {},
                ),
              ),
              Flexible(
                flex: 4,
                child: IconButton(
                  padding: EdgeInsets.only(right: 5),
                  icon: Icon(Icons.redo),
                  onPressed: () {},
                ),
              ),
              Spacer(
                flex: 2,
              ),
              Flexible(
                flex: 7,
                child: TextButton(
                  onPressed: () {
                    editorBloc.add(
                      {
                        "key": EditorEvent.appBarButtonPressed,
                        "data": EditorToolBar.insert,
                      },
                    );
                    //onPressedAppBarButton(AppBarButton.insert);
                  },
                  child: Text('Insert'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: TextButton(
                  onPressed: () {
                    editorBloc.add({
                      "key": EditorEvent.appBarButtonPressed,
                      "data": EditorToolBar.text,
                    });
                    //onPressedAppBarButton(AppBarButton.textStyle);
                  },
                  child: Text('Text style'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: TextButton(
                  onPressed: () {
                    editorBloc.add({
                      "key": EditorEvent.appBarButtonPressed,
                      "data": EditorToolBar.view,
                    });
                    //onPressedAppBarButton(AppBarButton.view);
                  },
                  child: Text('View'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              )
            ],
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return options.map((element) {
                  return PopupMenuItem(
                    child: Text(element),
                    value: element,
                  );
                }).toList();
              },
              /*onSelected: () {
                print(route);

                Navigator.pushNamed(context, route);
              },*/
            ),
          ],
        ),
        body: Column(
          children: [
            Visibility(
              visible: state.toolBarVisibility,
              child: ToolBar(
                children: getToolBarContent(editorBloc),
              ),
            ),
            Visibility(
              visible: state.subToolBarVisibility,
              child: Container(
                decoration: BoxDecoration(
                  color: globals.primaryColor,
                  border: Border(
                    top: BorderSide(color: Colors.black),
                  ),
                ),
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                height: subToolBarHeight,
                child: Row(
                  children: getSubToolBarContent(editorBloc),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Visibility(
                    visible: isListVisible,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(),
                        ),
                      ),
                      width: listWidth,
                      height: maxHeight,
                      child: Row(
                        children: [
                          WillPopScope(
                            onWillPop: () => _onWillPop(listBloc),
                            child: Container(
                              child: BlocProvider<ListBloc>.value(
                                  value: listBloc, child: ListSelection()),
                              width: (listWidth - listDividerWidth),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (details) => onDragUpdate(details),
                            onPanEnd: (details) => onDragEnd(details),
                            child: Container(
                              width: listDividerWidth,
                              height: maxHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: globals.primaryColor,
                                  border: Border(
                                    left: BorderSide(
                                        width: 0, style: BorderStyle.none),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: (maxWidth - listWidth),
                    child: Painter(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
