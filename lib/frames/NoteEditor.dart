import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/frames/ListSelection.dart';
import 'package:uninote/globals/colors.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/NotePainter.dart';
import 'package:uninote/widgets/ToolBar.dart';

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
        return null;
    }
  }
}

class NoteEditor extends StatefulWidget {
  NoteEditor({Key key}) : super(key: key);
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  AppBarButton lastPressedButton = null;
  List options = ['Settings1', 'Settings2', 'Settings3', 'marco', 'melorio'];
  double maxHeight;
  double maxWidth;
  double maxListWidth;
  double minListWidth;
  double hideTreshold;
  double defaultListWidth;
  double listWidth;
  double listDividerWidth = 10;
  bool isFirstBuild = true;
  bool isListVisible = false;
  bool shouldListBeVisible = false;
  bool isToolBarVisible = false;

  /*final GlobalKey _appBarKey = GlobalKey();
  Size appBarSize;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  Future<void> getSizeAndPosition() async {
    setState(() {
      RenderBox _appBarBox = _appBarKey.currentContext.findRenderObject();
      appBarSize = _appBarBox.size;
    });
  }*/
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

  void onPressedAppBarButton(AppBarButton button) {
    if (button == lastPressedButton) {
      isToolBarVisible = !isToolBarVisible;
    } else if (lastPressedButton == null) {
      lastPressedButton = button;
      isToolBarVisible = !isToolBarVisible;
    } else if (isToolBarVisible == false && lastPressedButton != button) {
      isToolBarVisible = !isToolBarVisible;
      lastPressedButton = button;
    } else {
      lastPressedButton = button;
    }
    setState(() {});
  }

  List<Widget> getToolBarContent(AppBarButton button) {
    List<Widget> list = List<Widget>.empty(growable: true);
    if (button == AppBarButton.insert) {
      list.add(IconButton(
        icon: Icon(Icons.text_fields),
        onPressed: () {},
      ));
    } else if (button == AppBarButton.textStyle) {
      list.add(IconButton(
        icon: Icon(Icons.pages_outlined),
        onPressed: () {},
      ));
    } else if (button == AppBarButton.view) {
      list.add(IconButton(
        icon: Icon(Icons.coronavirus_outlined),
        onPressed: () {},
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    updateSize();
    return Scaffold(
      appBar: AppBar(
        //key: _appBarKey,
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
                  onPressedAppBarButton(AppBarButton.insert);
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
                  onPressedAppBarButton(AppBarButton.textStyle);
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
                  onPressedAppBarButton(AppBarButton.view);
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
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return options.map((element) {
              return PopupMenuItem(
                child: Text(element),
                value: element,
              );
            }).toList();
          }
              /*onSelected: () {
              print(route);

              Navigator.pushNamed(context, route);
            },*/
              ),
        ],
      ),
      body: Row(children: [
        Visibility(
          visible: isListVisible,
          child: Container(
            width: listWidth,
            height: maxHeight,
            child: Row(
              children: [
                Container(
                  child: BlocProvider<ListBloc>(
                      create: (context) => ListBloc(ListState()),
                      child: ListSelection()),
                  width: (listWidth - listDividerWidth),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) => onDragUpdate(details),
                  onPanEnd: (details) => onDragEnd(details),
                  child: SizedBox(
                    width: listDividerWidth,
                    height: maxHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
          child: Column(
            children: [
              Visibility(
                visible: isToolBarVisible,
                child: ToolBar(
                  children: getToolBarContent(lastPressedButton),
                ),
              ),
              Expanded(
                child: Painter(),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
