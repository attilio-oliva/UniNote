import 'package:flutter/material.dart';
import 'package:uninote/bloc/ListBloc.dart';
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

  IconData getIconData(ListSubject subject) {
    switch (subject) {
      case ListSubject.notebook:
        return Icons.book;
      case ListSubject.note:
        return Icons.insert_drive_file_sharp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey.shade900,
      ),
      child: ReorderableListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            minLeadingWidth: 0,
            key: ValueKey(widget.items[index].title),
            title: Text(widget.items[index].title),
            leading: Icon(getIconData(widget.bloc.state.subject),
                color: Color(widget.items[index].colorValue).withOpacity(1)),
            onTap: () => widget.bloc.add(ListEventData(
                ListEvent.itemSelected, widget.items[index].title)),
          );
        },
        onReorder: reorderData,
      ),
    );
  }
}
