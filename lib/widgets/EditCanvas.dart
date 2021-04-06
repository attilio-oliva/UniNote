import 'package:flutter/material.dart';
import 'package:uninote/widgets/ListSelection.dart';
import 'package:uninote/widgets/NotePainter.dart';

class EditCanvas extends StatefulWidget {
  EditCanvas({Key key}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditCanvas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
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
      drawer: Container(
        padding: EdgeInsets.only(top: AppBar().preferredSize.height),
        child: Container(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 10.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              child: Drawer(
                child: ListSelection(title: "Notebook selection"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
