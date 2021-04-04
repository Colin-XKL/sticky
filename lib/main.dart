import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'about.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //TODO: set color
        // primarySwatch: Colors.lightGreen,
        primaryColor: Colors.white,
        primaryColorLight: Colors.teal,
        primaryColorDark: Colors.yellow,
        focusColor: Colors.lightGreen,
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<StickItem> l = [
    StickItem("Tutorial", "Follow these steps to quickly get started."),
    StickItem("#1 Paste from your pastebin",
        "Tap or click the plus button to paste something.\nIf it's empty, try to get some stuff.\n"),
    StickItem("#2 Copy from the list",
        "Tap or click the item in the list, and the content(not the title) will be copied to your pastebin\n"),
    StickItem("#3 Delete item", "slide the item remove it.\n"),
    StickItem("#4 Reorder items", "Long press the item and reorder it.\n")
  ];

  var lastDeleted = null;
  final msgEmpty = new SnackBar(
    content: Text("Empty Pastebin!"),
    duration: Duration(milliseconds: 500),
  );

  @override
  Widget build(BuildContext context) {
    // launch
    final msgCopied = new SnackBar(
      content: Text("Copied"),
      duration: Duration(milliseconds: 300),
      action: new SnackBarAction(
          label: 'Undo',
          onPressed: () {
            l.add(lastDeleted);
            // lastDeleted=null;
            setState(() {});
          }),
    );
    final msgPasted = new SnackBar(
      content: Text("Pasted"),
      duration: Duration(milliseconds: 300),
    );
    final msgDeleted = new SnackBar(
      content: Text("Deleted"),
      duration: Duration(milliseconds: 2000),
      action: new SnackBarAction(
          label: 'Undo',
          onPressed: () {
            l.add(lastDeleted);
            // lastDeleted=null;
            setState(() {});
          }),
    );

    return AreaWithKeyShortcut(
        onPasteDetected: () async {
          bool re = await _pasteFromPastebin();
          if (re) ScaffoldMessenger.of(context).showSnackBar(msgPasted);
        },
        onNewEmptyItemDetected: _newEmptyItem,
        child: Scaffold(
            appBar: new AppBar(
              foregroundColor: Colors.white,
              title: Text("Stickys"),
            ),
            drawer: Drawer(
              child: new ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(),
                  ListTile(
                    title: Text("ITEM #1"),
                    leading: Icon(Icons.title),
                  ),
                  ListTile(
                    title: Text("ITEM #2"),
                    leading: Icon(Icons.account_box_sharp),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  ListTile(
                    title: Text("Feedback"),
                    leading: IconButton(
                      icon: Icon(Icons.feedback_outlined),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                  AboutListTile(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                bool hasContent = await _pasteFromPastebin();
                if (hasContent)
                  ScaffoldMessenger.of(context).showSnackBar(msgPasted);
              },
            ),
            body: Demo()
            // ReorderableListView.builder(
            //     buildDefaultDragHandles: false,
            //     onReorder: (int oldIndex, int newIndex) {
            //       setState(() {
            //         if (oldIndex < newIndex) newIndex -= 1;
            //         var temp = l.removeAt(oldIndex);
            //         l.insert(newIndex, temp);
            //       });
            //     },
            //     itemCount: l.length,
            //     itemBuilder: (context, index) {
            //       final item = l[index];
            //       return Dismissible(
            //           key: item.key,
            //           background: listTileBackground(),
            //           onDismissed: (direction) {
            //             setState(() {
            //               lastDeleted = item;
            //               l.removeAt(index);
            //             });
            //             ScaffoldMessenger.of(context).showSnackBar(msgDeleted);
            //           },
            //           child: ReorderableDelayedDragStartListener(
            //               key: item.key,
            //               index: index,
            //               child: ListTile(
            //                 title: Text(item.title),
            //                 subtitle: Text(item.content),
            //                 contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            //                 onTap: () {
            //                   var value = item.content;
            //                   if (value.isNotEmpty) {
            //                     Clipboard.setData(ClipboardData(text: value));
            //                     lastDeleted = l[index];
            //                     l.removeAt(index);
            //                     ScaffoldMessenger.of(context)
            //                         .showSnackBar(msgCopied);
            //                     setState(() {});
            //                   } else {
            //                     ScaffoldMessenger.of(context)
            //                         .showSnackBar(msgEmpty);
            //                   }
            //                 },
            //               )));
            //     }))
            ));
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

  void _newEmptyItem() {
    l.add(StickItem("EMPTY ITEM", ""));
    ScaffoldMessenger.of(context).showSnackBar(msgEmpty);
    setState(() {});
  }

  Future<bool> _pasteFromPastebin() async {
    return Clipboard.getData(Clipboard.kTextPlain).then((value) {
      if (value != null && value.text.isNotEmpty) {
        l.add(StickItem("Text", value.text));
        Clipboard.setData(ClipboardData(text: ""));
        setState(() {});
        return true;
      } else {
        _newEmptyItem();
        return false;
      }
    });
  }
}

class View {
  //to be finished
  var itemList = <StickItem>[];
  var stickys = <ResizableWidget>[];
  int currentMode = 0; // 0 => list view  1 => stickys
  bool changeMode(int mode) {
    if (mode > 1) return false;
    currentMode = mode;
    return true;
  }
//TODO: add view change
// Widget get() {
//   if (currentMode==1){
//
//   }else if (currentMode==2){
//
//   }else{
//     return Text("Wrong mode number!");
//   }
// }
}

class StickItem {
  Key key;
  String title;
  bool isBinary;
  var content;
  String notations;

  StickItem(String title, String content) {
    this.key = UniqueKey();
    this.title = title;
    this.isBinary = false;
    this.content = content;
  }

  StickItem.binaryContent(String title, Object content, bool bin) {
    this.key = UniqueKey();
    this.title = title;
    this.isBinary = true;
    this.content = content;
  }
}

class AreaWithKeyShortcut extends StatelessWidget {
  const AreaWithKeyShortcut({
    Key key,
    @required this.child,
    @required this.onPasteDetected,
    @required this.onNewEmptyItemDetected,
  }) : super(key: key);
  final Widget child;
  final VoidCallback onPasteDetected;
  final VoidCallback onNewEmptyItemDetected;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        newEmptyItemKeySet: NewEmptyItemIntent(),
        pasteKeySet: PasteIntent(),
      },
      actions: {
        PasteIntent: CallbackAction(onInvoke: (e) => onPasteDetected?.call()),
        NewEmptyItemIntent:
            CallbackAction(onInvoke: (e) => onNewEmptyItemDetected?.call()),
      },
      child: child,
    );
  }
}

final newEmptyItemKeySet = LogicalKeySet(LogicalKeyboardKey.keyN);
final pasteKeySet = LogicalKeySet(LogicalKeyboardKey.space);

class PasteIntent extends Intent {}

class NewEmptyItemIntent extends Intent {}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
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

const ballDiameter = 20.0;

class _ResizableWidgetState extends State<ResizableWidget> {
  double height = 320;
  double width = 600;

  double top = 0;
  double left = 0;

  static const double minHeight = 128;
  static const double minWidth = 256;

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > minHeight ? newHeight : minHeight;
      width = newWidth > minWidth ? newWidth : minWidth;
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

              var newHeight = ((height + dy) ~/ GRID_FACTOR) * GRID_FACTOR;
              var newWidth = ((width + dx) ~/ GRID_FACTOR) * GRID_FACTOR;

              setState(() {
                height = newHeight > minHeight ? newHeight : minHeight;
                width = newWidth > minWidth ? newWidth : minWidth;
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
                top = (((top + dy) ~/ GRID_FACTOR) * GRID_FACTOR) as double;
                left = (((left + dx) ~/ GRID_FACTOR) * GRID_FACTOR) as double;
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

// // ----------------------
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
