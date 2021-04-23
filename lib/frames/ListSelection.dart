import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/CustomList.dart';
import 'NoteEditor.dart';

class ListSelection extends StatelessWidget {
  ListSelection({Key key, this.title}) : super(key: key);

  final String title;

  String getAppBarTitle(ListState state) {
    switch (state.subject) {
      case ListSubject.notebook:
        return "Select notebook";
      case ListSubject.note:
        return state.selectedItem;
    }
    return "Select ${state.subject.name}";
  }

  @override
  Widget build(BuildContext context) {
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    return BlocConsumer<ListBloc, ListState>(
      listener: (context, state) {
        if (state.swapToEditCanvas) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NoteEditor()));
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(getAppBarTitle(state)),
          centerTitle: true,
        ),
        body: CustomList(items: state.itemList, bloc: listBloc),
        bottomNavigationBar: BottomAppBar(
          child: Row(children: [
            Expanded(
              child: IconButton(
                icon: Icon(Icons.cloud_download_outlined),
                onPressed: () =>
                    listBloc.add(ListEventData(ListEvent.importRemoteResource)),
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () =>
                    listBloc.add(ListEventData(ListEvent.importLocalResource)),
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () =>
                    listBloc.add(ListEventData(ListEvent.itemAdded)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
