import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'views/list.dart';
import 'views/whiteboard.dart';
import 'about.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://246fb2d534314bf3935d50f4ef0afd0b@o850059.ingest.sentry.io/5884653';
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pinfo",
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
  ViewManager m = new ViewManager();

  @override
  State<StatefulWidget> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final msgEmpty = new SnackBar(
    content: Text("Empty Pastebin!"),
    duration: Duration(milliseconds: 500),
  );
  final msgPasted = new SnackBar(
    content: Text("Pasted"),
    duration: Duration(milliseconds: 300),
  );
  Widget view;

  void newItemTriggeredByKey() {
    int currentView = widget.m.getCurrentViewType();
    if (currentView == 0) {
      //list
      final ListDataController c = Get.find();
      c.l.add(StickItem("Empty ", ""));
    } else if (currentView == 1) {
      //whiteboard
      final WhiteBoardDataController wbc = Get.find();
      wbc.l.add(new ContentCard(
        Text(""),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    view = widget.m.getView().getWidget();

    return AreaWithKeyShortcut(
        onPasteDetected: () async {
          if (await pasteFromPastebin()) //has content
            ScaffoldMessenger.of(context).showSnackBar(msgPasted);
        },
        onNewEmptyItemDetected: newItemTriggeredByKey,
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
                    title: Text("List View"),
                    leading: Icon(Icons.title),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      setState(() {
                        widget.m.setCurrentViewIndex(0);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("Whiteboard"),
                    leading: Icon(Icons.dashboard_sharp),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      setState(() {
                        widget.m.setCurrentViewIndex(1);
                      });
                      Navigator.of(context).pop();
                    },
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
                if (await pasteFromPastebin()) //hasContent
                  ScaffoldMessenger.of(context).showSnackBar(msgPasted);
              },
            ),
            body: view));
  }

  Future<bool> pasteFromPastebin() async {
    final ListDataController c = Get.find();
    final WhiteBoardDataController wbc = Get.find();
    return Clipboard.getData(Clipboard.kTextPlain).then((value) {
      int viewType = widget.m.getCurrentViewType();
      bool notEmpty = (value != null && value.text.isNotEmpty);

      if ((viewType == 0 || viewType == 1)) {
        if (viewType == 0)
          c.l.add(notEmpty
              ? StickItem("Text", value.text)
              : StickItem("Empty ", ""));
        else if (viewType == 1)
          wbc.l.add(new ContentCard(
            Text(notEmpty ? value.text : ""),
          ));
        Clipboard.setData(ClipboardData(text: ""));
        return notEmpty;
      }
      return false;
    });
  }
}

class View {
  Key key;
  int viewMode; // 0 => list view  1 => stickys
  MyList2 l;
  WhiteBoard f;

  View(MyList2 list) {
    this.key = UniqueKey();
    this.l = list;
    this.viewMode = 0;
  }

  View.whiteboard(WhiteBoard p) {
    this.key = UniqueKey();
    this.f = p;
    this.viewMode = 1;
  }

  Widget getWidget() {
    if (viewMode == 0) {
      return l;
    } else if (viewMode == 1) {
      return f;
    } else
      return Text("Wrong view mode");
  }
}

class ViewManager {
  // 0 => list view  1 => stickys
  int currentViewIndex = 0;
  var views = [new View(new MyList2()), new View.whiteboard(new WhiteBoard())];

  View getView() {
    if (currentViewIndex < views.length)
      return views[currentViewIndex];
    else
      return new View(new MyList2());
  }

  int getCurrentViewType() {
    return getView().viewMode;
  }

  bool setCurrentViewIndex(int i) {
    if (i < views.length) {
      this.currentViewIndex = i;
      return true;
    } else
      return false;
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

// class MyList extends StatefulWidget {

//   @override
// // _MyListState createState() => _MyListState();
// }

// class _MyListState extends State<MyList> {
//   List<StickItem> l = [
//     StickItem("Tutorial", "Follow these steps to quickly get started."),
//     StickItem("#1 Paste from your pastebin",
//         "Tap or click the plus button to paste something.\nIf it's empty, try to get some stuff.\n"),
//     StickItem("#2 Copy from the list",
//         "Tap or click the item in the list, and the content(not the title) will be copied to your pastebin\n"),
//     StickItem("#3 Delete item", "slide the item remove it.\n"),
//     StickItem("#4 Reorder items", "Long press the item and reorder it.\n")
//   ];
//   var lastDeleted = null;
//
//
// }

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
