import 'package:flutter/material.dart';
import 'package:uninote/widgets/CustomList.dart';

class ListSelection extends StatefulWidget {
  ListSelection({Key key, this.title}) : super(key: key);

  final String title;
  final List<Item> items = [
    Item("University", 0xffe040fb),
    Item("Work", 0xff448aff),
    Item("Memos", 0xffeeff41),
  ];
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<ListSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: CustomList(items: widget.items),
      bottomNavigationBar: BottomAppBar(
        child: Row(children: [
          Spacer(),
          IconButton(
            icon: Icon(Icons.cloud_download_outlined),
            onPressed: () {},
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {},
          ),
          Spacer(flex: 3),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {},
          ),
          Spacer(flex: 2),
        ]),
      ),
    );
  }
}
