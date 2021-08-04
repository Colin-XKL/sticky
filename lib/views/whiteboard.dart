import "package:flutter/material.dart";
import 'package:get/get.dart';

class TheBoardController extends GetxController {
  RxList<ContentCard> l = [
    ContentCard.text('''I've just did simple prototype to show main idea.
    1. Draw size handlers with container;
    2. Use GestureDetector to get new variables of sizes
    3. Refresh the main container size.'''),
    ContentCard(
      Text("Hello Widget"),
    ),
  ].obs;

  static RxController get to => Get.find();

  bool addNewItem(String value) {
    //TODO: 兼容不同的内容类型
    bool notEmpty = (value != null && value.isNotEmpty);
    this.l.add(new ContentCard(
          Text(notEmpty ? value : ""),
        ));
    update();
    return notEmpty;
  }

  void removeItem(Key key) {
    this.l.removeWhere((element) => element.key == key);
    update();
  }
}

class TheBoard extends StatelessWidget {
  final TheBoardController wbc = Get.put(TheBoardController());

  @override
  Widget build(BuildContext context) {
    // print("board rebuild");
    return Container(
        padding: EdgeInsets.all(24),
        child: GetBuilder<TheBoardController>(
          init: TheBoardController(),
          builder: (c) => Stack(
            children: c.l,
          ),
        ));
  }
}

class CardState {
  double top = 0;
  double left = 0;
  double height = 320;
  double width = 600;
  bool locked = false;
  bool pined = false;

  CardState();
}

class ContentCard extends StatefulWidget {
  final Key key = UniqueKey();
  final Widget child;
  final CardState state = new CardState();

  ContentCard(this.child);

  ContentCard.text(String s)
      : this(Scrollbar(
            isAlwaysShown: false,
            child: SingleChildScrollView(
              child: SelectableText(s),
            )));

  @override
  _ContentCardState createState() => _ContentCardState();
}

// const double movingControllerAreaLength = 20.0;

class _ContentCardState extends State<ContentCard> {
  static const double minHeight = 128;
  static const double minWidth = 256;

  static Widget _getFunctionButton(IconData icon, Function() onPressed,
      [String tooltip]) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      splashRadius: 18,
      color: Colors.grey[700],

      // splashColor: Theme.of(context).accentColor,
      // focusColor: Theme.of(context).accentColor,
      // hoverColor: Theme.of(context).accentColor,
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
                                child: Icon(Icons.text_fields_rounded),
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
                                  _getFunctionButton(
                                      Icons.delete_outline_rounded, () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((timeStamp) {
                                      final TheBoardController wbc =
                                          Get.find<TheBoardController>();
                                      wbc.removeItem(widget.key);
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
                                        }, "Locked")
                                      : _getFunctionButton(
                                          Icons.lock_open_rounded, () {
                                          setState(() {
                                            widget.state.pined = true;
                                            widget.state.locked = true;
                                          });
                                        }, "Lock"),
                                  widget.state.pined
                                      ? _getFunctionButton(
                                          Icons.push_pin_rounded, () {
                                          setState(() {
                                            widget.state.pined = false;
                                          });
                                        }, "UnPin")
                                      : _getFunctionButton(
                                          Icons.push_pin_outlined, () {
                                          setState(() {
                                            widget.state.pined = true;
                                          });
                                        }, "Pin"),
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
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.child, this.onDrag, this.dragAreaLength});

  final Widget child;
  final Function onDrag;
  final double dragAreaLength;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX;
  double initY;

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
