import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
    newItem(CardData(CARD_TYPE.TEXT, TextCardContent(notEmpty ? str : "")));
    return notEmpty;
  }

  replaceItem(Key dataKey, CardData cardData) {
    int index = this.l.indexWhere((element) => element.dataKey==dataKey);
    this.l[index]=cardData;
    update();
    save();
  }

  @override
  ViewDataListItem reverseSerialize(Map item) {
    var content = TextCardContent(item['content']['text']);
    var state = item['state'];
    CardState cardState = new CardState();
    cardState.top = state['top'] ?? 0;
    cardState.left = state['left'] ?? 0;
    cardState.width = state['width'] ?? 600;
    cardState.height = state['height'] ?? 400;
    cardState.pined = state['pined'] ?? false;
    cardState.locked = state['locked'] ?? false;
    return CardData(
        CARD_TYPE.TEXT, new TextCardContent(content.toString()), cardState);
  }
}

class TheBoard extends TheView {
  TheBoard() : super(VIEW_MODE.CARDS, TheBoardController()) {
    // print('board initing');
    var items = storage.getItem(enumMapping[VIEW_MODE.CARDS]!);
    if (this.ctl.initDone) return;

    if (items != null) {
      if ((items as List).length > 0) {
        if (this.ctl.l.length == 1) this.ctl.l.removeAt(0); //remove init item
        // TODO: various card type support

        this.ctl.l.addAll(List<CardData>.from(items.map((item) {
          // check item save and load
          var content = TextCardContent(item['content']['text']);
          var state = item['state'];
          CardState cardState = new CardState();
          cardState.top = state['top'] ?? 0;
          cardState.left = state['left'] ?? 0;
          cardState.width = state['width'] ?? 600;
          cardState.height = state['height'] ?? 400;
          cardState.pined = state['pined'] ?? false;
          cardState.locked = state['locked'] ?? false;
          return CardData(CARD_TYPE.TEXT,
              new TextCardContent(content.toString()), cardState);
        })));
      } else
        // ctl.addNewItem("Add something here!");
        this.ctl.newItem(
            CardData(CARD_TYPE.TEXT, TextCardContent(("Add something here!"))));
    } else {
      var l = [
        TextCardContent('''I've just did simple prototype to show main idea.
    1. Draw size handlers with container;
    2. Use GestureDetector to get new variables of sizes
    3. Refresh the main container size.'''),
        TextCardContent("Hello Widget"),
      ];
      this
          .ctl
          .l
          .addAll(l.map((e) => CardData(CARD_TYPE.TEXT, e, new CardState())));
      this.ctl.save();
    }
    this.ctl.initDone = true;
    // print('board init done');
  }

  @override
  Widget build(BuildContext context) {
    // print("board rebuild");
    return Container(
      padding: EdgeInsets.all(24),
      child: GetBuilder<TheBoardController>(
          init: TheBoardController(),
          builder: (ctl) =>
              Stack(
                // TODO data list render func
                  children: ctl.l
                  .map((element) => BoardViewCard(element as CardData))
                      .toList())),
    );
  }

  @override
  String newItemFromCustomInput() {
    return "";
  }
}

class CardState extends Serializable {
  double top = 0;
  double left = 0;
  double height = 320;
  double width = 600;
  bool locked = false;
  bool pined = false;

  CardState();

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['top'] = this.top;
    m['left'] = this.left;
    m['height'] = this.height;
    m['width'] = this.width;
    m['locked'] = this.locked;
    m['pinned'] = this.pined;

    return m;
  }
}

abstract class CardBody extends StatelessWidget {
  final Key key = UniqueKey();
  final CARD_TYPE type;

  CardBody(this.type);
}

class CardData extends ViewDataListItem {
  final CARD_TYPE type;
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

abstract class CardContent extends Serializable {
  final CARD_TYPE cardType;

  CardContent(this.cardType);
}

class TextCardContent extends CardContent {
  String? text;

  TextCardContent(this.text) : super(CARD_TYPE.TEXT);

  @override
  Map<String, dynamic> serialize() {
    Map<String, dynamic> m = new Map();
    m['text'] = this.text;
    return m;
  }

  @override
  String toString() {
    return this.text!;
  }
}

class TextCard extends CardBody {
  final TextCardContent data;

  TextCard(String? str)
      : data = new TextCardContent(str),
        super(CARD_TYPE.TEXT);

  String? get text => this.data.text;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        isAlwaysShown: false,
        child: SingleChildScrollView(
          child: SelectableText(this.text!),
        ));
  }
}

enum CARD_TYPE { TEXT, IMAGE, LINK, TODO, WIDGET }

class BoardViewCard extends StatefulWidget {
  final Key key = UniqueKey();

  // final CardData data;
  final CardBody child;
  final CardState state;
  final Key dataKey;

  BoardViewCard(CardData cardData)
      : state = cardData.state,
        child = BoardViewCard.getCardWidget(cardData.content) as CardBody,
        dataKey = cardData.dataKey,
        super();

  static Widget getCardWidget(CardContent content) {
    if (content.cardType == CARD_TYPE.TEXT)
      return TextCard((content as TextCardContent).text);
    else {
      // TODO implement other kind of card
      return TextCard("unimplemented");
    }
  }

  // BoardViewCard(Widget widget) {
  //   this.child = widget;
  //   // this.type=CARD_TYPE.WIDGET;
  // }
  //
  // BoardViewCard.text(String s) {
  //   this.type = CARD_TYPE.TEXT;
  //   this.child = (Scrollbar(
  //       isAlwaysShown: false,
  //       child: SingleChildScrollView(
  //         child: SelectableText(s),
  //       )));
  // }

  @override
  _BoardViewCardState createState() => _BoardViewCardState();
}

// const double movingControllerAreaLength = 20.0;

class _BoardViewCardState extends State<BoardViewCard> {
  static const double minHeight = 128;
  static const double minWidth = 256;
  TextEditingController inputCtl = new TextEditingController();

  static Widget _getFunctionButton(IconData icon, Function() onPressed,
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
      color: Colors.grey[700],
    );
  }

  Widget _getContentCard(double height, double width, Widget child) {
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
                              color: Colors.grey.shade200,
                              width: 1,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                          //icon of card type & moving controller
                          padding: const EdgeInsets.all(4.0),
                          child: Tooltip(
                              message: widget.state.pined
                                  ? "Pinned"
                                  : "Drag to move the card",
                              child: ManipulatingBall(
                                child: Icon(
                                  Icons.text_fields_rounded,
                                  size: 26,
                                ),
                                onDrag: (dx, dy) {
                                  if (!widget.state.pined)
                                    setState(() {
                                      widget.state.top =
                                          (widget.state.top + dy) + .0;
                                      widget.state.left =
                                          (widget.state.left + dx) + .0;
                                      widget.state.top = widget.state.top > 0
                                          ? widget.state.top
                                          : 0;
                                      widget.state.left = widget.state.left > 0
                                          ? widget.state.left
                                          : 0;
                                    });
                                },
                                dragAreaLength: 48,
                              )),
                        ),
                        Expanded(
                          //title of content card
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Text",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          //button bar
                          child: Row(
                            children: [
                              ButtonBar(
                                buttonPadding: EdgeInsets.zero,
                                children: [
                                  _getFunctionButton(Icons.edit_rounded, () {
                                    TheBoardController controller =
                                    Get.find<TheBoardController>();
                                    this.inputCtl = new TextEditingController(
                                        text: controller
                                            .findItem(widget.dataKey)
                                            .content
                                            .toString());
                                    this.showEditDialog(
                                        context, widget.dataKey);
                                  }, "Edit", 22),
                                  _getFunctionButton(
                                      widget.state.locked
                                          ? Icons.copy
                                          : Icons.cut_rounded, () {
                                    final TheBoardController wbc =
                                    Get.find<TheBoardController>();
                                    final item = wbc.findItem(widget.dataKey);
                                    var value = item.content.toString();
                                    // if (value.isNotEmpty) {
                                    Clipboard.setData(
                                        ClipboardData(text: value));
                                    if (!widget.state.locked)
                                      wbc.removeItem(widget.dataKey);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Copied!'),
                                      duration: Duration(milliseconds: 300),
                                    ));
                                  }, "Copy", 20),
                                  _getFunctionButton(
                                      Icons.delete_outline_rounded, () {
                                    WidgetsBinding.instance!
                                        .addPostFrameCallback((timeStamp) {
                                      final TheBoardController wbc =
                                      Get.find<TheBoardController>();
                                      wbc.removeItem(widget.dataKey);
                                    });
                                  }, "Delete"),
                                  widget.state.locked
                                      ? _getFunctionButton(Icons.lock_rounded,
                                          () {
                                        setState(
                                              () {
                                            widget.state.locked = false;
                                            widget.state.pined = false;
                                          },
                                        );
                                      }, "Locked", 22)
                                      : _getFunctionButton(
                                      Icons.lock_open_rounded, () {
                                    setState(() {
                                      widget.state.pined = true;
                                      widget.state.locked = true;
                                    });
                                  }, "Lock", 22),
                                  widget.state.pined
                                      ? _getFunctionButton(
                                      Icons.push_pin_rounded, () {
                                    setState(() {
                                      widget.state.pined = false;
                                    });
                                  }, "UnPin", 22)
                                      : _getFunctionButton(
                                      Icons.push_pin_outlined, () {
                                    setState(() {
                                      widget.state.pined = true;
                                    });
                                  }, "Pin", 22),
                                ],
                              ),
                            ],
                          ),
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
                            child: Tooltip(
                              child: Icon(
                                Icons.signal_cellular_4_bar_rounded,
                                color: Colors.grey[100],
                              ),
                              message:
                              widget.state.locked ? "Locked" : "Drag to resize",
                            ),
                            onDrag: (dx, dy) {
                              //resize
                              // print("resize drag $dx $dy");
                              if (!widget.state.locked) {
                                num newHeight = (widget.state.height + dy);
                                num newWidth = (widget.state.width + dx);

                                setState(() {
                                  widget.state.height = newHeight > minHeight
                                      ? newHeight.toDouble()
                                      : minHeight;
                                  widget.state.width = newWidth > minWidth
                                      ? newWidth.toDouble()
                                      : minWidth;
                                });
                              }
                            },
                            dragAreaLength: 20,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(14, 8, 14, 8),
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
    // print("status: $widget.cardState._top , $widget.cardState._left");
    return Positioned(
      top: widget.state.top,
      left: widget.state.left,
      child: _getContentCard(
          widget.state.height, widget.state.width, widget.child),
    );
  }

  void showEditDialog(BuildContext ctx, Key dataKey) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Content'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("CANCEL")),
              TextButton(
                  onPressed: () {
                    TheBoardController controller =
                    Get.find<TheBoardController>();
                    var item = controller.findItem(dataKey) as CardData;
                    (item.content as TextCardContent).text=inputCtl.text;
                    controller.replaceItem(dataKey, item);
                    Navigator.of(context).pop();
                  },
                  child: Text("SAVE")),
            ],
            content: Container(
                constraints: BoxConstraints(maxWidth: 800, maxHeight: 600),
                child: AspectRatio(
                  aspectRatio: 1 / 0.618,
                  child: Column(
                    children: [
                      Expanded(
                          child: TextField(
                            controller: this.inputCtl,
                            maxLines: null,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Input multi-line content here",
                              labelText: "Content Text",
                              suffix: Icon(Icons.text_format_rounded),
                              // contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                              // border: InputBorder.none
                            ),
                            // ),
                          )),
                    ],
                  ),
                )),
          );
        });
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key? key, this.child, this.onDrag, this.dragAreaLength});

  final Widget? child;
  final Function? onDrag;
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
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag!(dx, dy);
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
