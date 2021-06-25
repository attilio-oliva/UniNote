import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/bloc/ListBloc.dart';
import 'package:uninote/globals/colors.dart' as globalColors;
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/states/ListState.dart';
import 'package:uninote/widgets/CustomList.dart';
import 'NoteEditor.dart';

String? lastSelectedNote;

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

  List<Widget> getActionsIcon(ListBloc listBloc) {
    List<Widget> list = List<Widget>.empty(growable: true);
    list.add(
      Material(
        child: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            listBloc.add({
              'key': ListEvent.marking,
              'data': "buttonPressed",
            });
          },
        ),
        color: (listBloc.state.isMarking == true)
            ? globalColors.pressedButtonColor
            : globalColors.primaryColor,
      ),
    );
    if (listBloc.state.isMarking == true) {
      list.add(
        Material(
          color: globalColors.primaryColor,
          child: IconButton(
            icon: Icon(Icons.accessible_forward_rounded),
            onPressed: () {
              listBloc.add({
                'key': ListEvent.delete,
                'data': "deleteSelected",
              });
            },
          ),
        ),
      );
    }
    return list;
  }

  bool shouldBeVisible(ListState state) {
    if (getAppBarTitle(state) == "Select notebook") {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ListBloc listBloc = BlocProvider.of<ListBloc>(context);
    return BlocConsumer<ListBloc, ListState>(
      listener: (context, state) {
        if (state.selectedNote != lastSelectedNote) {
          lastSelectedNote = state.selectedNote;
          if (lastSelectedNote != null) {
            FocusScope.of(context).unfocus();
            WidgetsBinding.instance?.focusManager.rootScope.unfocus();
            WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<EditorBloc>(
                      create: (context) => EditorBloc(
                        EditorState(
                          noteLocation:
                              "${listBloc.getBaseFilePath()}/document.xml",
                          //noteLocation:"${listBloc.getBaseFilePath()}/${state.selectedNote!}.xml",
                          mode: EditorMode.selection,
                          subject: EditorSubject.text,
                        ),
                      ),
                    ),
                    BlocProvider<ListBloc>.value(value: listBloc)
                  ],
                  child: NoteEditor(listBloc),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(getAppBarTitle(state)),
          centerTitle: true,
          leading: Visibility(
            visible: shouldBeVisible(state),
            child: IconButton(
              onPressed: () {
                listBloc.add({
                  'key': ListEvent.back,
                });
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          actions: getActionsIcon(listBloc),
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
                    icon: Icon(Icons.create_new_folder),
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
