import "package:flutter/material.dart";

class FreePainter extends StatefulWidget {
  @override
  _FreePainterState createState() => _FreePainterState();
}

class _FreePainterState extends State<FreePainter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Stack(
        children: [
          ResizableWidget(
            child: Text(
              '''I've just did simple prototype to show main idea.
  1. Draw size handlers with container;
  2. Use GestureDetector to get new variables of sizes
  3. Refresh the main container size.''',
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          ResizableWidget(
            child: Text("Hello Widget"),
          )
        ],
      ),
    );
  }
}

class ResizableWidget extends StatefulWidget {
  ResizableWidget({this.child});

  final Widget child;

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

const double ballDiameter = 20.0;

class _ResizableWidgetState extends State<ResizableWidget> {
  double height = 320;
  double width = 600;

  double top = 0;
  double left = 0;

  static const double minHeight = 128;
  static const double minWidth = 256;

  void onDrag(double dx, double dy) {
    double newHeight = height + dy;
    double newWidth = width + dx;

    setState(() {
      this.height = newHeight > minHeight ? newHeight : minHeight;
      this.width = newWidth > minWidth ? newWidth : minWidth;
    });
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
                  child: ListTile(
                    title: Text(
                      "Text",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    leading: Icon(Icons.text_fields),
                    dense: true,
                  ),
                ),
                // widget.child,

                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: widget.child,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    const GRID_FACTOR = 1;
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: _getContentCard(height, width, widget.child),
        ),

        // bottom right
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            child:
                Icon(Icons.adjust_rounded, color: Colors.grey.withOpacity(0.3)),
            onDrag: (dx, dy) {
              // var mid = (dx + dy) / 2;

              // num newHeight = (((height + dy) ~/ GRID_FACTOR) * GRID_FACTOR) ;
              // num newWidth = (((width + dx) ~/ GRID_FACTOR) * GRID_FACTOR);
              num newHeight = (height + dy);
              num newWidth = (width + dx);

              setState(() {
                height =
                    newHeight > minHeight ? newHeight.toDouble() : minHeight;
                width = newWidth > minWidth ? newWidth.toDouble() : minWidth;
                // top = top - mid;
                // left = left - mid;
              });
            },
          ),
        ),

        // center center -> left top => move
        Positioned(
          // top: top + height / 2 - ballDiameter / 2,
          // left: left + width / 2 - ballDiameter / 2,
          left: left,
          top: top,
          child: ManipulatingBall(
            child: Icon(
              Icons.push_pin,
              size: 14,
              color: Colors.red,
            ),
            onDrag: (dx, dy) {
              setState(() {
                top = (((top + dy) ~/ GRID_FACTOR) * GRID_FACTOR) + .0;
                left = (((left + dx) ~/ GRID_FACTOR) * GRID_FACTOR) + .0;
                top = top > 0 ? top : 0;
                left = left > 0 ? left : 0;
              });
            },
          ),
        ),
      ],
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.child, this.onDrag});

  final Widget child;
  final Function onDrag;

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
        width: ballDiameter,
        height: ballDiameter,
        child: widget.child,
      ),
    );
  }
}
