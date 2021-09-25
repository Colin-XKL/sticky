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
    print(this.itemLists.length);
  }

  Widget board(ItemList l) {
    print(l.list.toString());
    return Container(
        width: 200,
        height: 400,
        child: ListView.builder(
          itemBuilder: (context, index) {
            // print(ctl.l[index]);
            Block block = Block(l.list[index].str.toString());
            return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 600, maxWidth: 400),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Draggable(
                        data: l.list[index],
                        child: Container(
                          child: block,
                        ),
                        feedback: Container(
                          child: block,
                          color: Colors.yellow.shade400,
                        ),
                        childWhenDragging: Container(
                            child: block, color: Colors.blue.shade200),
                      ),
                      genDropTarget(l.key, index)
                    ],
                  ),
                ));
          },
          itemCount: l.list.length,
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
            // width: 300,
            // height: 70,
            // color: Colors.green.withAlpha(25),

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
    List<Widget> a = (this.itemLists.map((e) => board(e)).toList());

    return Container(
      child: Center(
        child: Wrap(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...a,
            Draggable<String>(
              // Data is the value this Draggable stores.
              data: 'red',
              child: Container(
                height: 120.0,
                width: 120.0,
                child: Card(
                  child: Icon(Icons.library_add_check_rounded),
                ),
              ),
              feedback: Container(
                height: 120.0,
                width: 120.0,
                child: Card(
                  child: Icon(Icons.add),
                ),
              ),
              childWhenDragging: Container(
                height: 120.0,
                width: 120.0,
                child: Center(
                  child: Icon(Icons.compare),
                ),
              ),
            ),
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
