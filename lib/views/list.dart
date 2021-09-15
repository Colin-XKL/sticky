import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:stickys/views/the_view.dart';

class TheListController extends TheViewController {
  ListItem lastDeleted = new ListItem("Empty", "No thing here.");

  TheListController() : super(VIEW_MODE.LIST);

  @override
  newItemFromString(String str) {
    bool notEmpty = (str.isNotEmpty);
    this.newItem(notEmpty ? ListItem("Text", str) : ListItem("Empty ", ""));
  }

  @override
  reverseSerialize(Map<dynamic, dynamic> item) {
    return ListItem(item['title'], item['content']);
  }
}

class ListInputOptionsController extends GetxController {
  RxBool multiLineMode = false.obs;
  RxBool trim = true.obs;

  switchMode() {
    this.multiLineMode.value = !this.multiLineMode.value;
  }

  switchTrim() {
    this.trim.value = !this.trim.value;
    update();
  }
}

class ListItem extends ViewDataListItem {
  final Key key = UniqueKey();
  late String title;
  bool isBinary = false;

  // var content;
  String? notations;

  ListItem(String title, String? content) {
    this.title = title;
    this.isBinary = false;
    this.content = content;
  }

  ListItem.binaryContent(String title, Object content, bool bin) {
    this.title = title;
    this.isBinary = true;
    this.content = content;
  }

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['title'] = this.title;
    m['isBinary'] = this.isBinary;
    m['content'] = content;
    return m;
  }

  @override
  String toString() {
    return "<ListItem> T: $title\tC:$content";
  }
}

class TheList extends TheView {
  final TextEditingController inputController = TextEditingController();
  final ListInputOptionsController optionsCtl =
      Get.find<ListInputOptionsController>();
  final FocusNode focus = new FocusNode();

  TheList() : super(VIEW_MODE.LIST, TheListController()) {
    // print('list initing');
    var items = storage.getItem(enumMapping[VIEW_MODE.LIST]!);
    if (this.ctl.initDone) return;
    if (items != null) {
      if ((items as List).length > 0) {
        if (this.ctl.l.length == 1) this.ctl.removeItemAt(0); //remove init item
        this.ctl.l.addAll(List<ListItem>.from(
            items.map((item) => ListItem(item['title'], item['content']))));
      } else
        this.ctl.newItem(ListItem("Add something here!", ""));
    } else {
      var l = [
        ListItem("Tutorial", "Follow these steps to quickly get started."),
        ListItem("#1 Paste from your pastebin",
            "Tap or click the plus button to paste something.\nIf it's empty, try to get some stuff.\n"),
        ListItem("#2 Copy from the list",
            "Tap or click the item in the list, and the content(not the title) will be copied to your pastebin\n"),
        ListItem("#3 Delete item", "slide the item remove it.\n"),
        ListItem("#4 Reorder items", "Long press the item and reorder it.\n")
      ];
      this.ctl.l.addAll(l);
      this.ctl.save();
    }
    this.ctl.initDone = true;
    // print('list init done');
  }

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
          // c.l.add(c.lastDeleted);
          c.newItem(c.lastDeleted);
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
          // c.l.add(c.lastDeleted);
          c.newItem(c.lastDeleted);
          // lastDeleted=null;
        }),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Expanded(
                child: Scrollbar(
                    isAlwaysShown: false,
                    showTrackOnHover: false,
                    child: Obx(() => ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        onReorder: (int oldIndex, int newIndex) {
                          if (oldIndex < newIndex) newIndex -= 1;
                          var temp = ctl.l.removeAt(oldIndex);
                          ctl.l.insert(newIndex, temp);
                          ctl.save();
                          this.focus.unfocus();
                        },
                        itemCount: ctl.l.length,
                        itemBuilder: (context, index) {
                          // print(ctl.l[index]);
                          final item = ctl.l[index] as ListItem;
                          return Dismissible(
                              key: item.key,
                              background: listTileBackground(),
                              onDismissed: (direction) {
                                ctl.removeItemAt(index);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(msgDeleted);
                                this.focus.unfocus();
                              },
                              child: ReorderableDelayedDragStartListener(
                                  key: item.key,
                                  index: index,
                                  child: ListTile(
                                    title: Text(item.title),
                                    subtitle: Text(item.content),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    onTap: () {
                                      var value = item.content;
                                      if (value.isNotEmpty)
                                        Clipboard.setData(
                                            ClipboardData(text: value));
                                      ctl.removeItemAt(index);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(value.isNotEmpty
                                              ? msgCopied
                                              : msgDeleted);
                                      this.focus.unfocus();
                                    },
                                  )));
                        })))),
            Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          ChoiceChip(
                              label: Text("MultiLineMode"),
                              selected: this.optionsCtl.multiLineMode.value,
                              selectedColor: Theme.of(context).accentColor,
                              onSelected: (bool selected) {
                                this.optionsCtl.switchMode();
                              }),
                          ChoiceChip(
                            label: Text("Trim Text"),
                            selected: this.optionsCtl.trim.value,
                            selectedColor: Theme.of(context).accentColor,
                            onSelected: (bool selected) {
                              this.optionsCtl.switchTrim();
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Theme.of(context).hoverColor,
                        // color: Colors.blueGrey[50],
                      ),
                      child: TextField(
                        controller: inputController,
                        focusNode: this.focus,
                        // mobile platform keyboard should not show up when opening the app
                        autofocus: false,
                        onSubmitted: (value) {
                          ctl.newItemFromString(value);
                          inputController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(msgPasted);
                          this.focus.unfocus();
                        },
                        cursorRadius: Radius.circular(4),
                        decoration: InputDecoration(
                            hintText: "Add your idea",
                            prefixIcon:
                                Icon(Icons.radio_button_checked_rounded),
                            border: InputBorder.none),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }

  @override
  Object newItemFromCustomInput() {
    String value = inputController.text;
    inputController.clear();
    this.focus.unfocus();
    return value;
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
