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
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            //padding: EdgeInsets.all(1.0),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: () {},
            ),
            Spacer(
              flex: 2,
            ),
            TextButton(
              onPressed: () {},
              child: Text('Insert'),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('Text style'),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('Insert'),
            ),
            Spacer(
              flex: 3,
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomPaint(
        painter: NotePainter(),
      ),
      drawer: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 10.0,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Drawer(
            child: ListSelection(title: "Notebook selection"),
          ),
        ),
      ),
    );
  }
}
