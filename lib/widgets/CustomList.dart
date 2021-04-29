import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';

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

  IconData getIconData(ListSubject subject) {
    switch (subject) {
      case ListSubject.notebook:
        return Icons.book;
      case ListSubject.section:
        return Icons.insert_drive_file_sharp;
      case ListSubject.note:
        return null;
    }
  }

  bool isEditing(int editingIndex, int index) {
    if (editingIndex != null) {
      if (index == editingIndex) {
        return true;
      }
    }
    return false;
  }

  FocusNode getAutoFocusNode(BuildContext context, ListState state) {
    FocusNode focusNode = FocusNode();
    if (state.editingIndex != null) {
      if (!focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(focusNode);
      }
    }
    return focusNode;
  }

  @override
  Widget build(BuildContext context) {
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    return BlocBuilder<ListBloc, ListState>(
      builder: (context, state) => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey.shade900,
        ),
        child: ReorderableListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(0, 0, 8, 0),
              minLeadingWidth: 0,
              key: ValueKey(widget.items[index].key),
              title: Visibility(
                visible: !isEditing(state.editingIndex, index),
                replacement: Container(
                  height: 40,
                  child: TextField(
                    focusNode: getAutoFocusNode(context, state),
                    onSubmitted: (value) {
                      listBloc.add({
                        'key': ListEvent.editRequested,
                        'index': index,
                        'data': value
                      });
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
                child: Text(widget.items[index].title),
              ),
              leading: Visibility(
                visible: state.subject != ListSubject.section,
                replacement: Container(
                  padding: EdgeInsets.all(0),
                  width: 10,
                  height: 48,
                  decoration: BoxDecoration(
                      color:
                          Color(widget.items[index].colorValue).withOpacity(1)),
                ),
                child: Icon(
                  getIconData(state.subject),
                  color: Color(widget.items[index].colorValue).withOpacity(1),
                ),
              ),
              onTap: () => listBloc.add({
                'key': ListEvent.itemSelected,
                'data': widget.items[index].title
              }),
            );
          },
          onReorder: reorderData,
        ),
      ),
    );
  }
}
