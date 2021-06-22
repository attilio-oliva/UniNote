import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/globals/types.dart';
import 'package:uninote/states/ListState.dart';

class CustomList extends StatefulWidget {
  final List<Node<Item>> items;
  CustomList(this.items);
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

  IconData? getIconData(ListSubject subject, Node<Item> nodeItem) {
    switch (subject) {
      case ListSubject.notebook:
        return Icons.book;
      case ListSubject.section:
        return Icons.insert_drive_file_sharp;
      case ListSubject.note:
        if (nodeItem.value!.isGroup) {
          return Icons.folder;
        }
        if (ListSubject.note.depth + 1 == nodeItem.degree) {
          return Icons.subdirectory_arrow_right;
        } else {
          return null;
        }
      default:
        return null;
    }
  }

  bool isEditing(int? editingIndex, int index) {
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
              key: ValueKey(widget.items[index].value!.key),
              title: Visibility(
                visible: !isEditing(state.editingIndex, index),
                replacement: Container(
                  height: 40,
                  child: RawKeyboardListener(
                    focusNode: getAutoFocusNode(context, state),
                    onKey: (event) {
                      if (Platform.isAndroid) {
                        if (event is RawKeyUpEvent &&
                            event.data is RawKeyEventDataAndroid) {
                          var data = event.data as RawKeyEventDataAndroid;
                          if (data.keyCode == 13) {
                            listBloc.add({
                              'key': ListEvent.editRequested,
                              'index': index,
                              'data': state.editingContent
                            });
                          }
                        }
                      } else {
                        if (event is RawKeyUpEvent) {
                          if (event.data.logicalKey ==
                              LogicalKeyboardKey.enter) {
                            listBloc.add({
                              'key': ListEvent.editRequested,
                              'index': index,
                              'data': state.editingContent
                            });
                          }
                        }
                      }
                    },
                    child: TextField(
                      focusNode: getAutoFocusNode(context, state),
                      onChanged: (value) => listBloc.add({
                        'key': ListEvent.editUpdate,
                        'data': value,
                      }),
                      /* ... not working
                      onSubmitted: (value) => listBloc.add({
                        'key': ListEvent.editRequested,
                        'index': index,
                        'data': value
                      }),
                      */
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
                child: Text(widget.items[index].value!.title),
              ),
              leading: Visibility(
                visible: state.subject != ListSubject.section,
                replacement: Container(
                  padding: EdgeInsets.all(0),
                  width: 10,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Color(widget.items[index].value!.colorValue)
                          .withOpacity(1)),
                ),
                child: Icon(
                  getIconData(state.subject, widget.items[index]),
                  color: Color(widget.items[index].value!.colorValue)
                      .withOpacity(1),
                ),
              ),
              onTap: () {
                if (!isEditing(state.editingIndex, index))
                  listBloc.add({
                    'key': ListEvent.itemSelected,
                    'index': index,
                  });
              },
            );
          },
          onReorder: reorderData,
        ),
      ),
    );
  }
}
