import 'package:flutter/material.dart';
import 'package:uninote/globals/colors.dart' as globalColors;
import 'package:uninote/widgets/EditCanvas.dart';

class Item {
  Item(this.title, this.colorValue);
  String title;
  int colorValue;
}

class CustomList extends StatefulWidget {
  CustomList({Key key, this.items}) : super(key: key);

  final List<Item> items;

  @override
  State<StatefulWidget> createState() => _ReordableState();
}

class _ReordableState extends State<CustomList> {
  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final item = widget.items.removeAt(oldindex);
      widget.items.insert(newindex, item);
    });
  }

  void sorting() {
    setState(() {
      widget.items.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey.shade900,
      ),
      child: ReorderableListView(
        //ListView.builder(
        //  itemCount: 1,
        //  itemBuilder: (BuildContext context, int index) {
        //  return ;
        // },
        //),
        children: <Widget>[
          for (final item in widget.items)
            ListTile(
              key: ValueKey(item.title),
              title: Text(item.title),
              leading: Icon(Icons.book, color: Color(item.colorValue)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EditCanvas())),
            )
        ],
        onReorder: reorderData,
      ),
    );
  }
}
