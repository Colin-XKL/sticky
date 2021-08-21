import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stickys/views/the_view.dart';
import 'views/list.dart';
import 'views/whiteboard.dart';
import 'about.dart';

Future<void> main() async {
  await GetStorage.init();
  final LocalStorage listStorage = new LocalStorage('list');
  final LocalStorage boardStorage = new LocalStorage('cards');

  await listStorage.ready;
  await boardStorage.ready;

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
      title: "Mind Box",
      theme: ThemeData(
          //TODO: set color
          primarySwatch: Colors.teal,
          primaryColor: Colors.white,
          primaryColorLight: Colors.teal,
          primaryColorDark: Colors.yellow,
          focusColor: Colors.lightGreen,
          fontFamily: 'Sans'),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  final ViewManager viewManager = new ViewManager();

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
  TheView view;

  void newItemTriggeredByKey() {
    VIEW_MODE currentView = widget.viewManager.getCurrentViewType();
    if (currentView == VIEW_MODE.LIST) {
      //list
      final TheListController c = Get.find();
      c.l.add(ListItem("Empty ", ""));
    } else if (currentView == VIEW_MODE.CARDS) {
      //whiteboard
      final TheBoardController wbc = Get.find();
      wbc.l.add(
        new CardData(CARD_TYPE.TEXT, TextCardContent("empty")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("view container widget build");
    view = widget.viewManager.getView();

    return AreaWithKeyShortcut(
        onPasteDetected: () async {
          if (await pasteFromPastebin()) //has content
            ScaffoldMessenger.of(context).showSnackBar(msgPasted);
        },
        onNewEmptyItemDetected: newItemTriggeredByKey,
        child: Scaffold(
            appBar: new AppBar(
              foregroundColor: Colors.white,
              title: Text("Mind Box"),
            ),
            drawer: Drawer(
              child: new ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountEmail: null,
                    accountName: null,
                  ),
                  ListTile(
                    title: Text("List View"),
                    leading: Icon(Icons.format_list_bulleted_rounded),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {},
                    ),
                    onTap: () {
                      setState(() {
                        widget.viewManager.setCurrentViewIndex(0);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("Whiteboard"),
                    leading: Icon(Icons.dashboard_sharp),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {},
                    ),
                    onTap: () {
                      setState(() {
                        widget.viewManager.setCurrentViewIndex(1);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("Feedback"),
                    leading: IconButton(
                      icon: Icon(Icons.feedback_outlined),
                      onPressed: () {},
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
                String ret = view.newItemFromCustomInput().toString();
                if (ret.length > 0)
                  view.ctl.newItemFromString(ret);
                else if (await pasteFromPastebin()) //hasContent
                  ScaffoldMessenger.of(context).showSnackBar(msgPasted);
              },
            ),
            body: view));
  }

  Future<bool> pasteFromPastebin() async {
    final TheListController c = Get.find();
    final TheBoardController wbc = Get.find();
    return Clipboard.getData(Clipboard.kTextPlain).then((value) {
      VIEW_MODE viewType = widget.viewManager.getCurrentViewType();
      bool notEmpty =
          (value != null && value.text != null && value.text.isNotEmpty);

      if ((viewType != null)) {
        if (viewType == VIEW_MODE.LIST)
          c.newItemFromString(value.text);
        else if (viewType == VIEW_MODE.CARDS) wbc.newItemFromString(value.text);
        Clipboard.setData(ClipboardData(text: ""));
        return notEmpty;
      }
      return false;
    });
  }
}

class ViewManager {
  // 0 => list view  1 => card
  int currentViewIndex = 0;
  List<TheView> views = [new TheList(), new TheBoard()];

  TheView getView() {
    if (currentViewIndex >= 0 && currentViewIndex < views.length)
      return views[currentViewIndex];
    else
      this.views.add(new TheList());
    return this.views[0];
  }

  VIEW_MODE getCurrentViewType() {
    return getView().viewMode;
  }

  bool setCurrentViewIndex(int i) {
    if (i >= 0 && i < views.length) {
      this.currentViewIndex = i;
      return true;
    } else
      return false;
  }
}

// KEY SHORTCUT RESPONSE
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
final pasteKeySet = LogicalKeySet(LogicalKeyboardKey.paste);

class PasteIntent extends Intent {}

class NewEmptyItemIntent extends Intent {}
