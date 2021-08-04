import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class ListItem {
  Key key;
  String title;
  bool isBinary;
  var content;
  String notations;

  ListItem(String title, String content) {
    this.key = UniqueKey();
    this.title = title;
    this.isBinary = false;
    this.content = content;
  }

  ListItem.binaryContent(String title, Object content, bool bin) {
    this.key = UniqueKey();
    this.title = title;
    this.isBinary = true;
    this.content = content;
  }
}

class TheListController extends GetxController {
  List<ListItem> l = [
    ListItem("Tutorial", "Follow these steps to quickly get started."),
    ListItem("#1 Paste from your pastebin",
        "Tap or click the plus button to paste something.\nIf it's empty, try to get some stuff.\n"),
    ListItem("#2 Copy from the list",
        "Tap or click the item in the list, and the content(not the title) will be copied to your pastebin\n"),
    ListItem("#3 Delete item", "slide the item remove it.\n"),
    ListItem("#4 Reorder items", "Long press the item and reorder it.\n")
  ].obs;
  var lastDeleted = new ListItem("Empty", "No thing here.");

  bool addNewItem(String value) {
    //TODO: 兼容不同的内容类型
    bool notEmpty = (value != null && value.isNotEmpty);
    this.l.add(notEmpty ? ListItem("Text", value) : ListItem("Empty ", ""));
    return notEmpty;
  }
}

class TheList extends StatelessWidget {
  final TheListController c = Get.put(TheListController());

  final msgPasted = new SnackBar(
    content: Text("Pasted"),
    duration: Duration(milliseconds: 300),
  );
  final msgEmpty = new SnackBar(
    content: Text("Empty"),
    duration: Duration(milliseconds: 300),
  );
  final msgCopied = new SnackBar(
    content: Text("Copied"),
    duration: Duration(milliseconds: 300),
    action: new SnackBarAction(
        label: 'Undo',
        onPressed: () {
          final TheListController c = Get.find<TheListController>();
          c.l.add(c.lastDeleted);
          // lastDeleted=null;
        }),
  );

  final msgDeleted = new SnackBar(
    content: Text("Deleted"),
    duration: Duration(milliseconds: 2000),
    action: new SnackBarAction(
        label: 'Undo',
        onPressed: () {
          final TheListController c = Get.find<TheListController>();
          c.l.add(c.lastDeleted);
          // lastDeleted=null;
        }),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scrollbar(
            isAlwaysShown: false,
            showTrackOnHover: false,
            child: Obx(() => ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) {
                  if (oldIndex < newIndex) newIndex -= 1;
                  var temp = c.l.removeAt(oldIndex);
                  c.l.insert(newIndex, temp);
                },
                itemCount: c.l.length,
                itemBuilder: (context, index) {
                  final item = c.l[index];
                  return Dismissible(
                      key: item.key,
                      background: listTileBackground(),
                      onDismissed: (direction) {
                        c.lastDeleted = item;
                        c.l.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(msgDeleted);
                      },
                      child: ReorderableDelayedDragStartListener(
                          key: item.key,
                          index: index,
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.content),
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            onTap: () {
                              var value = item.content;
                              if (value.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: value));
                                c.lastDeleted = c.l[index];
                                c.l.removeAt(index);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(msgCopied);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(msgEmpty);
                              }
                            },
                          )));
                }))));
  }
}

Widget listTileBackground() {
  return Container(
      color: Colors.red,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 64,
              maxWidth: 64,
            ),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              // height: 30.0,
              color: Colors.red,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 64,
              maxWidth: 64,
            ),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          )
        ],
      ));
}
