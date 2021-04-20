import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/CustomList.dart';
import 'EditCanvas.dart';

class ListSelection extends StatelessWidget {
  ListSelection({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    return BlocConsumer<ListBloc, ListState>(
      listener: (context, state) {
        if (state.swapToEditCanvas) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EditCanvas()));
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text("Select ${state.subject.name}"),
          centerTitle: true,
        ),
        body: CustomList(items: state.itemList, bloc: listBloc),
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
              onPressed: () {
                listBloc.add(ListEvent.itemAdded);
              },
            ),
            Spacer(flex: 2),
          ]),
        ),
      ),
    );
  }
}
