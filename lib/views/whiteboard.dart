import "package:flutter/material.dart";
import 'package:get/get.dart';

class WhiteBoardDataController extends GetxController {
  List<ResizableCard> l = [
    ResizableCard(
      child: Text('''I've just did simple prototype to show main idea.
  1. Draw size handlers with container;
  2. Use GestureDetector to get new variables of sizes
  3. Refresh the main container size.'''),
    ),
    ResizableCard(
      child: Text("Hello Widget"),
    )
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

class ResizableCard extends StatefulWidget {
  ResizableCard({this.child});

  final Key key = UniqueKey();
  Widget child;
  double top = 0;
  double left = 0;
  double height = 320;
  double width = 600;

  @override
  _ResizableCardState createState() => _ResizableCardState();
}

const double movingControllerAreaLength = 20.0;

class _ResizableCardState extends State<ResizableCard> {
  static const double minHeight = 128;
  static const double minWidth = 256;

  void onDrag(double dx, double dy) {
    double newHeight = widget.height + dy;
    double newWidth = widget.width + dx;

    setState(() {
      widget.height = newHeight > minHeight ? newHeight : minHeight;
      widget.width = newWidth > minWidth ? newWidth : minWidth;
    });
  }

  Widget _getFunctionButton(IconData icon, Function(Key key) onPressed,
      [String tooltip]) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed(this.widget.key),
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
                          padding: const EdgeInsets.all(4.0),
                          child: Tooltip(
                              message: "Drag to move the card",
                              child: ManipulatingBall(
                                child: Icon(Icons.text_fields),
                                onDrag: (dx, dy) {
                                  setState(() {
                                    widget.top = (widget.top + dy) + .0;
                                    widget.left = (widget.left + dx) + .0;
                                    widget.top =
                                        widget.top > 0 ? widget.top : 0;
                                    widget.left =
                                        widget.left > 0 ? widget.left : 0;
                                  });
                                },
                                dragAreaLength: 48,
                              )),
                        ),
                        Expanded(
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
                          child: Row(
                            children: [
                              ButtonBar(
                                buttonPadding: EdgeInsets.zero,
                                children: [
                                  _getFunctionButton(
                                      Icons.delete_outline_rounded, (k) {
                                    // setState(() {
                                    // final WhiteBoardDataController wbc =
                                    //     Get.find();
                                    // wbc.l.removeWhere(
                                    //     (element) => element.key == k);
                                    // });

                                    // setState(() {});
                                    // wbc.l.removeWhere((element) => element.key=)
                                  }, "asd"),
                                  _getFunctionButton(
                                      Icons.add_a_photo_rounded, (k) {}, "asd"),
                                  _getFunctionButton(
                                      Icons.airline_seat_recline_normal_sharp,
                                      (k) {},
                                      "asd"),
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
                          message: "Drag to resize",
                        ),
                        onDrag: (dx, dy) {
                          num newHeight = (widget.height + dy);
                          num newWidth = (widget.width + dx);

                          setState(() {
                            widget.height = newHeight > minHeight
                                ? newHeight.toDouble()
                                : minHeight;
                            widget.width = newWidth > minWidth
                                ? newWidth.toDouble()
                                : minWidth;
                          });
                        },
                        dragAreaLength: 20,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
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
      top: widget.top,
      left: widget.left,
      child: _getContentCard(widget.height, widget.width, widget.child),
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
