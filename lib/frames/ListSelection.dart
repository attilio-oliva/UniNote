import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/globals/colors.dart' as globalColors;
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/CustomList.dart';
import 'NoteEditor.dart';

class ListSelection extends StatelessWidget {
  ListSelection({this.title = ""});

  final String title;

  String getAppBarTitle(ListState state) {
    switch (state.subject) {
      case ListSubject.notebook:
        return "Select notebook";
      case ListSubject.section:
        return state.selectedItem;
      case ListSubject.note:
        return state.selectedItem;
      default:
        return "Select ${state.subject.name}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    return BlocConsumer<ListBloc, ListState>(
      listener: (context, state) {
        if (state.swapToNoteEditor) {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => BlocProvider<EditorBloc>(
                create: (context) => EditorBloc(
                  EditorState(
                    EditorMode.insertion,
                    EditorSubject.text,
                  ),
                ),
                child: NoteEditor(),
              ),
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(getAppBarTitle(state)),
          centerTitle: true,
        ),
        body: CustomList(state.itemList),
        bottomNavigationBar: BottomAppBar(
          child: Row(children: [
            Expanded(
              child: IconButton(
                color: globalColors.bottomButtonColor,
                icon: Icon(Icons.cloud_download_outlined),
                onPressed: () =>
                    listBloc.add({'key': ListEvent.importRemoteResource}),
              ),
            ),
            Expanded(
              child: IconButton(
                color: globalColors.bottomButtonColor,
                icon: Icon(Icons.file_download),
                onPressed: () =>
                    listBloc.add({'key': ListEvent.importLocalResource}),
              ),
            ),
            Visibility(
              visible: state.subject == ListSubject.note,
              child: Expanded(
                child: IconButton(
                    color: globalColors.bottomButtonColor,
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      if (state.editingIndex != null) {
                        listBloc.add({
                          'key': ListEvent.editRequested,
                          'data': state.editingContent,
                          'index': state.editingIndex
                        });
                      } else {
                        listBloc.add({'key': ListEvent.groupAdded});
                      }
                    }),
              ),
            ),
            Expanded(
              child: IconButton(
                color: globalColors.bottomButtonColor,
                icon: Icon(Icons.add_rounded),
                onPressed: () {
                  if (state.editingIndex != null) {
                    listBloc.add({
                      'key': ListEvent.editRequested,
                      'data': state.editingContent,
                      'index': state.editingIndex
                    });
                  } else {
                    listBloc.add({'key': ListEvent.itemAdded});
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
