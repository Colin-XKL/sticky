import "package:flutter/material.dart";
import 'package:get/get.dart';

class WhiteBoardDataController extends GetxController {
  List<ContentCard> l = [
    ContentCard.text('''I've just did simple prototype to show main idea.
    1. Draw size handlers with container;
    2. Use GestureDetector to get new variables of sizes
    3. Refresh the main container size.'''),
    ContentCard(
      Text("Hello Widget"),
    ),
  ].obs;
}

class WhiteBoard extends StatelessWidget {
  final WhiteBoardDataController wbc = Get.put(WhiteBoardDataController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Obx(() => Stack(
            children: wbc.l,
          )),
    );
  }
}

class ContentCard extends StatefulWidget {
  ContentCard(this.child);

  ContentCard.text(String s)
      : this(Scrollbar(
            isAlwaysShown: false,
            child: SingleChildScrollView(
              child: SelectableText(s),
            )));

  final Key key = UniqueKey();
  final Widget child;

  @override
  _ContentCardState createState() => _ContentCardState();
}

const double movingControllerAreaLength = 20.0;

class _ContentCardState extends State<ContentCard> {
  static const double minHeight = 128;
  static const double minWidth = 256;

  double top = 0;
  double left = 0;
  double height = 320;
  double width = 600;
  bool locked = false;
  bool pined = false;

  void onDrag(double dx, double dy) {
    double newHeight = height + dy;
    double newWidth = width + dx;

    setState(() {
      height = newHeight > minHeight ? newHeight : minHeight;
      width = newWidth > minWidth ? newWidth : minWidth;
    });
  }

  Widget _getFunctionButton(IconData icon, Function() onPressed,
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
                              message:
                                  pined ? "Pinned" : "Drag to move the card",
                              child: ManipulatingBall(
                                child: Icon(Icons.text_fields),
                                onDrag: (dx, dy) {
                                  if (!pined)
                                    setState(() {
                                      top = (top + dy) + .0;
                                      left = (left + dx) + .0;
                                      top = top > 0 ? top : 0;
                                      left = left > 0 ? left : 0;
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
                                      final WhiteBoardDataController wbc =
                                          Get.find();
                                      wbc.l.removeWhere((element) =>
                                          element.key == widget.key);
                                    });
                                  }, "Delete"),
                                  locked
                                      ? _getFunctionButton(Icons.lock_rounded,
                                          () {
                                          setState(
                                            () {
                                              locked = false;
                                              pined = false;
                                            },
                                          );
                                        }, "Locked")
                                      : _getFunctionButton(
                                          Icons.lock_open_rounded, () {
                                          setState(() {
                                            pined = true;
                                            locked = true;
                                          });
                                        }, "Lock"),
                                  pined
                                      ? _getFunctionButton(
                                          Icons.push_pin_rounded, () {
                                          setState(() {
                                            pined = false;
                                          });
                                        }, "UnPin")
                                      : _getFunctionButton(
                                          Icons.push_pin_outlined, () {
                                          setState(() {
                                            pined = true;
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
                          message: locked ? "Locked" : "Drag to resize",
                        ),
                        onDrag: (dx, dy) {
                          if (!locked) {
                            num newHeight = (height + dy);
                            num newWidth = (width + dx);

                            setState(() {
                              height = newHeight > minHeight
                                  ? newHeight.toDouble()
                                  : minHeight;
                              width = newWidth > minWidth
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
    return Positioned(
      top: top,
      left: left,
      child: _getContentCard(height, width, widget.child),
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
