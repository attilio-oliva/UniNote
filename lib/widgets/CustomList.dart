import 'package:flutter/material.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/canvas/EditCanvas.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';

class CustomList extends StatefulWidget {
  CustomList({Key key, this.items, this.bloc}) : super(key: key);

  final List<Item> items;
  final ListBloc bloc;
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
        children: <Widget>[
          for (final item in widget.items)
            ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                minLeadingWidth: 0,
                key: ValueKey(item.title),
                title: Text(item.title),
                leading: Icon(
                    (widget.bloc.state.subject == ListSubject.notebook)
                        ? Icons.book
                        : Icons.insert_drive_file_sharp,
                    color: Color(item.colorValue).withOpacity(1)),
                onTap: () => widget.bloc.add(ListEvent.itemSelected)
                //onTap: () => Navigator.push(
                //    context,
                //    MaterialPageRoute(
                //        builder: (BuildContext context) => EditCanvas())),
                )
        ],
        onReorder: reorderData,
      ),
    );
  }
}
