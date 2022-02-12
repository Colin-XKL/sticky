import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stickys/views/the_item.dart';
import 'package:stickys/views/the_view.dart';

class TheBoardController extends TheViewController {
  TheBoardController() : super(VIEW_MODE.CARDS);
  Map<Key, CardState> states = new Map();

  static RxController get to => Get.find();

  @override
  newItemFromString(String str) {
    //TODO: 兼容不同的内容类型
    bool notEmpty = (str.isNotEmpty);
    // this.l.add(new BoardViewCard.text(notEmpty ? value : ""));
    newItem(CardData(ITEM_TYPE.TEXT, TextCardContent(notEmpty ? str : "")));
  }

  replaceItem(Key dataKey, CardData cardData) {
    int index = this.l.indexWhere((element) => element.dataKey == dataKey);
    this.l[index] = cardData;
    update();
    save();
  }

  @override
  ViewDataListItem reverseSerialize(Map item) {
    var content = TextCardContent(item['content']['text']);
    var state = item['state'];
    CardState cardState = new CardState();
    cardState
      ..top = state['top'] ?? 0
      ..left = state['left'] ?? 0
      ..width = state['width'] ?? 600
      ..height = state['height'] ?? 400
      ..pinned = state['pinned'] ?? false
      ..locked = state['locked'] ?? false;
    return CardData(
        ITEM_TYPE.TEXT, new TextCardContent(content.toString()), cardState);
  }

  @override
  newItemsFromStringList(List<String> l) {
    //TODO: 兼容不同的内容类型
    l.forEach((str) {
      this.l.add(
          CardData(ITEM_TYPE.TEXT, TextCardContent(str.isNotEmpty ? str : "")));
    });
    update();
    save();
  }
}

class TheBoard extends TheView {
  TheBoard() : super(VIEW_MODE.CARDS, TheBoardController()) {
    // print('board initing');
    var items = bucket.getItem(storageBucketNameMapping[VIEW_MODE.CARDS]!);
    if (this.ctl.initiated) return;

    if (items != null) {
      if ((items as List).length > 0) {
        if (this.ctl.l.length == 1) this.ctl.l.removeAt(0); //remove init item
        // TODO: various card type support

        this.ctl.l.addAll(List<CardData>.from(items.map((item) {
          // check item save and load
          var content = TextCardContent(item['content']['text']);
          var state = item['state'];
          CardState cardState = new CardState();
          cardState
            ..top = state['top'] ?? 0
            ..left = state['left'] ?? 0
            ..width = state['width'] ?? 600
            ..height = state['height'] ?? 400
            ..pinned = state['pinned'] ?? false
            ..locked = state['locked'] ?? false;
          return CardData(ITEM_TYPE.TEXT,
              new TextCardContent(content.toString()), cardState);
        })));
      } else
        // ctl.addNewItem("Add something here!");
        this.ctl.newItem(
            CardData(ITEM_TYPE.TEXT, TextCardContent(("这里空空如也，写点什么吧 ~"))));
    } else {
      var l = [
        TextCardContent('''欢迎来到EnderBox的白板模式
        在这里你可以自由地排布和组织卡片以按照你想要的方式展示信息
    1. 同样地，你可以点击加号按钮来插入剪贴板的内容。如果剪贴板为空的话，你会得到一个空白的卡片
    2. 点击卡片上方的铅笔按钮可以编辑具体内容
    3. 拖动卡片左上角的图标可以移动卡片，拖动右下角的小三角可以更改卡片的大小。卡片上方的其他按钮可以帮助你固定卡片的位置、锁定卡片的大小
    '''),
        TextCardContent("Hello Widget"),
      ];
      this
          .ctl
          .l
          .addAll(l.map((e) => CardData(ITEM_TYPE.TEXT, e, new CardState())));
      this.ctl.save();
    }
    this.ctl.initiated = true;
    // print('board init done');
  }

  @override
  Widget build(BuildContext context) {
    // print("board rebuild");
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: GetBuilder<TheBoardController>(
          init: TheBoardController(),
          builder: (ctl) => Stack(
              // TODO data list render func
              children: ctl.l
                  .map((element) => BoardViewCard(element as CardData))
                  .toList())),
    );
  }

  @override
  List<String> newItemsFromCustomInput() {
    return [];
  }
}

class CardState implements Serializable {
  double top = 0;
  double left = 0;
  double height = 300;
  double width = min(500, Get.width - 40);
  bool locked = false;
  bool pinned = false;

  CardState();

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['top'] = this.top;
    m['left'] = this.left;
    m['height'] = this.height;
    m['width'] = this.width;
    m['locked'] = this.locked;
    m['pinned'] = this.pinned;
    return m;
  }
}

class CardData extends ViewDataListItem {
  final ITEM_TYPE type;
  final CardContent content;
  CardState state;

  CardData(this.type, this.content, [CardState? cardState])
      : state = cardState ?? new CardState();

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['type'] = this.type.index;
    m['content'] = this.content.serialize();
    m['state'] = this.state.serialize();
    return m;
  }

  @override
  String toString() {
    return "<CardData> Type: $type\tContent: $content";
  }
}

abstract class CardContent implements Serializable {
  final ITEM_TYPE cardType;

  CardContent(this.cardType);
}

class TextCardContent extends CardContent {
  String text;

  TextCardContent(this.text) : super(ITEM_TYPE.TEXT);

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['text'] = this.text;
    return m;
  }

  @override
  String toString() {
    return this.text;
  }
}

class BoardViewCard extends StatefulWidget {
  final Key key = UniqueKey();

  // final CardData data;
  final TheItemBlock child;
  final CardState state;
  final Key dataKey;

  BoardViewCard(CardData cardData)
      : state = cardData.state,
        child = BoardViewCard.getCardWidget(cardData.content) as TheItemBlock,
        dataKey = cardData.dataKey,
        super();

  static Widget getCardWidget(CardContent content) {
    if (content.cardType == ITEM_TYPE.TEXT)
      return TextBlock((content as TextCardContent).text);
    else {
      // TODO implement other kind of card
      return TextBlock("unimplemented");
    }
  }

  @override
  _BoardViewCardState createState() => _BoardViewCardState();
}

// const double movingControllerAreaLength = 20.0;

class _BoardViewCardState extends State<BoardViewCard> {
  static const double minHeight = 128;
  static const double minWidth = 300;
  TextEditingController inputCtl = new TextEditingController();

  static Widget funcButton(IconData icon, Function() onPressed,
      [String? tooltip, double? iconSize]) {
    return IconButton(
      icon: Icon(
        icon,
        size: iconSize,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      splashRadius: 18,
      color: Get.isDarkMode ? Colors.grey[200] : Colors.grey[700],
    );
  }

  Widget _getContentCard(double height, double width, Widget child) {
    var actions = [
      funcButton(Icons.edit_rounded, () {
        TheBoardController controller = Get.find<TheBoardController>();
        this.inputCtl = new TextEditingController(
            text: controller.findItem(widget.dataKey).content.toString());
        this.showEditDialog(context, widget.dataKey);
      }, "编辑", 22),
      funcButton(widget.state.locked ? Icons.copy : Icons.cut_rounded, () {
        final TheBoardController wbc = Get.find<TheBoardController>();
        final item = wbc.findItem(widget.dataKey);
        var value = item.content.toString();

        Clipboard.setData(ClipboardData(text: value));
        if (!widget.state.locked) wbc.removeItem(widget.dataKey);

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('已复制!'),
            duration: Duration(milliseconds: 300),
          ));
      }, widget.state.locked ? "复制" : "剪切", 20),
      funcButton(Icons.delete_outline_rounded, () {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          final TheBoardController wbc = Get.find<TheBoardController>();
          wbc.removeItem(widget.dataKey);
        });
      }, "Delete"),
      widget.state.locked
          ? funcButton(Icons.lock_rounded, () {
              setState(
                () {
                  widget.state
                    ..locked = false
                    ..pinned = false;
                },
              );
            }, "已锁定", 22)
          : funcButton(Icons.lock_open_rounded, () {
              setState(() {
                widget.state
                  ..pinned = true
                  ..locked = true;
              });
            }, "锁定位置和大小", 22),
      widget.state.pinned
          ? funcButton(Icons.push_pin_rounded, () {
              setState(() {
                widget.state.pinned = false;
              });
            }, "已锁定位置", 22)
          : funcButton(Icons.push_pin_outlined, () {
              setState(() {
                widget.state.pinned = true;
              });
            }, "锁定位置", 22),
    ];
    moveFunc(double dx, double dy) {
      if (!widget.state.pinned)
        setState(() {
          widget.state.top = widget.state.top + dy;
          widget.state.left = widget.state.left + dx;
          widget.state.top = max(widget.state.top, 0);
          widget.state.left = max(widget.state.left, 0);
        });
    }

    resizeFunc(double dx, double dy) {
      //resize

      if (!widget.state.locked) {
        double newHeight = (widget.state.height + dy);
        double newWidth = (widget.state.width + dx);
        setState(() {
          widget.state.height = max(newHeight, minHeight);
          widget.state.width = max(newWidth, minWidth);
        });
      }
    }

    return Container(
        height: height,
        width: width,
        child: SizedBox(
          width: width,
          height: height,
          child: Card(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                          //icon of card type & moving controller
                          padding: const EdgeInsets.all(4.0),
                          child: MouseRegion(
                              cursor: SystemMouseCursors.move,
                              child: Tooltip(
                                  message: widget.state.pinned
                                      ? "已锁定位置"
                                      : "拖动以移动卡片位置",
                                  child: ManipulatingBall(
                                    child: Icon(
                                      Icons.text_fields_rounded,
                                      size: 26,
                                    ),
                                    onDrag: moveFunc,
                                    dragAreaLength: 48,
                                  ))),
                        ),
                        Expanded(
                          //title of content card
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "文本内容",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          //button bar
                          child:
                              // Row(
                              //   children: [
                              ButtonBar(
                                  buttonPadding: EdgeInsets.zero,
                                  children: actions),
                          // ],
                          // ),
                        ),
                      ],
                      // dense: true,
                    ),
                  ),
                ),
                Expanded(
                    //content
                    child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ManipulatingBall(
                        child: SimpleHover(
                            cursorOnHover: SystemMouseCursors.resizeDownRight,
                            builder: (isHovered) {
                              return Tooltip(
                                child: Icon(Icons.signal_cellular_4_bar_rounded,
                                    color: Theme.of(context).dividerColor),
                                message: widget.state.locked
                                    ? "卡片大小已锁定"
                                    : "拖动以更改卡片大小",
                              );
                            }),
                        onDrag: resizeFunc,
                        dragAreaLength: 20,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: widget.child,
                    ),
                  ],
                ))
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.state.top,
      left: widget.state.left,
      child: _getContentCard(
          widget.state.height, widget.state.width, widget.child),
    );
  }

  void showEditDialog(BuildContext ctx, Key dataKey) {
    var dialogActions = [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("取消")),
      TextButton(
        onPressed: () {
          TheBoardController controller = Get.find<TheBoardController>();
          var item = controller.findItem(dataKey) as CardData;
          (item.content as TextCardContent).text = inputCtl.text;
          controller.replaceItem(dataKey, item);
          Navigator.of(context).pop();
        },
        child: Text("保存"),
      ),
    ];
    Widget editArea = TextField(
      controller: this.inputCtl,
      maxLines: null,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "键入多行文本",
        labelText: "内容文本",
        suffix: Icon(Icons.text_format_rounded),
        // contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 20),
        // border: InputBorder.none
      ),
      // ),
    );
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('编辑内容'),
            actions: dialogActions,
            content: Container(
                constraints: BoxConstraints(maxWidth: 800, maxHeight: 600),
                child: AspectRatio(
                  aspectRatio: 1 / 0.618,
                  child: Column(
                    children: [
                      Expanded(child: editArea),
                    ],
                  ),
                )),
          );
        });
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall(
      {Key? key,
      required this.child,
      required this.onDrag,
      this.dragAreaLength});

  final Widget child;
  final Function onDrag;
  final double? dragAreaLength;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double? initX;
  double? initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    double dx = details.globalPosition.dx - initX;
    double dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        child: widget.child,
      ),
    );
  }
}

class SimpleHover extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final MouseCursor cursorOnHover;
  final double noHoverOpacity;
  final double hoverOpacity;

  const SimpleHover(
      {Key? key,
      required this.builder,
      this.cursorOnHover = MouseCursor.defer,
      this.noHoverOpacity = 0.3,
      this.hoverOpacity = 0.95})
      : super(key: key);

  @override
  _SimpleHoverState createState() => _SimpleHoverState();
}

class _SimpleHoverState extends State<SimpleHover> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursorOnHover,
      onEnter: (_) => setState(() {
        this.isHovered = true;
      }),
      onExit: (_) => setState(() {
        this.isHovered = false;
      }),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        opacity: this.isHovered ? widget.hoverOpacity : widget.noHoverOpacity,
        child: widget.builder(isHovered),
      ),
    );
  }
}
