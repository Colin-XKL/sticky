import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:stickys/views/the_view.dart';

class TheListController extends TheViewController {
  ListItem lastDeleted = new ListItem("空", "这里什么也没有~.");

  TheListController() : super(VIEW_MODE.LIST);

  @override
  newItemFromString(String str) {
    this.newItem(
        str.isNotEmpty ? ListItem("Text", str) : ListItem("Empty ", ""), true);
  }

  @override
  reverseSerialize(Map<dynamic, dynamic> item) {
    return ListItem(item['title'], item['content']);
  }

  @override
  newItemsFromStringList(List<String> l) {
    l.reversed.forEach((str) {
      this.l.insert(0,
          str.isNotEmpty ? ListItem("Text", str) : ListItem("Empty ", "Empty"));
    });
    // l.forEach((str) {
    // this.l.add(str.isNotEmpty ? ListItem("Text", str) : ListItem("Empty ", ""));
    // });
    update();
    save();
  }
}

class InputOptionsController extends GetxController {
  RxBool multiLineMode = false.obs;
  RxBool trim = true.obs;
  RxBool multiLineToList = false.obs;
}

class ListItem extends ViewDataListItem {
  final Key key = UniqueKey();
  late String title;
  bool isBinary = false;

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
  final InputOptionsController optionsCtl = Get.find<InputOptionsController>();
  final FocusNode focus = new FocusNode();

  TheList() : super(VIEW_MODE.LIST, TheListController()) {
    // print('list initing');
    var items = bucket.getItem(storageBucketNameMapping[VIEW_MODE.LIST]!);
    if (this.ctl.initiated) return;
    if (items != null) {
      if ((items as List).length > 0) {
        if (this.ctl.l.length == 1) this.ctl.removeItemAt(0); //remove init item
        this.ctl.l.addAll(List<ListItem>.from(
            items.map((item) => ListItem(item['title'], item['content']))));
      } else
        this.ctl.newItem(ListItem("写点什么吧 ", ""));
    } else {
      var l = [
        ListItem("Tutorial", "欢迎使用Ender Box！"),
        ListItem("#1 Paste from your pastebin",
            "#1 点击加号按钮可以快速将你剪贴板的内容添加到这里\n当然你也可以在下方的输入框中自行填写.\n"),
        ListItem("#2 Copy from the list", "#2 点击列表中的条目，里面的内容就会被复制到你的剪贴板\n"),
        ListItem("#3 Delete item", "#3 向左或向右滑动某个条目就可以删除它\n"),
        ListItem("#4 Reorder items", "#4 长按一个条目上下拖动可以改变顺序\n"),
        ListItem("#4 Reorder items", "这就是EnderBox列表模式的所有功能啦，是不是很简单呢\n"),
      ];
      this.ctl.l.addAll(l);
      this.ctl.save();
    }
    this.ctl.initiated = true;
    // print('list init done');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(
            child: Scrollbar(
                isAlwaysShown: false,
                showTrackOnHover: false,
                child: Obx(() => ReorderableListView.builder(
                    // reverse: true,
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
                      final Widget tile = ListTile(
                        // leading: Icon(Icons.text_fields_outlined),
                        title: Text(item.content),
                        // subtitle: Text(item.content),
                        // contentPadding:
                        // const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        onTap: () {
                          var value = item.content;
                          if (value.isNotEmpty)
                            Clipboard.setData(ClipboardData(text: value));
                          ctl.removeItemAt(index);
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                                value.isNotEmpty ? msgCopied : msgDeleted);
                          this.focus.unfocus();
                        },
                      );
                      return Dismissible(
                          key: item.key,
                          background: listTileBackground,
                          onDismissed: (direction) {
                            ctl.removeItemAt(index);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(msgDeleted);
                            this.focus.unfocus();
                          },
                          child: ReorderableDelayedDragStartListener(
                              key: item.key, index: index, child: tile));
                    })))),
        Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    children: [
                      InputOptionsChip(
                          labelString: "多行模式",
                          avatar: Icon(Icons.format_list_numbered_rounded,
                              size: 20),
                          selected: this.optionsCtl.multiLineMode.value,
                          onSelected: (bool selected) {
                            this.optionsCtl.multiLineMode.value = selected;
                            if (!selected)
                              this.optionsCtl.multiLineToList.value = false;
                          }),
                      InputOptionsChip(
                        labelString: "清理空格",
                        avatar: Icon(
                          Icons.compare_arrows_rounded,
                        ),
                        selected: this.optionsCtl.trim.value,
                        onSelected: (bool selected) {
                          this.optionsCtl.trim.value = selected;
                        },
                      ),
                      InputOptionsChip(
                        labelString: "多行文本转列表",
                        avatar: Icon(
                          Icons.library_add_check_rounded,
                          size: 20,
                        ),
                        selected: this.optionsCtl.multiLineToList.value,
                        onSelected: (bool selected) {
                          this.optionsCtl.multiLineToList.value = selected;
                          if (selected)
                            this.optionsCtl.multiLineMode.value = true;
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).hoverColor,
                    // color: Colors.blueGrey[50],
                  ),
                  child: Obx(
                    () => TextField(
                      controller: inputController,
                      focusNode: this.focus,
                      maxLines: this.optionsCtl.multiLineMode.isTrue ? null : 1,
                      // mobile platform keyboard should not show up when opening the app
                      autofocus: false,
                      onSubmitted: (value) {
                        ctl.newItemFromString(value);
                        inputController.clear();
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(msgPasted);
                        this.focus.unfocus();
                      },
                      cursorRadius: const Radius.circular(4),
                      decoration: InputDecoration(
                          hintText: "写点什么吧 o(*￣▽￣*)ブ",
                          prefixIcon: Icon(Icons.radio_button_checked_rounded),
                          border: InputBorder.none),
                    ),
                  ),
                )
              ],
            )),
      ]),
    );
  }

  @override
  List<String> newItemsFromCustomInput() {
    String value = inputController.text;
    inputController.clear();
    this.focus.unfocus();
    List<String> ret = [];
    if (this.optionsCtl.multiLineToList.isTrue)
      ret = value.split('\n');
    else if (value.isNotEmpty) ret.add(value);
    if (this.optionsCtl.trim.isTrue)
      for (int i = 0; i < ret.length; i++) ret[i] = ret[i].trim();
    return ret;
  }

  static Container listTileBackground = Container(
      color: Colors.red,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 64,
              maxWidth: 64,
            ),
            child: const Icon(
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
            constraints: const BoxConstraints(
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

  final msgPasted = new SnackBar(
    content: Text("已粘贴"),
    duration: const Duration(milliseconds: 300),
  );
  final msgEmpty = new SnackBar(
    content: Text("无内容"),
    duration: const Duration(milliseconds: 300),
  );
  final msgCopied = new SnackBar(
    content: Text("已复制"),
    duration: const Duration(milliseconds: 300),
    action: new SnackBarAction(
        label: '撤销',
        onPressed: () {
          final TheListController c = Get.find<TheListController>();
          // c.l.add(c.lastDeleted);
          c.newItem(c.lastDeleted);
          // lastDeleted=null;
        }),
  );

  final msgDeleted = new SnackBar(
    content: Text("已删除"),
    duration: const Duration(milliseconds: 2000),
    action: new SnackBarAction(
        label: '撤销',
        onPressed: () {
          final TheListController c = Get.find<TheListController>();
          // c.l.add(c.lastDeleted);
          c.newItem(c.lastDeleted);
          // lastDeleted=null;
        }),
  );
}

class InputOptionsChip extends FilterChip {
  InputOptionsChip(
      {required String labelString, required Icon avatar, selected, onSelected})
      : super(
          label: Text(labelString),
          labelStyle: selected
              ? const TextStyle(color: Colors.white)
              : const TextStyle(color: Colors.black87),
          avatar: selected
              ? Icon(
                  avatar.icon,
                  size: avatar.size,
                  color: Colors.white,
                )
              : null,
          selected: selected,
          onSelected: onSelected,
          showCheckmark: false,
          selectedColor: Get.theme.colorScheme.secondary,
          padding: const EdgeInsets.fromLTRB(8, 0, 6, 0),
        );
}
