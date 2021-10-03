import 'package:flutter/material.dart';

class Block extends StatelessWidget {
  final Key key = UniqueKey();
  final String text;

  Block(this.text) : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.fromLTRB(16, 8, 8, 16),
      width: 300,
      height: 70,
      child: Card(
        child: Text(text),
      ),
    );
  }
}

class Item {
  final String str;
  Key listKey;

  Item({str, listKey})
      : this.str = str,
        this.listKey = listKey;
}

class ItemList {
  List<Item> list = [];
  Key key = UniqueKey();

  ItemList();

  ItemList.fromStrs(List<String> strs) {
    List<Item> l = [];
    strs.forEach((element) {
      l.add(Item(str: element, listKey: this.key));
    });
    this.list = l;
  }
}

class BlockView extends StatefulWidget {
  const BlockView({Key? key}) : super(key: key);

  @override
  _BlockViewState createState() => _BlockViewState();
}

class _BlockViewState extends State<BlockView> {
  List<ItemList> itemLists = [];
  Map<Key, ItemList> map = new Map();

  addNewList(ItemList l) {
    this.itemLists.add(l);
    this.map[l.key] = this.itemLists.last;
  }

  @override
  void initState() {
    print("init");
    var l1 = ItemList.fromStrs(["aaa", 'bbb']);
    var l2 = ItemList.fromStrs(["strs", 'ccc', 'ddd']);
    addNewList(l1);
    addNewList(l2);
    super.initState();
    // print(this.itemLists.length);
  }

  Widget board(ItemList l) {
    return Container(
        width: 200,
        height: 400,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(15), width: 2),
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            Widget content;
            if (index < l.list.length) {
              Block block = Block(l.list[index].str.toString());
              content = Draggable(
                data: l.list[index],
                child: Container(
                  margin: const EdgeInsets.all(1),
                  child: block,
                ),
                feedback: Container(
                  margin: const EdgeInsets.all(1),
                  child: block,
                  color: Colors.yellow.shade400,
                ),
                childWhenDragging:
                    Container(child: block, color: Colors.blue.shade200),
              );
            } else
              content = Container(
                height: 100,
                // color: Colors.black12,
              );
            return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 600, maxWidth: 400),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [content, genDropTarget(l.key, index)],
                  ),
                ));
          },
          itemCount: l.list.length + 1,
        ));
  }

  genDropTarget(Key targetListKey, int targetIndex) {
    return DragTarget<Item>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return Container(
          decoration: (accepted.length > 0)
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(15),
                  border: Border(
                      top: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 4)))
              : null,
        );
      },
      onWillAccept: (data) {
        print(data);
        return data != null;
      },
      onAccept: (data) {
        setState(() {
          var list = this.map[targetListKey]!.list;
          this
              .map[data.listKey]!
              .list
              .removeWhere((element) => element == data);
          data.listKey = targetListKey;
          if (list.length > targetIndex) {
            list.insert(targetIndex, data);
          } else
            list.add(data);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Wrap(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...(this.itemLists.map((e) => board(e)).toList()),
          ],
        ),
      ),
    );
  }
}

class BlockPage extends StatelessWidget {
  const BlockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blocks"),
      ),
      body: Container(
        child: BlockView(),
      ),
    );
  }
}
