import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'about.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
    StickItem("ZERO", "Hello World!"),
    StickItem("Tutorial", "Follow these steps to quickly start."),
    StickItem("#1 Paste from your pastebin",
        "Tap or click the plus button to paste something.\nIf it's empty, try to get stuff.\n"),
    StickItem("#2 Copy from the list",
        "Tap or click the item in the list, and the content(not the title) will be copied to your pastebin\n"),
    StickItem("#3 Delete item",
        "Long press the item in the list and then it'll be removed.\n")
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
          // Future future = new Future(() => null);

          bool re = await _pasteFromPastebin();
          if (re) {
            ScaffoldMessenger.of(context).showSnackBar(msgPasted);
          }
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
            body: ListView.builder(
                itemCount: l.length,
                itemBuilder: (context, index) {
                  final item = l[index];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.content),
                    onTap: () {
                      var value = item.content;

                      if (value.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: value));
                        lastDeleted = l[index];
                        l.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(msgCopied);
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(msgEmpty);
                      }
                    },
                    onLongPress: () {
                      lastDeleted = item;
                      l.removeAt(index);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(msgDeleted);
                    },
                  );
                })));
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

class StickItem {
  String title;
  bool isBinary;
  var content;
  String notations;

  StickItem(String title, String content) {
    this.title = title;
    this.isBinary = false;
    this.content = content;
  }

  StickItem.binaryContent(String title, Object content, bool bin) {
    this.title = title;
    this.isBinary = true;
    this.content = content;
  }
}

// class PasteIntent extends Intent {}
//
// class NewEmptyItemIntent extends Intent {}

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

Widget a() {
  return AreaWithKeyShortcut(
      child: Text("ASD"),
      onPasteDetected: () {},
      onNewEmptyItemDetected: () {});
}

//
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
