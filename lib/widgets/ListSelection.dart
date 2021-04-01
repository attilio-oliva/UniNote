import 'package:flutter/material.dart';

class ListSelection extends StatefulWidget {
  ListSelection({Key key, this.title}) : super(key: key);

  final String title;
  final List<String> items = ["University", "Work", "Memos"];

  @override
  _NotebookSelection createState() => _NotebookSelection();
}

class _NotebookSelection extends State<ListSelection> {
  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = widget.items.removeAt(oldindex);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ReorderableListView(
        children: <Widget>[
          for (final String item in widget.items)
            ListTile(
              key: ValueKey(item),
              title: Text(item),
              leading: Icon(Icons.book),
            ),
        ],
        onReorder: reorderData,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(children: [
          Spacer(),
          IconButton(icon: Icon(Icons.cloud_download_outlined)),
          Spacer(),
          IconButton(icon: Icon(Icons.file_download)),
          Spacer(flex: 3),
          IconButton(icon: Icon(Icons.add_circle_outline)),
          Spacer(flex: 2),
        ]),
      ),
    );
  }
}
