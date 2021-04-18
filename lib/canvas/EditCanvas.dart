import 'package:flutter/material.dart';
import 'package:uninote/canvas/ListSelection.dart';
import 'package:uninote/widgets/NotePainter.dart';

class EditCanvas extends StatefulWidget {
  EditCanvas({Key key}) : super(key: key);
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditCanvas> {
  List _options = ['Settings1', 'Settings2', 'Settings3'];
  double maxHeight;
  double maxWidth;
  double maxListWidth;
  double minListWidth;
  double defaultListWidth;
  double listWidth;
  double listDividerWidth = 10;
  bool isFirstBuild = true;
  bool isListVisible = false;
  bool shouldListBeVisible = false;
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
      shouldListBeVisible = false;
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
                onPressed: () {},
                child: Text('Insert'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: TextButton(
                onPressed: () {},
                child: Text('Text style'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: TextButton(
                onPressed: () {},
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
            itemBuilder: (BuildContext bc) => [
              PopupMenuItem(child: Text("Settings1"), value: "/settings1"),
              PopupMenuItem(child: Text("Settings2"), value: "/settings2"),
              PopupMenuItem(child: Text("Settings3"), value: "/settings3"),
            ],
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
                  child: ListSelection(title: "Notebook selection"),
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
          child: Painter(),
        ),
      ]),
    );
  }
}
