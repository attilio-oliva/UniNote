import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uninote/widgets/ListSelection.dart';
import 'package:uninote/widgets/NotePainter.dart';

class EditCanvas extends StatefulWidget {
  EditCanvas({Key key}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditCanvas> {
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

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        //key: _appBarKey,
        titleSpacing: 0,
        leadingWidth: 40,
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        child: CustomPaint(
          painter: NotePainter(),
        ),
      ),
      drawer: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: AppBar().preferredSize.height),
          child: Container(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1.0,
                      color: Colors.grey.shade900,
                    ),
                    right: BorderSide(
                      width: 10.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                child: ListSelection(title: "Notebook selection"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
